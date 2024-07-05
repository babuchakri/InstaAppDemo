import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

import '../NavigationBarScreens/profile_screen.dart';
import '../models/comments.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

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
    initializePostData();
  }

  void initializePostData() {
    List<dynamic> likes = widget.snap['likes'] ?? [];
    isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);
    likeCount = likes.length;
    getCommentCount();
  }

  void getCommentCount() async {
    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .get();

    setState(() {
      commentCount = commentsSnapshot.docs.length;
    });
  }

  void toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId']);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }

  void showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: 30,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void navigateToProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: userId,
          currentUserId: FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.black,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => navigateToProfile(context, widget.snap['uid']),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                  CachedNetworkImageProvider(widget.snap['profImage']),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => navigateToProfile(context, widget.snap['uid']),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.snap['username'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontFamily: 'Roboto-mono',
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
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 0),
                Text(
                  widget.snap['description'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 13),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () => showFullScreenImage(context, widget.snap['postUrl']),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.snap['postUrl'],
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                builder: (context) => CommentScreen(
                                    postId: widget.snap['postId']),
                              ),
                            );
                          },
                          iconSize: 20,
                        ),
                        const SizedBox(width: 0),
                        Text(
                          '$commentCount',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 0),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleLike,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 0),
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
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('h:mm a · MMM d, yyyy').format(date);
  }
}
