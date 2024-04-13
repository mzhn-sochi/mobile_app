import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

class RegistrationVerificationCodePage extends StatefulWidget {
  const RegistrationVerificationCodePage({super.key});

  @override
  State<RegistrationVerificationCodePage> createState() =>
      _RegistrationVerificationCodePageState();
}

class _RegistrationVerificationCodePageState
    extends State<RegistrationVerificationCodePage> {
  bool _onEditing = true;
  String? _code;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  "Введите код",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              VerificationCode(
                textStyle: const TextStyle(fontSize: 16.0),
                keyboardType: TextInputType.number,
                length: 5,
                fullBorder: true,

                // itemSize: 45,
                onCompleted: (String value) {
                  setState(() {
                    _code = value;
                  });
                  /*
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegistrationPage()))
                  */
                },
                onEditing: (bool value) {
                  setState(() {
                    _onEditing = value;
                  });
                  if (!_onEditing) FocusScope.of(context).unfocus();
                },
              ),
              const Spacer(),
              TextButton(
                child: const Text("Отправить код повторно"),
                onPressed: () => {},
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
