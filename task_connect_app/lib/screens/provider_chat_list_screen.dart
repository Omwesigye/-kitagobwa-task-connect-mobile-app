import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart'; // --- 1. ADD THIS ---
import 'chat_screen.dart'; 

// Model for the contact list
class ChatContact {
  final int id;
  final String name;
  final String lastMessage;

  ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
  });

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      id: json['id'],
      name: json['name'],
      lastMessage: json['last_message'] ?? '...',
    );
  }
}


class ProviderChatListScreen extends StatefulWidget {
  final int providerUserId;
  const ProviderChatListScreen({super.key, required this.providerUserId});

  @override
  _ProviderChatListScreenState createState() => _ProviderChatListScreenState();
}

class _ProviderChatListScreenState extends State<ProviderChatListScreen> {
  late Future<List<ChatContact>> _conversations;

  String get _apiUrl {
    return kIsWeb
        ? "http://127.0.0.1:8000/api"
        : "http://10.0.2.2:8000/api";
  }

  @override
  void initState() {
    super.initState();
    _conversations = _fetchConversations();
  }

  // --- 2. UPDATE THIS FUNCTION ---
  Future<List<ChatContact>> _fetchConversations() async {
    // Get the auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Call the new, secure route
    final response = await http.get(
      Uri.parse('$_apiUrl/chat/conversations'), // No User ID in URL
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Send the token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ChatContact.fromJson(json)).toList();
    } else {
      // This will now show the error from the server
      throw Exception('Failed to load conversations: ${response.body}');
    }
  }
  // -----------------------------

  void _openChat(BuildContext context, ChatContact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          myUserId: widget.providerUserId,
          contactUserId: contact.id,
          contactName: contact.name,
        ),
      ),
    ).then((_) {
      // Refresh the list when coming back from a chat
      setState(() {
        _conversations = _fetchConversations();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
        // Add a refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _conversations = _fetchConversations();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<ChatContact>>(
        future: _conversations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // The "Unauthenticated" error will now appear here
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no messages yet.'));
          }

          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(contact.name[0].toUpperCase()),
                ),
                title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(contact.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => _openChat(context, contact),
              );
            },
          );
        },
      ),
    );
  }
}

