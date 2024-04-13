
import 'package:flutter/material.dart';

class S3Image {
  static get(String path) {
    return Image.network("http://77.221.158.75:9000/prod/$path");
  }
}