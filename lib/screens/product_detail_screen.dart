import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/producto_detalle.dart';
import '../core/services/favoritos_service.dart';
import '../core/services/producto_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/wear_layout.dart';


class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String fallbackName;
  final String fallbackImage;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.fallbackName,
    required this.fallbackImage,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductoDetalle? _detalle;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detalle = await context.read<ProductoService>().getById(widget.productId);
      if (!mounted) return;
      setState(() {
        _detalle = detalle;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el producto.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiny = WearLayout.isTinyScreen(context);
    final favoritos = context.watch<FavoritosService>();
    final esFavorito = favoritos.favoritos.any((f) => f.productId == widget.productId);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: WearLayout.safePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: WearLayout.safeContentWidth(context) * 1.25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_rounded, size: tiny ? 12 : 16),
                      label: Text('Volver', style: TextStyle(fontSize: tiny ? 10 : 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gray400,
                        padding: EdgeInsets.symmetric(horizontal: tiny ? 6 : 12),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ),
                  SizedBox(height: tiny ? 6 : 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _detalle?.image ?? widget.fallbackImage,
                      width: tiny ? 100 : 140,
                      height: tiny ? 100 : 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: tiny ? 100 : 140,
                        height: tiny ? 100 : 140,
                        color: AppColors.gray600,
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: tiny ? 24 : 32),
                      ),
                    ),
                  ),
                  SizedBox(height: tiny ? 10 : 16),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                    )
                  else if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: tiny ? 10 : 13),
                    ),
                    SizedBox(height: tiny ? 8 : 12),
                    TextButton(
                      onPressed: _cargar,
                      child: Text('Reintentar', style: TextStyle(fontSize: tiny ? 10 : 13)),
                    ),
                  ] else if (_detalle != null) ...[
                    Text(
                      _detalle!.category.toUpperCase(),
                      style: TextStyle(color: AppColors.accent, fontSize: tiny ? 9 : 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    SizedBox(height: tiny ? 4 : 6),
                    Text(
                      _detalle!.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: tiny ? 13 : 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: tiny ? 8 : 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${_detalle!.price.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.white, fontSize: tiny ? 18 : 24, fontWeight: FontWeight.bold),
                        ),
                        if (_detalle!.oldPrice != null) ...[
                          SizedBox(width: tiny ? 6 : 8),
                          Text(
                            '\$${_detalle!.oldPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: tiny ? 11 : 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_detalle!.badgeDiscount != null) ...[
                      SizedBox(height: tiny ? 4 : 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: tiny ? 8 : 10, vertical: tiny ? 2 : 4),
                        decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          _detalle!.badgeDiscount!,
                          style: TextStyle(color: Colors.white, fontSize: tiny ? 9 : 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    SizedBox(height: tiny ? 16 : 22),
                    SizedBox(
                      width: double.infinity,
                      height: tiny ? 34 : 46,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final removed = await favoritos.removeFavorito(widget.productId);
                          if (removed && context.mounted) Navigator.of(context).pop();
                        },
                        icon: Icon(
                          esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: AppColors.red,
                          size: tiny ? 14 : 18,
                        ),
                        label: Text(
                          'Quitar de favoritos',
                          style: TextStyle(color: AppColors.red, fontSize: tiny ? 10 : 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          padding: tiny ? const EdgeInsets.symmetric(horizontal: 4) : null,
                        ),
                      ),
                    ),
                  ],

                  if (WearLayout.isLikelyRound(context))
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
