import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_text.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/generate_Story.dart';

class StoryBody extends StatefulWidget {
  final String story;
  final List<Map<String, dynamic>> options;
  const StoryBody({super.key, required this.story, required this.options});

  @override
  State<StoryBody> createState() => _StoryBodyState();
}

class _StoryBodyState extends State<StoryBody> {
  late final List<Map<String, dynamic>> options1_2;
  late final List<Map<String, dynamic>> options3_4;

  @override
  void initState() {
    super.initState();
    options1_2 = widget.options.sublist(0, 2);
    options3_4 = widget.options.sublist(2, 4);
  }

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
                color: const Color.fromARGB(255, 180, 180, 180) , borderRadius: BorderRadius.circular(15)),
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
                _buildOptionsRow(options1_2),
                const SizedBox(
                  height: 30,
                ),
                _buildOptionsRow(options3_4),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOptionsRow(List<Map<String, dynamic>> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options
          .map((option) => InkWell(
              onTap: () {
                print("tap on option ${option['idx']}");
                // check if tts is playing or continued, then pause it
                if ((appStateStore.state.ttsState == TtsState.playing) ||
                    (appStateStore.state.ttsState == TtsState.continued)) {
                  appStateStore.dispatch(StopSpeakAction());
                  String newVoiceText =
                      "Your choice is : option ${idx2Str(option['idx'])}";
                  appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
                  appStateStore.dispatch(SpeakTextAction(newVoiceText));
                }
                // push the new route on the previous route
                Navigator.pushNamed(context, '/game/wait_result');
              },
              child: MyCardText(
                width: 130,
                text: option['option'],
                textAlign: TextAlign.center,
                maxLines: 2,
                cardColor: Colors.purple[100]!,
              )))
          .toList(),
    );
  }
}
