import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AdminService {
  final String? token;
  AdminService(this.token);

  Map<String, String> get _baseHeaders => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  Map<String, String> get _jsonHeaders => {
    ..._baseHeaders,
    'Content-Type': 'application/json',
  };

  Future<List<dynamic>> fetchUsers() async =>
      _getList(ApiConfig.getUsers(), 'users');

  Future<List<dynamic>> fetchPendingProviders() async =>
      _getList(ApiConfig.adminPendingProviders(), 'pending providers');

  Future<List<dynamic>> fetchAllProviders() async =>
      _getList(ApiConfig.getAllProviders(), 'all providers');

  Future<List<dynamic>> fetchBookings() async =>
      _getList(ApiConfig.getBookings(), 'bookings');

  Future<List<dynamic>> fetchReports() async =>
      _getList(ApiConfig.adminReports(), 'reports');

  

  Future<void> deleteUser(int id) async =>
      _postOrDelete(ApiConfig.deleteUser(id), 'DELETE');

  Future<void> deleteProvider(int id) async =>
      _postOrDelete(ApiConfig.deleteProvider(id), 'DELETE');

  Future<void> approveProvider(int id) async =>
      _postOrDelete(ApiConfig.adminApproveProvider(id), 'POST');

  Future<void> updateBookingStatus(int id, String status) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.updateBookingStatus(id)),
        headers: _jsonHeaders,
        body: json.encode({'status': status}),
      );
      if (res.statusCode != 200)
        throw Exception('Failed to update booking status');
    } catch (e) {
      print("Error updating booking status: $e");
      rethrow;
    }
  }

  // -------------------- Helper Methods --------------------
  Future<List<dynamic>> _getList(String url, String type) async {
    try {
      final res = await http.get(Uri.parse(url), headers: _baseHeaders);
      if (res.statusCode == 200) return json.decode(res.body);
      throw Exception('Failed to fetch $type');
    } catch (e) {
      print("Error fetching $type: $e");
      return [];
    }
  }

  Future<void> _postOrDelete(String url, String method) async {
    try {
      late http.Response res;
      if (method == 'POST') {
        res = await http.post(Uri.parse(url), headers: _jsonHeaders);
      } else if (method == 'DELETE') {
        res = await http.delete(Uri.parse(url), headers: _baseHeaders);
      }
      if (res.statusCode != 200) throw Exception('Failed to $method $url');
    } catch (e) {
      print("Error $method $url: $e");
      rethrow;
    }
  }
}
