import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/api.dart';
import 'package:mobile_app/pages/create_ticket/send_ticket.dart';
import 'package:mobile_app/providers/ticket_provider.dart';
import 'package:mobile_app/widgets/next_button.dart';
import 'package:mobile_app/widgets/trade_point_list.dart';
import 'package:provider/provider.dart';

class SelectTradePoint extends StatefulWidget {
  const SelectTradePoint({super.key});

  @override
  State<SelectTradePoint> createState() => _SelectTradePointState();
}

class _SelectTradePointState extends State<SelectTradePoint> {
  int? selectedStoreIndex;
  List<TradePoint>? tradePoints;

  void updateTradePoints(List<TradePoint>? newTradePoints) {
    setState(() {
      tradePoints = newTradePoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    final createTicketProvider = Provider.of<CreateTicketDataModel>(context);

    void handleSelect(int? newIndex) {
      setState(() {
        selectedStoreIndex = newIndex;
      });
    }

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
              child: TradePointList(
                selectedStoreIndex: selectedStoreIndex,
                onSelect: handleSelect,
                onUpdateTradePoints: updateTradePoints,
              ),
            ),
            NextButton(
                onPressed: selectedStoreIndex == null ||
                        tradePoints == null ||
                        tradePoints!.isEmpty
                    ? null
                    : () {
                        createTicketProvider.setTradePointAddress(
                            tradePoints![selectedStoreIndex!]
                                .subtitle
                                .split('·')[1]
                                .trim());

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
