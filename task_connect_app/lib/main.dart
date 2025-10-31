import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// --- ADD THESE IMPORTS ---
// ✅ CORRECT
import 'package:task_connect_app/main_navigation_screen.dart';
import 'package:task_connect_app/screens/welcome_screen.dart';
// -------------------------
import 'package:task_connect_app/themes/theme.dart';
import 'package:task_connect_app/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- 1. CHECK IF USER IS LOGGED IN ---
  final prefs = await SharedPreferences.getInstance();
  // Get the stored values. If they don't exist, default to false/0.
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final int userId = prefs.getInt('userId') ?? 0;
  // ------------------------------------

  // --- 2. PASS THE VALUES TO THE APP ---
<<<<<<< HEAD
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    userId: userId,
  ));
=======
  runApp(MyApp(isLoggedIn: isLoggedIn, userId: userId));
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
}

class MyApp extends StatelessWidget {
  // --- 3. ACCEPT THE LOGIN DATA ---
  final bool isLoggedIn;
  final int userId;

<<<<<<< HEAD
  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.userId,
  });
=======
  const MyApp({super.key, required this.isLoggedIn, required this.userId});
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Connect App',
            debugShowCheckedModeBanner: false,
<<<<<<< HEAD
            
            // --- 4. CHOOSE THE CORRECT STARTING SCREEN ---
            home: isLoggedIn && userId != 0
                ? MainNavigationScreen(userId: userId) // If logged in, go to main app
                : const WelcomeScreen(),               // If not, go to welcome screen
            // -----------------------------------------

=======

            // --- 4. CHOOSE THE CORRECT STARTING SCREEN ---
            home: isLoggedIn && userId != 0
                ? MainNavigationScreen(
                    userId: userId,
                  ) // If logged in, go to main app
                : const WelcomeScreen(), // If not, go to welcome screen

            // -----------------------------------------
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
            theme: TAppTheme.lightTheme,
            darkTheme: TAppTheme.darkTheme,
            themeMode: themeProvider.themeData.brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark,
          );
        },
      ),
    );
  }
}