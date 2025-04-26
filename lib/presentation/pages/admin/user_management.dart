import 'package:flutter/material.dart';
import 'package:rentalcar_1/presentation/pages/admin/user_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final SupabaseClient _client = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await _client
        .from('users')
        .select('id, full_name, email, role, created_at')
        .eq('role', 'customer')
        .order('created_at', ascending: false);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
                child: Text('Failed to load users.',
                    style: TextStyle(color: Colors.white)));
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
                child: Text('No users found.',
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                color: const Color(0xff2C2B34),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(user['full_name'] ?? 'Unnamed',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(user['email'] ?? 'No email',
                      style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.tealAccent, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsPage(
                          userId: user['id'],
                          fullName: user['full_name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
