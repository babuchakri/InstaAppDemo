import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_form_one/providers/user_provider.dart';
import 'package:login_form_one/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _showImageError = false;
  bool _showSuccessMessage = false;

  void postImage(String uid, String username, String profImage) async {
    if (_file == null) {
      setState(() {
        _showImageError = true;
        _showSuccessMessage = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showImageError = false;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );

      if (res == "success") {
        setState(() {
          _isLoading = false;
          _showSuccessMessage = true;
        });
        _descriptionController.clear();
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
          _showSuccessMessage = false;
        });
        _showImageError = true;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showImageError = true;
        _showSuccessMessage = false;
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  Future<void> _selectImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _file = bytes;
        _showImageError = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: clearImage,
        ),
        title: Text(
          "new post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => postImage(
              user!.uid,
              user.username,
              user.photoUrl,
            ),
            child: Text(
              "post",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _isLoading ? LinearProgressIndicator() : SizedBox(height: 1),
          SizedBox(height: 10),
          if (_showImageError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Please select an image to post",
                style: TextStyle(color: Colors.red, fontSize: 20,fontWeight: FontWeight.bold),
              ),
            ),
          if (_showSuccessMessage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Posted successfully",
                style: TextStyle(color: Colors.green, fontSize: 20,fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_file != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _file!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.9,
                      ),
                    ),
                  ),
                if (_file == null)
                  GestureDetector(
                    onTap: () => _selectImage(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_file != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                maxLines: 5,
              ),
            ),
        ],
      ),
    );
  }
}
