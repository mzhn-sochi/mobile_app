import 'package:flutter/material.dart';
import 'package:mobile_app/providers/ticket_provider.dart';
import 'package:mobile_app/splash_screen.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
// import 'package:mobile_app/registration.dart';
// import 'package:mobile_app/send_request.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CreateTicketDataModel()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
            useMaterial3: true,
          ),
          home: const SplashScreen(), // const MainPage(), // const RegistrationPage(),
        ));
  }
}
