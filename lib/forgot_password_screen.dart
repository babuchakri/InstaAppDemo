import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _isLoading = false;
        _message = 'Password reset link sent to your email';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password Reset',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Enter your email'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains('Error') ? Colors.red : Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
