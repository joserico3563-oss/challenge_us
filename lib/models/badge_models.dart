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
      name: 'Primer paso',
      description: 'Todo bonchero empieza con una primera evidencia.',
      requirement: 'Completa tu primer reto.',
      icon: Icons.flag_rounded,
    ),
    BadgeInfo(
      id: 'challenges_5',
      name: 'Calentando motores',
      description: 'Ya le cogiste el ritmo al parche.',
      requirement: 'Completa 5 retos.',
      icon: Icons.bolt_rounded,
    ),
    BadgeInfo(
      id: 'challenges_25',
      name: 'Bonchero de oficio',
      description: 'Los retos ya son parte de tu rutina.',
      requirement: 'Completa 25 retos.',
      icon: Icons.military_tech_rounded,
    ),
    BadgeInfo(
      id: 'challenges_100',
      name: 'Leyenda del bonche',
      description: 'Tu nombre ya se menciona en las reuniones.',
      requirement: 'Completa 100 retos.',
      icon: Icons.workspace_premium_rounded,
    ),
    BadgeInfo(
      id: 'streak_3',
      name: 'Tres en línea',
      description: 'Tres días seguidos sin faltar al bonche.',
      requirement: 'Alcanza una racha de 3 días.',
      icon: Icons.local_fire_department_rounded,
    ),
    BadgeInfo(
      id: 'streak_7',
      name: 'Semana de fuego',
      description: 'Una semana entera cumpliendo.',
      requirement: 'Alcanza una racha de 7 días.',
      icon: Icons.whatshot_rounded,
    ),
    BadgeInfo(
      id: 'streak_30',
      name: 'Mes imparable',
      description: 'Treinta días de constancia.',
      requirement: 'Alcanza una racha de 30 días.',
      icon: Icons.calendar_month_rounded,
    ),
    BadgeInfo(
      id: 'second_chance',
      name: 'Segunda oportunidad',
      description: 'Si no sale a la primera, se vuelve a intentar.',
      requirement: 'Consigue que aprueben una evidencia en tu segundo intento.',
      icon: Icons.replay_rounded,
    ),
    BadgeInfo(
      id: 'fair_judge',
      name: 'Juez justo',
      description: 'Calificas a tiempo y sin dejar a nadie esperando.',
      requirement: 'Califica todas las evidencias de tus compañeros en 10 retos.',
      icon: Icons.how_to_vote_rounded,
    ),
    BadgeInfo(
      id: 'weekly_champion',
      name: 'Campeón de la semana',
      description: 'El número uno del ranking semanal.',
      requirement: 'Termina primero en el ranking semanal de tu bonche.',
      icon: Icons.emoji_events_rounded,
    ),
    BadgeInfo(
      id: 'monthly_champion',
      name: 'Rey del mes',
      description: 'El número uno del ranking mensual.',
      requirement: 'Termina primero en el ranking mensual de tu bonche.',
      icon: Icons.stars_rounded,
    ),
    BadgeInfo(
      id: 'level_5',
      name: 'Maestro de la Terraza',
      description: 'El máximo título de nivel de La Recocha.',
      requirement: 'Llega al nivel 5.',
      icon: Icons.groups_rounded,
    ),
  ];
}
