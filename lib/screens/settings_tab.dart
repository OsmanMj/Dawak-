import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../providers/medication_provider.dart';
import 'onboarding_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('الإشعارات'),
            subtitle: const Text('تفعيل التنبيهات للأدوية'),
            value: true,
            onChanged: (val) {},
            activeColor: Colors.teal,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('اللغة'),
            subtitle: const Text('العربية'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('عن التطبيق'),
            subtitle: const Text('نسخة 1.0.0'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.orange),
            title: const Text('كيفية استخدام التطبيق؟'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()));
            },
          ),
        ],
      ),
    );
  }
}
