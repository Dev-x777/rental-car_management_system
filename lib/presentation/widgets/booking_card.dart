import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onUpdate;

  const BookingCard({
    super.key,
    required this.booking,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isAdmin = Supabase.instance.client.auth.currentUser?.userMetadata?['role'] == 'admin';
    final car = booking['car'] as Map<String, dynamic>;
    final status = booking['status'] as String;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${car['brand']} ${car['model']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${dateFormat.format(DateTime.parse(booking['start_date']))} '
                '${timeFormat.format(DateTime.parse(booking['start_date']))}',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'to ${dateFormat.format(DateTime.parse(booking['end_date']))} '
                '${timeFormat.format(DateTime.parse(booking['end_date']))}',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs ${booking['total_cost'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isAdmin && (status == 'pending' || status == 'confirmed')) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending')
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus('confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text('Confirm'),
                  ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateBookingStatus('cancelled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
          if (!isAdmin && status == 'pending') ...[
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _updateBookingStatus('cancelled'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text('Cancel Booking'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', booking['id']);

      // Update car availability if booking is cancelled
      if (newStatus == 'cancelled') {
        await Supabase.instance.client
            .from('cars')
            .update({'availability': true})
            .eq('id', booking['car_id']);
      }

      onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(GlobalKey<ScaffoldMessengerState>().currentContext!)
          .showSnackBar(
        SnackBar(content: Text('Failed to update booking: ${e.toString()}')),
      );
    }
  }
}