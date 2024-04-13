import 'dart:typed_data';

import 'package:flutter/material.dart';

class TicketData {
  Uint8List? priceTagImage;
  String? tradePoint;
}

class CreateTicketDataModel with ChangeNotifier {
  final TicketData _ticketData = TicketData();

  TicketData? get ticketData => _ticketData;

  void setTradePoint(String tradePoint) {
    _ticketData.tradePoint = tradePoint;
    notifyListeners();
  }

  void setPriceTagImage(Uint8List image) {
    _ticketData.priceTagImage = image;
  }
}