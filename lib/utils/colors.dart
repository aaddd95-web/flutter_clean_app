import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (보라색 테마)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Purple

  // Background Colors
  static const Color background = Color(0xFFF9FAFB); // Light gray
  static const Color cardBackground = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textLight = Color(0xFF9CA3AF); // Light gray

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Category Colors (일정 태그 색상)
  static const Color exercise = Color(0xFF10B981); // Green
  static const Color meeting = Color(0xFF8B5CF6); // Purple
  static const Color personal = Color(0xFFF59E0B); // Amber
  static const Color work = Color(0xFF6366F1); // Indigo

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );

  // ============ 여기부터 다크모드 색상 추가 ============

  // Dark Mode - Primary Colors
  static const Color darkPrimary = Color(0xFF818CF8); // Lighter Indigo
  static const Color darkSecondary = Color(0xFFA78BFA); // Lighter Purple

  // Dark Mode - Background Colors
  static const Color darkBackground = Color(0xFF111827); // Very dark
  static const Color darkCardBackground = Color(0xFF1F2937); // Dark gray

  // Dark Mode - Text Colors
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Almost white
  static const Color darkTextSecondary = Color(0xFFD1D5DB); // Light gray
  static const Color darkTextLight = Color(0xFF9CA3AF); // Medium gray

  // Dark Mode - Status Colors
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkInfo = Color(0xFF60A5FA);

  // Dark Mode - Shadow
  static BoxShadow darkCardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
}