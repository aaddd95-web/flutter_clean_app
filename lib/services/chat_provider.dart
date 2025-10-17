import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? suggestedScheduleJson;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedScheduleJson,
  });

  // DB 저장용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'suggestedScheduleJson': suggestedScheduleJson,
    };
  }

  // DB 로드용
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      text: map['text'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      suggestedScheduleJson: map['suggestedScheduleJson'],
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  Database? _database;

  List<ChatMessage> get messages => _messages;

  ChatProvider() {
    _initDatabase().catchError((e) {
      print('ChatProvider 초기화 오류: $e');
    });
  }

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'chat_messages.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE chat_messages('
              'id TEXT PRIMARY KEY, '
              'text TEXT, '
              'isUser INTEGER, '
              'timestamp TEXT, '
              'suggestedScheduleJson TEXT)',
        );
      },
    );

    await _loadMessages();
  }

  // DB에서 메시지 불러오기
  Future<void> _loadMessages() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> maps =
    await _database!.query('chat_messages', orderBy: 'timestamp ASC');
    _messages.clear();
    _messages.addAll(
      List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i])),
    );
    notifyListeners();
  }

  // 메시지 추가
  Future<void> addMessage(ChatMessage message) async {
    if (_database == null) return;

    _messages.add(message);
    await _database!.insert(
      'chat_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  // 모든 메시지 삭제
  Future<void> clearMessages() async {
    if (_database == null) return;

    _messages.clear();
    await _database!.delete('chat_messages');
    notifyListeners();
  }

  // 채팅 기록 조회
  List<ChatMessage> getMessagesByDate(DateTime date) {
    return _messages.where((msg) {
      return msg.timestamp.year == date.year &&
          msg.timestamp.month == date.month &&
          msg.timestamp.day == date.day;
    }).toList();
  }
}