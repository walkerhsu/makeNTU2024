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
          color: Colors.black38,
          height: 10,
          thickness: 2,
        ),
        ListTile(
          leading: const Icon(
            Icons.home,
            size: 30,
          ),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        ListTile(
          leading: Image.asset(
            "assets/images/memoir.png",
            width: 30,
            height: 30,
          ),
          title: const Text('Memoirs'),
          onTap: () {
            Navigator.pushNamed(context, '/memoirs');
          },
        ),
        ListTile(
          leading: Image.asset(
            "assets/images/maintenace.png",
            width: 30,
            height: 30,
          ),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pushNamed(context, '/car_settings');
          },
        ),
      ],
    );
  }
}
