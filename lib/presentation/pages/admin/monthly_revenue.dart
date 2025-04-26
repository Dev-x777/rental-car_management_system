import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({Key? key}) : super(key: key);

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  late Future<List<Map<String, dynamic>>> _revenueData;

  @override
  void initState() {
    super.initState();
    _revenueData = _fetchRevenueData();
  }

  Future<List<Map<String, dynamic>>> _fetchRevenueData() async {
    try {
      final response = await Supabase.instance.client
          .from('monthly_revenue_dashboard')
          .select()
          .order('month', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Failed to load revenue data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Monthly Revenue Dashboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _revenueData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data[index];

              final month = entry['month']?.toString().split(' ')[0] ?? 'N/A';
              final category = entry['category'] ?? 'All Categories';
              final bookingsCount = entry['bookings_count'] ?? 0;
              final totalRevenue = entry['total_revenue'] ?? 0;
              final avgBookingValue = entry['avg_booking_value'] ?? 0;
              final percentage = entry['percentage_of_total'] ?? 0;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: const Color(0xff2C2B34),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$month - $category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _buildRow('Bookings:', bookingsCount.toString()),
                      _buildRow('Total Revenue:', '₹$totalRevenue'),
                      _buildRow('Average Booking:', '₹$avgBookingValue'),
                      _buildRow('Percentage of Total:', '$percentage%'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
