import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profileProvider.currentProfile?.name ?? 'مستخدم',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المستخدم الحالي',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Switch Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('التبديل بين المستخدمين',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAddProfileDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profileProvider.profiles.length,
              itemBuilder: (context, index) {
                final profile = profileProvider.profiles[index];
                final isSelected =
                    profile.id == profileProvider.currentProfileId;

                return Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected ? Colors.teal.shade50 : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? const BorderSide(color: Colors.teal, width: 2)
                          : BorderSide.none),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isSelected ? Colors.teal : Colors.grey.shade300,
                      child: Icon(Icons.person,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700),
                    ),
                    title: Text(profile.name,
                        style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.teal)
                        : null,
                    onTap: () {
                      profileProvider.switchProfile(profile.id);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ملف شخصي'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'الاسم',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<ProfileProvider>(context, listen: false)
                    .addProfile(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
