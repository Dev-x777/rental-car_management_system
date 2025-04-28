import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCarPage extends StatefulWidget {
  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();
  bool _isAvailable = true;
  String? _imageUrl;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image to upload')),
      );
      return;
    }

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
      final response = await _supabase.storage
          .from('car.images')
          .upload(fileName, _imageFile!);

      // Handle upload success by getting the public URL
      final publicUrl = _supabase.storage.from('car.images').getPublicUrl(fileName).toString();
      setState(() => _imageUrl = publicUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      // Handle errors in the try block
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
  }

  Future<void> _addCar() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _supabase.from('cars').insert({
          'brand': _brandController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text),
          'license_plate': _licensePlateController.text,
          'category': _categoryController.text,
          'daily_rate': double.tryParse(_dailyRateController.text),
          'availability': _isAvailable,
          'image_url': _imageUrl,  // Store the image URL in the database
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding car: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.tealAccent),
                title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.tealAccent),
                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.tealAccent),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.grey[850],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.tealAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label, TextInputType? type, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Add Car', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _brandController,
                label: 'Brand',
                validator: (value) => value!.isEmpty ? 'Brand is required' : null,
              ),
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                validator: (value) => value!.isEmpty ? 'Model is required' : null,
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                type: TextInputType.number,
                validator: (value) => (value!.isEmpty || int.tryParse(value) == null || int.parse(value) < 1990)
                    ? 'Enter a valid year (>= 1990)'
                    : null,
              ),
              _buildTextField(
                controller: _licensePlateController,
                label: 'License Plate',
                validator: (value) => value!.isEmpty ? 'License plate is required' : null,
              ),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                validator: (value) => value!.isEmpty ? 'Category is required' : null,
              ),
              _buildTextField(
                controller: _dailyRateController,
                label: 'Daily Rate (Rs)',
                type: TextInputType.number,
                validator: (value) => (value!.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0)
                    ? 'Enter a valid rate'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value),
                    activeColor: Colors.tealAccent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _imageFile != null
                    ? Container(
                  key: ValueKey(_imageFile),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
