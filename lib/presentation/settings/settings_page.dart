import 'package:flutter/material.dart';
import '../../widgets/flutterflow/modern_3d_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _dataRefreshInterval = 'Every 5 minutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Modern3DCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive email updates and alerts'),
                    value: _emailNotifications,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications'),
                    value: _pushNotifications,
                    onChanged: (value) => setState(() => _pushNotifications = value),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark theme'),
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Modern3DCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Data Refresh Interval'),
                    subtitle: Text(_dataRefreshInterval),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => setState(() => _dataRefreshInterval = value),
                      itemBuilder: (context) => [
                        'Real-time',
                        'Every minute',
                        'Every 5 minutes',
                        'Every 15 minutes',
                        'Every hour',
                      ].map((interval) => PopupMenuItem(
                        value: interval,
                        child: Text(interval),
                      )).toList(),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Export Data'),
                    subtitle: const Text('Download dashboard data'),
                    trailing: const Icon(Icons.download),
                    onTap: () {
                      // TODO: Implement data export
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Reset stored data'),
                    trailing: const Icon(Icons.cleaning_services),
                    onTap: () {
                      // TODO: Implement cache clearing
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Modern3DCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement password change
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Two-Factor Authentication'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Implement 2FA
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Delete Account'),
                    trailing: const Icon(Icons.delete_forever),
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      // TODO: Implement account deletion
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}