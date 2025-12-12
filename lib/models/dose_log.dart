class DoseLog {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool isTaken;
  final bool isSkipped;

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
    this.isSkipped = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'isTaken': isTaken,
      'isSkipped': isSkipped,
    };
  }

  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime:
          json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
      isTaken: json['isTaken'] ?? false,
      isSkipped: json['isSkipped'] ?? false,
    );
  }
}
