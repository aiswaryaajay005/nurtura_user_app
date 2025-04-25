// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:user_app/main.dart';

class ChatPage extends StatefulWidget {
  final String staffId;
  final String staffName;

  const ChatPage({super.key, required this.staffId, required this.staffName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  RealtimeChannel? _channel; // Made nullable to handle initialization
  List<Map<String, dynamic>> _messages = [];
  final _scrollController = ScrollController();
  String? _parentId; // Store the logged-in parent's ID
  bool _isLoadingMessages = true; // Track loading state for messages

  @override
  void initState() {
    super.initState();
    print(
        'ChatPage initialized with staffId: ${widget.staffId}, staffName: ${widget.staffName}');
    _parentId = supabase.auth.currentUser?.id; // Get the logged-in parent's ID
    if (_parentId == null) {
      print('Error: No authenticated user found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No authenticated user found')),
        );
      }
      return;
    }
    print('Logged-in parent ID: $_parentId');
    _setupRealtimeListener();
    _loadInitialMessages();
  }

  /// Sets up a Realtime subscription to listen for new messages
  void _setupRealtimeListener() {
    _channel = supabase.channel('chat_${widget.staffId}_$_parentId');

    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tbl_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'staff_id',
        value: widget.staffId,
      ),
      callback: (payload) {
        final newMessage = payload.newRecord;
        final isFromParent = newMessage['is_from_parent'] ?? true;
        final senderId = isFromParent
            ? newMessage['parent_sender_id']
            : newMessage['staff_sender_id'];
        final parentId = newMessage['parent_id'];

        // Only add the message if it involves the logged-in parent
        if (isFromParent && senderId == _parentId) {
          print('New message from parent (self): $newMessage');
          setState(() {
            print(
                'Adding message to list. Total messages: ${_messages.length + 1}');
            _messages.add(newMessage);
            _scrollToBottom();
          });
        } else if (!isFromParent &&
            senderId == widget.staffId &&
            parentId == _parentId) {
          print('New message from staff to this parent: $newMessage');
          setState(() {
            print(
                'Adding message to list. Total messages: ${_messages.length + 1}');
            _messages.add(newMessage);
            _scrollToBottom();
          });
        } else {
          print('Message does not involve this parent: $newMessage');
        }
      },
    );

    _channel!.subscribe((status, [error]) {
      if (status == 'SUBSCRIBED') {
        print(
            'Successfully subscribed to channel: chat_${widget.staffId}_$_parentId');
      } else if (error != null) {
        print('Failed to subscribe: $error');
      }
    });
  }

  /// Loads initial messages for the chat
  Future<void> _loadInitialMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      print(
          'Loading messages for staff ${widget.staffId} and parent $_parentId');
      final response = await supabase
          .from('tbl_messages')
          .select()
          .eq('staff_id', widget.staffId)
          .order('created_at', ascending: true);

      print('Raw messages for staff ${widget.staffId}: $response');

      // Filter messages to only include those involving the logged-in parent
      final filteredMessages = (response as List).where((message) {
        final isFromParent = message['is_from_parent'] ?? true;
        if (isFromParent) {
          final matchesParent = message['parent_sender_id'] == _parentId;
          print(
              'Message from parent: ${message['content']}, matches parent $_parentId: $matchesParent');
          return matchesParent;
        } else {
          final matchesStaff = message['staff_sender_id'] == widget.staffId;
          final matchesParent = message['parent_id'] == _parentId;
          print(
              'Message from staff: ${message['content']}, matches staff ${widget.staffId}: $matchesStaff, matches parent $_parentId: $matchesParent');
          return matchesStaff && matchesParent;
        }
      }).toList();

      setState(() {
        _messages = List<Map<String, dynamic>>.from(filteredMessages);
        print('Loaded initial messages: ${_messages.length}');
        print('Filtered messages: $_messages');
        _isLoadingMessages = false;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoadingMessages = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  /// Scrolls the chat to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Sends a message to the staff
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    print('Sending message with staff_id: ${widget.staffId}');
    try {
      if (_parentId == null) {
        throw Exception('No authenticated user found');
      }

      print('Parent ID: $_parentId');
      print('Staff ID: ${widget.staffId}');

      final response = await supabase
          .from('tbl_messages')
          .insert({
            'staff_id': widget.staffId,
            'parent_sender_id': _parentId,
            'content': _messageController.text.trim(),
            'is_from_parent': true,
          })
          .select()
          .single();

      print('Inserted message: $response');

      _messageController.clear();
      setState(() {
        _messages.add(response);
        _scrollToBottom();
      });
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  /// Formats the timestamp to a readable format (e.g., "10:15 PM" or "Mar 24, 10:15 PM")
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown time';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return DateFormat('h:mm a').format(dateTime); // e.g., "10:15 PM"
      } else {
        return DateFormat('MMM d, h:mm a')
            .format(dateTime); // e.g., "Mar 24, 10:15 PM"
      }
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Invalid time';
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Chat with ${widget.staffName}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isFromParent =
                              message['is_from_parent'] ?? true;
                          final timestamp =
                              _formatTimestamp(message['created_at']);

                          return Align(
                            alignment: isFromParent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Column(
                                crossAxisAlignment: isFromParent
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isFromParent
                                          ? Colors.deepPurple
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message['content'],
                                      style: TextStyle(
                                        color: isFromParent
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timestamp,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
