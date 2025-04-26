import 'package:flutter/material.dart';
import 'package:rentalcar_1/presentation/pages/admin/user_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _supabase
        .from('bookings')
        .select('*')
        .order('created_at', ascending: false);

    setState(() {
      _bookings = response;
      _isLoading = false;
    });
  }

  String _formatDate(String date) {
    return DateTime.tryParse(date)?.toLocal().toString().split(' ')[0] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: const Text('Booking Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E), // Dark app bar
        iconTheme: const IconThemeData(color: Colors.tealAccent), // Teal icons
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      )
          : _bookings.isEmpty
          ? const Center(
          child: Text('No bookings found.',
              style: TextStyle(color: Colors.white)))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];

          return Card(
            color: const Color(0xff2C2B34), // Card color
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                'Status: ${booking['status'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start: ${_formatDate(booking['start_date'])}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'End: ${_formatDate(booking['end_date'])}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'User ID: ${booking['user_id'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Car ID: ${booking['car_id'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Total: ₹${booking['total_cost']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.tealAccent,
                size: 18,
              ),
              onTap: () {
                // Navigate to booking details page
              },
            ),
          );
        },
      ),
    );
  }
}
