import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_form_one/LoginScreen.dart';
import 'package:login_form_one/providers/user_provider.dart';
import 'package:login_form_one/responsive/responsive_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDI0VvqY0APEw51IzHOU_6lazWbEiW6XQ8",
      appId: "1:142796807815:android:82af02291424b24a596222",
      messagingSenderId: "142796807815",
      storageBucket: "login-ff2e5.appspot.com",
      projectId: "login-ff2e5",

      // Include other necessary options like authDomain, databaseURL if using authentication.
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: ResponsiveScreen(
        // mobileScreen: MobileScreen(),
        // )
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveScreen(mobileScreen: LoginScreen());
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
