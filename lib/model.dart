class Product {
  final int? id;
  final String productId;
  final List<String> images;
  final List<String> bookedDates;

  Product({
    this.id,
    required this.productId,
    required this.images,
    required this.bookedDates,
  });

  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'productId': productId,
    'images': images.join(','), // Save images as a comma-separated string
    'bookedDates': bookedDates.map((date) => DateTime.parse(date).toIso8601String()).join(','), // Ensure ISO format
  };
}


 static Product fromMap(Map<String, dynamic> map) {
  return Product(
    id: map['id'],
    productId: map['productId'],
    images: (map['images'] as String).split(','),
    bookedDates: map['bookedDates'].isEmpty
        ? []
        : (map['bookedDates'] as String).split(',').map((date) => date.trim()).toList(),
  );
}

}
