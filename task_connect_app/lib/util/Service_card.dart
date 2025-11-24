import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/api_config.dart';

class ServiceCard extends StatelessWidget {
  final String providerImagePath;
  final String name;
  final String service;
  final String rating;

  const ServiceCard({
    super.key,
    required this.providerImagePath,
    required this.name,
    required this.service,
    required this.rating,
  });

  String _getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    // If it's already a full URL, normalize it for the current platform
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return _normalizeUrl(imagePath);
    }
    
    // For relative paths from Laravel (e.g., "storage/provider-photos/abc.jpg")
    // Just prepend the base URL
    return '${ApiConfig.publicBaseUrl}/$imagePath';
  }

  // Normalize URLs to work with current platform
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
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    final String imageUrl = _getImageUrl(providerImagePath);

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: imageUrl.isEmpty
                ? Container(
                    height: 120,
                    width: double.infinity,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: subTextColor,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ SERVICE CARD - Image load error: $error');
                      print('❌ SERVICE CARD - Attempted URL: $imageUrl');
                      return Container(
                        height: 120,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 30,
                              color: subTextColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Failed to load',
                              style: TextStyle(
                                fontSize: 10,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 120,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Name
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Service
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, right: 8),
            child: Text(
              service,
              style: TextStyle(color: subTextColor, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // Rating
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(rating, style: TextStyle(fontSize: 12, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}