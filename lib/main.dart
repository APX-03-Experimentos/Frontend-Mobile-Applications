import 'package:flutter/material.dart';
import 'package:learnhive_mobile/auth/viewmodels/auth_viewmodel.dart';
import 'package:learnhive_mobile/auth/views/login_view.dart';
import 'package:learnhive_mobile/auth/views/register_view.dart';
import 'package:learnhive_mobile/courses/viewmodels/course_viewmodel.dart';
import 'package:learnhive_mobile/courses/views/course_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => CourseViewModel()),
      // Agrega otros ViewModels aquí cuando los crees:
      // ChangeNotifierProvider(create: (_) => AssignmentViewModel()),
      // ChangeNotifierProvider(create: (_) => SubmissionViewModel()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LearnHive Mobile",
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: navigatorKey,
      home: const LoginView(),
      routes: {
        '/register': (_) => const RegisterView(),
        '/courses': (_) => const CourseView(),
      },
    );
  }
}