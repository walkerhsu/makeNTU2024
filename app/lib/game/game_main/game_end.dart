import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_image.dart';
import 'package:rpg_game/game/fetch_request.dart';

class GameEndPage extends StatelessWidget {
  const GameEndPage({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchAllImages(),
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
                title: const Text("Results"),
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
              body: ListView.builder(
                  itemCount: (snapshot.data as List).length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        MyCardImage(
                          imageName: snapshot.data![index],
                          text:
                              "qwer asd sdf  fsasdf asdf  fd d fsdf sdf asdf  asdf asdf asdf fdsf sdf  sdf sdf sdf sdf fd  asdf  ef r",
                          width: 350,
                          height: 150,
                          fontSize: 12,
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
