import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyDDY2vwCxH4efWNzy233L9oeJ_4_MqM7GM';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // ✅ 대화 컨텍스트 유지를 위한 메시지 히스토리
  final List<Map<String, dynamic>> _conversationHistory = [];

  // AI에게 일정 생성 요청
  Future<String> generateSchedule(String userMessage) async {
    // 사용자 메시지를 히스토리에 추가
    _conversationHistory.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            // ✅ 시스템 프롬프트 (첫 메시지)
            {
              'role': 'user',
              'parts': [{'text': _getSystemPrompt()}]
            },
            {
              'role': 'model',
              'parts': [{'text': '네, 일정 관리 전문 AI 어시스턴트입니다. 도와드리겠습니다!'}]
            },
            // ✅ 전체 대화 히스토리 포함
            ..._conversationHistory,
          ],
          'generationConfig': {
            'temperature': 0.9,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // AI 응답을 히스토리에 추가
        _conversationHistory.add({
          'role': 'model',
          'parts': [{'text': text}]
        });

        return text;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate schedule: $e');
    }
  }

  // ✅ 개선된 시스템 프롬프트
  String _getSystemPrompt() {
    return '''
당신은 친근하고 똑똑한 일정 관리 AI 어시스턴트입니다.

**역할:**
- 사용자의 요청을 정확히 이해하고 맞춤형 일정을 만들어줍니다
- 운동 루틴, 학습 계획, 하루 일정 등 모든 종류의 스케줄을 도와줍니다
- 자연스럽고 친근한 대화로 소통합니다

**응답 규칙:**
1. 사용자의 요청을 먼저 이해하고 간단히 확인합니다
2. 구체적인 일정을 다음 형식으로 작성합니다:

**[일정 제목]**
[기간 또는 날짜]

- [시간] - [활동명]: [설명]
- [시간] - [활동명]: [설명]
...

3. 최소 5개 이상의 상세한 활동을 포함합니다
4. 각 활동에 시간과 설명을 명확히 적습니다

**예시 1 - 운동 루틴:**
사용자: "다음주 일주일 운동 루틴 짜줘"

응답:
일주일 운동 루틴을 만들어드릴게요!

**한 주 운동 계획**
다음 주 월요일부터

- 월요일 - 상체 근력 운동 (60분): 벤치프레스, 덤벨 프레스, 풀업 3세트씩
- 화요일 - 유산소 운동 (40분): 조깅 또는 사이클 중강도로
- 수요일 - 하체 근력 운동 (60분): 스쿼트, 런지, 레그 프레스 3세트씩
- 목요일 - 휴식일: 가벼운 스트레칭 20분
- 금요일 - 전신 운동 (50분): 복합 운동 중심으로 버피, 플랭크 포함
- 토요일 - HIIT 운동 (30분): 고강도 인터벌 트레이닝
- 일요일 - 요가/스트레칭 (40분): 근육 회복과 유연성 향상

**예시 2 - 학습 계획:**
사용자: "내일 시험 공부 계획 짜줘"

응답:
효율적인 시험 공부 계획 만들어드릴게요!

**시험 전날 집중 학습**
내일

- 09:00 - 핵심 개념 복습 (2시간): 중요한 부분 정리하고 노트 다시 보기
- 11:00 - 휴식 (15분): 가벼운 간식과 스트레칭
- 11:15 - 문제 풀이 (2시간): 기출문제와 연습문제 풀기
- 13:15 - 점심 식사 (1시간): 충분한 휴식
- 14:15 - 약점 보완 (1.5시간): 어려운 부분 집중 학습
- 15:45 - 최종 정리 (1시간): 요약 노트 만들고 암기
- 16:45 - 휴식 및 가벼운 운동 (30분): 머리 식히기
- 20:00 - 마지막 복습 (1시간): 핵심만 빠르게 훑어보기

이제 사용자의 요청에 자연스럽게 응답하세요!
''';
  }

  // 응답을 파싱해서 구조화된 데이터로 변환
  Map<String, dynamic> parseScheduleResponse(String response) {
    final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();

    String title = '새 일정';
    String dateTime = '날짜 미정';
    List<String> activities = [];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // 제목 추출 (** 사이 또는 # 으로 시작)
      if (line.startsWith('**') && line.endsWith('**')) {
        title = line.replaceAll('**', '').trim();
      }
      else if (line.startsWith('#')) {
        title = line.replaceAll('#', '').trim();
      }
      // 날짜/시간 정보 추출
      else if (line.contains('월요일') || line.contains('화요일') ||
          line.contains('다음 주') || line.contains('내일') ||
          line.contains('오늘') || line.contains('이번 주')) {
        if (dateTime == '날짜 미정') {
          dateTime = line;
        }
      }
      // 활동 추출 (• 또는 - 또는 숫자. 로 시작)
      else if (line.startsWith('•') || line.startsWith('-') ||
          line.startsWith('*') || RegExp(r'^\d+\.').hasMatch(line)) {
        final cleanLine = line
            .replaceFirst(RegExp(r'^[•\-*]\s*'), '')
            .replaceFirst(RegExp(r'^\d+\.\s*'), '');
        if (cleanLine.isNotEmpty) {
          activities.add(cleanLine);
        }
      }
    }

    return {
      'title': title,
      'dateTime': dateTime,
      'activities': activities.isEmpty
          ? ['일정이 생성되었습니다. 자세한 내용은 위 메시지를 확인하세요.']
          : activities,
    };
  }

  // 대화 히스토리 초기화 (새 대화 시작 시)
  void clearHistory() {
    _conversationHistory.clear();
  }
}