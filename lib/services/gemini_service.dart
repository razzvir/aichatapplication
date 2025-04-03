import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey =
      "AIzaSyAvnDNMlJglmF0UMTww7FYWZYlkcy11M2w"; // Replace with your API key
  static const String _modelName = "gemini-1.5-flash"; // Use gemini-1.5-flash
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1/models/$_modelName:generateContent";

  Future<String> getChatResponse(String userMessage) async {
    final url = Uri.parse("$_baseUrl?key=$_apiKey");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]["content"]["parts"]?[0]["text"] ??
          "No response from AI";
    } else {
      return "Error: ${response.statusCode} - ${response.body}";
    }
  }
}
