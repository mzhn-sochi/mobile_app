import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app/api.dart';

class AuthClass {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> checkAuthentication() async {
    final jwtToken = await AuthClass.jwtToken;
    return jwtToken != null;
  }

  static Future<bool> login(String phone, String password) async {
    try {
      final result = await ApiClient.login(phone, password);
      await _storage.write(
          key: 'access_token', value: result['data']['accessToken']);
      await _storage.write(
          key: 'refresh_token', value: result['data']['refreshToken']);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register(String phone, String password) async {
    try {
      final result = await ApiClient.register(phone, password);
      print('Registration successful: $result');

      await _storage.write(
          key: 'access_token', value: result['data']['accessToken']);
      await _storage.write(
          key: 'refresh_token', value: result['data']['refreshToken']);

      return true;
    } catch (e) {
      print('Registration Error: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) throw Exception('Refresh token not found');
      final result = await ApiClient.refreshToken(refreshToken);
      await _storage.write(key: 'jwt_token', value: result['jwt_token']);
      return true;
    } catch (e) {
      print('Refresh Token Error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    // todo: Logout on server
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<String?> get jwtToken async {
    return await _storage.read(key: 'access_token');
  }
}
