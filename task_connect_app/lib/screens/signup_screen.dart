import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController ninController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  // --- 1. ADD LOCATION CONTROLLER ---
  final TextEditingController locationController = TextEditingController();

  String selectedRole = 'user';
  bool agreePersonalData = true;

  Future<void> registerUser() async {
    if (!_formSignupKey.currentState!.validate()) return;
    if (!mounted) return;

    final String apiUrl = kIsWeb
        ? "http://127.0.0.1:8000/api/register" // For Web
        : "http://10.0.2.2:8000/api/register"; // For Android Emulator

    try {
      final uri = Uri.parse(apiUrl); 

      // --- 2. UPDATE THE BODY TO MATCH YOUR AuthController ---
      final Map<String, dynamic> body = {
        'name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'role': selectedRole,
      };

      if (selectedRole == 'service_provider') {
        body.addAll({
          'service': serviceController.text.trim(),
          'nin': ninController.text.trim(),
          'telnumber': phoneController.text.trim(), // Fix: was 'phone'
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(), // Fix: was missing
        });
      }
      // ---------------------------------------------------

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);

      // --- 3. UPDATE SUCCESS LOGIC ---
      // Your backend returns 201 on success
      if (response.statusCode == 201) {
        
        final message = data['message'] ?? 'Registration successful.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
        
        // As per your AuthController, all users go back to login
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
             // Go to SigninScreen to login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SigninScreen()),
            );
          }
        });

      } else {
        // Handle validation errors from Laravel
        String errorMessage = data['message'] ?? 'Registration failed';
        if (data['errors'] != null) {
           // Get the first error from the list
           errorMessage = data['errors'].entries.first.value[0];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error connecting to $apiUrl. $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔽 Choose Role
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'service_provider',
                            child: Text('Service Provider'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Register As',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Full Name
                      TextFormField(
                        controller: fullNameController,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter Full Name' : null,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: emailController,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter Email' : null,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter Password' : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Additional fields if service provider
                      if (selectedRole == 'service_provider') ...[
                        const SizedBox(height: 20),
                        // --- 4. ADD LOCATION FIELD ---
                        TextFormField(
                          controller: locationController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter your location (e.g., Makerere)' : null,
                          decoration: InputDecoration(
                            labelText: 'Your Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // -------------------------
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: serviceController,
                          validator: (value) => value!.isEmpty
                              ? 'Enter the service you provide'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Service Type (e.g., Plumber)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: ninController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter NIN' : null,
                          decoration: InputDecoration(
                            labelText: 'NIN',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: phoneController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter Phone Number' : null,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: descriptionController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter Description' : null,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (val) {
                              setState(() => agreePersonalData = val ?? false);
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the processing of personal data',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (agreePersonalData) {
                              registerUser();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please agree to personal data',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

