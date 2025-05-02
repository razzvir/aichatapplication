import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  State<ImageGenerationScreen> createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? imageUrl;
  Uint8List? imageBytes;
  bool isLoading = false;

  Future<void> generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      isLoading = true;
      imageUrl = null;
      imageBytes = null;
    });

    final headers = {
      'Authorization':
          'Bearer vk-3ok3JGjjeXbgsSSGZCu82c0Q7nvC1m5mxSKsuYDO0sVa5',
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.vyro.ai/v2/image/generations'),
    );

    request.fields.addAll({
      'prompt': prompt,
      'style': 'realistic',
      'aspect_ratio': '1:1',
      'seed': '5',
    });

    request.headers.addAll(headers);

    try {
      final response = await request.send();

      final contentType = response.headers['content-type'];

      if (response.statusCode == 200) {
        if (contentType != null && contentType.contains('application/json')) {
          // Response is JSON (expected for Vyro API)
          final responseString = await response.stream.bytesToString();
          final jsonData = jsonDecode(responseString);
          final url = jsonData['image_url'];

          if (url != null) {
            setState(() {
              imageUrl = url;
            });
          } else {
            throw Exception('No image URL found in the response.');
          }
        } else {
          // Response might be raw image (not likely for Vyro)
          final bytes = await response.stream.toBytes();
          setState(() {
            imageBytes = bytes;
          });
        }
      } else {
        throw Exception(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget displayImage;

    if (isLoading) {
      displayImage = const CircularProgressIndicator();
    } else if (imageUrl != null) {
      displayImage = Image.network(imageUrl!);
    } else if (imageBytes != null) {
      displayImage = Image.memory(imageBytes!);
    } else {
      displayImage = const Text("Enter a prompt to generate an image");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Generator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: displayImage)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      hintText: "Enter prompt...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: generateImage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
