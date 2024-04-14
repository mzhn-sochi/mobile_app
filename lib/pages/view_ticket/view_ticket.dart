import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/api.dart';
import 'package:mobile_app/s3image.dart';
import 'package:mobile_app/utils.dart';

class ViewTicket extends StatefulWidget {
  final String id; // Add an id parameter

  const ViewTicket({super.key, required this.id});

  @override
  State<ViewTicket> createState() => _ViewTicketState();
}

class _ViewTicketState extends State<ViewTicket> {
  bool isLoading = true; // flag to manage loading state
  TicketView? ticketData;

  @override
  void initState() {
    super.initState();
    _fetchTicket();
  }

  void _fetchTicket() async {
    try {
      ticketData =
          await ApiClient.fetchTicket(widget.id); // Use the id from the widget
      // Update your state with the fetched data here
      setState(() {
        isLoading = false; // Set loading to false when data is loaded
      });
    } catch (error) {
      // Handle errors if any
      print('Error fetching ticket: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && ticketData == null) {
      return Container();
    }

    String date = "";
    if (!isLoading) {
      if (ticketData?.updatedAt != null) {
        date = formatUnixTimestamp(ticketData!.updatedAt!);
      } else {
        date = formatUnixTimestamp(ticketData!.createdAt);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching data
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Assuming S3Image widget takes a string URL or key
                    S3Image.get(ticketData!.image),
                    const Gap(20),
                    Text('Магазин: ${ticketData!.shopName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    Text('Адрес: ${ticketData!.address}',
                        style: const TextStyle(fontSize: 20)),
                    Text('Дата обновления заявки: $date',
                        style: const TextStyle(fontSize: 20)),
                    if (ticketData!.itemName != null) ...[
                      Text('Категория товара: ${ticketData!.itemName}')
                    ],
                    if (ticketData!.itemPrice != null) ...[
                      Text('Цена товара: ${ticketData!.itemPrice}')
                    ],
                    if (ticketData!.itemOverprice != null) ...[
                      Text('Цена товара завышена на: ${ticketData!.itemOverprice}%')
                    ],
                    Text('Статус: ${getTicketStatus(ticketData!.status)}',
                        style: const TextStyle(fontSize: 20)),
                    if (ticketData!.reason != null) ...[
                      Text('Причина: ${reasonParse(ticketData!.reason!)}',
                          style: const TextStyle(fontSize: 20))
                    ]
                  ],
                ),
              ),
      ),
    );
  }
}

String reasonParse(String reason) {
  if (reason.startsWith("ProcessException: ")) {
    return "Ошибка с распознаванием ценника. Попробуйте отправить снова";
  }

  return reason;
}
