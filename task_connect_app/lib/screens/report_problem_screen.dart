// lib/screens/report_problem_screen.dart

// --- 1. ADD THESE IMPORTS ---
import 'dart:convert';
import 'package:http/http.dart' as http;
// --------------------------

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportProblemPage extends StatefulWidget {
  final int userId;
  final VoidCallback onReportSubmitted; 

  const ReportProblemPage({
    super.key, 
    required this.userId,
    required this.onReportSubmitted,
  });

  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'power';
  String _selectedUrgency = 'medium';
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitProblem(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String apiUrl = kIsWeb
        ? "http://127.0.0.1:8000/api/reports" // For Web
        : "http://10.0.2.2:8000/api/reports"; // For Android Emulator
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['user_id'] = widget.userId.toString();
      request.fields['category'] = _selectedCategory;
      request.fields['urgency'] = _selectedUrgency;
      request.fields['description'] = _descriptionController.text;

      if (_imageFile != null) {
        if (kIsWeb) {
          var bytes = await _imageFile!.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: _imageFile!.name,
          );
          request.files.add(multipartFile);
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              _imageFile!.path,
            ),
          );
        }
      }
      
      request.headers['Accept'] = 'application/json';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Problem reported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (mounted) {
          widget.onReportSubmitted(); // Call the function to switch tabs
        }

      } else {
        String errorMessage = 'Failed to submit report';
        try {
          final responseBody = jsonDecode(response.body);
          errorMessage = responseBody['message'] ?? 'Failed to submit report';
        } catch (e) {
          errorMessage = 'Failed to submit report (${response.statusCode})';
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection Error: Cannot connect to $apiUrl. $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Problem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Estate Problem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let estate management know about issues in the community',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // Problem Category
              Text(
                'Problem Type',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'power',
                    child: Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Power Outage'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'water',
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Water Supply'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'garbage',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Garbage Collection'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'security',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Security Issue'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Row(
                      children: [
                        Icon(Icons.miscellaneous_services, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Other'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Urgency Level
              Text(
                'Urgency Level',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedUrgency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('Low - Can wait a few days'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Medium - Needs attention soon'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('High - Urgent attention needed'),
                  ),
                  DropdownMenuItem(
                    value: 'emergency',
                    child: Text('Emergency - Immediate action required'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUrgency = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Problem Description
              Text(
                'Problem Description',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe the problem in detail...\n• When did it start?\n• How is it affecting you?\n• Any specific location?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the problem';
                  }
                  if (value.length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Photo Upload (Optional)
              InkWell(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile == null
                      ? Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo (Optional)',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take a photo of the problem',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  )
                      : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _submitProblem(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}