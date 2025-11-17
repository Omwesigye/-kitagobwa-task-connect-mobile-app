import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_connect_app/main_navigation_screen.dart';
import 'package:task_connect_app/screens/admin_home.dart';
import 'package:task_connect_app/screens/provider_navigation_screen.dart';


class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // --- 1. ADD THESE MISSING VARIABLE DECLARATIONS ---
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController loginCodeController = TextEditingController();

  String selectedRole = 'user';
  bool hidePassword = true;
  bool isLoading = false;
  // ---------------------------------------------------

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Add mounted check
    if (!mounted) return;
    setState(() => isLoading = true);

    final Map<String, dynamic> body = {
      'email': emailController.text.trim(),
      'role': selectedRole,
    };

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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Add mounted check
      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = (jsonDecode(response.body) as Map)
              .cast<String, dynamic>();

          final Map<String, dynamic>? user = data['user'] is Map
              ? (data['user'] as Map).cast<String, dynamic>()
              : null;

          final dynamic rawId = user != null ? user['id'] : null;
          final int? userId = rawId is int
              ? rawId
              : (rawId is num
                    ? rawId.toInt()
                    : (rawId is String ? int.tryParse(rawId) : null));

          final String userRole = (user != null && user['role'] != null)
              ? user['role'].toString()
              : 'user';
          final String? token = data['token'] as String?;

          if (userId == null || token == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed: User data or token missing'),
              ),
            );
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userRole', userRole);
          await prefs.setString('auth_token', token);
          await prefs.setString('user_id', userId.toString());

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful as $userRole')),
          );

          if (userRole == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminHome()),
              (route) => false,
            );
          } else if (userRole == 'service_provider') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => ProviderNavigationScreen(userId: userId),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainNavigationScreen(userId: userId),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid response from server. Please check your connection.',
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        String errorMessage = 'Login failed';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Login failed';
        } catch (_) {
          errorMessage = 'Login failed (${response.statusCode})';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to $apiUrl: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB3E5FC), Color.fromARGB(255, 170, 198, 218)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Sign In",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Card container
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Role selection
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Login as',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('User')),
                              DropdownMenuItem(value: 'service_provider', child: Text('Service Provider')),
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => selectedRole = val);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Enter your email';
                              if (!value.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password for user/admin
                          if (selectedRole == 'user' || selectedRole == 'admin') ...[
                            TextFormField(
                              controller: passwordController,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePassword ? Icons.visibility_off : Icons.visibility,
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
                            const SizedBox(height: 20),
                          ],

                          // Login code for service provider
                          if (selectedRole == 'service_provider') ...[
                            TextFormField(
                              controller: loginCodeController,
                              decoration: InputDecoration(
                                labelText: 'Login Code',
                                prefixIcon: const Icon(Icons.vpn_key),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter login code' : null,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Sign In button
                          isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: loginUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 144, 189),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
