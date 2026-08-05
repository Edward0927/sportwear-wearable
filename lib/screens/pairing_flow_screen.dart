import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/wearable_status.dart';
import '../core/services/auth_service.dart';
import '../core/services/favoritos_service.dart';
import '../core/services/wearable_service.dart';
import '../core/theme/app_theme.dart';
import 'login_screen.dart';
import '../widgets/pairing_form.dart';
import '../widgets/wearable_dashboard.dart';

class PairingFlowScreen extends StatefulWidget {
  const PairingFlowScreen({super.key});

  @override
  State<PairingFlowScreen> createState() => _PairingFlowScreenState();
}

class _PairingFlowScreenState extends State<PairingFlowScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WearableService>().fetchStatus();
      context.read<FavoritosService>()
        ..fetchFavoritos()
        ..startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<FavoritosService>().stopAutoRefresh();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Consumer<WearableService>(
        builder: (context, wearableService, _) {
          if (wearableService.loading && wearableService.status == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.black));
          }

          if (wearableService.status == null) {
            return _ErrorRetry(
              message: wearableService.error ?? 'No se pudo cargar el estado del wearable.',
              onRetry: () => wearableService.fetchStatus(),
            );
          }

          final estado = wearableService.status!.estado;

          if (estado == WearableEstado.conectado) {
            return WearableDashboard(onLogout: _logout);
          }

          return PairingForm(onLogout: _logout);
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.gray400, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gray600)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
