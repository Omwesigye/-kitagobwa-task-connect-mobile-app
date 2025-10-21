import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/screens/welcome_screen.dart';
import 'package:task_connect_app/themes/theme.dart';
import 'package:task_connect_app/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Do not persist login after app kill
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Connect App',
            debugShowCheckedModeBanner: false,
            home: const WelcomeScreen(),
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
