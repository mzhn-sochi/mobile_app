import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'dart:async';

import 'package:mobile_app/api.dart';
import 'package:mobile_app/pages/view_ticket/view_ticket.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/utils.dart';
import 'package:provider/provider.dart';

class TicketList extends StatefulWidget {
  const TicketList({super.key});

  @override
  _TicketListState createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<TicketInLsit> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      List<TicketInLsit> fetchedTickets = await ApiClient.fetchTicketList();

      if (mounted) {
        setState(() {
          items = fetchedTickets;
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is TokenRefreshException) {
        if (mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          authProvider.logout();
        }
      } else {
        print("An unexpected error occurred: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        onRefresh: () async {
          await loadTickets();
        },
        child: ListView.separated(
          itemCount: items.length,
          padding: EdgeInsets.all(10),
          separatorBuilder: (BuildContext context, int index) {
            return Gap(20);
          },
          itemBuilder: (context, index) {
            TicketInLsit item = items[index];

            var status = getTicketStatus(item.status);

            String date;
            if (item.updatedAt != null) {
              date = formatUnixTimestamp(item.updatedAt!);
            } else {
              date = formatUnixTimestamp(item.createdAt);
            }

            return InkWell(
              onTap: () {
                // print('Tapped on: ${item.title}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTicket(
                      id: item.id,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.0), // Add padding around the ListTile
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey), // Define the border color and width
                  borderRadius: BorderRadius.circular(
                      5.0), // Optional: if you want rounded corners
                ),
                child: ListTile(
                  minVerticalPadding: 20,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child:
                        Text(item?.shopName ?? "", style: const TextStyle(fontSize: 20)),
                  ),
                  subtitle:
                      Text(item.address, style: const TextStyle(fontSize: 14)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          color: getColorFromTicketStatus(status),
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(date, style: const TextStyle(fontSize: 16))
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
