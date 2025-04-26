class Car {
  final String id;
  late final String brand;
  late final String model;
  late final int? year;
  late final String licensePlate;
  late final String? category;
  late final String? imageUrl;
  late final double? dailyRate;
  late final bool? availability;
  final DateTime? addedAt;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.licensePlate,
    this.year,
    this.category,
    this.imageUrl,
    this.dailyRate,
    this.availability,
    this.addedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      category: json['category'],
      imageUrl: json['image_url'],
      dailyRate: (json['daily_rate'] as num?)?.toDouble(),
      availability: json['availability'],
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
    );
  }
}
