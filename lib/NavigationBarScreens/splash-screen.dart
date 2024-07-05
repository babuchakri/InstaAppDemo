import 'package:flutter/material.dart';
import 'package:login_form_one/responsive/mobile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Fix: Key parameter should be 'key' instead of 'super.key'

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  void navigateToNextScreen() async {
    // Delay for 1 second
    await Future.delayed(const Duration(seconds: 2));

    // Check if the widget is still mounted before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileScreen()),
      );
    }
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
              'lib/images/splash.jpg', // Replace this with your image path
              width: 450, // Adjust width as needed
              height: 450, // Adjust height as needed
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
