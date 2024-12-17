import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final UserService _userService;
  User? _user;
  bool _initialized = false;

  User? get user => _user;
  bool get initialized => _initialized;

  AuthService() {
    _initUserService();
  }

  Future<void> _initUserService() async {
    _userService = await UserService.getInstance();
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _userService.saveUserData(user);
      }
      notifyListeners();
    });

    // Try automatic login if credentials exist
    await tryAutoLogin();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    try {
      final credentials = _userService.getCredentials();
      if (credentials != null) {
        await login(credentials['email']!, credentials['password']!);
        return true;
      }
    } catch (e) {
      print('Auto login failed: $e');
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    await _userService.saveUserData(userCredential.user!);
    await _userService.saveCredentials(email, password);
  }

  Future<void> register(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );
    await _userService.saveUserData(userCredential.user!);
    await _userService.saveCredentials(email, password);
  }

  Future<void> logout() async {
    await _userService.clearAll();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth == null) return null;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  bool isUserLoggedIn() {
    return _userService.isUserLoggedIn();
  }
}