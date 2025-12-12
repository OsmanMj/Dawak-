import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import 'add_medication_screen.dart';
import '../models/medication.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Removed StatefulWidget permissions logic as it's moved to MainScreen

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()));
                },
              ),
              if (medicationProvider.notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${medicationProvider.notifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
      body: medicationProvider.medications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication_outlined,
                        size: 80, color: Colors.teal.shade300),
                  ),
                  const SizedBox(height: 24),
                  const Text('قائمة أدويتك فارغة',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text('ابدأ بإضافة أدويتك لتنظيم مواعيدك',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddMedicationScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة دواء جديد'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicationProvider.medications.length,
              itemBuilder: (context, index) {
                final medication = medicationProvider.medications[index];
                return _buildMedicationCard(
                    context, medication, medicationProvider);
              },
            ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication medication,
      MedicationProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        AddMedicationScreen(medication: medication)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medication,
                      color: Colors.teal, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.history,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                              '${medication.dose}  •  ${_getFrequencyText(medication.frequency)}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: medication.scheduleTimes.map((time) {
                          final now = DateTime.now();
                          final isTaken =
                              provider.isDoseTaken(medication.id, time, now);

                          // Create scheduled DateTime for logging
                          final scheduledDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                // Time Display (Static, No Action)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 16,
                                          color: Colors.teal.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        time.format(context),
                                        style: TextStyle(
                                          color: Colors.teal.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Action Icon (New Icon "تم اخذ الدواء")
                                InkWell(
                                  onTap: isTaken
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'تأكيد تناول الدواء'),
                                              content: Text(
                                                  'هل أنت متأكد من أنك تناولت ${medication.name}؟'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('إلغاء'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close dialog
                                                    provider.logDose(
                                                      medication.id,
                                                      scheduledDateTime,
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'تم تسجيل الدواء بنجاح ✔️'),
                                                        duration: Duration(
                                                            seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                      'نعم، تم التناول',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isTaken
                                          ? Colors.green.shade100
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: isTaken
                                              ? Colors.green
                                              : Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          isTaken ? 'تم التناول' : 'تناول',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isTaken
                                                ? Colors.green.shade800
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          isTaken
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 18,
                                          color: isTaken
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () =>
                      _showOptionsDialog(context, provider, medication.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyText(Frequency freq) {
    switch (freq) {
      case Frequency.daily:
        return 'يومي';
      case Frequency.weekly:
        return 'أسبوعي';
      case Frequency.monthly:
        return 'شهري';
      case Frequency.asNeeded:
        return 'عند اللزوم';
    }
  }

  void _showOptionsDialog(
      BuildContext context, MedicationProvider provider, String id) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('تعديل الدواء'),
                    onTap: () {
                      Navigator.pop(context);
                      final med =
                          provider.medications.firstWhere((m) => m.id == id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddMedicationScreen(medication: med)));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('حذف الدواء'),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(context, provider, id);
                    },
                  ),
                ],
              ),
            ));
  }

  void _confirmDelete(
      BuildContext context, MedicationProvider provider, String id) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: const Text('هل أنت متأكد من حذف هذا الدواء؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    provider.deleteMedication(id);
                    Navigator.pop(context);
                  },
                  child: const Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }
}
