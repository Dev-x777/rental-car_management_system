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
          .from('full_revenue_dashboard_view')
          .select()
          .order('revenue_month', ascending: false);

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
        title: const Text(
          'Revenue Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _revenueData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final entry = data[index];

              final month = entry['revenue_month']?.toString().split(' ')[0] ?? 'N/A';
              final car = '${entry['brand']} ${entry['model']} (${entry['category']})';
              final customer = entry['full_name'] ?? 'N/A';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xff2C2B34),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$month - $car',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRow('Customer:', customer),
                      _buildRow('Total Revenue:', '₹${entry['total_revenue'] ?? 0}'),
                      _buildRow('Completed Bookings:', '${entry['completed_bookings'] ?? 0}'),
                      _buildRow('Cancelled Bookings:', '${entry['cancelled_bookings'] ?? 0}'),
                      _buildRow('Avg Revenue / Booking:', '₹${entry['avg_revenue_per_booking'] ?? 0}'),
                      _buildRow('Avg Booking Duration:', '${entry['avg_booking_duration_days'] ?? 0} days'),
                      _buildRow('Card Payments:', '${entry['card_payments'] ?? 0}'),
                      _buildRow('UPI Payments:', '${entry['upi_payments'] ?? 0}'),
                      _buildRow('Cash Payments:', '${entry['cash_payments'] ?? 0}'),
                      _buildRow('Wallet Payments:', '${entry['wallet_payments'] ?? 0}'),
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
