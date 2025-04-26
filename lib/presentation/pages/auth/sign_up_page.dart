import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/users.dart';
import 'login_page.dart';  // Import login page to navigate after sign-up

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final fullNameController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  void signUp() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text;
    final phone = phoneController.text;
    final fullName = fullNameController.text;

    if (email.isEmpty || password.isEmpty || phone.isEmpty || fullName.isEmpty) {
      _showError("All fields are required.");
      setState(() => isLoading = false);
      return;
    }

    try {
      // Insert user into the "users" table
      final response = await supabase.from('users').insert([
        {
          'email': email,
          'password_hash': password,
          'phone': phone,
          'full_name': fullName,
          'role': 'customer', // Default role is 'customer'
        }
      ]).select().single();

      // Check if the insertion was successful
      if (response != null) {
        // Navigate to the login page after successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        _showError('Failed to sign up. Please try again later.');
      }
    } catch (e) {
      _showError('Something went wrong. ${e.toString()}');
    }

    setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 50,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Create a New Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign up to get started!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // Glassmorphism card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: fullNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.person, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.email, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: phoneController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.phone, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
