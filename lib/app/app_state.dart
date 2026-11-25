import '../services/push_service.dart';

import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/api_auth_service.dart';
import '../services/services.dart';

/// Estado global de la aplicación (en memoria).
class AppState extends ChangeNotifier {
  AppState({
    required this.authService,
    required this.challengeService,
    required this.validationService,
    required this.permissionService,
    required this.groupService,
    required this.rankingService,
    required this.chatService,
    required this.storeService,
  }) {
    ApiService.onUnauthorized = _handleUnauthorized;
  }

  final AuthService authService;
  final ChallengeService challengeService;
  final EvidenceValidationService validationService;
  final PermissionService permissionService;
  final GroupService groupService;
  final RankingService rankingService;
  final ChatService chatService;
  final StoreService storeService;

  UserProfile? _user;
  List<Challenge> _challenges = const [];
  bool _challengesLoading = false;
  String? _challengesError;
  bool _authBusy = false;
  String? _authError;
  bool _disposed = false;
  final Set<String> _completedIds = <String>{};
  final Map<String, Evidence> _evidenceByChallenge = <String, Evidence>{};

  // Bonche, ranking y tienda
  GroupInfo? _group;
  List<ChatMessage> _messages = const [];
  RankingBoard? _weeklyBoard;
  RankingBoard? _monthlyBoard;
  List<StoreItem> _storeItems = const [];
  bool _socialLoading = false;
  String? _socialError;
  int _sessionPoints = 0;
  int _sessionCompleted = 0;
  int _replyCounter = 0;
  int _idCounter = 0;
  final Map<String, int> _inventory = <String, int>{};

  /// Integrantes que solo aparecen en el ranking global (de otros bonches).
  final Map<String, GroupMember> _rankingMembers = <String, GroupMember>{};

  // Ciclo de evidencias, votaciones y recompensas (lo decide el servidor).
  final Map<String, ChallengeProgress> _progress =
      <String, ChallengeProgress>{};
  List<PendingEvidence> _pendingVotes = const [];
  List<RewardNotice> _rewardNotices = const [];
  List<AppNotification> _notifications = const [];
  int _unreadNotifications = 0;
  Timer? _cycleTimer;
  bool _cycleBusy = false;
  bool _deletingGroup = false;
  int _cycleTick = 0;

  /// Motivo del último fallo de compra (null si no hubo).
  String? lastPurchaseError;

  // ---------------------------------------------------------------- lectura

  bool get isSignedIn => _user != null;
  UserProfile get user => _user ?? UserProfile.empty;
  LevelInfo get levelInfo => LevelSystem.fromXp(user.xp);
  List<Challenge> get challenges => _challenges;
  bool get challengesLoading => _challengesLoading;
  String? get challengesError => _challengesError;
  bool get authBusy => _authBusy;
  String? get authError => _authError;

  GroupInfo? get group => _group;

  bool get isLeader =>
      _group != null && _user != null && _group!.leaderId == _user!.id;
  List<ChatMessage> get messages => _messages;
  List<StoreItem> get storeItems => _storeItems;
  bool get socialLoading => _socialLoading;
  String? get socialError => _socialError;
  Map<String, int> get inventory => Map<String, int>.unmodifiable(_inventory);

  /// Evidencias de compañeros que el usuario aún debe calificar.
  List<PendingEvidence> get pendingVotes => _pendingVotes;

  /// Resultados de retos cerrados que el usuario todavía no ha visto.
  List<RewardNotice> get rewardNotices => _rewardNotices;

  /// Notificaciones internas guardadas en el servidor (las más recientes).
  List<AppNotification> get notifications => _notifications;

  /// Cantidad total de notificaciones sin leer.
  int get unreadNotifications => _unreadNotifications;

  ChallengeProgress? progressOf(String boncheRetoId) => _progress[boncheRetoId];

  int ownedCount(String itemId) => _inventory[itemId] ?? 0;

  Challenge? challengeById(String id) {
    for (final challenge in _challenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  Evidence? evidenceFor(String challengeId) =>
      _evidenceByChallenge[challengeId];

  /// Estado personal de un reto en el instante [at] (por defecto, ahora).
  ChallengeStatus statusOf(Challenge challenge, [DateTime? at]) {
    final now = at ?? DateTime.now();
    final retry = _progress[challenge.id]?.canRetry ?? false;
    if (_completedIds.contains(challenge.id) && !retry) {
      return ChallengeStatus.completed;
    }
    if (_progress[challenge.id]?.closed == true) {
      return ChallengeStatus.closed;
    }
    if (now.isBefore(challenge.startsAt)) return ChallengeStatus.upcoming;
    if (!now.isBefore(challenge.endsAt)) return ChallengeStatus.expired;
    return ChallengeStatus.available;
  }

  /// Integrantes del grupo que ya enviaron su evidencia (incluye al usuario).
  int groupCompleted(Challenge challenge) {
    final progress = _progress[challenge.id];
    if (progress != null) return progress.submittedCount;
    return challenge.completedBy +
        (_completedIds.contains(challenge.id) ? 1 : 0);
  }

  /// Reto protagonista de Inicio: activo, luego completado, luego próximo.
  Challenge? focusChallenge(DateTime now) {
    if (_challenges.isEmpty) return null;
    const order = [
      ChallengeStatus.available,
      ChallengeStatus.completed,
      ChallengeStatus.upcoming,
    ];
    for (final status in order) {
      for (final challenge in _challenges) {
        if (statusOf(challenge, now) == status) return challenge;
      }
    }
    return _challenges.first;
  }

  /// Próximo reto según los horarios del bonche (hora del dispositivo).
  DateTime? nextChallengeStart(DateTime now) {
    final current = _group;
    if (current == null || !current.configured || current.schedules.isEmpty) {
      return null;
    }
    DateTime? best;
    for (final s in current.schedules) {
      var candidate = DateTime(now.year, now.month, now.day, s.hour, s.minute);
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      if (best == null || candidate.isBefore(best)) best = candidate;
    }
    return best;
  }

  List<Challenge> otherChallenges(DateTime now) {
    final focus = focusChallenge(now);
    return _challenges.where((c) => c.id != focus?.id).toList();
  }

  // --------------------------------------------------- bonche y ranking (vivo)

  /// Integrantes del grupo; el usuario aparece con su nombre, nivel y racha
  /// reales de la sesión.
  List<GroupMember> get members {
    final current = _group;
    if (current == null) return const [];
    final me = _user;
    final info = levelInfo;
    return [
      for (final member in current.members)
        if (me != null && member.id == me.id)
          member.copyWith(
            name: me.displayName,
            level: info.level,
            streak: me.streak,
          )
        else
          member,
    ];
  }

  GroupMember? memberById(String id) {
    for (final member in members) {
      if (member.id == id) return member;
    }
    return _rankingMembers[id];
  }

  RankingBoard? boardFor(RankingPeriod period) {
    return period == RankingPeriod.weekly ? _weeklyBoard : _monthlyBoard;
  }

  /// Clasificación ordenada, sumando lo que el usuario ganó en esta sesión.
  List<RankingEntry> liveEntries(RankingPeriod period) {
    final board = boardFor(period);
    if (board == null) return const [];
    final me = _user;
    final entries = <RankingEntry>[
      for (final entry in board.entries)
        if (me != null && entry.memberId == me.id)
          entry.copyWith(
            points: entry.points + _sessionPoints,
            completed: entry.completed + _sessionCompleted,
          )
        else
          entry,
    ];
    entries.sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      if (byPoints != 0) return byPoints;
      return a.memberId.compareTo(b.memberId);
    });
    return entries;
  }

  /// Serie de evolución del usuario incluyendo los puntos de esta sesión.
  List<double> liveUserSeries(RankingPeriod period) {
    final board = boardFor(period);
    if (board == null) return const [];
    final series = List<double>.from(board.userSeries);
    if (series.isNotEmpty) series[series.length - 1] += _sessionPoints;
    return series;
  }

  // ------------------------------------------------------------ autenticación

  Future<bool> signInWithGoogle() => _signIn(authService.signInWithGoogle);

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _signIn(
      () => authService.signInWithEmail(email: email, password: password),
    );
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _signIn(
      () => authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
      fallbackError: 'No pudimos crear tu cuenta. Inténtalo de nuevo.',
    );
  }

  Future<bool> _signIn(
    Future<UserProfile> Function() action, {
    String fallbackError = 'No pudimos iniciar sesión. Inténtalo de nuevo.',
  }) async {
    if (_authBusy) return false;
    _authBusy = true;
    _authError = null;
    _notify();
    try {
      _user = await action();
      _resetSession();
      await loadSocial();
      await PushService.connectAccount();
      return true;
    } catch (error) {
      _user = null;
      ApiService.clearSession();
      _authError = _messageOf(error) ?? fallbackError;
      return false;
    } finally {
      _authBusy = false;
      _notify();
    }
  }

  /// Mensaje corto y legible de un error de autenticación.
  static String? _messageOf(Object error) {
    final text = error
        .toString()
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
    if (text.isEmpty || text.length > 160) return null;
    return text;
  }

  Future<void> signOut() async {
    await PushService.disconnectAccount();
    await authService.signOut();
    _stopCycle();
    _user = null;
    _challenges = const [];
    _challengesError = null;
    _resetSession();
    _notify();
  }

  void _resetSession() {
    _completedIds.clear();
    _evidenceByChallenge.clear();
    _inventory.clear();
    _sessionPoints = 0;
    _sessionCompleted = 0;
    _replyCounter = 0;
    _messages = const [];
    _group = null;
    _weeklyBoard = null;
    _monthlyBoard = null;
    _storeItems = const [];
    _socialError = null;
    _rankingMembers.clear();
    _progress.clear();
    _pendingVotes = const [];
    _rewardNotices = const [];
    _notifications = const [];
    _unreadNotifications = 0;
  }

  // -------------------------------------------------------------------- retos

  Future<void> loadChallenges() async {
    _challengesLoading = true;
    _challengesError = null;
    _notify();
    try {
      _challenges = await challengeService.fetchTodayChallenges(
        _group?.id ?? '',
      );
    } catch (_) {
      _challengesError = 'No pudimos cargar los retos de hoy.';
    } finally {
      _challengesLoading = false;
      _notify();
    }
  }

  /// Sube la evidencia al backend.
  ///
  /// La aprobación y las recompensas las decide el servidor al cerrar la
  /// votación del bonche; aquí solo se registra que la foto fue enviada.
  Future<RewardResult> completeChallenge(
    Challenge challenge,
    Evidence evidence, {
    Uint8List? photoBytes,
  }) async {
    if (_completedIds.contains(challenge.id) &&
        !(_progress[challenge.id]?.canRetry ?? false)) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: 'Ya enviaste tu evidencia para este reto.',
      );
    }

    try {
      final data = await ApiService.uploadEvidence(
        boncheRetoId: challenge.id,
        filePath: evidence.filePath,
        photoBytes: photoBytes,
      );
      _completedIds.add(challenge.id);
      _evidenceByChallenge[challenge.id] = evidence;
      _progress.remove(challenge.id);
      _notify();
      unawaited(refreshCycle());
      return RewardResult(
        approved: true,
        pendingVote: true,
        message:
            (data['message'] as String?) ??
            'Evidencia enviada. Espera la votación de tus vales.',
        challengeTitle: challenge.title,
        streak: user.streak,
      );
    } on ApiAuthException catch (error) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: error.message,
      );
    } on ApiException catch (error) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: error.message,
      );
    }
  }

  // ------------------------------------------- ciclo: votos y recompensas

  void _startCycle() {
    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(refreshCycle()),
    );
    unawaited(refreshCycle());
  }

  void _stopCycle() {
    _cycleTimer?.cancel();
    _cycleTimer = null;
  }

  /// Sincroniza con el servidor: perfil (XP y monedas), estado de cada reto,
  /// evidencias por calificar y resultados nuevos. Todo lo calcula el backend.
  Future<void> refreshCycle() async {
    final me = _user;
    if (me == null ||
        _cycleBusy ||
        _disposed ||
        _deletingGroup ||
        _socialLoading) {
      return;
    }
    _cycleBusy = true;
    try {
      final serverGroup = await groupService.fetchGroup(me.id);

      if (_disposed || _user?.id != me.id || _deletingGroup || _socialLoading) {
        return;
      }

      if (serverGroup?.id != _group?.id) {
        _group = serverGroup;
        _challenges = const [];
        _challengesError = null;
        _completedIds.clear();
        _evidenceByChallenge.clear();
        _progress.clear();
        _pendingVotes = const [];
        _rewardNotices = const [];
        _notifications = const [];
        _unreadNotifications = 0;
        _weeklyBoard = null;
        _monthlyBoard = null;
        _rankingMembers.clear();
        _messages = const [];
        _sessionPoints = 0;
        _sessionCompleted = 0;
        _cycleTick = 0;

        await loadSocial();
        return;
      }

      _group = serverGroup;

      final profile = await ApiService.getMe();
      final groupId = _group?.id ?? '';
      final statuses = groupId.isEmpty
          ? const <ChallengeProgress>[]
          : await ApiService.getChallengeStatuses(groupId);
      final pending = await ApiService.getPendingVotes();
      final notices = await ApiService.getUnseenRewards();
      NotificationInbox? inbox;
      try {
        inbox = await ApiService.getNotifications();
      } catch (_) {
        inbox = null; // si falla, se conserva la lista anterior
      }

      final current = _user;
      if (_disposed ||
          current == null ||
          current.id != me.id ||
          _deletingGroup ||
          (_group?.id ?? '') != groupId) {
        return;
      }
      _user = current.copyWith(
        xp: profile.xp,
        coins: profile.coins,
        streak: profile.streak,
        bestStreak: profile.bestStreak,
        completedChallenges: profile.completedChallenges,
      );
      _progress.clear();
      for (final status in statuses) {
        _progress[status.boncheRetoId] = status;
        if (status.submitted) _completedIds.add(status.boncheRetoId);
      }
      final hadNotices = _rewardNotices.length;
      _pendingVotes = pending;
      _rewardNotices = notices;
      if (inbox != null) {
        _notifications = inbox.items;
        _unreadNotifications = inbox.unreadCount;
      }
      _cycleTick++;
      if (_group != null &&
          (_cycleTick % 6 == 0 || notices.length > hadNotices)) {
        unawaited(_reloadRanking());
      }
    } catch (_) {
      // Sin conexión o error momentáneo: se reintenta en el próximo ciclo.
    } finally {
      _cycleBusy = false;
      _notify();
    }
  }

  /// Emite el voto del usuario. Devuelve un mensaje de error o null si salió bien.
  Future<String?> castVote(
    PendingEvidence evidence, {
    required bool approve,
  }) async {
    try {
      await ApiService.castVote(
        evidenceId: evidence.evidenceId,
        approve: approve,
      );
    } on ApiAuthException catch (error) {
      return error.message;
    } on ApiException catch (error) {
      final code = error.statusCode;
      if (code == 400 || code == 409) {
        // Ya calificada o votación cerrada: deja de estar pendiente.
        _removePending(evidence.evidenceId);
        unawaited(refreshCycle());
      }
      return error.message;
    }
    _removePending(evidence.evidenceId);
    unawaited(refreshCycle());
    return null;
  }

  void _removePending(String evidenceId) {
    _pendingVotes = [
      for (final item in _pendingVotes)
        if (item.evidenceId != evidenceId) item,
    ];
    _notify();
  }

  /// Recarga el ranking del bonche (XP del periodo, datos del servidor).
  Future<void> _reloadRanking() async {
    final groupId = _group?.id ?? '';
    if (groupId.isEmpty) return;
    try {
      final now = DateTime.now();
      final weekly = await rankingService.fetchBoard(
        RankingPeriod.weekly,
        now,
        boncheId: groupId,
      );
      final monthly = await rankingService.fetchBoard(
        RankingPeriod.monthly,
        now,
        boncheId: groupId,
      );
      if (_deletingGroup || _group?.id != groupId) return;
      _weeklyBoard = weekly;
      _monthlyBoard = monthly;
      _notify();
    } catch (_) {
      // Se reintenta en un ciclo posterior.
    }
  }

  /// Marca una notificación como leída (al instante) y avisa al servidor.
  Future<void> markNotificationRead(AppNotification item) async {
    if (item.read) return;
    _notifications = [
      for (final n in _notifications)
        if (n.id == item.id) n.copyWith(read: true) else n,
    ];
    if (_unreadNotifications > 0) _unreadNotifications--;
    _notify();
    try {
      await ApiService.markNotificationsRead([item.id]);
    } catch (_) {
      // Si falla, volverá a aparecer como no leída en el próximo ciclo.
    }
  }

  /// Marca todas las notificaciones como leídas.
  Future<void> markAllNotificationsRead() async {
    if (_unreadNotifications == 0) return;
    _notifications = [for (final n in _notifications) n.copyWith(read: true)];
    _unreadNotifications = 0;
    _notify();
    try {
      await ApiService.markAllNotificationsRead();
    } catch (_) {
      // Si falla, volverán a aparecer como no leídas en el próximo ciclo.
    }
  }

  /// El usuario ya vio el resultado de un reto.
  Future<void> dismissReward(RewardNotice notice) async {
    _rewardNotices = [
      for (final item in _rewardNotices)
        if (item.id != notice.id) item,
    ];
    _notify();
    try {
      await ApiService.markRewardsSeen([notice.id]);
    } catch (_) {
      // Si falla, el aviso volverá a aparecer en el próximo ciclo.
    }
  }

  // ----------------------------------------------- bonche, ranking y tienda

  /// Crea un bonche real en el servidor. Devuelve un mensaje de error o null.
  Future<String?> createGroup({
    required String name,
    String description = '',
  }) async {
    final me = _user;
    if (me == null) return 'Inicia sesión primero.';
    try {
      await groupService.createGroup(
        name: name,
        description: description,
        leaderId: me.id,
      );
      await loadSocial();
      return _group == null
          ? 'No pudimos cargar tu bonche. Inténtalo de nuevo.'
          : null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Une al usuario a un bonche con su código. Devuelve un error o null.
  Future<String?> joinGroup(String inviteCode) async {
    final me = _user;
    if (me == null) return 'Inicia sesión primero.';
    try {
      await groupService.joinGroup(inviteCode: inviteCode, userId: me.id);
      await loadSocial();
      return _group == null
          ? 'No pudimos cargar tu bonche. Inténtalo de nuevo.'
          : null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Guarda nombre, cantidad, horas y duración de los retos (solo el líder).
  Future<String?> saveGroupConfig({
    required String name,
    required int challengesPerDay,
    required int windowMinutes,
    required List<String> times,
  }) async {
    final me = _user;
    final current = _group;
    if (me == null || current == null) return 'No encontramos tu bonche.';
    try {
      await groupService.updateGroup(
        groupId: current.id,
        userId: me.id,
        name: name,
        challengesPerDay: challengesPerDay,
        windowMinutes: windowMinutes,
        times: times,
        tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
      await loadSocial();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> leaveCurrentGroup(String expectedGroupId) {
    return _detachCurrentGroup(expectedGroupId, leave: true);
  }

  Future<String?> deleteCurrentGroup(String expectedGroupId) {
    return _detachCurrentGroup(expectedGroupId, leave: false);
  }

  Future<String?> _detachCurrentGroup(
    String expectedGroupId, {
    required bool leave,
  }) async {
    final current = _group;
    final me = _user;

    if (current == null || me == null || current.id != expectedGroupId) {
      return 'No encontramos tu bonche.';
    }

    if (!leave && !isLeader) {
      return 'Solo el lider puede eliminar el Bonche.';
    }

    if (_deletingGroup || _socialLoading || _challengesLoading) {
      return 'Espera un momento e intentalo nuevamente.';
    }

    _deletingGroup = true;
    _stopCycle();

    try {
      if (leave) {
        await groupService.leaveGroup(current.id);
      } else {
        await groupService.deleteGroup(current.id);
      }

      if (_disposed || _user?.id != me.id) return null;

      _group = null;
      _challenges = const [];
      _challengesError = null;
      _completedIds.clear();
      _evidenceByChallenge.clear();
      _progress.clear();
      _pendingVotes = const [];
      _rewardNotices = const [];
      _notifications = const [];
      _unreadNotifications = 0;
      _weeklyBoard = null;
      _monthlyBoard = null;
      _rankingMembers.clear();
      _messages = const [];
      _sessionPoints = 0;
      _sessionCompleted = 0;
      _socialError = null;
      _cycleTick = 0;

      await loadSocial();
      return null;
    } catch (error) {
      return _messageOf(error) ??
          (leave
              ? 'No pudimos salir del Bonche.'
              : 'No pudimos eliminar el Bonche.');
    } finally {
      _deletingGroup = false;
      if (!_disposed && _user != null) _startCycle();
      _notify();
    }
  }

  Future<void> loadSocial() async {
    _socialLoading = true;
    _socialError = null;
    _notify();
    try {
      final now = DateTime.now();
      final group = await groupService.fetchGroup(_user?.id ?? '');
      final groupId = group?.id ?? '';
      final (messages, weekly, monthly, items) = await (
        chatService.fetchMessages(),
        rankingService.fetchBoard(RankingPeriod.weekly, now, boncheId: groupId),
        rankingService.fetchBoard(
          RankingPeriod.monthly,
          now,
          boncheId: groupId,
        ),
        storeService.fetchItems(),
      ).wait;
      _group = group;
      _messages = messages;
      _weeklyBoard = weekly;
      _monthlyBoard = monthly;
      _storeItems = items;

      _rankingMembers.clear();
      for (final board in <RankingBoard?>[weekly, monthly]) {
        if (board == null) continue;
        for (final entry in board.entries) {
          if (entry.name.isEmpty) continue;
          _rankingMembers[entry.memberId] = GroupMember(
            id: entry.memberId,
            name: entry.name,
            level: LevelSystem.fromXp(entry.points).level,
            streak: 0,
          );
        }
      }

      await _loadInventory();
      await loadChallenges();
      if (_user != null) _startCycle();
    } catch (error) {
      _socialError = error is ApiAuthException ? error.message : 'No pudimos cargar tu bonche. Revisa tu conexión e inténtalo de nuevo.';
    } finally {
      _socialLoading = false;
      _notify();
    }
  }

  /// Inventario real del usuario (lo guarda el servidor).
  Future<void> _loadInventory() async {
    try {
      final entries = await ApiService.getInventory();
      _inventory.clear();
      for (final entry in entries) {
        _inventory[entry.itemId] = entry.quantity;
      }
    } catch (_) {
      // Si falla, la tienda sigue funcionando con lo que ya se conocía.
    }
  }

  /// Compra un artículo: el servidor descuenta las monedas y guarda el inventario.
  Future<PurchaseResult> purchase(StoreItem item) async {
    lastPurchaseError = null;
    final owned = ownedCount(item.id);
    if (item.oneTime && owned > 0) return PurchaseResult.alreadyOwned;
    if (user.coins < item.price) return PurchaseResult.insufficientCoins;
    try {
      final receipt = await ApiService.purchaseItem(
        itemId: item.id,
        requestId:
            'rq-${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}',
      );
      _user = user.copyWith(coins: receipt.coins);
      _inventory[item.id] = receipt.quantity;
      _notify();
      return PurchaseResult.success;
    } on ApiAuthException catch (error) {
      lastPurchaseError = error.message;
      return PurchaseResult.failed;
    } on ApiException catch (error) {
      if (error.statusCode == 402) return PurchaseResult.insufficientCoins;
      if (error.statusCode == 409 && item.oneTime) {
        return PurchaseResult.alreadyOwned;
      }
      lastPurchaseError = error.message;
      return PurchaseResult.failed;
    }
  }

  /// Envía un mensaje al chat del Bonche (simulado, sin servidor).
  void sendMessage(String text) {
    final trimmed = text.trim();
    final me = _user;
    if (trimmed.isEmpty || me == null) return;
    _messages = [
      ..._messages,
      ChatMessage(
        id: _newId(),
        authorId: me.id,
        text: trimmed,
        sentAt: DateTime.now(),
      ),
    ];
    _notify();
    unawaited(_scheduleReply(trimmed, me.id));
  }

  Future<void> _scheduleReply(String text, String myId) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (_disposed || _user?.id != myId) return;
    try {
      final reply = await chatService.replyTo(
        text: text,
        members: members,
        excludeId: myId,
        seed: _replyCounter++,
      );
      if (_disposed || _user?.id != myId) return;
      _messages = [..._messages, reply];
      _notify();
    } catch (_) {
      // Si la respuesta simulada falla, no pasa nada.
    }
  }

  String _newId() =>
      'm-${_idCounter++}-${DateTime.now().microsecondsSinceEpoch}';

  // ----------------------------------------------------------------- interno

  /// La API rechazó el token (401): la sesión deja de ser válida.
  ///
  /// Se limpia todo lo que dependía del usuario para que ninguna pantalla siga
  /// mostrando datos de una sesión muerta.
  Future<void> restoreWebSession() async {
    if (!kIsWeb || _disposed || _authBusy) return;

    final service = authService;
    if (service is! ApiAuthService) return;

    _authBusy = true;
    _authError = null;
    _notify();

    try {
      final restored = await service.restoreSession();
      if (_disposed || restored == null) return;

      _user = restored;
      _resetSession();
      await loadSocial();
      if (_user != null && _socialError != null) {
        throw ApiException(_socialError!);
      }
    } finally {
      _authBusy = false;
      _notify();
    }
  }

  void _handleUnauthorized() {
    if (_disposed) return;
    _stopCycle();
    _user = null;
    _challenges = const [];
    _challengesError = null;
    _authError = 'Tu sesión venció. Inicia sesión de nuevo.';
    _socialError = null;
    _resetSession();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopCycle();
    ApiService.onUnauthorized = null;
    super.dispose();
  }
}
