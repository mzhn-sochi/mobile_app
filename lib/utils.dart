import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_app/api.dart';
import 'package:path_provider/path_provider.dart';

String formatUnixTimestamp(int unixTimestamp) {
  var date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  var formattedDate =
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  return formattedDate;
}

Future<File> writeToFile(Uint8List data, String filename) async {
  final directory = await getTemporaryDirectory(); // Get temporary directory
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(data);
  return file;
}

String formatPhoneNumber(String phoneNumber) {
  // Check if the input phone number is valid
  if (phoneNumber.length != 11) {
    throw Exception('Invalid phone number');
  }

  // Extracting the country code, area code, and the rest of the number
  String countryCode = phoneNumber.substring(0, 1);
  String areaCode = phoneNumber.substring(1, 4);
  String restOfNumber = phoneNumber.substring(4);

  // Returning the formatted phone number
  return '+$countryCode($areaCode)${restOfNumber.substring(0, 2)}-${restOfNumber.substring(2, 4)}-${restOfNumber.substring(4)}';
}

String getTicketStatus(TicketStatus status) {
  switch (status) {
    case TicketStatus.waitingOCR:
    case TicketStatus.waitingValidation:
    case TicketStatus.waitingApproval:
      return 'Обработка';
    case TicketStatus.closed:
      return 'Закрыт';
    case TicketStatus.rejected:
      return 'Отклонено';
    default:
      return '-';
  }
}

Color getColorFromTicketStatus(String status) {
  switch (status) {
    case 'Обработка':
      return Colors.orange;
    case 'Отклонено':
      return Colors.red;
    case 'Закрыт':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
