import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnhive_mobile/auth/viewmodels/auth_viewmodel.dart';
import 'package:learnhive_mobile/auth/views/login_view.dart';
import 'package:learnhive_mobile/auth/views/register_view.dart';
import 'package:learnhive_mobile/courses/viewmodels/course_viewmodel.dart';
import 'package:learnhive_mobile/courses/views/courses_view.dart';
import 'package:learnhive_mobile/notifications/services/websocket_service.dart';
import 'package:provider/provider.dart';

import 'assignments/viewmodels/assignment_viewmodel.dart';
import 'assignments/viewmodels/submission_viewmodel.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'notifications/bloc/notifications_bloc.dart';
import 'notifications/services/notification_service.dart';
import 'notifications/views/notification_view.dart';

final notificationService = NotificationService();
final webSocketService = WebSocketService();
final notificationsBloc = NotificationsBloc(notificationService, webSocketService);

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // ✅ Usar BlocProvider.value con la instancia ya creada
        BlocProvider.value(value: notificationsBloc),
      ],
      child: MultiProvider(
        providers: [
          // ViewModels
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => CourseViewModel()),
          ChangeNotifierProvider(create: (_) => AssignmentViewModel()),
          ChangeNotifierProvider(create: (_) => SubmissionViewModel()),
          // Theme y Locale
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// MyApp simplificado
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: "LearnHive Mobile",
          navigatorKey: MyApp.navigatorKey,
          theme: ThemeData(primarySwatch: Colors.blue),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          home: const LoginView(),
          routes: {
            '/register': (_) => const RegisterView(),
            '/courses': (_) => const CoursesView(),
            '/notifications': (_) => const NotificationView(),
          },
        );
      },
    );
  }
}
