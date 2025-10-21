import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/bookings.dart';
import 'package:task_connect_app/screens/home_page.dart';
import 'package:task_connect_app/screens/provider_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId;

  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // PageStorageBucket preserves widget state between refreshes
  final PageStorageBucket _bucket = PageStorageBucket();

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(
        onNavigateToProviders: () => _onItemTapped(1),
        key: const PageStorageKey('HomePage'),
      ),
      ProviderListScreen(key: const PageStorageKey('ProviderListScreen')),
      // Add Bookings screen here if you implement it
      BookingsScreen(
        userId: widget.userId,
        key: const PageStorageKey('BookingsScreen'),
      ),
    ];

    return Scaffold(
      body: PageStorage(bucket: _bucket, child: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Providers'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
