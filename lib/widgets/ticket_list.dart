import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mobile_app/api.dart';

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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate fetching data
    List<TicketInLsit> fetchedTickets = await ApiClient.fetchTicketList();

    if (mounted) {
      setState(() {
        items = fetchedTickets;
        isLoading = false;
      });
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
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            TicketInLsit item = items[index];
            return InkWell(
              onTap: () {
                print('Tapped on: ${item.title}');
              },
              child: ListTile(
                leading: SizedBox(
                  height: 80.0,
                  width: 80.0, // fixed width and height
                  child: Image.network(item.image),
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 20)),
                subtitle: Text(item.address, style: const TextStyle(fontSize: 18)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.status,
                        style: TextStyle(
                            color: _getStatusColor(item.status), fontSize: 14)),
                    Text(item.date, style: const TextStyle(fontSize: 14))
                  ],
                ),
              ),
            );
          },
        ));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Обработка':
        return Colors.orange;
      case 'Отклонено':
        return Colors.red;
      case 'Одобрено':
        return Colors.green;
      case 'Открыта':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
