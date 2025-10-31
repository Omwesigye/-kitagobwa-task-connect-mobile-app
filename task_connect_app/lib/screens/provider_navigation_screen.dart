import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/provider_chat_list_screen.dart';
import 'package:task_connect_app/screens/provider_bookings_screen.dart'; 
// --- 1. IMPORT THE NEW SETTINGS SCREEN ---
import 'package:task_connect_app/screens/provider_settings_screen.dart';

class ProviderNavigationScreen extends StatefulWidget {
  final int userId;
  const ProviderNavigationScreen({super.key, required this.userId});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // --- 2. ADD THE SETTINGS SCREEN TO THE LIST ---
    _pages = [
      ProviderBookingsScreen(userId: widget.userId), // Index 0
      ProviderChatListScreen(providerUserId: widget.userId), // Index 1
      const ProviderSettingsScreen(), // Index 2
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        // --- 3. ADD THE NEW NAVIGATION ITEM ---
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

