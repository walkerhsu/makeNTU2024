import 'package:flutter/material.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';

class GameAppBar extends StatefulWidget {
  const GameAppBar({super.key, required this.viewModel});
  final ViewModel viewModel;
  @override
  State<GameAppBar> createState() => _GameAppBarState();
}

class _GameAppBarState extends State<GameAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Game'),
      leading: IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
      actions: [
        Padding( 
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
              onTap: () {
                print(widget.viewModel.ttsState);
                if (widget.viewModel.ttsState == TtsState.stopped) {
                  widget.viewModel.speak();
                } else if (widget.viewModel.ttsState == TtsState.playing) {
                  widget.viewModel.pause();
                } else if (widget.viewModel.ttsState == TtsState.paused) {
                  widget.viewModel.speak();
                }
              },
              child: widget.viewModel.ttsState == TtsState.playing
                  ? Image.asset(
                      'assets/images/pause.png',
                      width: 25,
                    )
                  : Image.asset(
                      'assets/images/sound.png',
                      width: 25,
                    )),
        ),
      ],
    );
  }
}
