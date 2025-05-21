import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nairobivacanthouses/homepage/homepage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = Get.isDarkMode;
  bool _notificationsEnabled = true;
  double _textSize = 16.0;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Swahili'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Language'),
            _buildDropdownSetting(),
            const SizedBox(height: 24),
            _buildSectionTitle('Appearance'),
            _buildDarkModeToggle(),
            const SizedBox(height: 24),
            _buildSectionTitle('Notifications'),
            _buildNotificationToggle(),
            const SizedBox(height: 24),
            _buildSectionTitle('Text Size'),
            _buildTextSizeSlider(),
            const SizedBox(height: 24),
            _buildSectionTitle('Account Settings'),
            _buildAccountSettings(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87,
      ),
    );
  }

  Widget _buildDropdownSetting() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade600
              : Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        isExpanded: true,
        underline: const SizedBox(),
        items: _languages.map((String language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(
              language,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Language set to $newValue')),
            );
          }
        },
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
        ),
        Switch(
          value: _isDarkMode,
          activeColor: Colors.orange.shade700,
          onChanged: (bool value) {
            setState(() {
              _isDarkMode = value;
            });
            Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(value ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Enable Notifications',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          activeColor: Colors.orange.shade700,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value ? 'Notifications Enabled' : 'Notifications Disabled',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextSizeSlider() {
    return Column(
      children: [
        Slider(
          value: _textSize,
          min: 12.0,
          max: 24.0,
          divisions: 6,
          label: '${_textSize.round()} px',
          activeColor: Colors.orange.shade700,
          onChanged: (double newValue) {
            setState(() {
              _textSize = newValue;
            });
          },
        ),
        Text(
          'Text Size: ${_textSize.round()} px',
          style: TextStyle(
            fontSize: _textSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.account_circle, color: Colors.orange.shade700),
          title: Text('Edit Profile'),
          onTap: () {
            // Navigate to profile edit page
          },
        ),
        ListTile(
          leading: Icon(Icons.lock, color: Colors.orange.shade700),
          title: Text('Change Password'),
          onTap: () {
            // Navigate to change password page
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          onPressed: () => Get.off(() => const HomeScreen())),
    );
  }
}
