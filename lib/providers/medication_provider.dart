import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class MedicationProvider with ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  List<Medication> _medications = [];
  List<DoseLog> _logs = [];
  String _currentProfileId = '';

  MedicationProvider(this._storageService, this._notificationService);

  NotificationService get notificationService => _notificationService;

  List<Medication> get medications => _medications;
  List<DoseLog> get logs => _logs;

  void updateProfile(String profileId) {
    if (_currentProfileId != profileId) {
      _currentProfileId = profileId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_currentProfileId.isEmpty) return;
    _medications = await _storageService.getMedications(_currentProfileId);
    _logs = await _storageService.getLogs(_currentProfileId);
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await _storageService.saveMedications(_medications, _currentProfileId);
    await _notificationService.scheduleMedicationReminders(medication);
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      // Cancel old notifications
      await _notificationService.cancelNotifications(_medications[index]);

      _medications[index] = medication;
      await _storageService.saveMedications(_medications, _currentProfileId);

      // Schedule new notifications
      await _notificationService.scheduleMedicationReminders(medication);
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    final medication = _medications.firstWhere((m) => m.id == id);
    await _notificationService.cancelNotifications(medication);

    _medications.removeWhere((m) => m.id == id);
    await _storageService.saveMedications(_medications, _currentProfileId);
    notifyListeners();
  }

  Future<void> logDose(String medicationId, DateTime scheduledTime,
      {bool isTaken = true, bool isSkipped = false}) async {
    final log = DoseLog(
      id: const Uuid().v4(),
      medicationId: medicationId,
      scheduledTime: scheduledTime,
      takenTime: DateTime.now(),
      isTaken: isTaken,
      isSkipped: isSkipped,
    );
    _logs.add(log);
    await _storageService.saveLogs(_logs, _currentProfileId);
    notifyListeners();
  }

  // Helper to get logs for a specific day
  List<DoseLog> getLogsForDate(DateTime date) {
    return _logs.where((log) {
      return log.scheduledTime.year == date.year &&
          log.scheduledTime.month == date.month &&
          log.scheduledTime.day == date.day;
    }).toList();
  }

  // Get list of missed/due medications for today
  List<Map<String, dynamic>> get notifications {
    final now = DateTime.now();
    List<Map<String, dynamic>> alerts = [];

    for (var med in _medications) {
      // Check today's schedule
      // (Simplified logic: assumes daily/recurring. Ideally should check Frequency)
      // For MVP we check if freq is daily or if today matches frequency

      // We will look for schedules that passed today
      for (var time in med.scheduleTimes) {
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (scheduledDateTime.isBefore(now)) {
          // Check if logged
          final isDone = _logs.any((log) =>
              log.medicationId == med.id &&
              log.scheduledTime.year == scheduledDateTime.year &&
              log.scheduledTime.month == scheduledDateTime.month &&
              log.scheduledTime.day == scheduledDateTime.day &&
              log.scheduledTime.hour == scheduledDateTime.hour &&
              log.scheduledTime.minute == scheduledDateTime.minute);

          if (!isDone) {
            alerts.add({
              'title': 'حان وقت الدواء',
              'body': 'لم تقم بتسجيل تناول ${med.name} (${med.dose})',
              'time': scheduledDateTime,
              'medication': med,
            });
          }
        }
      }
    }
    // Sort by time (newest first)
    alerts.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return alerts;
  }

  bool isDoseTaken(String medId, TimeOfDay scheduledTime, DateTime date) {
    return _logs.any((log) =>
        log.medicationId == medId &&
        log.scheduledTime.year == date.year &&
        log.scheduledTime.month == date.month &&
        log.scheduledTime.day == date.day &&
        log.scheduledTime.hour == scheduledTime.hour &&
        log.scheduledTime.minute == scheduledTime.minute &&
        log.isTaken);
  }
}
