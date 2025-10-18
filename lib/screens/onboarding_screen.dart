import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'onboarding_details_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedLevel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(  // ← 추가
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 40),

              // 상단 제목
              Text(
                '환영합니다! 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'AI가 당신만의 맞춤 건강 플랜을 만들어드립니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 60),

              // 레벨 선택 제목
              Text(
                '운동/식단 경험 수준을 선택해주세요',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),

              // 초보자 카드
              _buildLevelCard(
                context: context,
                level: 'beginner',
                title: '초보자',
                subtitle: '체계적인 운동/식단을 처음 시작해요',
                icon: Icons.local_florist,
                description: [
                  '쉬운 용어로 친절하게 설명',
                  '기초부터 차근차근 시작',
                  '실천 가능한 작은 목표 제시',
                  '격려와 동기부여 중심',
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              const SizedBox(height: 16),

              // 전문가 카드
              _buildLevelCard(
                context: context,
                level: 'expert',
                title: '전문가',
                subtitle: '경험이 있고 세밀한 관리가 필요해요',
                icon: Icons.military_tech,
                description: [
                  '구체적인 수치와 데이터 제공',
                  '과학적 근거 기반 조언',
                  '미세 조정으로 성과 극대화',
                  '주기화 프로그램 설계',
                ],
                gradient: AppColors.primaryGradient,
              ),

                  const SizedBox(height: 40),  // ← Spacer 대신 고정 높이

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedLevel == null ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingDetailsScreen(
                          userLevel: selectedLevel!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? AppColors.darkTextLight.withOpacity(0.3)
                        : AppColors.textLight.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),  // Padding 닫기
        ),    // SingleChildScrollView 닫기
    );      // Scaffold 닫기
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required String level,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> description,
    required LinearGradient gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              isDark ? AppColors.darkCardShadow : AppColors.cardShadow,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,  // ← 이 줄 추가
          children: [
            Row(
              children: [
                // 아이콘
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // 제목
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 선택 체크
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),  // 16 → 12
            const Divider(),
            const SizedBox(height: 8),   // 12 → 8

            // 설명 리스트
            ...description.map((desc) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: isDark ? AppColors.darkSuccess : AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      desc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}