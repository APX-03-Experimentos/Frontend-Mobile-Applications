import 'package:flutter/material.dart';
import 'package:learnhive_mobile/auth/viewmodels/auth_viewmodel.dart';
import 'package:learnhive_mobile/auth/views/login_view.dart';
import 'package:learnhive_mobile/auth/views/register_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LearnHive Mobile",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginView(),
      routes: {
        '/register': (_) => const RegisterView(),
      },
    );
  }
}