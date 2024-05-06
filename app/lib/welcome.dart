import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rpg_game/game/Components/drawer.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
          title: const Text("CaRPG"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InkWell(
                onTap: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    text:
                        "This is CaRPG. With CaRPG, you can interact with the surroundings while immersed in the story corresponded with your tour trip.\n\n Now, press Play and enjoy the game!",
                  );
                },
                child: const Icon(Icons.question_mark_rounded),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.6,
          backgroundColor: Color.fromARGB(255, 249, 163, 3),
          // Define your drawer contents here
          child: const DrawerViews(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                "assets/images/main.png",
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              const SizedBox(
                height: 70,
              ),
              const Text(
                "CaRPG",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 52,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    color: Color.fromARGB(255, 249, 163, 3)),
              ),
              const SizedBox(height: 50),
              SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/game/settings');
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color.fromARGB(255, 249, 163, 3)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)))),
                      child: const Text(
                        "Play",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            ),
                      ))),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
        drawerEnableOpenDragGesture: false);
  }
}
