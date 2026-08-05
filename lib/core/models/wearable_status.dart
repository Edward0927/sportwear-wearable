/// Mismos 4 estados que maneja la web Angular (`WearableStatus`).
enum WearableEstado { desconectado, buscando, emparejando, conectado }

WearableEstado wearableEstadoFromString(String value) {
  switch (value) {
    case 'buscando':
      return WearableEstado.buscando;
    case 'emparejando':
      return WearableEstado.emparejando;
    case 'conectado':
      return WearableEstado.conectado;
    case 'desconectado':
    default:
      return WearableEstado.desconectado;
  }
}

class WearableMetricas {
  final int heartRate;
  final int steps;
  final int calories;
  final int batteryPct;
  final double distanceKm;

  WearableMetricas({
    required this.heartRate,
    required this.steps,
    required this.calories,
    required this.batteryPct,
    required this.distanceKm,
  });

  factory WearableMetricas.fromJson(Map<String, dynamic> json) {
    return WearableMetricas(
      heartRate: (json['heartRate'] as num).toInt(),
      steps: (json['steps'] as num).toInt(),
      calories: (json['calories'] as num).toInt(),
      batteryPct: (json['batteryPct'] as num).toInt(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );
  }

  factory WearableMetricas.vacias() => WearableMetricas(
        heartRate: 0,
        steps: 0,
        calories: 0,
        batteryPct: 100,
        distanceKm: 0,
      );
}

class WearablePairing {
  final String deviceId;
  final String deviceName;
  final String pairingCode;
  final String firmware;
  final String generatedAt;

  WearablePairing({
    required this.deviceId,
    required this.deviceName,
    required this.pairingCode,
    required this.firmware,
    required this.generatedAt,
  });

  factory WearablePairing.fromJson(Map<String, dynamic> json) {
    return WearablePairing(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      pairingCode: json['pairingCode'] as String,
      firmware: json['firmware'] as String,
      generatedAt: json['generatedAt'] as String,
    );
  }
}

class WearableStatusModel {
  final WearableEstado estado;
  final WearableMetricas metricas;
  final WearablePairing pairing;

  WearableStatusModel({
    required this.estado,
    required this.metricas,
    required this.pairing,
  });

  factory WearableStatusModel.fromJson(Map<String, dynamic> json) {
    return WearableStatusModel(
      estado: wearableEstadoFromString(json['status'] as String),
      metricas: WearableMetricas.fromJson(json['metrics'] as Map<String, dynamic>),
      pairing: WearablePairing.fromJson(json['pairing'] as Map<String, dynamic>),
    );
  }
}
