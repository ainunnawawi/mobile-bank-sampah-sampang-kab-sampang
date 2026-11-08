import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variabel Global Key untuk navigasi deep link
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Mendengarkan saat aplikasi dibuka lewat link email (sajuang://create-password)
    _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'sajuang' && uri.host == 'create-password') {
        final token = uri.queryParameters['token'];
        final email = uri.queryParameters['email'];

        // Pindah layar otomatis ke RegisterScreen di Step Buat Password
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
              deepLinkToken: token,
              deepLinkEmail: email,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Menghubungkan GlobalKey
      title: 'SAJUANG',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}