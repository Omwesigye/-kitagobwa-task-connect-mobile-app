import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/chat_screen.dart';
import 'package:task_connect_app/screens/api_config.dart';

class ProviderCard extends StatelessWidget {
  final String name;
  final String service;
  final String telnumber;
  final String description;
  final List<String> images;
  final double rating;
  final bool isSaved;
  final Function(bool) onSaveToggle;
  final VoidCallback onBook;
  final int loggedInUserId;
  final int providerUserId;
  final String providerName;

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
    required this.loggedInUserId,
    required this.providerUserId,
    required this.providerName,
  });

  void _openChat(BuildContext context) {
    if (providerUserId == 0) {
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

  String _getImageUrl(String imageUrl) {
    // If it's already a full URL, normalize it for the current platform
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return _normalizeUrl(imageUrl);
    }
    
    // For relative paths from Laravel (e.g., "storage/provider-photos/abc.jpg")
    // Just prepend the base URL
    return '${ApiConfig.publicBaseUrl}/$imageUrl';
  }

  // Normalize URLs to work with current platform (Android uses 10.0.2.2, Web uses localhost)
  String _normalizeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final host = uri.host.toLowerCase();
    
    // Replace localhost/127.0.0.1/10.0.2.2 with the correct host for this platform
    if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
      final base = Uri.parse(ApiConfig.publicBaseUrl);
      return Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: uri.path,
        query: uri.query.isEmpty ? null : uri.query,
      ).toString();
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
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
                print('❌ Image load error: $error');
                print('❌ Attempted URL: ${_getImageUrl(images[0])}');
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image failed to load',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
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
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.phone,
                      color: theme.colorScheme.onSurface,
                      size: 16,
                    ),
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
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => _openChat(context),
                  tooltip: 'Chat with $name',
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => onSaveToggle(!isSaved),
                  tooltip: 'Save Provider',
                ),
                ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}