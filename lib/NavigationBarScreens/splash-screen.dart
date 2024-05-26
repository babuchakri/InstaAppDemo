import 'package:flutter/material.dart';
import 'package:login_form_one/LoginScreen.dart';
import 'package:login_form_one/responsive/mobile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/images/img.png', // Replace this with your image path
              width: 300, // Adjust width as needed
              height: 300, // Adjust height as needed
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
            const SizedBox(height: 20), // Optional: Add spacing between image and other widgets
            // Add other widgets like text or buttons if needed
          ],
        ),
      ),
    );
  }
}
