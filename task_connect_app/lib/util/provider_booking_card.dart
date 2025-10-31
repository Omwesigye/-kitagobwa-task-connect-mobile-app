import 'package:flutter/material.dart';
import 'package:task_connect_app/models/booking_model.dart';

class ProviderBookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onComplete;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onDecline,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerName = booking.user?['name'] ?? 'Customer'; // Get customer name

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking with: $customerName',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, '${booking.date} at ${booking.time}'),
            _buildInfoRow(Icons.location_on, booking.location),
            _buildInfoRow(Icons.work, booking.service),
            const Divider(height: 24),
            _buildStatusButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context) {
    String status = booking.providerStatus.toLowerCase();

    if (status == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: onDecline,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    if (status == 'accepted') {
      return Center(
        child: ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Mark as Complete', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // For 'completed' or 'declined'
    return Center(
      child: Text(
        'Status: ${booking.providerStatus.toUpperCase()}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: status == 'completed' ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
