/// (`GET /api/favoritos`), sincronizado desde la tienda Angular.
class Favorito {
  final String productId;
  final String name;
  final String category;
  final String image;
  final double price;
  final String fechaAgregado;

  Favorito({
    required this.productId,
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    required this.fechaAgregado,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      productId: json['productId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      fechaAgregado: json['fechaAgregado'] as String,
    );
  }
}
