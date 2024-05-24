import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'individual_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('conversations').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final members = conversation['members'] as List<dynamic>;

              // Check if the current user is a part of this conversation
              if (members.contains(widget.currentUserId)) {
                final otherUserId = members.firstWhere((id) => id != widget.currentUserId);
                return ListTile(
                  title: Text('Conversation with $otherUserId'), // You can display other user's name here
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IndividualChatScreen(uid: otherUserId, currentUserId: '',)),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
