import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../models/models.dart';
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
  });

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
  bool _streakCountedToday = false;
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
  List<ChatMessage> get messages => _messages;
  List<StoreItem> get storeItems => _storeItems;
  bool get socialLoading => _socialLoading;
  String? get socialError => _socialError;
  Map<String, int> get inventory => Map<String, int>.unmodifiable(_inventory);

  int ownedCount(String itemId) => _inventory[itemId] ?? 0;

  Challenge? challengeById(String id) {
    for (final challenge in _challenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  Evidence? evidenceFor(String challengeId) => _evidenceByChallenge[challengeId];

  /// Estado personal de un reto en el instante [at] (por defecto, ahora).
  ChallengeStatus statusOf(Challenge challenge, [DateTime? at]) {
    final now = at ?? DateTime.now();
    if (_completedIds.contains(challenge.id)) return ChallengeStatus.completed;
    if (now.isBefore(challenge.startsAt)) return ChallengeStatus.upcoming;
    if (!now.isBefore(challenge.endsAt)) return ChallengeStatus.expired;
    return ChallengeStatus.available;
  }

  /// Integrantes del grupo que ya completaron el reto (incluye al usuario).
  int groupCompleted(Challenge challenge) {
    return challenge.completedBy + (_completedIds.contains(challenge.id) ? 1 : 0);
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
    return null;
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

  Future<bool> _signIn(Future<UserProfile> Function() action) async {
    if (_authBusy) return false;
    _authBusy = true;
    _authError = null;
    _notify();
    try {
      _user = await action();
      _resetSession();
      await Future.wait<void>([loadChallenges(), loadSocial()]);
      return true;
    } catch (_) {
      _user = null;
      _authError = 'No pudimos iniciar sesión. Inténtalo de nuevo.';
      return false;
    } finally {
      _authBusy = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    try {
      await authService.signOut();
    } finally {
      _user = null;
      _challenges = const [];
      _challengesError = null;
      _resetSession();
      _notify();
    }
  }

  void _resetSession() {
    _completedIds.clear();
    _evidenceByChallenge.clear();
    _streakCountedToday = false;
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
  }

  // -------------------------------------------------------------------- retos

  Future<void> loadChallenges() async {
    _challengesLoading = true;
    _challengesError = null;
    _notify();
    try {
      _challenges = await challengeService.fetchTodayChallenges();
    } catch (_) {
      _challengesError = 'No pudimos cargar los retos de hoy.';
    } finally {
      _challengesLoading = false;
      _notify();
    }
  }

  /// Valida la evidencia y, si se aprueba, aplica XP, monedas y racha.
  Future<RewardResult> completeChallenge(
    Challenge challenge,
    Evidence evidence,
  ) async {
    if (_completedIds.contains(challenge.id)) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: 'Este reto ya está completado.',
      );
    }

    final validation = await validationService.validate(
      challenge: challenge,
      evidence: evidence,
    );
    if (!validation.approved) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: validation.message,
      );
    }
    // Evita doble recompensa si se confirmó dos veces mientras se validaba.
    if (_completedIds.contains(challenge.id)) {
      return RewardResult.rejected(
        challengeTitle: challenge.title,
        message: 'Este reto ya está completado.',
      );
    }

    final before = levelInfo;
    _completedIds.add(challenge.id);
    _evidenceByChallenge[challenge.id] = evidence;

    // Ventaja "Doble XP" comprada en la tienda.
    var xp = challenge.xpReward;
    var doubleXpUsed = false;
    final charges = ownedCount(StoreItem.doubleXpId);
    if (charges > 0) {
      xp *= 2;
      doubleXpUsed = true;
      if (charges - 1 <= 0) {
        _inventory.remove(StoreItem.doubleXpId);
      } else {
        _inventory[StoreItem.doubleXpId] = charges - 1;
      }
    }

    var streak = user.streak;
    var bestStreak = user.bestStreak;
    if (!_streakCountedToday) {
      streak += 1;
      _streakCountedToday = true;
      if (streak > bestStreak) bestStreak = streak;
    }

    _sessionPoints += challenge.points;
    _sessionCompleted += 1;
    _messages = [
      ..._messages,
      ChatMessage.system(
        id: _newId(),
        text: '${user.firstName} completó "${challenge.title}"',
        sentAt: DateTime.now(),
      ),
    ];

    _user = user.copyWith(
      xp: user.xp + xp,
      coins: user.coins + challenge.coinReward,
      streak: streak,
      bestStreak: bestStreak,
      completedChallenges: user.completedChallenges + 1,
    );
    final after = levelInfo;
    _notify();

    return RewardResult(
      approved: true,
      message: validation.message,
      challengeTitle: challenge.title,
      xpGained: xp,
      coinsGained: challenge.coinReward,
      streak: streak,
      leveledUp: after.level > before.level,
      level: after.level,
      levelTitle: after.title,
      doubleXpUsed: doubleXpUsed,
    );
  }

  // ----------------------------------------------- bonche, ranking y tienda

  Future<void> loadSocial() async {
    _socialLoading = true;
    _socialError = null;
    _notify();
    try {
      final now = DateTime.now();
      final (group, messages, weekly, monthly, items) = await (
        groupService.fetchGroup(),
        chatService.fetchMessages(),
        rankingService.fetchBoard(RankingPeriod.weekly, now),
        rankingService.fetchBoard(RankingPeriod.monthly, now),
        storeService.fetchItems(),
      ).wait;
      _group = group;
      _messages = messages;
      _weeklyBoard = weekly;
      _monthlyBoard = monthly;
      _storeItems = items;
    } catch (_) {
      _socialError =
          'No pudimos cargar tu bonche. Revisa tu conexión e inténtalo de nuevo.';
    } finally {
      _socialLoading = false;
      _notify();
    }
  }

  /// Compra un artículo de la tienda descontando monedas.
  PurchaseResult purchase(StoreItem item) {
    final owned = ownedCount(item.id);
    if (item.oneTime && owned > 0) return PurchaseResult.alreadyOwned;
    if (user.coins < item.price) return PurchaseResult.insufficientCoins;
    _user = user.copyWith(coins: user.coins - item.price);
    _inventory[item.id] = owned + 1;
    _notify();
    return PurchaseResult.success;
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

  String _newId() => 'm-${_idCounter++}-${DateTime.now().microsecondsSinceEpoch}';

  // ----------------------------------------------------------------- interno

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}