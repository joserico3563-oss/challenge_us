// LA_RECOCHA_ENTREGA_FINAL
import 'package:flutter/material.dart' show IconData, Icons;

/// Insignia del catálogo. Se consigue por hitos, nunca con compras.
class BadgeInfo {
  const BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.requirement,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;

  /// Hito que hay que cumplir para desbloquearla.
  final String requirement;
  final IconData icon;

  String get assetPath => switch (id) {
    'first_challenge' => 'assets/larecocha/badges/ajaytuque.png',
    'challenges_5' => 'assets/larecocha/badges/cogiendolavaina.png',
    'challenges_25' => 'assets/larecocha/badges/bonchero.png',
    'challenges_100' => 'assets/larecocha/badges/leyenda.png',
    'streak_3' => 'assets/larecocha/badges/trescoronando.png',
    'streak_7' => 'assets/larecocha/badges/nocogesuave.png',
    'streak_30' => 'assets/larecocha/badges/elquenofalla.png',
    'second_chance' => 'assets/larecocha/badges/la2da.png',
    'fair_judge' => 'assets/larecocha/badges/elvar.png',
    'weekly_champion' => 'assets/larecocha/badges/elreydelpico.png',
    'monthly_champion' => 'assets/larecocha/badges/elquemanda.png',
    'level_5' => 'assets/larecocha/badges/cacique.png',
    _ => 'assets/larecocha/badges/ajaytuque.png',
  };
}

/// Catálogo visual de insignias.
///
/// Todavía NO existe en el servidor un registro real de insignias ganadas ni
/// la lógica de desbloqueo automático. Mientras tanto [unlockedIds] está vacío
/// y ninguna insignia se muestra como ganada.
class BadgeCatalog {
  BadgeCatalog._();

  /// Ids de insignias confirmadas como ganadas (vacío hasta que haya datos reales).
  static const Set<String> unlockedIds = <String>{};

  static bool isUnlocked(String id) => unlockedIds.contains(id);

  static const List<BadgeInfo> all = [
    BadgeInfo(
      id: 'first_challenge',
      name: 'Ajá, ¿y Tú Qué?',
      description:
          'Te estrenaste en el bonche. ¡Ahora es que empieza la recocha!',
      requirement: 'Completa tu primer reto.',
      icon: Icons.flag_rounded,
    ),
    BadgeInfo(
      id: 'challenges_5',
      name: 'Cogiendo la Vaina',
      description: 'Ya le estás cogiendo el tiro a esto de los retos.',
      requirement: 'Completa 5 retos.',
      icon: Icons.bolt_rounded,
    ),
    BadgeInfo(
      id: 'challenges_25',
      name: 'Bonchero de Oficio',
      description: 'Esto ya no es casualidad. Tú sí sabes de recocha.',
      requirement: 'Completa 25 retos.',
      icon: Icons.military_tech_rounded,
    ),
    BadgeInfo(
      id: 'challenges_100',
      name: 'Leyenda del Bonche',
      description: 'Cien retos después, tu nombre ya es historia en el bonche.',
      requirement: 'Completa 100 retos.',
      icon: Icons.workspace_premium_rounded,
    ),
    BadgeInfo(
      id: 'streak_3',
      name: '3 Días Coronando',
      description: 'Tres días seguidos dándole sin aflojar.',
      requirement: 'Alcanza una racha de 3 días.',
      icon: Icons.local_fire_department_rounded,
    ),
    BadgeInfo(
      id: 'streak_7',
      name: 'No Coge Suave',
      description: 'Una semana completa y todavía tienes energía para más.',
      requirement: 'Alcanza una racha de 7 días.',
      icon: Icons.whatshot_rounded,
    ),
    BadgeInfo(
      id: 'streak_30',
      name: 'El Que No Falla',
      description: 'Treinta días demostrando que lo tuyo es pura constancia.',
      requirement: 'Alcanza una racha de 30 días.',
      icon: Icons.calendar_month_rounded,
    ),
    BadgeInfo(
      id: 'second_chance',
      name: 'A la Segunda Va',
      description: 'La primera no salió, pero aquí nadie se rinde.',
      requirement: 'Consigue que aprueben una evidencia en tu segundo intento.',
      icon: Icons.replay_rounded,
    ),
    BadgeInfo(
      id: 'fair_judge',
      name: 'El VAR del Bonche',
      description:
          'Aquí se revisa todo. Nadie se queda esperando su veredicto.',
      requirement:
          'Califica todas las evidencias de tus compañeros en 10 retos.',
      icon: Icons.how_to_vote_rounded,
    ),
    BadgeInfo(
      id: 'weekly_champion',
      name: 'Rey del Picó',
      description: 'Esta semana nadie te quitó el primer puesto.',
      requirement: 'Termina primero en el ranking semanal de tu bonche.',
      icon: Icons.emoji_events_rounded,
    ),
    BadgeInfo(
      id: 'monthly_champion',
      name: 'El Que Manda',
      description: 'Un mes entero dominando el ranking del bonche.',
      requirement: 'Termina primero en el ranking mensual de tu bonche.',
      icon: Icons.stars_rounded,
    ),
    BadgeInfo(
      id: 'level_5',
      name: 'Cacique del Bonche',
      description: 'Llegaste a la cima. Ya eres un duro de La Recocha.',
      requirement: 'Llega al nivel 5.',
      icon: Icons.groups_rounded,
    ),
  ];
}
