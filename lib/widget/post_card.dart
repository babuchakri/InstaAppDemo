import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comments.dart'; // Make sure to update the import path as per your project structure.

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    List<dynamic> likes = widget.snap['likes'] ?? [];
    isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);
    likeCount = likes.length;
    _getCommentCount();
  }

  void _getCommentCount() async {
    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
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
    DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']);

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
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: CachedNetworkImageProvider(widget.snap['profImage']),
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
                              text: widget.snap['username'],
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
                              text: _formatTimestamp(widget.snap['datePublished']),
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 0),
                Text(
                  widget.snap['description'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 13),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: widget.snap['postUrl'],
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
                        // Update in PostCard widget
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommentScreen(postId: widget.snap['postId']),
                              ),
                            );
                          },
                          iconSize: 20,
                        ),

                        Text(
                          '$commentCount',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.poll_outlined , color: Colors.grey),
                          onPressed: () {},
                          iconSize: 20,
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.grey),
                      onPressed: () {},
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('h:mm a · MMM d, yyyy').format(date);
  }
}
//hello world