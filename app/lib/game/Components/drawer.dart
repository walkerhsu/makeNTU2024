import "package:flutter/material.dart";

// MyCardText

class DrawerViews extends StatelessWidget {
  const DrawerViews({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 55,
        ),
        const Divider(
          color: Color.fromARGB(255, 29, 2, 67),
          height: 10,
          thickness: 2,
        ),
        ListTile(
          leading: const Icon(
            Icons.home,
            size: 30,
          ),
          title: const Text('Home', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 29, 2, 67))),
          onTap: () {
            // Navigator.popUntil(context, (route) => route.isFirst)
            Navigator.popAndPushNamed(context, '/home');
          },
        ),
        ListTile(
          leading: Image.asset(
            "assets/images/memoir.png",
            width: 30,
            height: 30,
          ),
          title: const Text('Memoirs', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 29, 2, 67))),
          onTap: () {
            Navigator.popAndPushNamed(context, '/memoirs');
          },
        ),
        ListTile(
          leading: Image.asset(
            "assets/images/maintenace.png",
            width: 30,
            height: 30,
          ),
          title: const Text('Settings', style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 29, 2, 67))),
          onTap: () {
            Navigator.popAndPushNamed(context, '/car_settings');
          },
        ),
      ],
    );
  }
}
