import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http; // We no longer need this
import 'package:task_connect_app/models/service_provider.dart';
// import 'package:task_connect_app/models/booking_model.dart'; // We don't need this model here
// --- 1. IMPORT YOUR API SERVICE ---
import 'package:task_connect_app/services/api_service.dart'; 
// ---------------------------------

class BookPage extends StatefulWidget {
  final ServiceProviderModel provider;
  final int userId; // This is the CUSTOMER'S ID

  const BookPage({super.key, required this.provider, required this.userId});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  // --- 2. GET THE BASE URL (for images) ---
  String get _baseUrl {
    return kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
  }
  // ------------------------------------

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

  // --- 3. REPLACE YOUR _confirmBooking FUNCTION ---
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

    try {
      // Call the ApiService to create the booking
      // This now sends the auth token automatically
      await ApiService.createBooking(
        // 'userId' is now handled by the token in your Laravel backend
        providerId: widget.provider.id,
        providerName: widget.provider.name,
        providerImageUrl: widget.provider.images.isNotEmpty
            ? widget.provider.images[0]
            : '',
        service: widget.provider.service,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        time: _formatTimeOfDay(_selectedTime!),
        location: _locationController.text,
      );

      if (!mounted) return; 

      // Show success dialog
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
    } catch (e) {
      if (!mounted) return;
      // Show error from ApiService
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red,));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // -------------------------------------------------

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
            
            // --- 4. FIX IMAGE URL ---
            if (provider.images.isNotEmpty)
              Image.network(
                provider.images[0].startsWith('http')
                  ? provider.images[0]
                  // Use _baseUrl to construct the full URL
                  : '$_baseUrl/storage/${provider.images[0]}',
                height: 150, 
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, color: Colors.grey[400]),
                ),
              ),
            // ------------------------

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
    // Format to HH:MM:SS
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }
}

