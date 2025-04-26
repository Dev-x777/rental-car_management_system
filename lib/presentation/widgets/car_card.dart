import 'package:flutter/material.dart';
import 'package:rentalcar_1/data/models/car.dart';
import 'package:rentalcar_1/presentation/pages/car_details_page.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final bool toRoute;

  const CarCard({
    super.key,
    required this.car,
    this.toRoute = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toRoute
          ? Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CarDetailsPage(carId: car.id, car: car),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xff2C2B34),
              const Color(0xff1D1C22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: car.imageUrl != null
                  ? Image.network(
                car.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
              )
                  : const Image(
                image: AssetImage('assets/car_image.png'),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              car.model ?? 'Unknown Model',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          car.year?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Row(
                      children: [
                        const Icon(Icons.local_taxi,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          car.category ?? 'N/A',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Rs ${car.dailyRate?.toStringAsFixed(2) ?? '0.00'}/day',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                    shadows: [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'License Plate: ${car.licensePlate ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}