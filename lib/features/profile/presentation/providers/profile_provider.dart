import 'package:flutter/foundation.dart';

import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_my_profile.dart';
import '../../domain/usecases/update_my_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final GetMyProfile getMyProfile;
  final UpdateMyProfile updateMyProfile;

  ProfileProvider({required this.getMyProfile, required this.updateMyProfile});

  Profile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await getMyProfile();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({required String displayName, required String phone}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await updateMyProfile(displayName: displayName, phone: phone);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
