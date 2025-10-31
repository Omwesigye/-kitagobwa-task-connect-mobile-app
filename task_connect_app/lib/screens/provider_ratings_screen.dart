import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart' show RatingBarIndicator;
import 'package:intl/intl.dart';
import 'package:task_connect_app/models/rating_model.dart';
import 'package:task_connect_app/services/api_service.dart';

class ProviderRatingsScreen extends StatefulWidget {
  const ProviderRatingsScreen({super.key});

  @override
  State<ProviderRatingsScreen> createState() => _ProviderRatingsScreenState();
}

class _ProviderRatingsScreenState extends State<ProviderRatingsScreen> {
  late Future<Map<String, dynamic>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = ApiService.getProviderRatings();
  }

  // Helper to format the date
  String _formatDate(String date) {
    try {
      return DateFormat.yMMMd().format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings & Reviews'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ratingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not load ratings.'));
          }

          final data = snapshot.data!;
          final double averageRating =
              double.tryParse(data['average_rating'].toString()) ?? 0.0;
          final List<RatingModel> ratings = (data['ratings'] as List)
              .map((item) => RatingModel.fromJson(item))
              .toList();

          return Column(
            children: [
              // --- 1. AVERAGE RATING HEADER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    Text(
                      'Your Average Rating',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 30.0,
                    ),
                  ],
                ),
              ),

              // --- 2. "WHAT PEOPLE ARE SAYING" ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'What People Are Saying',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              
              // --- 3. LIST OF REVIEWS ---
              Expanded(
                child: ratings.isEmpty
                    ? const Center(child: Text('You have no reviews yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          final rating = ratings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rating.user.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _formatDate(rating.createdAt),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  RatingBarIndicator(
                                    rating: rating.rating.toDouble(),
                                    itemBuilder: (context, index) =>
                                        const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 16.0,
                                  ),
                                  if (rating.comment != null &&
                                      rating.comment!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(rating.comment!),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
