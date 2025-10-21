import 'package:flutter/material.dart';

class BookingsCard extends StatefulWidget {
  final String providerName;
  final String service;
  final String providerImageUrl;
  final String date;
  final String time;
  final String userStatus;
  final String providerStatus;

  const BookingsCard({
    super.key,
    required this.providerName,
    required this.service,
    required this.providerImageUrl,
    required this.date,
    required this.time,
    required this.userStatus,
    required this.providerStatus,
  });

  @override
  State<BookingsCard> createState() => _BookingsCardState();
}

class _BookingsCardState extends State<BookingsCard> {
  bool _isCompleted = false;
  double _rating = 3.0;
  String _report = "";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.providerImageUrl),
                  onBackgroundImageError: (_, __) =>
                      const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.providerName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.service,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${widget.date}  Time: ${widget.time}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User: ${widget.userStatus}, Provider: ${widget.providerStatus}',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.userStatus == 'Completed'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: _isCompleted,
                  onChanged: (val) {
                    setState(() => _isCompleted = val ?? false);
                  },
                ),
              ],
            ),

            // Expanded Section: Report & Rating
            AnimatedCrossFade(
              crossFadeState: _isCompleted
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report any issues:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describe any problems...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => _report = val,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rate their work:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _rating.toStringAsFixed(1),
                            value: _rating,
                            onChanged: (value) {
                              setState(() => _rating = value);
                            },
                          ),
                        ),
                        Text(_rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
