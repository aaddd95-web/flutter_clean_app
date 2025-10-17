import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final List<Schedule> _schedules = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 초기화 시 DB에서 불러오기
  Future<void> loadSchedules() async {
    _schedules.clear();
    _schedules.addAll(await _dbHelper.getAllSchedules());

    // 앱 시작 시 모든 알림 재설정
    await rescheduleAllNotifications();

    notifyListeners();
  }

  List<Schedule> get schedules => _schedules;

  // 날짜별 일정 가져오기
  List<Schedule> getSchedulesForDay(DateTime day) {
    return _schedules.where((schedule) {
      return schedule.startTime.year == day.year &&
          schedule.startTime.month == day.month &&
          schedule.startTime.day == day.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // 오늘 일정 가져오기
  List<Schedule> getTodaySchedules() {
    final now = DateTime.now();
    return getSchedulesForDay(now);
  }

  Future<void> addSchedule(Schedule schedule, {bool enableNotification = true}) async {
    _schedules.add(schedule);
    await _dbHelper.insertSchedule(schedule);

    // 알림 설정
    if (enableNotification) {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

      if (notificationsEnabled) {
        await NotificationService().scheduleNotification(
          id: schedule.id.hashCode,
          title: schedule.title,
          body: '${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')}',
          scheduledTime: schedule.startTime,
        );
      }
    }

    notifyListeners();
  }

  // 일정 삭제 + 알림 취소
  Future<void> removeSchedule(String id) async {
    _schedules.removeWhere((schedule) => schedule.id == id);
    await _dbHelper.deleteSchedule(id);

    // 알림 취소
    await NotificationService().cancelNotification(id.hashCode);

    notifyListeners();
  }

  // 일정 수정 + 알림 재설정
  Future<void> updateSchedule(Schedule updatedSchedule, {bool enableNotification = true}) async {
    final index = _schedules.indexWhere((s) => s.id == updatedSchedule.id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      await _dbHelper.updateSchedule(updatedSchedule);

      // 기존 알림 취소 후 새로 설정
      await NotificationService().cancelNotification(updatedSchedule.id.hashCode);

      if (enableNotification) {
        final prefs = await SharedPreferences.getInstance();
        final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

        if (notificationsEnabled) {
          await NotificationService().scheduleNotification(
            id: updatedSchedule.id.hashCode,
            title: updatedSchedule.title,
            body: '${updatedSchedule.startTime.hour}:${updatedSchedule.startTime.minute.toString().padLeft(2, '0')}',
            scheduledTime: updatedSchedule.startTime,
          );
        }
      }

      notifyListeners();
    }
  }

  // 앱 시작 시 지나간 알림 재설정
  Future<void> rescheduleAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (!notificationsEnabled) return;

    for (var schedule in _schedules) {
      // 미래의 일정만 알림 설정
      if (schedule.startTime.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          id: schedule.id.hashCode,
          title: schedule.title,
          body: '${schedule.startTime.hour}:${schedule.startTime.minute.toString().padLeft(2, '0')}',
          scheduledTime: schedule.startTime,
        );
      }
    }
  }

  // AI가 생성한 일정을 Schedule 객체로 변환
  Schedule createScheduleFromAI({
    required String title,
    required String dateTimeStr,
    required List<String> activities,
  }) {
    // 간단한 날짜 파싱 (내일, 오늘 등)
    DateTime startTime;
    DateTime endTime;

    if (dateTimeStr.contains('내일')) {
      startTime = DateTime.now().add(const Duration(days: 1));
      startTime = DateTime(startTime.year, startTime.month, startTime.day, 6, 0);
      endTime = startTime.add(const Duration(hours: 6));
    } else if (dateTimeStr.contains('오늘')) {
      startTime = DateTime.now();
      startTime = DateTime(startTime.year, startTime.month, startTime.day,
          startTime.hour + 1, 0);
      endTime = startTime.add(const Duration(hours: 6));
    } else {
      // 기본값
      startTime = DateTime.now().add(const Duration(hours: 1));
      endTime = startTime.add(const Duration(hours: 6));
    }

    return Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: activities.join('\n'),
      category: ScheduleCategory.personal,
      activities: activities,
    );
  }
}