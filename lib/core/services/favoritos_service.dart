import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/favorito.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Trae los favoritos que el usuario agregó desde la tienda Angular
/// (`GET /api/favoritos`). Es el mismo backend que usa `WearableService`,
class FavoritosService extends ChangeNotifier {
  final ApiClient _apiClient;

  FavoritosService(this._apiClient);

  List<Favorito> _favoritos = [];
  List<Favorito> get favoritos => _favoritos;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Timer? _refreshTimer;

  Future<void> fetchFavoritos() async {
    
    if (_favoritos.isEmpty) {
      _loading = true;
      notifyListeners();
    }
    try {
      final data = await _apiClient.get('/favoritos') as List<dynamic>;
      _favoritos = data
          .map((json) => Favorito.fromJson(json as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  
  Future<bool> removeFavorito(String productId) async {
    try {
      await _apiClient.delete('/favoritos/$productId');
      _favoritos = _favoritos.where((f) => f.productId != productId).toList();
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  
  void startAutoRefresh() {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetchFavoritos());
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
