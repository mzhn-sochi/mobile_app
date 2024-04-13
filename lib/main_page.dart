import 'package:flutter/material.dart';
import 'package:mobile_app/login.dart';
import 'package:mobile_app/pages/create_ticket/select_photo_step.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/widgets/profile_tab.dart';
import 'package:mobile_app/widgets/ticket_list.dart';
import 'package:provider/provider.dart';
// import 'package:mobile_app/pages/send_request/select_traid_point.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
   

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); 

    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return Scaffold(
        body: Container(),
      );
    }

    return Scaffold(
        body: <Widget>[
          const Expanded(child: TicketList()),
          const Card(),
          const ProfileTab(),
        ][currentPageIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            if (index == 1) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SelectPhotoStep()));
              return;
            }

            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.add),
              label: 'Добавить',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: 'Профиль',
            ),
          ],
        ));
  }
}
