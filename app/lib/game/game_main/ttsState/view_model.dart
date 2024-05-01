import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

class ViewModel {
  final TtsState ttsState;
  final Function speak;
  final Function stop;
  final Function pause;
  String text;

  ViewModel({
    this.ttsState = TtsState.stopped,
    this.text = "",
    required this.speak,
    required this.stop,
    required this.pause,
  });

  factory ViewModel.create(Store<AppState> store) {
    return ViewModel(
      ttsState: store.state.ttsState,
      text: store.state.voiceText,
      speak: () {
        print("speaking: ${store.state.voiceText}");
        store.dispatch(SpeakTextAction(store.state.voiceText));
      },
      stop: () {
        store.dispatch(StopSpeakAction());
      },
      pause: () {
        store.dispatch(PauseSpeakAction());
      },
    );
  }
}