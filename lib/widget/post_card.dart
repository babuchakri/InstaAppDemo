import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        child: CachedNetworkImage(
          imageUrl: snap['postUrl'],
          fit: BoxFit.contain, // Adjust the fit to contain to maintain aspect ratio
          width: double.infinity,
          placeholder: (context, url) => SizedBox.shrink(), // Empty SizedBox as placeholder
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
