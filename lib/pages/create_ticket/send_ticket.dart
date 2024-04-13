import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:gap/gap.dart';
import 'package:mobile_app/api.dart';
import 'package:mobile_app/main_page.dart';
import 'package:mobile_app/providers/ticket_provider.dart';
import 'package:mobile_app/utils.dart';
import 'package:mobile_app/widgets/next_button.dart';
import 'package:provider/provider.dart'; // For simulating a delay

class SendTicketPage extends StatefulWidget {
  const SendTicketPage({super.key});

  @override
  State<SendTicketPage> createState() => _SendTicketPageState();
}

class _SendTicketPageState extends State<SendTicketPage> {
  bool _isLoading = false;
  bool _isSuccess = false;

  // This method simulates sending a request
  Future<void> _sendTicket() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final createTicketProvider = Provider.of<CreateTicketDataModel>(context, listen: false);

    var address = createTicketProvider.ticketData!.tradePoint!;
    var image = await writeToFile(createTicketProvider.ticketData!.priceTagImage!, 'tmp.jpg');

    await ApiClient.createTicket(
      image,
      address,
    );

    // Imagine this is where you'd call your actual API
    // For simulation, we just set _isSuccess to true after the delay
    setState(() {
      _isLoading = false; // Stop loading
      _isSuccess = true; // Request successful
    });
  }

  @override
  void initState() {
    super.initState();
    _sendTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isLoading) ...[
              const MaxGap(150),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
            ] else if (_isSuccess) ...[
              const MaxGap(150),
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 20),
              const Text('Ваша заявка успешно подана',
                  style: TextStyle(fontSize: 20)),
              const Text(
                'Благодарим вас за вашу заявку! Мы получили ваш запрос и приступили к его обработке. Наши специалисты приложат все усилия, чтобы как можно скорее рассмотреть вашу заявку и предоставить вам необходимую информацию или помощь. Мы ценим ваше терпение и доверие. Спасибо за ваше сотрудничество!',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              NextButton(
                  label: "Закрыть",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainPage()),
                    );
                  })
            ],
          ],
        ),
      ),
    );
  }
}
