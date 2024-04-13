import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/login.dart';
import 'package:mobile_app/main_page.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:ru_phone_formatter/ru_phone_formatter.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final phoneTextController = TextEditingController();
  final ruFormatter = RuPhoneInputFormatter();
  final passwordTextController = TextEditingController();

  // bool get isSendButtonEnabled => ruFormatter.isDone() && ruFormatter.isRussian;
  bool get isSendButtonEnabled =>
      ruFormatter.isDone() &&
      ruFormatter.isRussian &&
      passwordTextController.text.isNotEmpty;

  String extractNumbers(String input) {
    // This pattern matches any digit in the string
    RegExp regExp = RegExp(r'\d+');

    // Finds all matches and maps them to their string value
    Iterable<String> matches = regExp.allMatches(input).map((m) => m.group(0)!);

    // Joins all matched strings (digits) into one continuous string
    return matches.join();
  }

  void register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    BuildContext localContext = context;

    final success = await authProvider.register(
        extractNumbers(phoneTextController.text), passwordTextController.text);

    if (!success) {
      ScaffoldMessenger.of(localContext).showSnackBar(
          const SnackBar(content: Text("Ошибка регистрации, попробуйте позже")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      });      
      return Scaffold(
        body: Container(),
      );
    }

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Регистрация",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                /*
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Укажите номер телефона, на него будет отправлен СМС код.",
                    textAlign: TextAlign.center,
                  ),
                ),
                */
                const Gap(20),
                TextFormField(
                  controller: phoneTextController,
                  inputFormatters: [ruFormatter],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: "Телефон",
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: passwordTextController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.password),
                      hintText: "Пароль",
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ElevatedButton(
                    onPressed: isSendButtonEnabled
                        ? () => {
                              /*
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationVerificationCodePage()))
                              */
                              register()
                            }
                        : null,
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size.fromHeight(40)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Theme.of(context).disabledColor;
                          }
                          return Theme.of(context).primaryColor;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white), // Text color
                    ),
                    child: const Text('РЕГИСТРАЦИЯ'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Уже есть аккаунт?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      child: const Text("Войти"),
                      onPressed: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginPage()))
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
