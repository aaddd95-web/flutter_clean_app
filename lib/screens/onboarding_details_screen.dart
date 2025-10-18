import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../utils/colors.dart';
import '../models/user_profile.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class OnboardingDetailsScreen extends StatefulWidget {
  final String userLevel;

  const OnboardingDetailsScreen({
    super.key,
    required this.userLevel,
  });

  @override
  State<OnboardingDetailsScreen> createState() => _OnboardingDetailsScreenState();
}

class _OnboardingDetailsScreenState extends State<OnboardingDetailsScreen> {
  int currentStep = 0;

  // 사용자 입력값
  String? selectedGoal;
  List<String> selectedFocusAreas = [];
  int selectedDaysPerWeek = 3;
  double targetCalories = 2000;

  final List<Map<String, dynamic>> goals = [
    {
      'id': 'weight_loss',
      'title': '체중 감량',
      'icon': Icons.trending_down,
      'color': Color(0xFFEF4444),
    },
    {
      'id': 'muscle_gain',
      'title': '근육 증가',
      'icon': Icons.fitness_center,
      'color': Color(0xFF3B82F6),
    },
    {
      'id': 'maintenance',
      'title': '체중 유지',
      'icon': Icons.balance,
      'color': Color(0xFF10B981),
    },
    {
      'id': 'endurance',
      'title': '지구력 향상',
      'icon': Icons.directions_run,
      'color': Color(0xFFF59E0B),
    },
  ];

  final List<Map<String, dynamic>> focusAreas = [
    {'id': 'chest', 'title': '가슴', 'icon': Icons.self_improvement},
    {'id': 'back', 'title': '등', 'icon': Icons.accessibility_new},
    {'id': 'legs', 'title': '하체', 'icon': Icons.accessibility},
    {'id': 'arms', 'title': '팔', 'icon': Icons.front_hand},
    {'id': 'core', 'title': '코어', 'icon': Icons.circle},
    {'id': 'cardio', 'title': '유산소', 'icon': Icons.directions_run},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 진행 표시
          LinearProgressIndicator(
            value: (currentStep + 1) / 3,
            backgroundColor: isDark
                ? AppColors.darkTextLight.withOpacity(0.3)
                : AppColors.textLight.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),

          // 스텝 내용
          Expanded(
            child: IndexedStack(
              index: currentStep,
              children: [
                _buildGoalStep(context),
                _buildFocusAreasStep(context),
                _buildScheduleStep(context),
              ],
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildGoalStep(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '목표를 선택해주세요',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '가장 우선순위가 높은 목표 하나를 선택해주세요',
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = selectedGoal == goal['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGoal = goal['id'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardTheme
                          .color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? goal['color']
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: goal['color'].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        else
                          isDark ? AppColors.darkCardShadow : AppColors
                              .cardShadow,
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: goal['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            goal['icon'],
                            size: 40,
                            color: goal['color'],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          goal['title'],
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusAreasStep(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '집중하고 싶은 부위를 선택해주세요',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '여러 개 선택 가능합니다 (최소 1개)',
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: focusAreas.length,
              itemBuilder: (context, index) {
                final area = focusAreas[index];
                final isSelected = selectedFocusAreas.contains(area['id']);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedFocusAreas.remove(area['id']);
                      } else {
                        selectedFocusAreas.add(area['id']);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          .withOpacity(0.1)
                          : Theme
                          .of(context)
                          .cardTheme
                          .color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimary : AppColors
                            .primary)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        isDark ? AppColors.darkCardShadow : AppColors
                            .cardShadow,
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          area['icon'],
                          size: 36,
                          color: isSelected
                              ? (isDark ? AppColors.darkPrimary : AppColors
                              .primary)
                              : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          area['title'],
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? (isDark ? AppColors.darkPrimary : AppColors
                                .primary)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '운동 일정과 목표 칼로리',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '마지막 단계입니다!',
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors
                  .textSecondary,
            ),
          ),

          const SizedBox(height: 40),

          // 주당 운동 일수
          Text(
            '주당 운동 일수',
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final days = index + 1;
              final isSelected = selectedDaysPerWeek == days;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDaysPerWeek = days;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : Theme
                        .of(context)
                        .cardTheme
                        .color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          : (isDark ? AppColors.darkTextLight : AppColors
                          .textLight),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$days',
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          // 목표 칼로리
          Text(
            '하루 목표 칼로리',
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${targetCalories.toInt()} kcal',
            style: Theme
                .of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
          Slider(
            value: targetCalories,
            min: 1200,
            max: 3500,
            divisions: 46,
            activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            onChanged: (value) {
              setState(() {
                targetCalories = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1,200',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                ),
              ),
              Text(
                '3,500',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 정보 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkInfo : AppColors.info).withOpacity(
                  0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppColors.darkInfo : AppColors.info)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? AppColors.darkInfo : AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.userLevel == 'beginner'
                        ? 'AI가 당신의 정보를 바탕으로 쉽고 실천 가능한 플랜을 만들어드립니다.'
                        : 'AI가 과학적 데이터를 기반으로 최적화된 프로그램을 설계합니다.',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: isDark ? AppColors.darkInfo : AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    bool canProceed = false;

    if (currentStep == 0) {
      canProceed = selectedGoal != null;
    } else if (currentStep == 1) {
      canProceed = selectedFocusAreas.isNotEmpty;
    } else {
      canProceed = true;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.darkPrimary : AppColors
                      .primary,
                  side: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('이전'),
              ),
            ),

          if (currentStep > 0) const SizedBox(width: 12),

          // 다음/완료 버튼
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: canProceed ? () {
                if (currentStep < 2) {
                  setState(() {
                    currentStep++;
                  });
                } else {
                  _completeOnboarding(context);
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors
                    .primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? AppColors.darkTextLight.withOpacity(0.3)
                    : AppColors.textLight.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                currentStep < 2 ? '다음' : 'AI 플랜 생성하기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding(BuildContext context) async {
    // 매크로 영양소 자동 계산
    Map<String, double> macros = _calculateMacros(
      goal: selectedGoal!,
      calories: targetCalories,
    );

    // UserProfile 생성
    final profile = UserProfile(
      id: const Uuid().v4(),
      level: widget.userLevel,
      goal: selectedGoal!,
      focusAreas: selectedFocusAreas,
      daysPerWeek: selectedDaysPerWeek,
      targetCalories: targetCalories,
      macroTargets: macros,
      createdAt: DateTime.now(),
    );

    // TODO: SharedPreferences나 Provider에 저장

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));

// 메인 화면으로 이동 (기존 스택 제거)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
    );

    // 성공 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('프로필이 설정되었습니다! AI가 플랜을 준비하고 있어요 🎉'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Map<String, double> _calculateMacros({
    required String goal,
    required double calories,
  }) {
    double proteinRatio, carbsRatio, fatsRatio;

    switch (goal) {
      case 'weight_loss':
      // 고단백, 저탄수화물
        proteinRatio = 0.35; // 35%
        carbsRatio = 0.35; // 35%
        fatsRatio = 0.30; // 30%
        break;
      case 'muscle_gain':
      // 고탄수화물, 고단백
        proteinRatio = 0.30; // 30%
        carbsRatio = 0.45; // 45%
        fatsRatio = 0.25; // 25%
        break;
      case 'endurance':
      // 고탄수화물
        proteinRatio = 0.25; // 25%
        carbsRatio = 0.50; // 50%
        fatsRatio = 0.25; // 25%
        break;
      default: // maintenance
      // 균형잡힌 비율
        proteinRatio = 0.30; // 30%
        carbsRatio = 0.40; // 40%
        fatsRatio = 0.30; // 30%
    }

    // 칼로리를 그램으로 변환
    // 단백질: 4kcal/g, 탄수화물: 4kcal/g, 지방: 9kcal/g
    return {
      'protein': (calories * proteinRatio) / 4,
      'carbs': (calories * carbsRatio) / 4,
      'fats': (calories * fatsRatio) / 9,
    };
  }
}