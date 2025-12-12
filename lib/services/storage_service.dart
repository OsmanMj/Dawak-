import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _medicationsKey = 'medications';
  static const String _logsKey = 'logs';
  static const String _profilesKey = 'profiles';
  static const String _currentProfileIdKey = 'current_profile_id';

  Future<void> saveMedications(
      List<Medication> medications, String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_medicationsKey}_$profileId';
    final List<String> jsonList =
        medications.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<List<Medication>> getMedications(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_medicationsKey}_$profileId';
    final List<String>? jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];
    return jsonList
        .map((json) => Medication.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveLogs(List<DoseLog> logs, String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_logsKey}_$profileId';
    final List<String> jsonList =
        logs.map((l) => jsonEncode(l.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<List<DoseLog>> getLogs(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '${_logsKey}_$profileId';
    final List<String>? jsonList = prefs.getStringList(key);
    if (jsonList == null) return [];
    return jsonList.map((json) => DoseLog.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        profiles.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_profilesKey, jsonList);
  }

  Future<List<UserProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_profilesKey);
    if (jsonList == null) return [];
    return jsonList
        .map((json) => UserProfile.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveCurrentProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentProfileIdKey, id);
  }

  Future<String?> getCurrentProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentProfileIdKey);
  }

  static const String _onboardingKey = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, seen);
  }
}
