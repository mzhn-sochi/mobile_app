import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/api.dart';
import 'package:mobile_app/pages/create_ticket/send_ticket.dart';
import 'package:mobile_app/providers/ticket_provider.dart';
import 'package:mobile_app/widgets/next_button.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class SelectTradePoint extends StatefulWidget {
  const SelectTradePoint({super.key});

  @override
  State<SelectTradePoint> createState() => _SelectTradePointState();
}

class _SelectTradePointState extends State<SelectTradePoint> {
  int? selectedStoreIndex;
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
      final fetchedTradePoints = await ApiClient.fetchTradePoints(pos, 5);
      setState(() {
        tradePoints = fetchedTradePoints;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
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
    final createTicketProvider = Provider.of<CreateTicketDataModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/images/dpr-arms-1.png'),
              width: 80,
            ),
            const MaxGap(10),
            const Text(
              "Уточните адрес торговой точки",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const MaxGap(30),
            Expanded(
              flex: 8,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: tradePoints?.length ?? 0,
                      itemBuilder: (context, index) {
                        final tradePoint = tradePoints![index];
                        return RadioListTile<int>(
                          title: Text(
                              tradePoint.title), // Use tradePoint data here
                          subtitle: Text(
                              "${tradePoint.subtitle}\n${tradePoint.distance}"), // Use tradePoint data here
                          value: index,
                          groupValue: selectedStoreIndex,
                          onChanged: (int? value) {
                            setState(() {
                              selectedStoreIndex = value;
                            });
                          },
                        );
                      },
                    ),
            ),
            NextButton(
                onPressed: selectedStoreIndex == null
                    ? null
                    : () {
                        createTicketProvider.setTradePoint(
                            tradePoints![selectedStoreIndex!].title);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SendTicketPage()),
                        );
                      }),
          ],
        ),
      ),
    );
  }
}
