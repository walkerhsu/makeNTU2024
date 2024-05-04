// generate app bat class

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.active = true,
    required this.title,
  });
  final double height;
  final bool active;
  final String title;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: AppStateStore,
        child: StoreConnector<AppState, TTSViewModel>(
            converter: (Store<AppState> store) {
          return TTSViewModel.create(store);
        }, builder: (BuildContext context, TTSViewModel ttsViewModel) {
          return AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                AppStateStore.dispatch(ttsViewModel.stop());
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                    onTap: () {
                      if (!active) return;
                      if (ttsViewModel.ttsState == TtsState.stopped) {
                        ttsViewModel.speak();
                      } else if (ttsViewModel.ttsState == TtsState.playing ||
                          ttsViewModel.ttsState == TtsState.continued) {
                        ttsViewModel.pause();
                      } else if (ttsViewModel.ttsState == TtsState.paused) {
                        ttsViewModel.speak();
                      }
                    },
                    child: ttsViewModel.ttsState == TtsState.playing ||
                            ttsViewModel.ttsState == TtsState.continued
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
        }));
  }
}
