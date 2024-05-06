import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_image.dart';
import 'package:rpg_game/game/Components/card_text.dart';
import 'package:rpg_game/game/Components/drawer.dart';

class MemoriDetailPage extends StatefulWidget {
  const MemoriDetailPage({super.key});

  @override
  State<MemoriDetailPage> createState() => _MemoriDetailPageState();
}

class _MemoriDetailPageState extends State<MemoriDetailPage> {
  late final String title;
  late final String story;
  late final List imagesURLs;
  @override
  Widget build(BuildContext context) {
    // get the data from the previous page
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    title = data['title'];
    story = data['story'];
    imagesURLs = data['imagesURLs'];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body:Column(
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: MyCardText(
                  text: story,
                  width: 350,
                  fontSize: 12,
                  maxLines: 50,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                  itemCount: imagesURLs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        MyCardImage(
                          imageName: imagesURLs[index],
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
            ),
          ],
        )
    );
  }
}
