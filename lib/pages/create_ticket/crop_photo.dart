import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/pages/send_request/send_photo.dart';

class ConfigurableCrop extends StatefulWidget {
  final String imagePath;

  const ConfigurableCrop({super.key, required this.imagePath});

  @override
  State<ConfigurableCrop> createState() => _ConfigurableCropState();
}

class _ConfigurableCropState extends State<ConfigurableCrop> {
  final _controller = CropController();
  Uint8List? imageBytes;

  var _isProcessing = false;
  set isProcessing(bool value) {
    setState(() {
      _isProcessing = value;
    });
  }

  Uint8List? _croppedData;
  set croppedData(Uint8List? value) {
    setState(() {
      _croppedData = value;
    });
  }

  @override
  void initState() {
    super.initState();

    imageBytes = File(widget.imagePath).readAsBytesSync();
  }

  void _navigateToNextScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendPhotoPage(imageBytes: _croppedData!),
      ),
    );

    Navigator.popUntil(
        context, ModalRoute.withName("SelectPhotoStep")
    );
    Navigator.pop(context, _croppedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Кадрирование изображения',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          if (_croppedData == null)
            IconButton(
              icon: const Icon(Icons.cut),
              onPressed: () {
                isProcessing = true;
                _controller.crop();
              },
            ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),
      body: Visibility(
        visible: !_isProcessing,
        replacement: const Center(child: CircularProgressIndicator()),
        child: Crop(
          controller: _controller,
          image: imageBytes!,
          onCropped: (cropped) {
            croppedData = cropped;
            isProcessing = false;
            _navigateToNextScreen();
          },
        ),
      ),
    );
  }
}
