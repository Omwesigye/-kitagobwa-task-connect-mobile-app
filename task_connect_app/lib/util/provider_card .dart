import 'package:flutter/material.dart';

class ProviderCard extends StatefulWidget {
  final String name;
  final String service;
  final String telnumber;
  final String description;
  final List<String> images;
  final double rating;
  final bool isSaved;
  final ValueChanged<bool> onSaveToggle;
  final VoidCallback onBook;

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
  });

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  bool _isExpanded = false;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor, // adapt to theme
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Circular image + service & name
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.images.isNotEmpty
                        ? NetworkImage(
                            widget.images.first.startsWith('http')
                                ? widget.images.first
                                : 'http://127.0.0.1:8000${widget.images.first}',
                          )
                        : null,
                    child: widget.images.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: theme.iconTheme.color,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(widget.name, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined,
                      color: _isSaved
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() => _isSaved = !_isSaved);
                      widget.onSaveToggle(_isSaved);
                    },
                  ),
                ],
              ),

              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(widget.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Tel: ${widget.telnumber}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: widget.onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
