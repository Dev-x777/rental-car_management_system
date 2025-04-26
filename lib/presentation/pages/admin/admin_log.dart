import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  _AdminLogsPageState createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _adminLogs;

  @override
  void initState() {
    super.initState();
    _adminLogs = fetchAdminLogs();
  }

  Future<List<Map<String, dynamic>>> fetchAdminLogs() async {
    try {
      final response = await _supabaseClient
          .from('admin_logs')
          .select('id, admin_id, action, details, performed_at')
          .order('performed_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Logs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2C2B34),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _adminLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs available'));
          }

          final logs = snapshot.data!;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                color: Colors.grey[900],
                child: ListTile(
                  title: Text(
                    'Action: ${log['action']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin ID: ${log['admin_id']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Details: ${log['details'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Performed at: ${log['performed_at']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
