import 'package:flutter/material.dart';
import 'package:mobile_app/login.dart';
import 'package:mobile_app/main_page.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Check if the app is ready and redirect accordingly
        if (auth.isReady) {
          if (auth.isLoggedIn) {
            return const MainPage();
          } else {
            return const LoginPage();
          }
        }
        // Until the app is ready, show a loading indicator
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
