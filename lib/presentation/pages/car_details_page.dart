import 'package:flutter/material.dart';
import 'package:rentalcar_1/data/models/car.dart';
import 'package:rentalcar_1/presentation/pages/maps_details_page.dart';
import 'package:rentalcar_1/presentation/widgets/more_card.dart';
import 'package:rentalcar_1/presentation/widgets/car_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login_page.dart';

class CarDetailsPage extends StatefulWidget {
  final String carId;
  final Car car;

  const CarDetailsPage({super.key, required this.carId, required this.car});

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Car> fetchCarDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('cars')
          .select()
          .eq('id', widget.carId)
          .single();
      return Car.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch car details: $e');
    }
  }

  Future<List<Car>> fetchOtherCars() async {
    try {
      final response = await Supabase.instance.client
          .from('cars')
          .select()
          .neq('id', widget.carId)
          .eq('availability', true)
          .order('daily_rate', ascending: true)
          .limit(3);
      return response.map<Car>((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch other cars: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Car>(
      future: fetchCarDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
                child: CircularProgressIndicator(color: Colors.tealAccent)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)),
            ),
          );
        }

        final currentCar = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            title: const Text('Car Details', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1E1E1E),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SlideTransition(
                      position: _slideAnimation,
                      child: CarCard(car: currentCar, toRoute: false)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpecificationsCard(currentCar),
                        const SizedBox(height: 20),
                        _buildDescriptionSection(currentCar),
                        const SizedBox(height: 30),
                        _buildReviewsSection(currentCar.id!),
                        const SizedBox(height: 30),
                        _buildActionButtons(context, currentCar),
                        const SizedBox(height: 30),
                        const Text('Similar Vehicles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent,
                            )),
                        const SizedBox(height: 12),
                        FutureBuilder<List<Car>>(
                          future: fetchOtherCars(),
                          builder: (context, otherCarsSnapshot) {
                            if (otherCarsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.tealAccent));
                            }
                            if (otherCarsSnapshot.hasError) {
                              return Text('Error loading similar vehicles',
                                  style: TextStyle(color: Colors.grey[400]));
                            }
                            if (!otherCarsSnapshot.hasData ||
                                otherCarsSnapshot.data!.isEmpty) {
                              return Text('No similar vehicles available',
                                  style: TextStyle(color: Colors.grey[400]));
                            }
                            return Column(
                              children: otherCarsSnapshot.data!
                                  .map((otherCar) => GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarDetailsPage(
                                          carId: otherCar.id!,
                                          car: otherCar),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 12),
                                  child: MoreCard(car: otherCar),
                                ),
                              ))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showReviewDialog,
            backgroundColor: Colors.tealAccent,
            child: const Icon(Icons.rate_review, color: Colors.black),
          ),
        );
      },
    );
  }

  Widget _buildReviewsSection(String carId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('reviews')
          .select('rating, review_text, reviewed_at')
          .eq('car_id', carId)
          .order('reviewed_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent));
        }

        if (snapshot.hasError) {
          return Text('Error loading reviews',
              style: TextStyle(color: Colors.grey[400]));
        }

        final reviews = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                )),
            const SizedBox(height: 12),
            if (reviews.isEmpty)
              Text('No review available',
                  style: TextStyle(color: Colors.grey[400]))
            else
              Column(
                children: reviews.map((review) {
                  final rating = review['rating'] ?? 0;
                  final text = review['review_text'] ?? '';
                  final date =
                  DateTime.tryParse(review['reviewed_at'] ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                                  (i) => Icon(Icons.star,
                                  size: 18,
                                  color:
                                  i < rating ? Colors.amber : Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(text, style: TextStyle(color: Colors.white)),
                          if (date != null)
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSpecificationsCard(Car car) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                )),
            const SizedBox(height: 12),
            _buildSpecItem('Brand', car.brand),
            _buildSpecItem('Model', car.model),
            _buildSpecItem('Year', car.year?.toString()),
            _buildSpecItem('Category', car.category),
            _buildSpecItem('License Plate', car.licensePlate),
            _buildSpecItem(
                'Daily Rate', '\$${car.dailyRate?.toStringAsFixed(2)}'),
            _buildSpecItem(
                'Availability',
                (car.availability ?? false)
                    ? 'Available'
                    : 'Not Available',
                valueColor:
                (car.availability ?? false) ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Car car) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            )),
        const SizedBox(height: 8),
        Text(
          'The ${car.brand} ${car.model} is available for rent at \$${car.dailyRate?.toStringAsFixed(2)} per day. '
              'This ${car.year ?? 'well-maintained'} vehicle comes with all standard features '
              'and provides excellent driving experience. Book now to enjoy your journey!',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Car car) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapsDetailsPage(car: car),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.tealAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.tealAccent),
            ),
            child: const Text('VIEW LOCATION'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (car.availability ?? false)
                ? () => _bookCar(context, car)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              (car.availability ?? false) ? Colors.tealAccent : Colors.grey,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('BOOK NOW'),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem(String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              )),
          Text(value ?? 'N/A',
              style: TextStyle(
                color: valueColor ?? Colors.white,
              )),
        ],
      ),
    );
  }

  void _bookCar(BuildContext context, Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
            'Book ${car.brand} ${car.model} for \$${car.dailyRate?.toStringAsFixed(2)} per day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Booking confirmed for ${car.brand} ${car.model}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog() {
    int selectedRating = 5;
    TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Leave a Review', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedRating,
                dropdownColor: const Color(0xFF1E1E1E),
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  labelStyle: TextStyle(color: Colors.tealAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
                items: List.generate(5, (index) => index + 1)
                    .map((rating) => DropdownMenuItem(
                  value: rating,
                  child: Text('$rating Star${rating > 1 ? 's' : ''}', style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: (value) {
                  selectedRating = value ?? 5;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your review...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
            ),
            ElevatedButton(
              onPressed: () => _submitReview(selectedRating, reviewController.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
              child: const Text('Send', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReview(int rating, String reviewText) async {
    final userId = GlobalUser.getUserId(); // Get from your GlobalUser class

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a review')),
      );
      Navigator.pop(context);
      return;
    }

    if (reviewText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review text cannot be empty')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('reviews').insert({
        'car_id': widget.carId,
        'user_id': userId,
        'rating': rating,
        'review_text': reviewText.trim(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
      setState(() {}); // Refresh to show new review
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $error')),
      );
    }
  }

}
