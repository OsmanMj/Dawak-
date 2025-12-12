import 'package:flutter/material.dart';

enum Frequency {
  daily,
  weekly,
  monthly,
  asNeeded,
}

class Medication {
  final String id;
  final String name;
  final String dose; // e.g., "500mg", "1 pill"
  final Frequency frequency;
  final List<TimeOfDay> scheduleTimes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imagePath;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.scheduleTimes,
    this.startDate,
    this.endDate,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'frequency': frequency.index,
      'scheduleTimes':
          scheduleTimes.map((t) => '${t.hour}:${t.minute}').toList(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dose: json['dose'],
      frequency: Frequency.values[json['frequency']],
      scheduleTimes: (json['scheduleTimes'] as List).map((t) {
        final parts = t.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      imagePath: json['imagePath'],
    );
  }
}
