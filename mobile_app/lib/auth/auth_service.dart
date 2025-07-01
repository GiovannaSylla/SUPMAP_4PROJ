import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService with ChangeNotifier {
  final _auth0 = Auth0(
    'dev-bm0sid7ybtowbw6r.us.auth0.com',
    'com.supmap.mobile://login-callback',
  );

  Credentials? _credentials;
  UserProfile? _user;
  String? _role;

  UserProfile? get user => _user;
  String? get role => _role;

  Future<void> login() async {
    try {
      _credentials = await _auth0.webAuthentication().login(
        audience: 'https://supmap/api',
        scope: 'openid profile email',
      );
      _user = _credentials?.user;
      await loadUserMetadata();
      notifyListeners();
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth0.webAuthentication().logout();
      _credentials = null;
      _user = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> loadUserMetadata() async {
    if (_credentials == null) return;

    final idToken = _credentials!.idToken;
    final decoded = parseJwt(idToken);
    _role = decoded['https://supmap/roles']?.first ?? 'utilisateur';
    notifyListeners();
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT');

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return json.decode(decoded);
  }
}