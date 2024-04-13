import 'package:flutter/foundation.dart';
import 'package:mobile_app/api.dart';
import 'package:mobile_app/auth.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isReady = false;
  Profile? _profile;

  bool get isLoggedIn => _isLoggedIn;
  bool get isReady => _isReady;
  Profile? get profile => _profile;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  set isReady(bool value) {
    _isReady = value;
    notifyListeners();
  }

  Future<void> initializeApp() async {
    await checkCurrentToken();
    if (_isLoggedIn) {
      await fetchProfile();
    }
    isReady = true;
  }

  Future<void> fetchProfile() async {
    _profile = await ApiClient.fetchProfile();
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    bool success = await AuthClass.login(phone, password);
    isLoggedIn = success;
    return success;
  }

  Future<bool> register(String phone, String password, String lastName, String firstName, String middleName) async {
    bool success = await AuthClass.register(phone, password, lastName, firstName, middleName);
    isLoggedIn = success;
    return success;
  }

  Future<void> logout() async {
    await AuthClass.logout();
    isLoggedIn = false;
  }

  Future<void> checkCurrentToken() async {
    isLoggedIn = await AuthClass.checkAuthentication();
  }
}
