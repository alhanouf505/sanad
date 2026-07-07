import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SanadApp());

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سند الساركوما',
      debugShowCheckedModeBanner: false,
      theme: buildSanadTheme(),
      // واجهة عربية من اليمين لليسار
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
