import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/users.dart';
import '../auth/login_page.dart';
import '../car_list_screen.dart';


class UserProfile extends StatefulWidget {
  final UserModel userData;

  const UserProfile({super.key, required this.userData});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _profileImageUrl;
  List<Booking> _bookingHistory = [];
  bool _isLoading = true;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
    _fetchBookingHistory();
  }

  // Fetch the profile image URL from the users table
  Future<void> _fetchProfileImage() async {
    try {
      final response = await _supabase
          .from('users')
          .select('profile_photo')
          .eq('id', widget.userData.id)
          .maybeSingle();

      if (response != null && response['profile_photo'] != null) {
        setState(() {
          _profileImageUrl = response['profile_photo'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile image: $e");
    }
  }

  // Fetch the user's booking history from the bookings table
  Future<void> _fetchBookingHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabase
          .from('bookings')
          .select('*, cars(brand, model, category)')
          .eq('user_id', widget.userData.id);

      setState(() {
        _bookingHistory = (response as List<dynamic>)
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching booking history: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Open a bottom sheet to choose an image source (gallery or camera)
  Future<void> _pickImage() async {
    try {
      final imageSource = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          color: const Color(0xFF1E1E1E),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.tealAccent),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.tealAccent),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
              ),
            ],
          ),
        ),
      );

      if (imageSource == null) return;

      final pickedFile = await _picker.pickImage(
        source: imageSource,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image selected. Tap 'Upload Photo' to save"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Upload the selected image to Supabase Storage and update the profile photo in the database
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      await _pickImage();
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
        return;
      }
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = '${widget.userData.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload file to storage
      await _supabase.storage
          .from('profilephotos')
          .upload(fileName, _imageFile!, fileOptions: const FileOptions(upsert: true));

      // Get public URL for the uploaded file
      final publicUrl = _supabase.storage
          .from('profilephotos')
          .getPublicUrl(fileName);

      // Update the profile photo URL in the database
      final response = await _supabase
          .from('users')
          .update({'profile_photo': publicUrl})
          .eq('id', widget.userData.id)
          .select()
          .maybeSingle();

      if (response == null) {
        throw Exception('Failed to update profile in database.');
      }

      setState(() {
        _profileImageUrl = publicUrl;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Update password functionality (no hashing, directly store password)
  Future<void> _updatePassword() async {
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Update Password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new password',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF2C2C2C),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog if "Cancel" is pressed
            child: const Text('Cancel', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () async {
              // Perform password update logic here
              try {
                final response = await _supabase.from('users').update({
                  'password_hash': passwordController.text, // Store password directly (no hashing)
                }).eq('id', widget.userData.id);

                if (response != null) {
                  Navigator.of(context).pop(); // Close dialog after successful update
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated successfully")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  // Logout functionality
  Future<void> _logout() async {
    bool? logoutConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text('No', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Yes
            child: const Text('Yes', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (logoutConfirmed == true) {
      await _supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()), // Navigate to Login Page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CarListScreen(userData: widget.userData),
              ),
            );
          },
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildUpdateButtons(),
            const SizedBox(height: 16),
            const Text(
              'Booking History',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
                : _buildBookingHistory(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.tealAccent.withOpacity(0.2),
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!) as ImageProvider
                : _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : null,
            child: _imageFile == null && _profileImageUrl == null
                ? const Icon(Icons.person, size: 40, color: Colors.tealAccent)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userData.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.userData.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _uploadImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.upload),
          label: _isUploading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          )
              : const Text('Upload Photo'),
        ),
        ElevatedButton.icon(
          onPressed: _updatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.lock),
          label: const Text('Update Password'),
        ),
      ],
    );
  }

  Widget _buildBookingHistory() {
    if (_bookingHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No booking history available.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _bookingHistory.length,
      itemBuilder: (context, index) {
        final booking = _bookingHistory[index];
        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('${booking.carBrand} ${booking.carModel}', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Category: ${booking.carCategory}', style: const TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Red color for logout button
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Logout'),
      ),
    );
  }
}
