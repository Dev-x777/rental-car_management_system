import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  final String fullName;

  const UserDetailsPage({required this.userId, required this.fullName, Key? key}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late Future<Map<String, dynamic>> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _fetchUserDetails();
  }

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('user_complete_history_view')
          .select('user_id, full_name, email, phone, role, user_created_at, bookings, payments, reviews')
          .eq('user_id', widget.userId)
          .single();

      if (response == null) {
        throw Exception('User not found');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  Future<void> _deleteUser() async {
    try {
      final response = await Supabase.instance.client
          .from('users')  // Make sure the table name is 'users'
          .delete()  // Perform delete
          .eq('id', widget.userId);  // Use 'id' as the correct column for deletion

      if (response.error != null) {
        throw Exception('Failed to delete user: ${response.error?.message}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );

      Navigator.pop(context);  // Navigate back to the previous screen after successful deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details of ${widget.fullName}', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final userDetails = snapshot.data!;

          // Extract user details
          final userInfo = {
            'Full Name': userDetails['full_name'] ?? 'N/A',
            'Email': userDetails['email'] ?? 'N/A',
            'Phone': userDetails['phone'] ?? 'N/A',
            'Role': userDetails['role'] ?? 'N/A',
            'User Created At': userDetails['user_created_at'] ?? 'N/A',
          };

          final List<dynamic> bookings = userDetails['bookings'] ?? [];
          final List<dynamic> payments = userDetails['payments'] ?? [];
          final List<dynamic> reviews = userDetails['reviews'] ?? [];

          // Check if the user has any bookings
          bool hasBooking = bookings.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // User Info Card
                _buildInfoCard(context, 'User Information', userInfo),
                const SizedBox(height: 20),

                // Booking Information Card (if available)
                if (!hasBooking)
                  _buildInfoCard(context, 'Booking Information', {'Status': 'User didn\'t book any car.'}),
                if (hasBooking)
                  _buildBookingList(context, bookings),

                const SizedBox(height: 20),
                _buildPaymentList(context, payments),
                const SizedBox(height: 20),
                _buildReviewList(context, reviews),

                // Delete User Button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _deleteUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Delete User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<dynamic> bookings) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bookings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...bookings.map((booking) {
              final car = booking['car_details'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking ID: ${booking['booking_id']}'),
                    Text('Start Date: ${booking['start_date']}'),
                    Text('End Date: ${booking['end_date']}'),
                    Text('Status: ${booking['booking_status']}'),
                    Text('Total Cost: \$${booking['booking_total_cost']}'),
                    const SizedBox(height: 8),
                    Text('Car: ${car['car_brand']} ${car['car_model']} (${car['car_year']})'),
                    Text('License Plate: ${car['car_license_plate']}'),
                    Text('Daily Rate: \$${car['car_daily_rate']}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(BuildContext context, List<dynamic> payments) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payments', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...payments.map((payment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment ID: ${payment['payment_id']}'),
                    Text('Amount: \$${payment['payment_amount']}'),
                    Text('Method: ${payment['payment_method']}'),
                    Text('Status: ${payment['payment_status']}'),
                    Text('Paid At: ${payment['payment_date']}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList(BuildContext context, List<dynamic> reviews) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...reviews.map((review) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Car ID: ${review['car_id']}'),
                    Text('Rating: ${review['review_rating']}'),
                    Text('Comment: ${review['review_text']}'),
                    Text('Reviewed At: ${review['reviewed_at']}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark, // Dark mode for better UI consistency
        primarySwatch: Colors.teal, // Teal primary color
        cardColor: Colors.grey[850], // Card background color (darker tone)
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[700], // Darker teal for app bar
          elevation: 0,
        ),
      ),
      home: UserDetailsPage(userId: 'user_id_example', fullName: 'John Doe'),
    ),
  );
}
