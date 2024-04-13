import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/pages/create_ticket/add_photo.dart';
import 'package:mobile_app/pages/create_ticket/select_trade_point.dart';
import 'package:mobile_app/providers/ticket_provider.dart';
import 'package:mobile_app/pages/create_ticket/widgets/select_photo_button.dart';
import 'package:mobile_app/widgets/next_button.dart';
import 'package:provider/provider.dart';

class SelectPhotoStep extends StatefulWidget {
  const SelectPhotoStep({super.key});

  @override
  State<SelectPhotoStep> createState() => _SelectPhotoStepState();
}

class _SelectPhotoStepState extends State<SelectPhotoStep> {
  Uint8List? priceTagImage;

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
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            const Image(
              image: AssetImage('assets/images/dpr-arms-1.png'),
              width: 80,
            ),
            const MaxGap(10),
            const Text(
              "Загрузите фото ценника",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const MaxGap(10),
            const Text(
              "Пожалуйста, убедитесь, что ценник полностью попадает в кадр фотографии, чтобы его можно было четко прочитать.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(120, 0, 0, 0),
              ),
            ),
            const MaxGap(30),
            // Use a ternary operator to conditionally display the image or the button
            priceTagImage != null
                ? SizedBox(
                    width: 200, // Указывайте необходимую ширину
                    height: 200,
                    child: Image.memory(priceTagImage!, fit: BoxFit.contain),
                  )
                : SelectPhotoButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings:
                                const RouteSettings(name: "SelectPhotoStep"),
                            builder: (context) => const AddPhotoPage()),
                      );

                      if (result != null && result is Uint8List) {
                        setState(() {
                          priceTagImage = result;
                        });
                      }
                    },
                  ),
            const Spacer(),
            NextButton(
                onPressed: priceTagImage != null
                    ? () {
                        createTicketProvider.setPriceTagImage(priceTagImage!);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectTradePoint()),
                        );
                      }
                    : null),
          ]),
        ),
      ),
    );
  }
}
