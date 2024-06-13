import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'individual_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  const ChatScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String _searchQuery = '';

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          margin: EdgeInsets.only(left: 0),
          child: Text(
            'Chats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xFF323232),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.white70),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _searchQuery.isEmpty
                  ? chats.where('participants', arrayContains: widget.currentUserId).snapshots()
                  : chats
                  .where('participants', arrayContains: widget.currentUserId)
                  .where('chatName', isGreaterThanOrEqualTo: _searchQuery)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    var chat = chatDocs[index];
                    List<dynamic> participants = chat['participants'];

                    // Ensure participants is a List<String>
                    List<String> participantIds = participants.map((p) => p as String).toList();

                    // Find the other user's ID
                    var otherUserId = participantIds.firstWhere((id) => id != widget.currentUserId);

                    return FutureBuilder(
                      future: getUserInfo(otherUserId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return ListTile(
                            title: Text('Loading...', style: TextStyle(color: Colors.white)),
                          );
                        }

                        var userInfo = userSnapshot.data!;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(userInfo['photoUrl']),
                          ),
                          title: Text(userInfo['username'], style: TextStyle(color: Colors.white)),
                          subtitle: Text(chat['lastMessage'], style: TextStyle(color: Colors.grey)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndividualChatScreen(
                                  currentUserId: widget.currentUserId,
                                  otherUserId: otherUserId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
