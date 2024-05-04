import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/drawer.dart';
import 'package:rpg_game/game/Components/memoir.dart';
import 'package:rpg_game/game/fetch_request.dart';

class MemoirsPage extends StatelessWidget {
  const MemoirsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchMemoirs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                leading: Builder(
                    builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        )),
                title: const Text("Memoirs"),
              ),
              drawer: Drawer(
                width: MediaQuery.of(context).size.width * 0.6,
                backgroundColor: const Color.fromARGB(255, 72, 112, 154),
                // Define your drawer contents here
                child: const DrawerViews(),
              ),
              body: ListView.builder(
                  itemCount: (snapshot.data as List).length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        MyMemoirImage(
                          imageURL: snapshot.data![index]["image"],
                          title: snapshot.data![index]["title"],
                          date: snapshot.data![index]["date"],
                          dest: snapshot.data![index]["destination"],
                          width: 350,
                          height: 150,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: Colors.black,
                          height: 10,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ],
                    );
                  }),
            );
          }
        });
  }
}
