import 'package:flutter/material.dart';
// 1. --- ADD CHAT SCREEN IMPORT ---
import 'package:task_connect_app/screens/chat_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For image URL logic

class ProviderCard extends StatelessWidget {
  // Your existing fields
  final String name;
  final String service;
  final String telnumber;
  final String description;
  final List<String> images;
  final double rating;
  final bool isSaved;
  final Function(bool) onSaveToggle;
  final VoidCallback onBook;

  // --- 2. ADD THE NEW FIELDS (from provider_list_screen) ---
  final int loggedInUserId;
  final int providerUserId;
  final String providerName;
  // --------------------------------------------------------

  const ProviderCard({
    super.key,
    required this.name,
    required this.service,
    required this.telnumber,
    required this.description,
    required this.images,
    required this.rating,
    required this.isSaved,
    required this.onSaveToggle,
    required this.onBook,
    // --- 3. ADD TO CONSTRUCTOR ---
    required this.loggedInUserId,
    required this.providerUserId,
    required this.providerName,
  });
  // -----------------------------

  // --- 4. ADD THE NAVIGATION FUNCTION ---
  void _openChat(BuildContext context) {
    if (providerUserId == 0) {
      // This happens if the user_id wasn't in the API response
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find provider to chat with.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          myUserId: loggedInUserId,
          contactUserId: providerUserId,
          contactName: providerName,
        ),
      ),
    );
  }
  // ------------------------------------

  // --- Helper to fix image URLs ---
  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl; // Already a full URL
    }
    // Use platform-aware base URL
<<<<<<< HEAD
    final String baseUrl =
        kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
=======
    final String baseUrl = kIsWeb
        ? "http://127.0.0.1:8000"
        : "http://10.0.2.2:8000";
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
    return '$baseUrl/storage/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This is the new UI layout that includes the chat button
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures image respects the border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (images.isNotEmpty)
            Image.network(
              _getImageUrl(images[0]),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                );
              },
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Text(name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(service,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.primaryColor)),
=======
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
<<<<<<< HEAD
                    Text(rating.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium),
=======
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium,
                    ),
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
                    const SizedBox(width: 12),
                    Icon(Icons.phone, color: theme.iconTheme.color, size: 16),
                    const SizedBox(width: 4),
                    Text(telnumber, style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- 5. THIS IS THE NEW CHAT BUTTON ---
                IconButton(
<<<<<<< HEAD
                  icon: Icon(Icons.chat_bubble_outline,
                      color: theme.primaryColor),
=======
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.primaryColor,
                  ),
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
                  onPressed: () => _openChat(context), // Call the chat function
                  tooltip: 'Chat with $name',
                ),
                // ------------------------------------

                // SAVE BUTTON
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => onSaveToggle(!isSaved),
                  tooltip: 'Save Provider',
                ),

                // BOOK BUTTON
                ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
<<<<<<< HEAD
                  child: const Text('Book Now'),
                ),
              ],
            ),
          )
=======
                  child: const Text('viewDetails'),
                ),
              ],
            ),
          ),
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
        ],
      ),
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
