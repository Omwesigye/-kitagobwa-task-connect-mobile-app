import 'package:flutter/material.dart';
import 'package:task_connect_app/models/booking_model.dart';
import 'package:task_connect_app/services/api_service.dart';
import 'package:task_connect_app/util/provider_booking_card.dart';

class ProviderBookingsScreen extends StatefulWidget {
  final int userId;
  const ProviderBookingsScreen({super.key, required this.userId});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.fetchProviderBookings();
  }

  // Refresh the list of bookings
  void _refreshBookings() {
    setState(() {
      _bookingsFuture = ApiService.fetchProviderBookings();
    });
  }

  // Handle the 'Accept' button press
  Future<void> _acceptBooking(int bookingId) async {
    try {
      await ApiService.acceptBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Accepted!'), backgroundColor: Colors.green),
      );
      _refreshBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Handle the 'Decline' button press
  Future<void> _declineBooking(int bookingId) async {
     try {
      await ApiService.declineBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Declined'), backgroundColor: Colors.orange),
      );
      _refreshBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Handle the 'Complete' button press
  Future<void> _completeBooking(int bookingId) async {
     try {
      await ApiService.completeBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Marked as Complete!'), backgroundColor: Colors.blue),
      );
      _refreshBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete: $e'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBookings,
          ),
        ],
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no bookings.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ProviderBookingCard(
                booking: booking,
                onAccept: () => _acceptBooking(booking.id!),
                onDecline: () => _declineBooking(booking.id!),
                onComplete: () => _completeBooking(booking.id!),
              );
            },
          );
        },
      ),
    );
  }
}
