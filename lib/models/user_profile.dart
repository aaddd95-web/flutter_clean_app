class UserProfile {
  final String id;
  final String level; // 'beginner' or 'expert'
  final String goal; // 'weight_loss', 'muscle_gain', 'maintenance', 'endurance'
  final List<String> focusAreas; // ['chest', 'legs', 'cardio', 'arms', 'back', 'core']
  final int daysPerWeek;
  final double targetCalories;
  final Map<String, double> macroTargets; // protein, carbs, fats
  final Map<String, dynamic>? dietaryRestrictions; // 알레르기, 채식 등
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.level,
    required this.goal,
    required this.focusAreas,
    required this.daysPerWeek,
    required this.targetCalories,
    required this.macroTargets,
    this.dietaryRestrictions,
    required this.createdAt,
    this.updatedAt,
  });

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'goal': goal,
      'focusAreas': focusAreas,
      'daysPerWeek': daysPerWeek,
      'targetCalories': targetCalories,
      'macroTargets': macroTargets,
      'dietaryRestrictions': dietaryRestrictions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      level: json['level'],
      goal: json['goal'],
      focusAreas: List<String>.from(json['focusAreas']),
      daysPerWeek: json['daysPerWeek'],
      targetCalories: json['targetCalories'],
      macroTargets: Map<String, double>.from(json['macroTargets']),
      dietaryRestrictions: json['dietaryRestrictions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // 복사 생성자
  UserProfile copyWith({
    String? level,
    String? goal,
    List<String>? focusAreas,
    int? daysPerWeek,
    double? targetCalories,
    Map<String, double>? macroTargets,
    Map<String, dynamic>? dietaryRestrictions,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: this.id,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      focusAreas: focusAreas ?? this.focusAreas,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      targetCalories: targetCalories ?? this.targetCalories,
      macroTargets: macroTargets ?? this.macroTargets,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 레벨 한글명
  String get levelName {
    switch (level) {
      case 'beginner':
        return '초보자';
      case 'expert':
        return '전문가';
      default:
        return '알 수 없음';
    }
  }

  // 목표 한글명
  String get goalName {
    switch (goal) {
      case 'weight_loss':
        return '체중 감량';
      case 'muscle_gain':
        return '근육 증가';
      case 'maintenance':
        return '체중 유지';
      case 'endurance':
        return '지구력 향상';
      default:
        return '알 수 없음';
    }
  }
}