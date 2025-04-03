import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    messages.add({"role": "user", "text": message});
    notifyListeners();

    String response = await _geminiService.getChatResponse(message);
    messages.add({"role": "bot", "text": response});
    notifyListeners();
  }
}
