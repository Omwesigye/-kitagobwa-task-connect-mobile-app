import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/main_navigation_screen.dart';
<<<<<<< HEAD
import 'package:task_connect_app/screens/provider_navigation_screen.dart'; 
=======
import 'package:task_connect_app/screens/admin_home.dart';
import 'package:task_connect_app/screens/provider_navigation_screen.dart';

>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController loginCodeController = TextEditingController();

  String selectedRole = 'user';
  bool hidePassword = true;
  bool isLoading = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final Map<String, dynamic> body = {
      'email': emailController.text.trim(),
      'role': selectedRole,
    };

    // Admin & user use password, service providers use login code
    if (selectedRole == 'user' || selectedRole == 'admin') {
      body['password'] = passwordController.text.trim();
    } else {
      body['login_code'] = loginCodeController.text.trim();
    }

    final String apiUrl = kIsWeb
        ? "http://127.0.0.1:8000/api/login"
        : "http://10.0.2.2:8000/api/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
<<<<<<< HEAD
        // --- 1. EXTRACT ALL DATA FROM LOGIN ---
        final userId = data['user'] != null ? data['user']['id'] : null;
        final String userRole = data['user'] != null ? data['user']['role'] : 'user';
        final String? token = data['token']; // Get the token
        // ----------------------------------------
=======
        final userId = data['user']?['id'];
        final String userRole = data['user']?['role'] ?? 'user';
        final String? token = data['token'];
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: User data or token missing')),
          );
          return;
        }

<<<<<<< HEAD
        // --- 2. SAVE EVERYTHING TO SharedPreferences ---
=======
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', userRole);
<<<<<<< HEAD
        await prefs.setString('auth_token', token); // ⇐ CRITICAL STEP
        // ---------------------------------------------
=======
        await prefs.setString('auth_token', token);
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful as $userRole')),
        );

<<<<<<< HEAD
        // --- 3. NAVIGATE BASED ON ROLE ---
        if (userRole == 'service_provider') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderNavigationScreen(userId: userId),
            ),
=======
        // Role-based navigation
        if (userRole == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminHome()),
            (route) => false,
          );
        } else if (userRole == 'service_provider') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ProviderNavigationScreen(userId: userId)),
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
<<<<<<< HEAD
            MaterialPageRoute(
              builder: (_) => MainNavigationScreen(userId: userId),
            ),
            (route) => false,
          );
        }
        // ---------------------------------
=======
            MaterialPageRoute(builder: (_) => MainNavigationScreen(userId: userId)),
            (route) => false,
          );
        }
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
<<<<<<< HEAD
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error connecting to $apiUrl. $e')));
=======
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to $apiUrl. $e')),
      );
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Role selection now includes admin
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Login as'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'service_provider', child: Text('Service Provider')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')), // ✅
                ],
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your email';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password for user/admin
              if (selectedRole == 'user' || selectedRole == 'admin')
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter password';
                    if (value.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),

              // Login code for service provider
              if (selectedRole == 'service_provider')
                TextFormField(
                  controller: loginCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Login Code',
                    hintText: 'Enter the code sent to your email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter login code';
                    return null;
                  },
                ),
              const SizedBox(height: 30),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

