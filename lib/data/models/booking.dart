class Booking {
  final String id;
  final String userId;
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double totalCost;
  final DateTime createdAt;

  final String? carBrand;
  final String? carModel;
  final String? carCategory;

  Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalCost,
    required this.createdAt,
    this.carBrand,
    this.carModel,
    this.carCategory,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      carId: json['car_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      carBrand: json['cars']?['brand'] as String?,
      carModel: json['cars']?['model'] as String?,
      carCategory: json['cars']?['category'] as String?,
    );
  }
}