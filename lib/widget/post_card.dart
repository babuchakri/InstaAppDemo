import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 0.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          snap['postUrl'],
          fit: BoxFit.contain, // Adjust the fit to contain to maintain aspect ratio
          width: double.infinity,
        ),
      ),
    );
  }
}
