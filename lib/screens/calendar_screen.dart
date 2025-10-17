import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';           // ← 추가
import '../utils/colors.dart';
import '../models/schedule.dart';
import '../services/schedule_provider.dart';       // ← 추가
import '../widgets/add_schedule_dialog.dart';  // ← 추가

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Schedule>> _events = {};

  @override
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Schedule> _getEventsForDay(DateTime day) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    return provider.getSchedulesForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                color: AppColors.primary,
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddScheduleDialog(
                  selectedDate: _selectedDay ?? _focusedDay,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 8),
          _buildSelectedDayEvents(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: AppColors.error),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppColors.textSecondary),
          weekendStyle: TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Events for ${DateFormat('MMM d').format(_selectedDay ?? _focusedDay)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No events for this day',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(events[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Schedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Color(schedule.category.color),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.getTimeRange(),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (schedule.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(schedule.category.color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.category.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(schedule.category.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}