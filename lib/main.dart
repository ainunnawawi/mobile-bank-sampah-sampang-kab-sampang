import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'screens/auth/login_screen.dart'; // Pastikan import ini sesuai lokasi file kamu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAJUANG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundPage,
        primaryColor: AppColors.primarySage,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primarySage,
          primary: AppColors.primarySage,
          secondary: AppColors.accentYellow,
          surface: AppColors.backgroundPage,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primarySage,
          elevation: 0,
          foregroundColor: AppColors.textDark,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textDark),
        ),
      ),
      home: LoginScreen(), // <--- const sudah dihapus di sini
    );
  }
}