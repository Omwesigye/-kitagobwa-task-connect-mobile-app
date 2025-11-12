// lib/api_config.dart
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  // Optional compile-time overrides:
  // flutter run -d chrome --dart-define=BACKEND_PUBLIC_BASE=http://localhost/your-path
  // flutter run -d chrome --dart-define=BACKEND_API_BASE=http://localhost/your-path/api
  static const String _overridePublicBase =
      String.fromEnvironment('BACKEND_PUBLIC_BASE', defaultValue: '');
  static const String _overrideApiBase =
      String.fromEnvironment('BACKEND_API_BASE', defaultValue: '');

  static String get baseUrl {
    if (_overrideApiBase.isNotEmpty) return _overrideApiBase;
    // Default: web → localhost:8000/api, android emulator → 10.0.2.2:8000/api
    return kIsWeb ? "http://localhost:8000/api" : "http://10.0.2.2:8000/api";
  }

  // Base URL for non-API public resources like /storage/* (no /api suffix)
  static String get publicBaseUrl {
    if (_overridePublicBase.isNotEmpty) return _overridePublicBase;
    if (kIsWeb) {
      // Prefer localhost for web builds to match common dev servers
      return "http://localhost:8000";
    }
    // On Android emulator use 10.0.2.2; on other platforms (Windows, iOS, macOS)
    // default to localhost. Adjust if accessing from a physical device.
    try {
      if (Platform.isAndroid) {
        return "http://10.0.2.2:8000";
      }
    } catch (_) {
      // Platform may not be available in some contexts; fall through
    }
    return "http://127.0.0.1:8000";
  }

  // -----------------------------
  // AUTH
  // -----------------------------
  static String login() => "$baseUrl/login";
  static String register() => "$baseUrl/register";
  static String logout() => "$baseUrl/logout";

  // -----------------------------
  // ADMIN ROUTES
  // -----------------------------
  // Service Providers
  static String adminPendingProviders() => "$baseUrl/admin/pending-providers";
  static String adminApproveProvider(int id) =>
      "$baseUrl/admin/approve-provider/$id";
  static String getAllProviders() => "$baseUrl/admin/providers";
  static String deleteProvider(int id) => "$baseUrl/admin/providers/$id";

  // Users
  static String getUsers() => "$baseUrl/admin/users";
  static String deleteUser(int id) => "$baseUrl/admin/users/$id";

  // Bookings
  static String getBookings() => "$baseUrl/admin/bookings";
  static String updateBookingStatus(int id) =>
      "$baseUrl/admin/bookings/$id/status";

  // -----------------------------
  // BOOKINGS (Provider & Public)
  // -----------------------------
  static String createBooking() => "$baseUrl/bookings";
  static String deleteBooking(int id) => "$baseUrl/bookings/$id";
  static String acceptBooking(int id) => "$baseUrl/bookings/$id/accept";
  static String declineBooking(int id) => "$baseUrl/bookings/$id/decline";
  static String completeBooking(int id) => "$baseUrl/bookings/$id/complete";
  static String providerBookings() => "$baseUrl/provider/bookings";

  // -----------------------------
  // SERVICE PROVIDERS (Public)
  // -----------------------------
  static String getProviders() => "$baseUrl/service-providers";
  static String providerProfile() => "$baseUrl/provider/profile";
  static String providerPhotos() => "$baseUrl/provider/photos";
  static String providerDeletePhoto() => "$baseUrl/provider/photos/delete";
  static String providerRatings() => "$baseUrl/provider/ratings";

  // -----------------------------
  // CHAT
  // -----------------------------
  static String sendMessage() => "$baseUrl/chat/send";
  static String chatHistory(int userId, int contactId) =>
      "$baseUrl/chat/history/$userId/$contactId";
  static String getConversations() => "$baseUrl/chat/conversations";

  // -----------------------------
  // REPORTS & RATINGS
  // -----------------------------
  static String postReport() => "$baseUrl/reports";
  static String adminReports() => "$baseUrl/admin/reports";
  static String postRating() => "$baseUrl/ratings";

  // -----------------------------
  // UTILITY
  // -----------------------------
  static String showImage(String filename) => "$baseUrl/image/$filename";

  // -----------------------------
  // LIVE LOCATIONS
  // -----------------------------
  static String postLocation() => "$baseUrl/location";
  static String getLocations() => "$baseUrl/locations";
  static String nearbyProviders() => "$baseUrl/providers/nearby";
}
