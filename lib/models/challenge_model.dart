class ChallengeModel {
  final String id;
  final String title;
  final String objective;
  final String description;
  final String category;
  final String difficulty;
  final String evidenceType;
  final int points;
  final int xpReward;
  final int coinReward;
  final String? startsAt;
  final String? endsAt;
  final int completedBy;
  final int totalMembers;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.objective,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.evidenceType,
    required this.points,
    required this.xpReward,
    required this.coinReward,
    this.startsAt,
    this.endsAt,
    required this.completedBy,
    required this.totalMembers,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      objective: json['objective'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      evidenceType: json['evidenceType'] ?? '',
      points: json['points'] ?? 100,
      xpReward: json['xpReward'] ?? 40,
      coinReward: json['coinReward'] ?? 25,
      startsAt: json['startsAt'],
      endsAt: json['endsAt'],
      completedBy: json['completedBy'] ?? 0,
      totalMembers: json['totalMembers'] ?? 5,
    );
  }
}