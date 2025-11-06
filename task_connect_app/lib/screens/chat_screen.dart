import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/models/message_model.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int myUserId;
  final int contactUserId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.myUserId,
    required this.contactUserId,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  String get _apiUrl {
    return kIsWeb
        ? "http://127.0.0.1:8000/api"
        : "http://10.0.2.2:8000/api";
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          '$_apiUrl/chat/history/${widget.myUserId}/${widget.contactUserId}');
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          setState(() {
            _messages =
                data.map((json) => MessageModel.fromJson(json)).toList();
            _isLoading = false;
          });
          // Scroll to bottom after messages are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        } catch (e) {
          throw Exception('Invalid JSON response. The server may have returned an HTML error page.');
        }
      } else {
        throw Exception('Failed to load messages (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final url = Uri.parse('$_apiUrl/chat/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'sender_id': widget.myUserId,
          'receiver_id': widget.contactUserId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        try {
          // Add message to list locally for instant UI update
          final newMessage = MessageModel.fromJson(jsonDecode(response.body));
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        } catch (e) {
          throw Exception('Invalid JSON response. The server may have returned an HTML error page.');
        }
      } else {
        throw Exception('Failed to send message (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final bool isSentByMe = message.senderId == widget.myUserId;
                      return _MessageBubble(
                        message: message,
                        isSentByMe: isSentByMe,
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          _isSending
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;

  const _MessageBubble({
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isSentByMe
        ? Theme.of(context).primaryColor
        : Colors.grey[700];
    final textColor = isSentByMe ? Colors.white : Colors.white;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  isSentByMe ? const Radius.circular(12) : Radius.zero,
              bottomRight:
                  isSentByMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: textColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            DateFormat('h:mm a').format(message.createdAt.toLocal()),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
