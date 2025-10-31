import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/screens/welcome_screen.dart';
import 'package:task_connect_app/screens/provider_edit_profile_screen.dart';
import 'package:task_connect_app/screens/provider_manage_photos_screen.dart';
// --- 1. ADD THIS IMPORT ---
import 'package:task_connect_app/screens/provider_ratings_screen.dart';


class ProviderSettingsScreen extends StatefulWidget {
  const ProviderSettingsScreen({super.key});

  @override
  State<ProviderSettingsScreen> createState() => _ProviderSettingsScreenState();
}

class _ProviderSettingsScreenState extends State<ProviderSettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    try {
      // 1. Tell the server to log out (and invalidate the token)
      await ApiService.logout();
    } catch (e) {
      // Catch any errors but proceed with local logout
      print('Error logging out from server: $e');
    } finally {
      // 2. Clear all local data regardless of API success
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      await prefs.remove('userRole');
      await prefs.remove('auth_token');

      // 3. Navigate to WelcomeScreen and remove all other screens
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false, // This clears the stack
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Settings"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderEditProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Manage Photos"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderManagePhotosScreen(),
                  ),
                );
              },
            ),
            // --- 2. ADD THIS NEW LIST TILE ---
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text("My Ratings & Reviews"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderRatingsScreen(),
                  ),
                );
              },
            ),
            // ---------------------------------
            const Divider(height: 40),

            // --- LOGOUT BUTTON ---
            Center(
              child: _isLoggingOut
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            )
            // ---------------------
          ],
        ),
      ),
    );
  }
}

