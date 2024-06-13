import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  void _postComment() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userName = userDoc['username'];
    final userImage = userDoc['photoUrl'];

    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
        'userId': userId,
        'username': userName,
        'comment': _commentController.text,
        'datePublished': Timestamp.now(),
        'userImage': userImage,
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('datePublished', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var commentSnap = snapshot.data!.docs[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(commentSnap['userImage']),
                      ),
                      title: Text(commentSnap['username']),
                      subtitle: Text(commentSnap['comment']),
                      trailing: Text(DateFormat('h:mm a · MMM d, yyyy').format(commentSnap['datePublished'].toDate())),
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
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
