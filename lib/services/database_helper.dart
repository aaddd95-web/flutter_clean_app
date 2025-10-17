import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('schedules.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        location TEXT,
        description TEXT,
        category TEXT NOT NULL,
        activities TEXT,
        reminderMinutes INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertSchedule(Schedule schedule) async {
    final db = await database;
    await db.insert(
      'schedules',
      {
        'id': schedule.id,
        'title': schedule.title,
        'startTime': schedule.startTime.toIso8601String(),
        'endTime': schedule.endTime.toIso8601String(),
        'location': schedule.location,
        'description': schedule.description,
        'category': schedule.category.name,
        'activities': schedule.activities?.join('|||'),
        'reminderMinutes': schedule.reminderMinutes,
        'isCompleted': schedule.isCompleted ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Schedule>> getAllSchedules() async {
    final db = await database;
    final result = await db.query('schedules');

    return result.map((json) {
      return Schedule(
        id: json['id'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        location: json['location'] as String?,
        description: json['description'] as String?,
        category: ScheduleCategory.values.firstWhere(
              (e) => e.name == json['category'],
          orElse: () => ScheduleCategory.personal,
        ),
        activities: json['activities'] != null
            ? (json['activities'] as String).split('|||')
            : null,
        reminderMinutes: json['reminderMinutes'] as int,
        isCompleted: (json['isCompleted'] as int) == 1,
      );
    }).toList();
  }

  Future<void> deleteSchedule(String id) async {
    final db = await database;
    await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final db = await database;
    await db.update(
      'schedules',
      {
        'title': schedule.title,
        'startTime': schedule.startTime.toIso8601String(),
        'endTime': schedule.endTime.toIso8601String(),
        'location': schedule.location,
        'description': schedule.description,
        'category': schedule.category.name,
        'activities': schedule.activities?.join('|||'),
        'reminderMinutes': schedule.reminderMinutes,
        'isCompleted': schedule.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}