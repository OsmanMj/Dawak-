import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final StorageService _storageService;
  List<UserProfile> _profiles = [];
  String? _currentProfileId;

  ProfileProvider(this._storageService) {
    _loadProfiles();
  }

  List<UserProfile> get profiles => _profiles;
  String? get currentProfileId => _currentProfileId;

  UserProfile? get currentProfile {
    try {
      return _profiles.firstWhere((p) => p.id == _currentProfileId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadProfiles() async {
    _profiles = await _storageService.getProfiles();
    _currentProfileId = await _storageService.getCurrentProfileId();

    // Create default profile if none exists
    if (_profiles.isEmpty) {
      await addProfile('المستخدم الرئيسي');
    }

    if (_currentProfileId == null && _profiles.isNotEmpty) {
      _currentProfileId = _profiles.first.id;
      await _storageService.saveCurrentProfileId(_currentProfileId!);
    }

    notifyListeners();
  }

  Future<void> addProfile(String name) async {
    final newProfile = UserProfile(id: const Uuid().v4(), name: name);
    _profiles.add(newProfile);
    await _storageService.saveProfiles(_profiles);

    if (_currentProfileId == null) {
      await switchProfile(newProfile.id);
    }

    notifyListeners();
  }

  Future<void> switchProfile(String id) async {
    _currentProfileId = id;
    await _storageService.saveCurrentProfileId(id);
    notifyListeners();
  }
}
