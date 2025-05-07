import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firma ve Not Yönetimi',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DashboardPage(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
