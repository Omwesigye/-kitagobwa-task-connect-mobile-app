// lib/util/booking_card.dart

// --- 1. ADD IMPORTS ---
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
// ----------------------

import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/api_config.dart';

class BookingsCard extends StatefulWidget {
  final String providerName;
  final String service;
  final String providerImageUrl;
  final String date;
  final String time;
  final String userStatus;
  final String providerStatus;

  // --- 2. ADD THESE REQUIRED FIELDS ---
  final int bookingId;
  final int providerId;
  final int userId;
  final VoidCallback onRatingSubmitted; // To refresh the list
  // ------------------------------------

  const BookingsCard({
    super.key,
    required this.providerName,
    required this.service,
    required this.providerImageUrl,
    required this.date,
    required this.time,
    required this.userStatus,
    required this.providerStatus,
    // --- 3. ADD TO CONSTRUCTOR ---
    required this.bookingId,
    required this.providerId,
    required this.userId,
    required this.onRatingSubmitted,
  });

  @override
  State<BookingsCard> createState() => _BookingsCardState();
}

class _BookingsCardState extends State<BookingsCard> {
  // --- 4. REMOVE _isCompleted, ADD CONTROLLER & LOADING ---
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  // ---------------------------------------------------

  // --- 5. ADD THE API URL ---
  String get _apiUrl {
    return kIsWeb
        ? "http://127.0.0.1:8000/api"
        : "http://10.0.2.2:8000/api";
  }

  String get _baseUrl {
    // Deprecated in favor of ApiConfig.publicBaseUrl; keep for API text references
    return ApiConfig.publicBaseUrl;
  }
  // -------------------------

  // --- 6. ADD THE SUBMIT RATING FUNCTION ---
  Future<void> _submitRating() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'provider_id': widget.providerId,
          'booking_id': widget.bookingId,
          'rating': _rating.toInt(),
          'comment': _commentController.text.trim(),
        }),
      );

      if (!mounted) return;
      
      if (response.statusCode == 201) {
        try {
          final body = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Call the callback to refresh the bookings list
          widget.onRatingSubmitted();
        } catch (e) {
          // If JSON parsing fails, still show success (the server accepted it)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRatingSubmitted();
        }
      } else {
        String errorMessage = 'Failed to submit review';
        try {
          final body = jsonDecode(response.body);
          errorMessage = body['message'] ?? 'Failed to submit review';
        } catch (e) {
          errorMessage = 'Failed to submit review (${response.statusCode})';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ---------------------------------------

  @override
  Widget build(BuildContext context) {
    // --- 7. CHECK STATUS FROM WIDGET ---
    bool isCompleted = widget.userStatus.toLowerCase() == 'completed' ||
        widget.providerStatus.toLowerCase() == 'completed';
    // ---------------------------------

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
                  // --- 8. FIX IMAGE URL ---
                  backgroundImage: NetworkImage(
                    widget.providerImageUrl.startsWith('http')
                      ? widget.providerImageUrl
                      : '$_baseUrl/storage/${widget.providerImageUrl}'
                  ),
                  onBackgroundImageError: (_, __) =>
                      const Icon(Icons.person, size: 30),
                ),
                // --------------------------
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
                        'Date: ${widget.date}   Time: ${widget.time}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User: ${widget.userStatus}, Provider: ${widget.providerStatus}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // --- 9. REMOVE CHECKBOX ---
              ],
            ),

            // Expanded Section: Report & Rating
            AnimatedCrossFade(
              // --- 10. USE isCompleted VARIABLE ---
              crossFadeState: isCompleted
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              // ----------------------------------
              duration: const Duration(milliseconds: 300),
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate this service:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      // --- 11. USE CONTROLLER ---
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add a public comment... (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    // --- 12. ADD SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Submit Review",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    )
                    // -----------------------------
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