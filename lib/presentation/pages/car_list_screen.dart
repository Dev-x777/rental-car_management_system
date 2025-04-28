import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rentalcar_1/presentation/pages/users/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/car.dart';
import '../../data/models/users.dart';
import '../widgets/car_card.dart';
import 'auth/login_page.dart';

class CarListScreen extends StatefulWidget {
  final UserModel userData;

  const CarListScreen({super.key, required this.userData});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<Car> _cars = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _profileImageUrl;

  String? _selectedBrand = 'All';
  String? _selectedModel = 'All';
  String? _selectedCategory = 'All';
  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _fetchCars();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('avatar_url')
            .eq('id', user.id)
            .single();

        if (response != null && response['avatar_url'] != null) {
          setState(() {
            _profileImageUrl = response['avatar_url'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile image: $e");
    }
  }

  Future<void> _fetchCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var query = Supabase.instance.client.from('cars').select().eq('availability', true);

      if (_selectedBrand != 'All') {
        query = query.eq('brand', _selectedBrand!);
      }
      if (_selectedModel != 'All') {
        query = query.eq('model', _selectedModel!);
      }
      if (_selectedCategory != 'All') {
        query = query.eq('category', _selectedCategory!);
      }
      if (_minPrice != null) {
        query = query.gte('daily_rate', _minPrice!);
      }
      if (_maxPrice != null) {
        query = query.lte('daily_rate', _maxPrice!);
      }

      final response = await query;

      setState(() {
        _cars = (response as List<dynamic>)
            .map((json) => Car.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cars';
      });
      debugPrint("Error fetching cars: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar:PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Text(
            '${_getGreeting()}, ${widget.userData.fullName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => UserProfile(userData: widget.userData),
                    ),
                        (route) => false,
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.tealAccent.withOpacity(0.15),
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.tealAccent, size: 26)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchCars,
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.refresh, color: Colors.black),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCustomDropdown(
                    value: _selectedBrand,
                    onChanged: (value) {
                      setState(() => _selectedBrand = value);
                      _fetchCars();
                    },
                    items: ['All', 'Toyota', 'Ford', 'BMW', 'Honda'],
                  ),
                  _buildCustomDropdown(
                    value: _selectedModel,
                    onChanged: (value) {
                      setState(() => _selectedModel = value);
                      _fetchCars();
                    },
                    items: ['All', 'Corolla', 'Civic', 'F150', 'X5'],
                  ),
                  _buildCustomDropdown(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      _fetchCars();
                    },
                    items: ['All', 'SUV', 'Sedan', 'Hatchback', 'Luxury', 'Van'],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.tealAccent),
                    onPressed: _fetchCars,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String? value,
    required void Function(String?) onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: Colors.black87,
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.tealAccent,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_cars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_rental, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No cars available',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            TextButton(
              onPressed: _fetchCars,
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.tealAccent,
      onRefresh: _fetchCars,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cars.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CarCard(car: _cars[index]),
        ),
      ),
    );
  }

}
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    return 'Good Morning';
  } else if (hour >= 12 && hour < 17) {
    return 'Good Afternoon';
  } else if (hour >= 17 && hour < 20) {
    return 'Good Evening';
  } else {
    return 'Sweet Dreams';
  }
}
