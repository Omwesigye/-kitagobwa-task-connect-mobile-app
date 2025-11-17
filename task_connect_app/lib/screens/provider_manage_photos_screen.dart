import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/screens/api_config.dart';

class ProviderManagePhotosScreen extends StatefulWidget {
  const ProviderManagePhotosScreen({super.key});

  @override
  State<ProviderManagePhotosScreen> createState() =>
      _ProviderManagePhotosScreenState();
}

class _ProviderManagePhotosScreenState
    extends State<ProviderManagePhotosScreen> {
  late Future<List<String>> _photosFuture;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Get the base URL for displaying images
  String get _baseUrl {
    return ApiConfig.publicBaseUrl;
  }

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  // Fetches the list of photo URLs from the API
  void _loadPhotos() {
    _photosFuture = ApiService.getPhotos();
  }

  // Refreshes the list of photos
  void _refreshPhotos() {
    setState(() {
      _photosFuture = ApiService.getPhotos();
    });
  }

  // Handles picking and uploading a new photo
  Future<void> _uploadPhoto() async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return; // User cancelled

    setState(() => _isUploading = true);

    try {
      await ApiService.uploadPhoto(imageFile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: Colors.green),
      );
      _refreshPhotos(); // Refresh the list to show the new photo
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Upload failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // Handles deleting a photo
  Future<void> _deletePhoto(String filename) async {
    try {
      await ApiService.deletePhoto(filename);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Photo deleted successfully!'),
            backgroundColor: Colors.green),
      );
      _refreshPhotos(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Delete failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPhotos,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have not uploaded any photos yet.'));
          }

          final photos = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              // --- THIS IS THE FIX ---
final filename = photos[index];

// Check if the path is from the "New System" (starts with 'provider-photos/')
final bool isNewStorage = filename.startsWith('provider-photos/');

// Build the correct URL based on the system
final String imageUrl = isNewStorage
    ? '$_baseUrl/storage/$filename'  // NEW SYSTEM URL
    : '$_baseUrl/images/$filename';   // OLD SYSTEM URL
// ----------------------

              return Stack(
                fit: StackFit.expand,
                children: [
                  // The Image
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                  // Delete Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: () => _deletePhoto(filename),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      // Floating Action Button to Upload
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadPhoto,
        tooltip: 'Upload Photo',
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_a_photo),
      ),
    );
  }
}
