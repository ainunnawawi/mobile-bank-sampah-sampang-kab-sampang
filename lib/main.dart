import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) async {
      if (uri.scheme == 'sajuang' && uri.host == 'verify-email') {
        final token = uri.queryParameters['token'] ?? '';
        final email = uri.queryParameters['email'] ?? '';

        if (token.isNotEmpty && email.isNotEmpty) {
          final result = await ApiService.verifikasiEmailToken(
            email: email,
            token: token,
          );

          final context = _navigatorKey.currentContext;
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Verifikasi diproses'),
                backgroundColor: result['success'] ? Colors.green : Colors.red,
              ),
            );
          }

          if (result['success']) {
            final savedToken = await ApiService.getToken();
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => savedToken != null
                    ? const DashboardScreen()
                    : const LoginScreen(),
              ),
              (route) => false,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'SAJUANG',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}