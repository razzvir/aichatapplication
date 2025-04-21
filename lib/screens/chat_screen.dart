import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
// For web file bytes
import 'dart:io' show File; // Only for mobile
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  final String backgroundImage;
  final Function(String) onWallpaperChange;

  const ChatScreen({
    super.key,
    required this.backgroundImage,
    required this.onWallpaperChange,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(message);
      _messageController.clear();
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      String fileName = result.files.single.name;
      String? filePath;
      Uint8List? fileBytes;

      bool isImage =
          result.files.single.extension == "jpg" ||
          result.files.single.extension == "png";

      if (kIsWeb) {
        // Web: Use bytes instead of path
        fileBytes = result.files.single.bytes;
        filePath = result.files.single.name; // Just use the name for web
      } else {
        // Mobile/Desktop: Use file path
        filePath = result.files.single.path;
      }

      if (filePath != null) {
        Provider.of<ChatProvider>(context, listen: false).addFileMessage(
          filePath,
          fileName,
          isImage: isImage,
          fileBytes: fileBytes,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatProvider = Provider.of<ChatProvider>(context); // ✅ Add this

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI ChatApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(chatProvider.messages[index]);
                },
              ),
            ),
            _buildMessageInput(chatProvider), // ✅ Fix: Pass chatProvider
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.blue),
            onPressed: () => _pickFile(context),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.red,
            ),
            onPressed: _listen,
          ),
          chatProvider.isLoading
              ? const Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color.fromARGB(255, 255, 12, 12),
                  ),
                ),
              )
              : IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: _sendMessage,
              ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    bool isUser = message["role"] == "user";
    bool isLoading = message["loading"] ?? false; // Check if loading
    bool isImage = message["isImage"] ?? false;
    bool isPdf = message["isPdf"] ?? false;
    Uint8List? fileBytes = message["fileBytes"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isUser
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft:
                isUser ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(15),
          ),
          border: const Border(
            bottom: BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                )
                : isImage
                ? kIsWeb
                    ? Image.memory(
                      fileBytes!,
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                    : Image.file(
                      File(message["filePath"]),
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                : isPdf
                ? GestureDetector(
                  onTap: () => OpenFile.open(message["filePath"]),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        "Open PDF",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
                : Text(
                  message["text"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
            ),
            child: const Text(
              "Settings",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wallpaper),
            title: const Text("Set Wallpaper"),
            onTap: () => _showWallpaperSelection(context),
          ),
        ],
      ),
    );
  }

  void _showWallpaperSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> wallpapers = [
          "assets/chatapp_wallpaper1.jpg",
          "assets/chatapp_wallpaper2.jpg",
          "assets/chatapp_wallpaper3.jpg",
          "assets/chatapp_wallpaper4.jpg",
          "assets/chatapp_wallpaper5.jpg",
          "assets/chatapp_wallpaper6.jpg",
          "assets/chatapp_wallpaper7.jpg",
          "assets/chatapp_wallpaper8.jpg",
          "assets/chatapp_wallpaper9.jpg",
          "assets/chatapp_wallpaper10.jpg",
        ];

        return AlertDialog(
          title: const Text("Choose Wallpaper"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onWallpaperChange(wallpapers[index]);
                    Navigator.pop(context);
                  },
                  child: Image.asset(wallpapers[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
