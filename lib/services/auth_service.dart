import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  final DatabaseService _db = DatabaseService.instance;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('logged_user_id');
    if (userId != null) {
      _currentUser = await _db.getUserById(userId);
      notifyListeners();
    }
  }

  Future<({bool success, String message})> register(String username, String password) async {
    if (username.trim().isEmpty) {
      return (success: false, message: 'Le nom d\'utilisateur est requis');
    }
    if (password.length < 4) {
      return (success: false, message: 'Le mot de passe doit faire au moins 4 caractères');
    }

    final existing = await _db.getUserByUsername(username);
    if (existing != null) {
      return (success: false, message: 'Ce nom d\'utilisateur existe déjà');
    }

    final user = User(
      username: username,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    final id = await _db.createUser(user);
    _currentUser = User(
      id: id,
      username: user.username,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('logged_user_id', id);

    notifyListeners();
    return (success: true, message: 'Compte créé avec succès');
  }

  Future<({bool success, String message})> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);
    if (user == null) {
      return (success: false, message: 'Utilisateur non trouvé');
    }

    if (user.passwordHash != _hashPassword(password)) {
      return (success: false, message: 'Mot de passe incorrect');
    }

    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('logged_user_id', user.id!);

    notifyListeners();
    return (success: true, message: 'Connexion réussie');
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user_id');
    notifyListeners();
  }
}
