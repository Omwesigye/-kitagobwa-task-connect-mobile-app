// lib/api_config.dart
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    return kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";
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
}
