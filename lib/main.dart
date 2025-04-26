import 'package:flutter/material.dart';
import 'package:rentalcar_1/presentation/pages/auth/login_page.dart';
import 'package:rentalcar_1/presentation/pages/admin/admin_dashboard.dart';
import 'package:rentalcar_1/presentation/pages/car_list_screen.dart';
import 'package:rentalcar_1/presentation/pages/onboarding_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/models/users.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ivrhimqmihkwdmppjnvv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2cmhpbXFtaWhrd2RtcHBqbnZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyNzg4NDEsImV4cCI6MjA1OTg1NDg0MX0.4rP9ZsGviTQ7Sb1q7yBrBXTKbCftDPbQdhI5kC7d1MU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental Car App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OnboardingPage(),
    );
  }
}

