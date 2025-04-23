import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aichatapp/screens/chat_screen.dart';

class HomePage extends StatelessWidget {
  final Function(String) onWallpaperChange;
  final String backgroundImage;

  const HomePage({
    super.key,
    required this.onWallpaperChange,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/robot_bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.65)),

          // Center Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello 👋',
                  style: GoogleFonts.lobster(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome to your AI Chat Assistant!',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Bottom Center Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            backgroundImage: backgroundImage,
                            onWallpaperChange: onWallpaperChange,
                          ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Let’s Chat 🤖',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
