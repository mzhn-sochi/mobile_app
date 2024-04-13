import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mobile_app/api.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/s3image.dart';
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
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            TicketInLsit item = items[index];

            var status = _getStatus(item.status);

            return InkWell(
              onTap: () {
                // print('Tapped on: ${item.title}');
              },
              child: ListTile(
                leading: SizedBox(
                  height: 80.0,
                  width: 80.0, // fixed width and height
                  child: S3Image.get(item.image),
                ),
                // title: Text(item.title!, style: const TextStyle(fontSize: 20)),
                subtitle:
                    Text(item.address, style: const TextStyle(fontSize: 18)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 14,
                      ),
                    ),
                    Text(formatUnixTimestamp(item.createdAt),
                        style: const TextStyle(fontSize: 14))
                  ],
                ),
              ),
            );
          },
        ));
  }

  String _getStatus(int status) {
    switch (status) {
      case 0:
      case 1:
      case 2:
        return 'Обработка';
      case 3:
        return 'Закрыт';
      case 4:
        return 'Отклонено';
      default:
        return '-';
    }
  }

  Color _getStatusColor(String status) {
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
}
