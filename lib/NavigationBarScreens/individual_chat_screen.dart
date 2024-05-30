import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({Key? key}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSwitched ? Icons.toggle_on : Icons.toggle_off,
        color: _isSwitched ? Colors.green : Colors.red,
        size: 35, // Adjusted the size to match the overall design
      ),
      onPressed: () {
        setState(() {
          _isSwitched = !_isSwitched;
        });
        // Add your toggle button handling logic here
      },
    );
  }
}

class IndividualChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const IndividualChatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      DocumentReference chatDocRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(getChatId(widget.currentUserId, widget.otherUserId));

      await chatDocRef.collection('messages').add({
        'senderId': widget.currentUserId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await chatDocRef.set({
        'participants': [widget.currentUserId, widget.otherUserId],
        'lastMessage': message,
        'lastTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
    }
  }

  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Set color of the icon to white
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0, // Removes default padding for the title
        title: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            var userData = snapshot.data?.data() as Map<String, dynamic>;
            return Row(
              children: [
                CircleAvatar(
                  radius: 15, // Adjust the radius for the profile picture
                  backgroundImage: NetworkImage(userData['photoUrl']),
                ),
                SizedBox(width: 8), // Adjust the width to reduce the gap
                Text(
                  userData['username'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Adjust the font size to match Instagram's username size
                    fontWeight: FontWeight.bold, // Adjust the font weight if needed
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          ToggleButton(), // Use the ToggleButton widget here
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white, // Set color of the icon to white
            ),
            onPressed: () {
              // Add your action here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId(widget.currentUserId, widget.otherUserId))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == widget.currentUserId;

                    return ListTile(
                      title: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
