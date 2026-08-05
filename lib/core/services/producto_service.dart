import 'package:flutter/foundation.dart';

import '../models/producto_detalle.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Consulta el detalle de un producto (`GET /api/products/{id}`). Usado
class ProductoService extends ChangeNotifier {
  final ApiClient _apiClient;

  ProductoService(this._apiClient);

  Future<ProductoDetalle> getById(String id) async {
    try {
      final data = await _apiClient.get('/products/$id');
      return ProductoDetalle.fromJson(data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }
}
