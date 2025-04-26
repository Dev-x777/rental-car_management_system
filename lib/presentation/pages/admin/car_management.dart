import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentalcar_1/data/models/car.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_car.dart';

class CarManagementPage extends StatefulWidget {
  @override
  _CarManagementPageState createState() => _CarManagementPageState();
}

class _CarManagementPageState extends State<CarManagementPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase.from('cars').select();
      setState(() {
        _cars = response.map((json) => Car.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cars: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCar(String carId) async {
    try {
      await _supabase.from('cars').delete().eq('id', carId);
      _loadCars();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting car')),
      );
    }
  }

  Future<void> _updateCar(Car car) async {
    try {
      await _supabase.from('cars').update({
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'license_plate': car.licensePlate,
        'category': car.category,
        'daily_rate': car.dailyRate,
        'availability': car.availability,
        'image_url': car.imageUrl,
      }).eq('id', car.id);
      _loadCars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating car: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white), // Fixed back button color
        title: const Text('Car Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      )
          : _cars.isEmpty
          ? const Center(
        child: Text('No cars available',
            style: TextStyle(color: Colors.white54, fontSize: 16)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          final car = _cars[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              color: const Color(0xff1E1E1E),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: car.imageUrl != null
                      ? Image.network(
                    car.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.tealAccent.withOpacity(0.2),
                    child: const Icon(Icons.directions_car,
                        color: Colors.tealAccent),
                  ),
                ),
                title: Text(
                  '${car.brand} ${car.model}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('License: ${car.licensePlate}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text('₹${car.dailyRate?.toStringAsFixed(2)} / day',
                        style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.tealAccent),
                      onPressed: () => _showEditCarDialog(context, car),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.redAccent),
                      onPressed: () => _deleteCar(car.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCarPage()),
          ).then((_) => _loadCars());
        },
      ),
    );
  }

  void _showEditCarDialog(BuildContext context, Car car) {
    final brandController = TextEditingController(text: car.brand);
    final modelController = TextEditingController(text: car.model);
    final yearController = TextEditingController(text: car.year?.toString());
    final licensePlateController = TextEditingController(text: car.licensePlate);
    final categoryController = TextEditingController(text: car.category);
    final dailyRateController = TextEditingController(text: car.dailyRate?.toString());
    bool isAvailable = car.availability ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Edit Car', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInputField(brandController, 'Brand'),
                    _buildInputField(modelController, 'Model'),
                    _buildInputField(yearController, 'Year', isNumber: true),
                    _buildInputField(licensePlateController, 'License Plate'),
                    _buildInputField(categoryController, 'Category'),
                    _buildInputField(dailyRateController, 'Daily Rate', isNumber: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Available', style: TextStyle(color: Colors.white)),
                        Switch(
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          },
                          activeColor: Colors.tealAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () {
                    car.brand = brandController.text;
                    car.model = modelController.text;
                    car.year = int.tryParse(yearController.text);
                    car.licensePlate = licensePlateController.text;
                    car.category = categoryController.text;
                    car.dailyRate = double.tryParse(dailyRateController.text);
                    car.availability = isAvailable;

                    _updateCar(car);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                  child: const Text('Save', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.tealAccent),
          filled: true,
          fillColor: Colors.black12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
