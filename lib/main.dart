import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/create_reminder_screen.dart';
import 'screens/reminder_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/reminder_storage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  await NotificationService.instance.initialize();
  runApp(const ReminderApp());
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      theme: AppTheme.dark,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return _fadeRoute(const CreateReminderScreen(), settings);
          case '/reminder-details':
            // Handle both String (notification payload) and Map (tile tap with id).
            String? message;
            String? reminderId;
            final args = settings.arguments;
            if (args is String) {
              message = args;
            } else if (args is Map) {
              message = args['message'] as String?;
              reminderId = args['id'] as String?;
            }
            return _slideRoute(
              FutureBuilder<String>(
                future: _resolveMessage(message),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  return ReminderDetailScreen(
                    reminderMessage: snapshot.data!,
                    reminderId: reminderId,
                  );
                },
              ),
              settings,
            );
          default:
            return null;
        }
      },
    );
  }

  static Future<String> _resolveMessage(String? payload) async {
    if (payload != null && payload.isNotEmpty) return payload;
    final msg = await ReminderStorage.getLatestMessage();
    return msg ?? 'No reminder found';
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
    );
  }

  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
