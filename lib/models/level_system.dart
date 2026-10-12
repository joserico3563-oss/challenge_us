/// Información de nivel calculada a partir del XP total.
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.title,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  final int level;
  final String title;
  final int xpIntoLevel;
  final int xpForNextLevel;

  double get progress => xpIntoLevel / xpForNextLevel;
  int get xpRemaining => xpForNextLevel - xpIntoLevel;
}

/// Sistema de niveles (distinto del sistema de insignias).
class LevelSystem {
  LevelSystem._();

  static const int xpPerLevel = 100;

  static const List<String> _titles = [
    'Recién llegado',
    'Parcero',
    'Bonchero',
    'Gran Bonchero',
    'Maestro de la Terraza',
  ];

  static LevelInfo fromXp(int xp) {
    final safeXp = xp < 0 ? 0 : xp;
    final level = safeXp ~/ xpPerLevel + 1;
    final titleIndex =
        level - 1 < _titles.length ? level - 1 : _titles.length - 1;
    return LevelInfo(
      level: level,
      title: _titles[titleIndex],
      xpIntoLevel: safeXp % xpPerLevel,
      xpForNextLevel: xpPerLevel,
    );
  }
}