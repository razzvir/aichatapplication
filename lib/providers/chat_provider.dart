import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<Map<String, dynamic>> _messages = [];

  bool isLoading = false; // ✅ Add this

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  /// Send a text message and get AI response
  Future<void> sendMessage(String message) async {
    addUserMessage(message);

    isLoading = true; // ✅ Start loading animation
    notifyListeners();

    try {
      String response = await _geminiService.getChatResponse(message);
      _messages.add({"role": "bot", "text": response});
    } catch (e) {
      _messages.add({
        "role": "bot",
        "text": "Error: Unable to fetch response.",
      });
    }

    isLoading = false; // ✅ Stop loading animation
    notifyListeners();
  }

  /// Add a user text message to chat
  void addUserMessage(String message) {
    _messages.add({"role": "user", "text": message});
    notifyListeners();
  }

  /// Add a file message (image or PDF)
  void addFileMessage(
    String filePath,
    String name, {
    required bool isImage,
    Uint8List? fileBytes,
  }) {
    _messages.add({
      "role": "user",
      "filePath": filePath,
      "isImage": isImage,
      "isPdf": filePath.endsWith(".pdf"),
    });
    notifyListeners();
  }
}
