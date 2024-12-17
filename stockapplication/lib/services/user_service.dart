import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static const String KEY_USER_DATA = 'user_data';
  static const String KEY_CREDENTIALS = 'user_credentials';
  final SharedPreferences _prefs;

  UserService(this._prefs);

  // Create a singleton instance
  static UserService? _instance;
  static Future<UserService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = UserService(prefs);
    }
    return _instance!;
  }

  // Save user credentials
  Future<void> saveCredentials(String email, String password) async {
    final credentials = {
      'email': email,
      'password': password,
    };
    await _prefs.setString(KEY_CREDENTIALS, json.encode(credentials));
  }

  // Get stored credentials
  Map<String, String>? getCredentials() {
    final credentialsString = _prefs.getString(KEY_CREDENTIALS);
    if (credentialsString != null) {
      final Map<String, dynamic> data = json.decode(credentialsString);
      return {
        'email': data['email'] as String,
        'password': data['password'] as String,
      };
    }
    return null;
  }
  // Save user data
  // Save user data
  Future<void> saveUserData(User user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLoginAt': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(KEY_USER_DATA, json.encode(userData));
  }

// Get stored user data
  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString(KEY_USER_DATA);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }


  // Clear all user data and credentials
  Future<void> clearAll() async {
    await _prefs.remove(KEY_USER_DATA);
    await _prefs.remove(KEY_CREDENTIALS);
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _prefs.containsKey(KEY_USER_DATA) && _prefs.containsKey(KEY_CREDENTIALS);
  }
}