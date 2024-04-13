import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/utils.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  logout () async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            const Gap(20),
            const CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatar.jpg"),
              radius: 50,
            ),
            authProvider.profile?.firstName != null
                ? Text(
                    "${(authProvider.profile?.lastName)!} ${(authProvider.profile?.firstName)!} ${(authProvider.profile?.middleName)!}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : const SizedBox(),
            authProvider.profile?.phone != null
                ? Text(
                    formatPhoneNumber(authProvider.profile!.phone),
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
