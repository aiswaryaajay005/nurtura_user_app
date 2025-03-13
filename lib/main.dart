import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/account.dart';
import 'package:user_app/home_ui.dart';
import 'package:user_app/theme_provider.dart';
import 'package:user_app/user_login.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/userui/main_ui.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://gflbqmzjujxsdbidtyhk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmbGJxbXpqdWp4c2RiaWR0eWhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NDc1MzUsImV4cCI6MjA1MzAyMzUzNX0.Zo7c3j74r5YTwhvwoaE0ukuWs87JyZtWyuVTtn8KTwI',
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MainApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeProvider.themeData,
        home: const MainUi());
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final user = supabase.auth.currentUser;

    if (user != null) {
      // If the user is logged in, navigate to the home page
      return HomeUi();
    } else {
      // If the user is not logged in, navigate to the login page
      return MainUi();
    }
  }
}
