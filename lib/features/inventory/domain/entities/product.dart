class Product {
  const Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.batch,
    required this.quantity,
    required this.expiryDate,
  });

  final int? id;
  final String barcode;
  final String name;
  final String batch;
  final int quantity;
  final DateTime expiryDate;

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    String? batch,
    int? quantity,
    DateTime? expiryDate,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      batch: batch ?? this.batch,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
