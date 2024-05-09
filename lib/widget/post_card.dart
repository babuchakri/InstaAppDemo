import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.black,
        elevation: 5, // Increase elevation for a lifted effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        shadowColor: Colors.grey.withOpacity(1), // Add a slight shadow effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundImage: NetworkImage(snap['profImage']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snap['username'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snap['description'],
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                snap['postUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 350,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up, color: Colors.grey, size: 20),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.comment, color: Colors.grey, size: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border, color: Colors.grey, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
