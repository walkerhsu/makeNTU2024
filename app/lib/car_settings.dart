import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_image.dart';
import 'package:rpg_game/game/Components/drawer.dart';

class CarSettingsPage extends StatelessWidget {
  const CarSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                )),
        title: const Text("Car Settings"),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        backgroundColor: const Color.fromARGB(255, 72, 112, 154),
        // Define your drawer contents here
        child: const DrawerViews(),
      ),
      body: const Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Center(
            child: MyCardImage(
              imageName: "car.png",
              text: "ABC-1234",
              isOnline: false,
              width: 350,
              height: 150,
              fontSize: 26,
            ),
          ),
        ],
      ),
      drawerEnableOpenDragGesture: false
    );
  }
}
