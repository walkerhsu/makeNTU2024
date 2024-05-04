import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/card_text.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';

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
  late final bool haveOptions;

  @override
  void initState() {
    super.initState();
    if (widget.options.length == 4) {
      options1_2 = widget.options.sublist(0, 2);
      options3_4 = widget.options.sublist(2, 4);
      haveOptions = true;
    } else {
      haveOptions = false;
    }
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
                color: const Color.fromARGB(255, 180, 180, 180),
                borderRadius: BorderRadius.circular(15)),
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyCardText(
                  text: widget.story,
                  fontSize: 20,
                  maxLines: 5,
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (appStateStore.state.sentenceIndex == 0) return;
                          await appStateStore.dispatch(SetSentenceIndexAction
                              (appStateStore.state.sentenceIndex - 1));
                          await appStateStore.dispatch(StopSpeakAction());
                          // await appStateStore.dispatch(SpeakTextAction());
                        },
                        icon: const Icon(Icons.arrow_back_ios_outlined)),
                    IconButton(
                        onPressed: () async {
                          if (appStateStore.state.sentenceIndex ==
                              appStateStore.state.storySentences.length - 1) {
                            return;
                          }
                          await appStateStore.dispatch(SetSentenceIndexAction
                              (appStateStore.state.sentenceIndex + 1));
                          await appStateStore.dispatch(StopSpeakAction());
                          // await appStateStore.dispatch(SpeakTextAction());
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios_outlined,
                        )),
                  ],
                ),
                if (haveOptions) _buildOptionsRow(options1_2),
                if (haveOptions) const SizedBox(height: 25),
                if (haveOptions) _buildOptionsRow(options3_4),
                if (haveOptions) const SizedBox(height: 25),
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
                // check if tts is playing or continued, then pause it
                if ((appStateStore.state.ttsState == TtsState.playing) ||
                    (appStateStore.state.ttsState == TtsState.continued)) {
                  appStateStore.dispatch(StopSpeakAction());
                }
                // push the new route on the previous route
                userStateStore.dispatch(SetOptionAction(option['option']));
                appStateStore.dispatch(SetStorySentencesAction(['']));
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
