class Schedule {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? description;
  final ScheduleCategory category;
  final List<String>? activities;
  final int reminderMinutes;
  final bool isCompleted;

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.description,
    required this.category,
    this.activities,
    this.reminderMinutes = 15,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'description': description,
      'category': category.name,
      'activities': activities,
      'reminderMinutes': reminderMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      description: json['description'],
      category: ScheduleCategory.values.firstWhere(
            (e) => e.name == json['category'],
        orElse: () => ScheduleCategory.personal,
      ),
      activities: json['activities'] != null
          ? List<String>.from(json['activities'])
          : null,
      reminderMinutes: json['reminderMinutes'] ?? 15,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? description,
    ScheduleCategory? category,
    List<String>? activities,
    int? reminderMinutes,
    bool? isCompleted,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      category: category ?? this.category,
      activities: activities ?? this.activities,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String getTimeRange() {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

enum ScheduleCategory {
  exercise,
  meeting,
  personal,
  work,
}

extension ScheduleCategoryExtension on ScheduleCategory {
  String get label {
    switch (this) {
      case ScheduleCategory.exercise:
        return 'Exercise';
      case ScheduleCategory.meeting:
        return 'Meeting';
      case ScheduleCategory.personal:
        return 'Personal';
      case ScheduleCategory.work:
        return 'Work';
    }
  }

  int get color {
    switch (this) {
      case ScheduleCategory.exercise:
        return 0xFF10B981;
      case ScheduleCategory.meeting:
        return 0xFF8B5CF6;
      case ScheduleCategory.personal:
        return 0xFFF59E0B;
      case ScheduleCategory.work:
        return 0xFF6366F1;
    }
  }
}