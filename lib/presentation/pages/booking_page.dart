import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'auth/login_page.dart'; // Assuming you have GlobalUser here

class BookingPage extends StatefulWidget {
  final String carId;
  const BookingPage({Key? key, required this.carId}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  dynamic _userDetails;
  dynamic _carDetails;
  bool _isLoading = true;
  bool _isBooking = false;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalCost = 0.0;

  final Color neonTeal = const Color(0xFF1DE9B6); // Neon Teal

  @override
  void initState() {
    super.initState();
    _fetchUserAndCarDetails();
  }

  Future<void> _fetchUserAndCarDetails() async {
    try {
      final userId = GlobalUser.getUserId();
      if (userId.isEmpty) throw 'User ID is empty.';

      final userResponse = await supabase.from('users').select().eq('id', userId).maybeSingle();
      final carResponse = await supabase.from('cars').select().eq('id', widget.carId).maybeSingle();

      if (userResponse == null || carResponse == null) {
        throw 'User or Car data not found.';
      }

      setState(() {
        _userDetails = userResponse;
        _carDetails = carResponse;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: neonTeal,
              onPrimary: Colors.black,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: neonTeal,
              onPrimary: Colors.black,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<bool> _checkCarAvailability() async {
    final response = await supabase.from('bookings')
        .select()
        .eq('car_id', widget.carId)
        .or('status.eq.pending,status.eq.confirmed')
        .gte('start_date', _startDateController.text)
        .lte('end_date', _endDateController.text);

    if (response != null && (response as List).isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submitBooking() async {
    try {
      final userId = GlobalUser.getUserId();
      final carId = widget.carId;
      final startDate = _startDateController.text;
      final endDate = _endDateController.text;

      if (userId.isEmpty || carId.isEmpty || startDate.isEmpty || endDate.isEmpty) {
        throw 'Please fill out all fields.';
      }

      setState(() {
        _isBooking = true;
      });

      final isAvailable = await _checkCarAvailability();

      if (!isAvailable) {
        _showDialog('Car Not Available', 'The car is not available for the selected dates.');
        setState(() {
          _isBooking = false;
        });
        return;
      }

      final bookingResponse = await supabase.from('bookings').insert({
        'user_id': userId,
        'car_id': carId,
        'start_date': startDate,
        'end_date': endDate,
        'total_cost': _totalCost,
        'status': 'pending',
      }).select();

      final bookingId = bookingResponse[0]['id'];  // Get the booking ID

      _showPaymentMethodDialog(bookingId);

    } catch (e) {
      print('Booking Error: $e');
      setState(() {
        _isBooking = false;
      });
      _showDialog('Error', 'Booking failed: $e');
    }
  }

  Future<void> _showPaymentMethodDialog(String bookingId) async {
    String? selectedPaymentMethod;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Select Payment Method', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Card', style: TextStyle(color: Colors.white)),
                onTap: () {
                  selectedPaymentMethod = 'card';
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('UPI', style: TextStyle(color: Colors.white)),
                onTap: () {
                  selectedPaymentMethod = 'upi';
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Cash', style: TextStyle(color: Colors.white)),
                onTap: () {
                  selectedPaymentMethod = 'cash';
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Wallet', style: TextStyle(color: Colors.white)),
                onTap: () {
                  selectedPaymentMethod = 'wallet';
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedPaymentMethod != null) {
      await _recordPayment(bookingId, selectedPaymentMethod!);
    }
  }

  Future<void> _recordPayment(String bookingId, String paymentMethod) async {
    try {
      await supabase.from('payments').insert({
        'booking_id': bookingId,
        'user_id': GlobalUser.getUserId(),
        'amount': _totalCost,
        'payment_method': paymentMethod,
        'payment_status': 'pending',
      });

      await supabase.from('bookings').update({
        'status': 'confirmed',
      }).eq('id', bookingId);

      _showDialog('Payment Successful', 'Your payment has been recorded, and the booking is confirmed!');
    } catch (e) {
      print('Payment Error: $e');
      _showDialog('Payment Error', 'An error occurred while processing your payment.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: neonTeal)),
          ),
        ],
      ),
    );
  }

  double _calculateTotalCost() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays;
      if (days > 0) {
        _totalCost = (days * (_carDetails['daily_rate'] as num)).toDouble();
      }
    }
    return _totalCost;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: neonTeal)),
      );
    }

    if (_userDetails == null || _carDetails == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(child: Text('Failed to load user or car details.', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Booking Page', style: TextStyle(color: neonTeal)),
        iconTheme: IconThemeData(color: neonTeal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_carDetails['image_url'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(_carDetails['image_url']),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        '${_carDetails['brand']} ${_carDetails['model']}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Daily Rate: ₹${(_carDetails['daily_rate'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  labelStyle: TextStyle(color: neonTeal),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: neonTeal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: neonTeal, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                onTap: () => _selectStartDate(context),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  labelStyle: TextStyle(color: neonTeal),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: neonTeal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: neonTeal, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 20),
              if (_startDate != null && _endDate != null)
                Text(
                  'Total Cost: ₹${_calculateTotalCost().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBooking ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonTeal,  // Replaced 'primary' with 'backgroundColor'
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isBooking
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Book Now', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
