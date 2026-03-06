import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comic_app/auth_gate.dart';
import 'package:comic_app/screens/main_screen.dart';
import 'package:comic_app/theme/theme_provider.dart';
import 'package:comic_app/user/login_page.dart';
import 'package:comic_app/theme/app_colors.dart';
import 'package:comic_app/user/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  runApp(
    ChangeNotifierProvider(create: (_) => themeProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.themeMode,
    );
  }
}
