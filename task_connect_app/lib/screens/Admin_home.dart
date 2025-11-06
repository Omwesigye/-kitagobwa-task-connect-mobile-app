import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/screens/admin_service.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';
import 'admin_reports.dart';
import 'live location.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? token;
  late AdminService service;

  List users = [];
  List pendingProviders = [];
  List allProviders = [];
  List bookings = [];

  bool isLoading = false;

  Map<String, bool> tabLoading = {
    'users': false,
    'pendingProviders': false,
    'allProviders': false,
    'bookings': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchCurrentTab();
    });
    _loadTokenAndFetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTokenAndFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    service = AdminService(token);
    if (token == null || token!.isEmpty) {
      _showError('You are not logged in. Please sign in as admin.');
      return;
    }
    _fetchCurrentTab();
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('auth_token');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // ---------------- FETCH METHODS ----------------
  void _fetchCurrentTab() {
    switch (_tabController.index) {
      case 0:
        fetchUsers();
        break;
      case 1:
        fetchPendingProviders();
        break;
      case 2:
        fetchAllProviders();
        break;
      case 3:
        fetchBookings();
        break;
    }
  }

  Future<void> fetchUsers() async {
    setState(() => tabLoading['users'] = true);
    try {
      users = await service.fetchUsers();
    } catch (e) {
      _showError('Error fetching users: $e');
    } finally {
      setState(() => tabLoading['users'] = false);
    }
  }

  Future<void> fetchPendingProviders() async {
    setState(() => tabLoading['pendingProviders'] = true);
    try {
      pendingProviders = await service.fetchPendingProviders();
    } catch (e) {
      _showError('Error fetching pending providers: $e');
    } finally {
      setState(() => tabLoading['pendingProviders'] = false);
    }
  }

  Future<void> fetchAllProviders() async {
    setState(() => tabLoading['allProviders'] = true);
    try {
      allProviders = await service.fetchAllProviders();
    } catch (e) {
      _showError('Error fetching all providers: $e');
    } finally {
      setState(() => tabLoading['allProviders'] = false);
    }
  }

  Future<void> fetchBookings() async {
    setState(() => tabLoading['bookings'] = true);
    try {
      bookings = await service.fetchBookings();
    } catch (e) {
      _showError('Error fetching bookings: $e');
    } finally {
      setState(() => tabLoading['bookings'] = false);
    }
  }

  // ---------------- ACTION METHODS ----------------
  Future<void> deleteUser(int id) async {
    try {
      await service.deleteUser(id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User deleted")));
      setState(() => users.removeWhere((u) => u['id'] == id));
    } catch (e) {
      _showError('Error deleting user: $e');
    }
  }

  Future<void> deleteProvider(int id) async {
    try {
      await service.deleteProvider(id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Provider deleted")));
      setState(() {
        pendingProviders.removeWhere((p) => p['id'] == id);
        allProviders.removeWhere((p) => p['id'] == id);
      });
    } catch (e) {
      _showError('Error deleting provider: $e');
    }
  }

  Future<void> approveProvider(int id) async {
    try {
      await service.approveProvider(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Provider approved. OTP sent to their email."),
        ),
      );
      setState(() {
        final provider = pendingProviders.firstWhere((p) => p['id'] == id);
        pendingProviders.removeWhere((p) => p['id'] == id);
        allProviders.add(provider);
      });
    } catch (e) {
      _showError('Error approving provider: $e');
    }
  }

  Future<void> updateBookingStatus(int id, String status) async {
    try {
      await service.updateBookingStatus(id, status);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booking updated")));
      fetchBookings();
    } catch (e) {
      _showError('Error updating booking: $e');
    }
  }

  // ---------------- UTILITY ----------------
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                title: Text(
                  'Admin Menu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.report_problem),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminReportsPage(service: service),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Live Location'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiveLocationPage(),
                    ),
                  );
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.people), text: 'Users (${users.length})'),
            Tab(
                icon: const Icon(Icons.hourglass_bottom),
                text: 'Pending (${pendingProviders.length})'),
            Tab(icon: const Icon(Icons.badge), text: 'Providers (${allProviders.length})'),
            Tab(icon: const Icon(Icons.event_note), text: 'Bookings (${bookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildPendingProvidersTab(),
          _buildAllProvidersTab(),
          _buildBookingsTab(),
        ],
      ),
    );
  }

  // ---------------- TAB WIDGETS ----------------
  Widget _buildUsersTab() {
    if (tabLoading['users']!) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) return const Center(child: Text("No users available"));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Text(
                (user['name'] ?? '?').toString().trim().substring(0, 1).toUpperCase(),
              ),
            ),
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text(user['email'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteUser(user['id']),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueRow(label: 'ID', value: user['id']?.toString()),
                    KeyValueRow(label: 'Role', value: user['role']?.toString()),
                    KeyValueRow(
                        label: 'Approved',
                        value: (user['is_approved'] == 1).toString()),
                    if (user['created_at'] != null)
                      KeyValueRow(label: 'Created', value: user['created_at'].toString()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingProvidersTab() {
    if (tabLoading['pendingProviders']!) return const Center(child: CircularProgressIndicator());
    if (pendingProviders.isEmpty) return const Center(child: Text("No pending providers"));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: pendingProviders.length,
      itemBuilder: (context, index) {
        final provider = pendingProviders[index];
        final user = provider['user'] ?? {};
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            leading: const Icon(Icons.pending_actions),
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text(provider['service'] ?? 'No service'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueRow(label: 'User ID', value: user['id']?.toString()),
                    KeyValueRow(label: 'Email', value: user['email']?.toString()),
                    KeyValueRow(label: 'Location', value: provider['location']?.toString()),
                    KeyValueRow(label: 'Tel', value: provider['telnumber']?.toString()),
                    KeyValueRow(label: 'NIN', value: provider['nin']?.toString()),
                    KeyValueRow(label: 'Description', value: provider['description']?.toString()),
                  ],
                ),
              ),
              ButtonBar(
                children: [
                  TextButton.icon(
                    onPressed: () => approveProvider(provider['id']),
                    icon: const Icon(Icons.check, color: Colors.green),
                    label: const Text('Approve'),
                  ),
                  TextButton.icon(
                    onPressed: () => deleteProvider(provider['id']),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllProvidersTab() {
    if (tabLoading['allProviders']!) return const Center(child: CircularProgressIndicator());
    if (allProviders.isEmpty) return const Center(child: Text("No providers available"));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: allProviders.length,
      itemBuilder: (context, index) {
        final provider = allProviders[index];
        final user = provider['user'] ?? {};
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            leading: const Icon(Icons.badge),
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text(provider['service'] ?? 'No service'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteProvider(provider['id']),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueRow(label: 'User ID', value: user['id']?.toString()),
                    KeyValueRow(label: 'Email', value: user['email']?.toString()),
                    KeyValueRow(label: 'Location', value: provider['location']?.toString()),
                    KeyValueRow(label: 'Tel', value: provider['telnumber']?.toString()),
                    KeyValueRow(label: 'NIN', value: provider['nin']?.toString()),
                    KeyValueRow(label: 'Description', value: provider['description']?.toString()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    if (tabLoading['bookings']!) return const Center(child: CircularProgressIndicator());
    if (bookings.isEmpty) return const Center(child: Text("No bookings available"));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            leading: const Icon(Icons.event_note),
            title: Text("${booking['user_name']} → ${booking['provider_name']}"),
            subtitle: Text("${booking['service']} at ${booking['date']} ${booking['time']}"),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => updateBookingStatus(booking['id'], value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueRow(label: 'Booking ID', value: booking['id']?.toString()),
                    KeyValueRow(label: 'Status', value: booking['status']?.toString()),
                    if (booking['address'] != null)
                      KeyValueRow(label: 'Address', value: booking['address'].toString()),
                    if (booking['notes'] != null)
                      KeyValueRow(label: 'Notes', value: booking['notes'].toString()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
