import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_text.dart';

class GameMain extends StatefulWidget {
  final String story;
  final List<String> options;
  const GameMain({super.key, required this.story, required this.options});

  @override
  State<GameMain> createState() => _GameMainState();
}

class _GameMainState extends State<GameMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyCardText(
                  text: widget.story,
                  maxLines: 50,
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {},
                        child: MyCardText(
                          width: 130,
                          text: widget.options[0],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          cardColor: Colors.red,
                        )),
                    InkWell(
                        onTap: () {},
                        child: MyCardText(
                          width: 130,
                          text: widget.options[1],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          cardColor: Colors.red,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {},
                        child: MyCardText(
                          width: 130,
                          text: widget.options[2],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          cardColor: Colors.red,
                        )),
                    InkWell(
                        onTap: () {},
                        child: MyCardText(
                          width: 130,
                          text: widget.options[3],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          cardColor: Colors.red,
                        )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
