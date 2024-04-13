import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _storage = const FlutterSecureStorage();
  String? _name;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _storage.read(key: 'profile.name');
    final phoneNumber = await _storage.read(key: 'profile.phone');
    setState(() {
      _name = name;
      _phoneNumber = phoneNumber;
    });
  }

  logout () async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            const Gap(20),
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://www.woolha.com/media/2020/03/eevee.png'),
              radius: 50,
            ),
            _name != null
                ? Text(
                    _name!,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : const SizedBox(),
            _phoneNumber != null
                ? Text(
                    _phoneNumber!,
                    style: const TextStyle(fontSize: 16),
                  )
                : const SizedBox(),
            const Spacer(),
            TextButton(
              child: const Text("Выйти"),
              onPressed: () => {
                logout()
              },
            ),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}
