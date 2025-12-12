import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);
    final logs = medicationProvider.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الجرعات'),
        centerTitle: true,
      ),
      body: logs.isEmpty
          ? const Center(child: Text('لا يوجد سجلات حتى الآن'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                // Determine if we need to show medication name.
                // Logs only store medicationId, so we need to look up the name.
                // If medication is deleted, we might not find it.
                // A robust app would store the name in the log or handle this gracefully.
                final log = logs[index];

                // Safe-guard if medication was deleted but we kept logs (not implemented yet, but good practice to handle nullable)

                String medName = 'دواء غير موجود';
                try {
                  medName = medicationProvider.medications
                      .firstWhere((m) => m.id == log.medicationId)
                      .name;
                } catch (e) {
                  medName = 'دواء محذوف';
                }

                return ListTile(
                  // leading: Icon(
                  //   log.isTaken ? Icons.check_circle : Icons.cancel,
                  //   color: log.isTaken ? Colors.green : Colors.red,
                  // ),
                  title: Text(medName),
                  subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(log.scheduledTime)),
                  trailing: Text(log.isTaken ? 'تم التناول' : 'فائتة/متروكة'),
                );
              },
            ),
    );
  }
}
