import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/web_inspired_theme.dart';
import 'routes/app_router.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - continues without it if not configured)
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase not configured - continuing without push notifications');
    debugPrint('Error: $e');
  }
  
  // Initialize Notification Service
  try {
    await NotificationService().initialize();
    debugPrint('✅ Notification service initialized');
  } catch (e) {
    debugPrint('⚠️ Notification service initialization failed: $e');
  }
  
  runApp(
    const ProviderScope(
      child: RigCheckApp(),
    ),
  );
}

class RigCheckApp extends ConsumerWidget {
  const RigCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeState.themeMode,
      theme: WebInspiredTheme.lightTheme,
      darkTheme: WebInspiredTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
