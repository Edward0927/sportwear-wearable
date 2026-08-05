import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';
import '../core/models/favorito.dart';
import '../core/services/auth_service.dart';
import '../core/services/favoritos_service.dart';
import '../core/services/wearable_service.dart';
import '../screens/product_detail_screen.dart';

class WearableDashboard extends StatelessWidget {
  final VoidCallback onLogout;

  const WearableDashboard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final wearableService = context.watch<WearableService>();
    final usuario = context.watch<AuthService>().usuario;
    final status = wearableService.status!;
    final metricas = status.metricas;
    final pairing = status.pairing;
    final tiny = WearLayout.isTinyScreen(context);

    return RefreshIndicator(
      onRefresh: () => wearableService.fetchStatus(),
      child: ListView(
        padding: WearLayout.safePadding(context),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (usuario != null)
                  Flexible(
                    child: Text(
                      'Hola, ${usuario.nombre.split(' ').first}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: tiny ? 13 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                SizedBox(width: tiny ? 4 : 8),
                InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.logout_rounded, size: tiny ? 15 : 18, color: AppColors.gray600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(WearLayout.isTinyScreen(context) ? 12 : 20),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Color(0xFF2FBF5C), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'Conectado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    const Spacer(),
                    Text('${metricas.batteryPct}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 3),
                    const Icon(Icons.battery_std_rounded, color: Colors.white70, size: 15),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pairing.deviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: WearLayout.isTinyScreen(context) ? 16 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${pairing.deviceId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _MetricsGrid(
            cards: [
              _MetricCard(
                icon: Icons.favorite_rounded,
                label: 'Cardio',
                value: '${metricas.heartRate}',
                unit: 'bpm',
              ),
              _MetricCard(
                icon: Icons.directions_walk_rounded,
                label: 'Pasos',
                value: '${metricas.steps}',
                unit: 'pasos',
              ),
              _MetricCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Cal.',
                value: '${metricas.calories}',
                unit: 'kcal',
              ),
              _MetricCard(
                icon: Icons.route_rounded,
                label: 'Distancia',
                value: metricas.distanceKm.toStringAsFixed(2),
                unit: 'km',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  wearableService.isSyncing ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                  size: 16,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    wearableService.isSyncing
                        ? (WearLayout.isTinyScreen(context) ? 'Sincronizando…' : 'Sincronizando métricas cada 3 segundos…')
                        : 'Sincronización pausada',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: tiny ? 34 : 48,
            child: OutlinedButton.icon(
              onPressed: () => _confirmarDesconexion(context, wearableService),
              icon: Icon(Icons.link_off_rounded, size: tiny ? 14 : 18, color: AppColors.red),
              label: Text('Desvincular', style: TextStyle(color: AppColors.red, fontSize: tiny ? 11 : 14)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gray200),
                padding: tiny ? const EdgeInsets.symmetric(horizontal: 4) : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _FavoritosSincronizados(),
        ],
      ),
    );
  }

  Future<void> _confirmarDesconexion(BuildContext context, WearableService wearableService) async {
    final tiny = WearLayout.isTinyScreen(context);
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(tiny ? 8 : 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppColors.black,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.94),
            padding: EdgeInsets.symmetric(horizontal: tiny ? 14 : 22, vertical: tiny ? 12 : 22),
            // SingleChildScrollView como red de seguridad: si el contenido
            // no cabe en la altura disponible, hace scroll en vez de
            // desbordarse.
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.link_off_rounded, color: AppColors.red, size: tiny ? 18 : 32),
                  SizedBox(height: tiny ? 4 : 12),
                  Text(
                    '¿Desvincular?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: tiny ? 12 : 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: tiny ? 4 : 10),
                  Text(
                    tiny ? 'Dejas de sincronizar hasta emparejar de nuevo.' : 'Dejarás de sincronizar métricas hasta volver a emparejar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: tiny ? 9 : 13, height: 1.3),
                  ),
                  SizedBox(height: tiny ? 10 : 20),
                  SizedBox(
                    width: double.infinity,
                    height: tiny ? 28 : 40,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Desvincular', style: TextStyle(fontSize: tiny ? 9 : 13)),
                    ),
                  ),
                  SizedBox(height: tiny ? 2 : 8),
                  SizedBox(
                    width: double.infinity,
                    height: tiny ? 24 : 36,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text('Cancelar', style: TextStyle(fontSize: tiny ? 9 : 13, color: Colors.white60)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmar == true) {
      await wearableService.desconectar();
    }
  }
}

class _FavoritosSincronizados extends StatelessWidget {
  const _FavoritosSincronizados();

  @override
  Widget build(BuildContext context) {
    final favoritosService = context.watch<FavoritosService>();

    final tiny = WearLayout.isTinyScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_rounded, size: tiny ? 14 : 18, color: AppColors.black),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Favoritos sincronizados',
                maxLines: tiny ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: tiny ? 12 : 15, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => favoritosService.fetchFavoritos(),
              icon: Icon(Icons.refresh_rounded, size: tiny ? 15 : 18, color: AppColors.gray400),
              tooltip: 'Actualizar',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
        SizedBox(height: tiny ? 2 : 4),
        Text(
          tiny ? 'Desliza uno para quitarlo.' : 'Desliza un producto hacia la izquierda para quitarlo de favoritos.',
          style: TextStyle(fontSize: tiny ? 10 : 12, color: AppColors.gray600),
        ),
        SizedBox(height: tiny ? 8 : 12),
        if (favoritosService.loading && favoritosService.favoritos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: AppColors.black)),
          )
        else if (favoritosService.error != null && favoritosService.favoritos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              favoritosService.error!,
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          )
        else if (favoritosService.favoritos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Aún no tienes favoritos. Agrega productos desde la tienda y aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          )
        else
          Column(
            children: favoritosService.favoritos
                .map((f) => _FavoritoTile(favorito: f))
                .toList(),
          ),
      ],
    );
  }
}

class _FavoritoTile extends StatelessWidget {
  final Favorito favorito;

  const _FavoritoTile({required this.favorito});

  Future<bool> _confirmarYEliminar(BuildContext context) async {
    final tiny = WearLayout.isTinyScreen(context);
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(tiny ? 8 : 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: AppColors.black,
            padding: EdgeInsets.symmetric(horizontal: tiny ? 14 : 22, vertical: tiny ? 12 : 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline_rounded, color: AppColors.red, size: tiny ? 18 : 32),
                SizedBox(height: tiny ? 4 : 10),
                Text(
                  '¿Quitar de favoritos?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: tiny ? 11 : 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: tiny ? 4 : 8),
                Text(
                  favorito.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white60, fontSize: tiny ? 9 : 12),
                ),
                SizedBox(height: tiny ? 10 : 18),
                SizedBox(
                  width: double.infinity,
                  height: tiny ? 28 : 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('Quitar', style: TextStyle(fontSize: tiny ? 9 : 13)),
                  ),
                ),
                SizedBox(height: tiny ? 2 : 8),
                SizedBox(
                  width: double.infinity,
                  height: tiny ? 24 : 36,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('Cancelar', style: TextStyle(fontSize: tiny ? 9 : 13, color: Colors.white60)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmar != true) return false;
    if (!context.mounted) return false;
    return context.read<FavoritosService>().removeFavorito(favorito.productId);
  }

  @override
  Widget build(BuildContext context) {
    final tiny = WearLayout.isTinyScreen(context);
    final imgSize = tiny ? 34.0 : 46.0;

    return Dismissible(
      key: ValueKey(favorito.productId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarYEliminar(context),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: tiny ? 14 : 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_rounded, color: Colors.white, size: tiny ? 18 : 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(tiny ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    productId: favorito.productId,
                    fallbackName: favorito.name,
                    fallbackImage: favorito.image,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  favorito.image,
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: imgSize,
                    height: imgSize,
                    color: AppColors.gray100,
                    child: Icon(Icons.image_not_supported_outlined, size: tiny ? 14 : 18, color: AppColors.gray400),
                  ),
                ),
              ),
            ),
            SizedBox(width: tiny ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    favorito.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: tiny ? 11 : 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          favorito.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: tiny ? 9 : 11, color: AppColors.gray600),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${favorito.price.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: tiny ? 11 : 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<Widget> cards;

  const _MetricsGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    // En pantallas diminutas (ej. Wear OS Small Round, ~192dp), 2 tarjetas
    // por fila quedan demasiado angostas para ser legibles: se apilan en
    // 1 columna. En pantallas más grandes se acomodan de a 2.
    if (WearLayout.isTinyScreen(context)) {
      return Column(
        children: [
          for (final card in cards) ...[
            card,
            if (card != cards.last) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: cards[i]),
              if (i + 1 < cards.length) ...[
                const SizedBox(width: 12),
                Expanded(child: cards[i + 1]),
              ],
            ],
          ),
          if (i + 2 < cards.length) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.black),
          const SizedBox(height: 6),
          // FittedBox se encarga de encoger el texto si el espacio es más
          // angosto de lo esperado (por ejemplo cerca del borde de una
          // pantalla redonda), en vez de desbordar.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 3),
                Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}
