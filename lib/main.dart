import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => ChatProvider(), child: MyApp()),
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
      home: HomePage(
        key: ValueKey(
          backgroundImage,
        ), // Forces widget rebuild when backgroundImage changes
        onWallpaperChange: updateWallpaper,
        backgroundImage: backgroundImage,
      ),
    );
  }
}
