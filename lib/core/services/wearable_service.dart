import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/wearable_status.dart';
import 'api_client.dart';
import 'api_exception.dart';

class WearableService extends ChangeNotifier {
  final ApiClient _apiClient;
  final _random = Random();

  WearableService(this._apiClient);

  WearableStatusModel? _status;
  WearableStatusModel? get status => _status;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Timer? _syncTimer;
  bool get isSyncing => _syncTimer != null;

 
  Future<void> fetchStatus() async {
    _setLoading(true);
    try {
      final data = await _apiClient.get('/wearable/me');
      _status = WearableStatusModel.fromJson(data as Map<String, dynamic>);
      _error = null;

      if (_status!.estado == WearableEstado.conectado) {
        _startAutoSync();
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  
  Future<bool> emparejar({required String deviceId, required String pairingCode}) async {
    _setLoading(true);
    try {
      final data = await _apiClient.post('/wearable/pair', {
        'deviceId': deviceId.trim(),
        'pairingCode': pairingCode.trim(),
      });
      _status = WearableStatusModel.fromJson(data as Map<String, dynamic>);
      _error = null;
      _startAutoSync();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> desconectar() async {
    _stopAutoSync();
    _setLoading(true);
    try {
      await _apiClient.delete('/wearable/me');
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      await fetchStatus();
      _setLoading(false);
    }
  }


  Future<void> _syncOnce() async {
    if (_status == null) return;

    final anterior = _status!.metricas;
    final nuevosPasos = anterior.steps + _random.nextInt(15);

    final metricas = WearableMetricas(
      heartRate: 68 + _random.nextInt(40),
      steps: nuevosPasos,
      calories: (nuevosPasos * 0.045).round(),
      distanceKm: double.parse((nuevosPasos * 0.0007).toStringAsFixed(2)),
      batteryPct: max(1, anterior.batteryPct - (_random.nextDouble() < 0.1 ? 1 : 0)),
    );

    try {
      final data = await _apiClient.post('/wearable/sync', {
        'heartRate': metricas.heartRate,
        'steps': metricas.steps,
        'calories': metricas.calories,
        'distanceKm': metricas.distanceKm,
        'batteryPct': metricas.batteryPct,
      });
      _status = WearableStatusModel.fromJson(data as Map<String, dynamic>);
      notifyListeners();
    } on ApiException {
      
      _stopAutoSync();
      await fetchStatus();
    }
  }

  void _startAutoSync() {
    _stopAutoSync();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) => _syncOnce());
  }

  void _stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoSync();
    super.dispose();
  }
}
