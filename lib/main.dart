

import 'package:email_password_login/screens/login_screen.dart';
import 'package:flutter/material.dart';


void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Standard Show',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 35, 77, 26),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
