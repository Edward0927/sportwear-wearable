/// (`GET /api/products/{id}`) — el mismo endpoint que usa la tienda
class ProductoDetalle {
  final String id;
  final String name;
  final String category;
  final String image;
  final double price;
  final double? oldPrice;
  final String? badge;
  final String? badgeDiscount;

  ProductoDetalle({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    this.oldPrice,
    this.badge,
    this.badgeDiscount,
  });

  factory ProductoDetalle.fromJson(Map<String, dynamic> json) {
    return ProductoDetalle(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: json['oldPrice'] != null ? (json['oldPrice'] as num).toDouble() : null,
      badge: json['badge'] as String?,
      badgeDiscount: json['badgeDiscount'] as String?,
    );
  }
}
