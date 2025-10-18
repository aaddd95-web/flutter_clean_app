import 'package:http/http.dart' as http;
import 'dart:convert';
import 'health_ai_prompts.dart';

class HealthAIService {
  static const String apiUrl = "https://api.anthropic.com/v1/messages";

  // 초기 루틴 생성
  Future<Map<String, dynamic>> generateInitialRoutine({
    required String userLevel,
    required String goal,
    required List<String> focusAreas,
    required int daysPerWeek,
    required double targetCalories,
  }) async {
    final prompt = HealthAIPrompts.getRoutineCreationPrompt(
      userLevel: userLevel,
      goal: goal,
      focusAreas: focusAreas,
      daysPerWeek: daysPerWeek,
      targetCalories: targetCalories,
    );

    return await _callClaude(
      systemPrompt: HealthAIPrompts.getSystemPrompt(userLevel),
      userPrompt: prompt,
    );
  }

  // Claude API 호출
  Future<Map<String, dynamic>> _callClaude({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "model": "claude-sonnet-4-20250514",
        "max_tokens": 4000,
        "system": systemPrompt,
        "messages": [
          {"role": "user", "content": userPrompt}
        ]
      }),
    );

    final data = jsonDecode(response.body);
    final text = data['content'][0]['text'];

    // JSON 파싱
    return jsonDecode(text);
  }
}