import 'package:flutter/material.dart';
import 'package:task_connect_app/services/api_service.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() => _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _errorMessage = '';

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _telnumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Fetch the provider's current data
  Future<void> _loadProfile() async {
    try {
      final profileData = await ApiService.getProviderProfile();
      setState(() {
        _nameController.text = profileData['name'] ?? '';
        _emailController.text = profileData['email'] ?? '';
        _locationController.text = profileData['location'] ?? '';
        _telnumberController.text = profileData['telnumber'] ?? '';
        _descriptionController.text = profileData['description'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Save the updated data
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    setState(() => _isLoading = true);

    try {
      // Create a map of the data to send
      Map<String, String> profileData = {
        'name': _nameController.text,
        'location': _locationController.text,
        'telnumber': _telnumberController.text,
        'description': _descriptionController.text,
      };

      await ApiService.updateProviderProfile(profileData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the settings screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (Cannot be changed)',
                        ),
                        readOnly: true, // Email is not editable
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telnumberController,
                        decoration: const InputDecoration(labelText: 'Phone Number (e.g., 07...)'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Your Location (e.g., Kampala)'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your location' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe your services...',
                        ),
                        maxLines: 5,
                        validator: (value) =>
                            value!.length < 10 ? 'Description is too short (min 10 chars)' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
