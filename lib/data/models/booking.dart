class Booking {
  final String id;
  final String carBrand;
  final String carModel;
  final String carCategory;
  final DateTime startDate;
  final DateTime endDate;

  Booking({
    required this.id,
    required this.carBrand,
    required this.carModel,
    required this.carCategory,
    required this.startDate,
    required this.endDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final car = json['cars'] ?? {}; // very important
    return Booking(
      id: json['id'] as String,
      carBrand: car['brand'] ?? 'Unknown',
      carModel: car['model'] ?? 'Unknown',
      carCategory: car['category'] ?? 'Unknown',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
}
