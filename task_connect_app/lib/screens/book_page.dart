import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/models/booking_model.dart';

class BookPage extends StatefulWidget {
  final ServiceProviderModel provider;
  final int userId; // Make this non-nullable

  const BookPage({super.key, required this.provider, required this.userId});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  String get _baseUrl => 'http://127.0.0.1:8000'; // Laravel backend URL

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date, time, and enter location'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final booking = BookingModel(
      userId: widget.userId, // PASS userId here
      providerId: widget.provider.id,
      providerName: widget.provider.name ?? 'Unknown',
      providerImageUrl: widget.provider.images.isNotEmpty
          ? widget.provider.images[0]
          : '',
      service: widget.provider.service ?? '',
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      time: _formatTimeOfDay(_selectedTime!),
      location: _locationController.text,
      userStatus: 'pending',
      providerStatus: 'pending',
    );

    try {
      final url = Uri.parse('$_baseUrl/api/bookings');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(
        url,
        body: jsonEncode(booking.toJson()),
        headers: headers,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your booking was successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Scaffold(
      appBar: AppBar(title: Text('Book ${provider.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(provider.service, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            if (provider.images.isNotEmpty)
              Image.network(provider.images[0], height: 150, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(provider.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Enter your location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Select Date'),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedDate != null
                      ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                      : 'No date selected',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickTime,
                  child: const Text('Select Time'),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'No time selected',
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }
}
