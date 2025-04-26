import 'package:flutter/material.dart';
import 'package:rentalcar_1/presentation/pages/admin/monthly_revenue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_page.dart';
import 'admin_log.dart';
import 'booking_management.dart';
import 'car_management.dart';
import 'user_management.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2C2B34),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xff2C2B34),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Abstract background
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.directions_car,
                  title: 'Manage Cars',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CarManagementPage()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.people,
                  title: 'Manage Users',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserManagementPage()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.receipt,
                  title: 'View Bookings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BookingManagementPage()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.event_note,
                  title: 'Admin Logs', // <-- NEW CARD
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminLogsPage()),
                  ),
                ),

                _DashboardCard(
                  icon: Icons.attach_money_outlined,
                  title: 'Revenue', // <-- NEW CARD
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RevenuePage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
