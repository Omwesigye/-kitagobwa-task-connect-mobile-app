// lib/screens/bookings.dart

import 'package:flutter/material.dart';
import 'package:task_connect_app/models/booking_model.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/util/booking_card.dart';
// We don't need rate_booking_screen.dart anymore
// import 'package:task_connect_app/screens/rate_booking_screen.dart'; 

class BookingsScreen extends StatefulWidget {
  final int userId; // Pass the current user id
  const BookingsScreen({super.key, required this.userId});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<BookingModel> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedBookings = await ApiService.fetchBookings(widget.userId);
      setState(() {
        bookings = fetchedBookings;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        // --- ADD REFRESH BUTTON ---
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.book_online, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      // --- UPDATE HOW YOU CALL BookingsCard ---
                      return BookingsCard(
                        // Pass all the data
                        bookingId: b.id!,
                        providerId: b.providerId,
                        userId: widget.userId,
                        onRatingSubmitted: _fetchBookings, // Pass the refresh function

                        // Original data
                        providerName: b.providerName,
                        service: b.service,
                        providerImageUrl: b.providerImageUrl,
                        date: b.date,
                        time: b.time,
                        userStatus: b.userStatus,
                        providerStatus: b.providerStatus,
                      );
                    },
                  ),
                ),
    );
  }
}