import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SelectPhotoButton extends StatelessWidget {
  final void Function()? onPressed;

  const SelectPhotoButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed!();
      },
        child: Container(
      padding: const EdgeInsets.all(60), // Adjust padding as needed
      decoration: BoxDecoration(
        // color: Colors.grey, // Grey background color
        border: Border.all(
          color: Colors.black26, // Red border color
          width: 2, // Border width
        ),
        borderRadius: BorderRadius.circular(5), // More squared corners
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min, // Fit to content size
        children: <Widget>[
          Icon(
            Icons.camera_alt, // Camera icon
            size: 70, // Icon size, adjust as needed
          ),
          Gap(8), // Space between icon and text
          Text(
            'Добавьте фото', // Text
            style: TextStyle(
              fontSize: 18, // Text size, adjust as needed
              color: Colors.black, // Text color
            ),
            textAlign: TextAlign.center, // Center the text
          ),
        ],
      ),
    ));
  }
}
