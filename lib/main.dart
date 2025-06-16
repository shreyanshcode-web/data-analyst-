import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/auth/login_page.dart';
import 'theme/modern_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ModernTheme.darkTheme,
      home: const LoginPage(),
    );
  }
}
