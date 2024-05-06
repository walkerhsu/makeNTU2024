import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/drawer.dart';
import 'package:rpg_game/game/Components/memoir.dart';
import 'package:rpg_game/game/fetch_request.dart';
import 'package:rpg_game/memori_detail.dart';

class MemoirsPage extends StatelessWidget {
  const MemoirsPage({super.key});
  final images = const [
    'assets/images/mountain.png',
    'assets/images/taipei-101.png',
    'assets/images/river.png',
    'assets/images/river.png',
    'assets/images/mountain.png',
    'assets/images/river.png',
    'assets/images/taipei-101.png',
    'assets/images/river.png',
    'assets/images/mountain.png',
    'assets/images/mountain.png'
  ];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: retrieveMemoryResponse(),
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
                  itemCount: (snapshot.data as List<String>).length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          child: MyMemoirImage(
                            imageURL: images[index],
                            title: snapshot.data[index],
                            width: 350,
                            height: 150,
                          ),
                          onTap: () async {
                            Map<String, dynamic> response =
                                await retrieveSingleMemoryResponse(
                                    snapshot.data[index]);
                            if (!context.mounted) return;
                            print(response["title"]);
                            Navigator.pushNamed(context, '/memoris_detail',
                                arguments: {
                                  'title': response["title"],
                                  'imagesURLs': response["images"],
                                  'story': response["story"]
                                });
                          },
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
              drawerEnableOpenDragGesture: false,
            );
          }
        });
  }
}
