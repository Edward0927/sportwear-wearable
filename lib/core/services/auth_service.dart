import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool get isAuthenticated => _apiClient.isAuthenticated;

  Future<void> login({required String email, required String password}) async {
    final data = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    await _apiClient.setToken(data['token'] as String);
    _usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final data = await _apiClient.post('/auth/register', {
      'nombre': nombre,
      'email': email,
      'password': password,
      'telefono': telefono ?? '',
    });

    await _apiClient.setToken(data['token'] as String);
    _usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    _usuario = null;
    await _apiClient.clearToken();
    notifyListeners();
  }
}
