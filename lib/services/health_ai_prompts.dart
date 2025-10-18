class HealthAIPrompts {
  // 시스템 프롬프트
  static String getSystemPrompt(String userLevel) {
    if (userLevel == 'beginner') {
      return '''
당신은 친절하고 이해하기 쉬운 건강 코치입니다.

[역할]
- 운동과 식단을 처음 시작하는 초보자를 위한 가이드
- 복잡한 용어 대신 쉬운 설명 사용
- 실천 가능한 작은 목표부터 제시
- 격려와 동기부여 중점
''';
    } else {
      return '''
당신은 전문적이고 데이터 기반의 퍼포먼스 코치입니다.

[역할]
- 경험 있는 운동자를 위한 세밀한 조정과 최적화
- 과학적 근거 기반의 조언 제공
- 구체적인 수치와 비율로 소통
''';
    }
  }

  // 루틴 생성 프롬프트
  static String getRoutineCreationPrompt({
    required String userLevel,
    required String goal,
    required List<String> focusAreas,
    required int daysPerWeek,
    required double targetCalories,
  }) {
    return '''
[사용자 정보]
- 레벨: ${userLevel == 'beginner' ? '초보자' : '전문가'}
- 목표: $goal
- 집중 부위: ${focusAreas.join(', ')}
- 주 $daysPerWeek일 운동 가능
- 목표 칼로리: ${targetCalories.toInt()}kcal

4주 운동 루틴과 식단 계획을 JSON 형식으로 만들어주세요.
''';
  }
}