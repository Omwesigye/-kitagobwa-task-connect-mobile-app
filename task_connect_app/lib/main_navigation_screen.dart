// lib/main_navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/bookings.dart';
import 'package:task_connect_app/screens/home_page.dart';
import 'package:task_connect_app/screens/provider_list_screen.dart';
import 'package:task_connect_app/screens/report_problem_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId;

  const MainNavigationScreen({super.key, required this.userId});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
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
      BookingsScreen(
        userId: widget.userId,
        key: const PageStorageKey('BookingsScreen'),
      ),
      
      // --- UPDATE THIS LINE ---
      ReportProblemPage(
        userId: widget.userId,
        key: const PageStorageKey('ReportProblemPage'),
        // Pass the function to switch the tab to index 0
        onReportSubmitted: () => _onItemTapped(0), 
      ),
      // ------------------------
    ];

    return Scaffold(
      body: PageStorage(bucket: _bucket, child: screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}