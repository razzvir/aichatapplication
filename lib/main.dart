import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/chat_provider.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String backgroundImage = "assets/chatapp_wallpaper7.jpg"; // Default wallpaper

  void updateWallpaper(String newWallpaper) {
    setState(() {
      backgroundImage = newWallpaper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
      ),
      home:
          FirebaseAuth.instance.currentUser == null
              ? const LoginScreen() // Show login screen if not logged in
              : HomePage(
                key: ValueKey(
                  backgroundImage,
                ), // Forces widget rebuild when wallpaper changes
                onWallpaperChange: updateWallpaper,
                backgroundImage: backgroundImage,
              ),
    );
  }
}
