import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../services/notification_service.dart';
import '../services/schedule_provider.dart';
import '../services/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _reminderAlerts = true;
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@email.com';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = _prefs.getBool('notifications_enabled') ?? true;
      _reminderAlerts = _prefs.getBool('reminder_alerts') ?? true;
      _userName = _prefs.getString('user_name') ?? 'John Doe';
      _userEmail = _prefs.getString('user_email') ?? 'john.doe@email.com';
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _pushNotifications = value);
    await _prefs.setBool('notifications_enabled', value);

    if (!value) {
      await NotificationService().cancelAllNotifications();
    } else {
      if (mounted) {
        await context.read<ScheduleProvider>().rescheduleAllNotifications();
      }
    }
  }

  Future<void> _updateUserName() async {
    final controller = TextEditingController(text: _userName);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이름 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '이름을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _userName = controller.text);
              await _prefs.setString('user_name', controller.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserEmail() async {
    final controller = TextEditingController(text: _userEmail);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이메일 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '이메일을 입력하세요',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _userEmail = controller.text);
              await _prefs.setString('user_email', controller.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                'Push Notifications',
                _pushNotifications,
                Icons.notifications_outlined,
                _toggleNotifications,
              ),
              _buildSwitchTile(
                'Email Notifications',
                _emailNotifications,
                Icons.email_outlined,
                    (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                'Reminder Alerts',
                _reminderAlerts,
                Icons.alarm,
                    (value) {
                  setState(() {
                    _reminderAlerts = value;
                  });
                  _prefs.setBool('reminder_alerts', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'AI Settings',
            [
              _buildNavigationTile(
                'AI Model',
                'Gemini 2.0 Flash',
                Icons.auto_awesome,
                    () {},
              ),
              _buildSwitchTile(
                'Smart Suggestions',
                true,
                Icons.lightbulb_outline,
                    (value) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
// _buildAppearanceSection(),  // 임시 비활성화
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              _buildNavigationTile(
                'Version',
                '1.0.0',
                Icons.info_outline,
                null,
              ),
              _buildNavigationTile(
                'Terms of Service',
                '',
                Icons.description_outlined,
                    () {},
              ),
              _buildNavigationTile(
                'Privacy Policy',
                '',
                Icons.privacy_tip_outlined,
                    () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: _updateUserName,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty
                      ? _userName.split(' ').map((e) => e[0]).join().toUpperCase()
                      : 'JD',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _updateUserEmail,
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return _buildSection(
          'Appearance',
          [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) {
                  themeProvider.toggleTheme();
                },
                activeColor: AppColors.primary,
              ),
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              'Theme Color',
              'Indigo',
              Icons.palette_outlined,
                  () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile(
      String title,
      bool value,
      IconData icon,
      Function(bool) onChanged,
      ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile(
      String title,
      String? subtitle,
      IconData icon,
      VoidCallback? onTap,
      ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null && subtitle.isNotEmpty
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: onTap != null
          ? Icon(
        Icons.chevron_right,
        color: AppColors.textLight,
      )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout functionality coming soon')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}