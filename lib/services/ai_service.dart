import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Google Gemini API 키
  static const String _apiKey = 'AIzaSyDDY2vwCxH4efWNzy233L9oeJ_4_MqM7GM';

  // Gemini 2.0 Flash 모델 사용 (가장 안정적인 무료 모델)
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // AI에게 일정 생성 요청
  Future<String> generateSchedule(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': _buildPrompt(userMessage),
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate schedule: $e');
    }
  }

  // 간단한 채팅 응답
  Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': message,
                }
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        return '죄송해요, 지금은 응답할 수 없어요. 나중에 다시 시도해주세요.';
      }
    } catch (e) {
      return '네트워크 오류가 발생했어요: $e';
    }
  }

  // AI에게 주는 프롬프트
  String _buildPrompt(String userMessage) {
    return '''
당신은 일정 관리 전문 AI 어시스턴트입니다.

사용자 요청: "$userMessage"

위 요청을 분석하여 상세한 일정을 만들어주세요.

응답 형식:
1. 일정 제목
2. 날짜와 시간
3. 각 활동의 시간별 상세 일정 (최소 5개 이상)
4. 각 활동마다 예상 소요 시간과 설명 포함

예시:
**생산적인 아침 루틴**
내일, 오전 6:00 - 12:00

• 6:00 AM - 명상 (15분): 하루를 시작하기 전 마음을 정리하세요
• 6:15 AM - 운동 (45분): 유산소 운동과 스트레칭으로 몸을 깨우세요
• 7:00 AM - 건강한 아침 식사 (30분): 단백질과 과일 중심의 식사
• 8:00 AM - 집중 업무 시간 (2시간): 가장 중요한 작업 먼저 처리
• 10:00 AM - 커피 브레이크 (15분): 짧은 휴식으로 재충전
• 10:15 AM - 팀 회의 (45분): 오늘의 목표와 진행 상황 공유
• 11:00 AM - 이메일 및 관리 업무 (1시간): 밀린 업무 정리

위와 같은 형식으로 자세하고 실용적인 일정을 만들어주세요.
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

      // 제목 추출 (볼드체나 첫 줄)
      if (i == 0 || line.startsWith('**')) {
        title = line.replaceAll('**', '').trim();
      }
      // 날짜/시간 추출
      else if (line.contains('오전') || line.contains('오후') ||
          line.contains('AM') || line.contains('PM') ||
          line.contains('내일') || line.contains('오늘')) {
        dateTime = line;
      }
      // 활동 추출 (• 또는 - 로 시작)
      else if (line.startsWith('•') || line.startsWith('-') ||
          line.contains('AM') || line.contains('PM')) {
        activities.add(line.replaceFirst(RegExp(r'^[•\-]\s*'), ''));
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
}