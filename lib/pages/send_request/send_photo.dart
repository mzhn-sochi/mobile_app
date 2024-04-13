import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

class SendPhotoPage extends StatefulWidget {
  final Uint8List imageBytes;

  const SendPhotoPage({super.key, required this.imageBytes});

  @override
  State<SendPhotoPage> createState() => _SendPhotoPageState();
}

class _SendPhotoPageState extends State<SendPhotoPage> {
  String? serverResponse;
  bool isLoading = false; // Add a loading state variable

  Future<void> sendPhoto() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      var uri = Uri.parse('http://77.221.158.75:8080/api/v1/analyze');
      var result = await FlutterImageCompress.compressWithList(
        widget.imageBytes,
        minWidth: 960, // 1920,
        minHeight: 540, // 1080,
        quality: 80,
      );

      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'pricetag', // The field name for the file in the API
          result,
          filename: 'pricetag.jpg', // Use the filename from the path
        ));

      // You can add other fields if needed
      // request.fields['otherField'] = 'value';

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        setState(() {
          serverResponse = jsonEncode(json.decode(
              utf8.decode(responseData))); // Convert the whole map to a string
          isLoading = false; // Stop loading
        });
      } else {
        setState(() {
          serverResponse = 'Failed to send photo';
          isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      setState(() {
        serverResponse = 'Error: $e';
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Photo'),
      ),
      body: Center(
        child: isLoading // Check if loading
            ? const CircularProgressIndicator() // Show loading indicator
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.imageBytes.isNotEmpty
                      ? Image.memory(widget.imageBytes)
                      : const Text("No image selected"),
                  ElevatedButton(
                    onPressed: () {
                      sendPhoto();
                    },
                    child: const Text('Send Photo'),
                  ),
                  if (serverResponse != null) Text('Response: $serverResponse'),
                ],
              ),
      ),
    );
  }
}
