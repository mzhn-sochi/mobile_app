import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

String formatUnixTimestamp(int unixTimestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  var formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  return formattedDate;
}


Future<File> writeToFile(Uint8List data, String filename) async {
  final directory = await getTemporaryDirectory(); // Get temporary directory
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(data);
  return file;
}