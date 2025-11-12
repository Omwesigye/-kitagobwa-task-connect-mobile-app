import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor; // adapts to light/dark
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    // Resolve full image URL - backend should return full URLs, but handle both cases
    final String resolvedImageUrl = () {
      if (providerImagePath.isEmpty) return '';
      
      // If it's already a full URL (starts with http:// or https://), use it directly
      if (providerImagePath.startsWith('http://') || providerImagePath.startsWith('https://')) {
        return _normalizeAbsoluteUrl(providerImagePath);
      }
      
      // If it starts with /storage/, it's a relative path from the backend root
      if (providerImagePath.startsWith('/storage/')) {
        return '${ApiConfig.publicBaseUrl}$providerImagePath';
      }
      
      // If it's a storage path like "provider-photos/...", construct the URL
      if (providerImagePath.contains('provider-photos/') || providerImagePath.contains('reports/')) {
        return '${ApiConfig.publicBaseUrl}/storage/$providerImagePath';
      }
      
      // Legacy: if it's just a filename, try the public/images path
      return '${ApiConfig.publicBaseUrl}/storage/$providerImagePath';
    }();

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
            child: resolvedImageUrl.isEmpty
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
                    resolvedImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: subTextColor,
                      ),
                    ),
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

String _normalizeAbsoluteUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return url;
  }

  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host == '127.0.0.1') {
    final base = Uri.parse(ApiConfig.publicBaseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: uri.path,
      query: uri.query.isEmpty ? null : uri.query,
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    ).toString();
  }

  return url;
}
