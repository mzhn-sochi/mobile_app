import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/api.dart';

class TradePointList extends StatefulWidget {
  final int? selectedStoreIndex;
  final Function(int?) onSelect;
  final Function(List<TradePoint>?) onUpdateTradePoints;

  const TradePointList({
    super.key,
    this.selectedStoreIndex,
    required this.onSelect,
    required this.onUpdateTradePoints,
  });

  @override
  State<TradePointList> createState() => _TradePointListState();
}

class _TradePointListState extends State<TradePointList> {
  List<TradePoint>? tradePoints;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTradePoints();
  }

  Future<void> _fetchTradePoints() async {
    try {
      final pos = await _determinePosition();
      final fetchedTradePoints =
          await ApiClient.fetchTradePoints(pos.longitude, pos.latitude, 5);
      setState(() {
        tradePoints = fetchedTradePoints;
        isLoading = false;
      });
      widget.onUpdateTradePoints(tradePoints); // Update tradePoints in parent
    } catch (e) {
      print('Error fetching trade points: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: tradePoints?.length ?? 0,
            itemBuilder: (context, index) {
              final tradePoint = tradePoints![index];
              return RadioListTile<int>(
                title: Text(tradePoint.title),
                subtitle:
                    Text("${tradePoint.subtitle}\n${tradePoint.distance}"),
                value: index,
                groupValue: widget.selectedStoreIndex,
                onChanged: (int? value) {
                  widget.onSelect(value); // Call the onSelect callback
                },
              );
            },
          );
  }
}
