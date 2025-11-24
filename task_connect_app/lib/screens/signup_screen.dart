import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController ninController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedRole = 'user';
  bool agreePersonalData = true;
  bool isLoading = false;
  List<XFile> selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRole == 'service_provider' && selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one work image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final String apiUrl = kIsWeb
        ? "http://127.0.0.1:8000/api/register"
        : "http://10.0.2.2:8000/api/register";

    try {
      http.Response response;

      if (selectedRole == 'service_provider' && selectedImages.isNotEmpty) {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields['name'] = fullNameController.text.trim();
        request.fields['email'] = emailController.text.trim();
        request.fields['password'] = passwordController.text.trim();
        request.fields['role'] = selectedRole;
        request.fields['service'] = serviceController.text.trim();
        request.fields['nin'] = ninController.text.trim();
        request.fields['telnumber'] = phoneController.text.trim();
        request.fields['description'] = descriptionController.text.trim();
        request.fields['location'] = locationController.text.trim();

        for (var image in selectedImages) {
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            request.files.add(http.MultipartFile.fromBytes(
              'images[]',
              bytes,
              filename: path.basename(image.path),
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              'images[]',
              image.path,
            ));
          }
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final Map<String, dynamic> body = {
          'name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'role': selectedRole,
        };

        response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        );
      }

      if (!mounted) return;

      if (response.statusCode == 201) {
        String message = 'Registration successful';
        try {
          final data = jsonDecode(response.body);
          message = data['message'] ?? message;
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SigninScreen()),
            );
          }
        });
      } else {
        String errorMessage = 'Registration failed';
        try {
          final data = jsonDecode(response.body);
          if (data['errors'] != null) {
            errorMessage = data['errors'].values.first[0];
          } else {
            errorMessage = data['message'] ?? errorMessage;
          }
        } catch (_) {
          errorMessage = 'Registration failed (${response.statusCode})';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to $apiUrl. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                Text(
                  "Sign Up",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
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
                              labelText: 'Register as',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'user', child: Text('User')),
                              DropdownMenuItem(
                                  value: 'service_provider',
                                  child: Text('Service Provider')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => selectedRole = val);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Full Name
                          TextFormField(
                            controller: fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Enter Full Name' : null,
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
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Enter Email' : null,
                          ),
                          const SizedBox(height: 20),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Enter Password' : null,
                          ),
                          const SizedBox(height: 20),

                          // Service Provider Fields
                          if (selectedRole == 'service_provider') ...[
                            TextFormField(
                              controller: locationController,
                              decoration: InputDecoration(
                                labelText: 'Location',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter Location' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: serviceController,
                              decoration: InputDecoration(
                                labelText: 'Service Type',
                                prefixIcon: const Icon(Icons.work),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter Service Type' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: ninController,
                              decoration: InputDecoration(
                                labelText: 'NIN',
                                prefixIcon: const Icon(Icons.badge),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter NIN' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter Phone Number' : null,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                prefixIcon: const Icon(Icons.description),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter Description' : null,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 20),

                            // Images Upload
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: pickImages,
                                  icon: const Icon(Icons.add_photo_alternate),
                                  label: const Text('Select Images'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                if (selectedImages.isNotEmpty)
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: selectedImages.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: FutureBuilder<Uint8List?>(
                                                  future: selectedImages[index]
                                                      .readAsBytes(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState ==
                                                            ConnectionState.done &&
                                                        snapshot.hasData) {
                                                      return Image.memory(
                                                        snapshot.data!,
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      );
                                                    }
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: InkWell(
                                                  onTap: () => removeImage(index),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Agree checkbox
                          Row(
                            children: [
                              Checkbox(
                                  value: agreePersonalData,
                                  onChanged: (val) =>
                                      setState(() => agreePersonalData = val ?? false)),
                              const Expanded(
                                child: Text(
                                  'I agree to the processing of personal data',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Submit button
                          isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: agreePersonalData ? registerUser : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Already have an account? Sign In",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 48, 144, 189),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
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
