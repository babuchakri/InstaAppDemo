import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comments.dart'; // Update the import path as per your project structure.

class FullPostScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const FullPostScreen({super.key, required this.post});

  @override
  _FullPostScreenState createState() => _FullPostScreenState();
}

class _FullPostScreenState extends State<FullPostScreen> {
  bool isLiked = false;
  int likeCount = 0;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    List<dynamic> likes = widget.post['likes'] ?? [];
    isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);
    likeCount = likes.length;
    _getCommentCount();
  }

  void _getCommentCount() async {
    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post['postId'])
        .collection('comments')
        .get();
    if (mounted) {
      setState(() {
        commentCount = commentsSnapshot.docs.length;
      });
    }
  }

  void _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post['postId']);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
      if (mounted) {
        setState(() {
          isLiked = false;
          likeCount--;
        });
      }
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
      if (mounted) {
        setState(() {
          isLiked = true;
          likeCount++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: CachedNetworkImageProvider(widget.post['profImage']),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.post['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Robotomono',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' · ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _formatTimestamp(widget.post['datePublished']),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.more_horiz, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.post['description'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.post['postUrl'],
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const ImageIcon(
                                  AssetImage('lib/images/comment_three.png'),
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CommentScreen(postId: widget.post['postId']),
                                    ),
                                  );
                                },
                                iconSize: 20,
                              ),
                              Text(
                                '$commentCount',
                                style: const TextStyle(color: Colors.white),
                              ),

                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: _toggleLike,
                                iconSize: 20,
                              ),
                              Text(
                                '$likeCount',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('h:mm a · MMM d, yyyy').format(date);
  }
}
