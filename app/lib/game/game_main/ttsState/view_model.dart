import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

class TTSViewModel {
  final TtsState ttsState;
  final Function speak;
  final Function stop;
  final Function pause;
  List<String> storySentences;
  String text;

  TTSViewModel({
    this.ttsState = TtsState.playing,
    this.storySentences = const [],
    this.text = "",
    required this.speak,
    required this.stop,
    required this.pause,
  });

  factory TTSViewModel.create(Store<AppState> store) {
    return TTSViewModel(
      ttsState: store.state.ttsState,
      storySentences : store.state.storySentences,
      text: store.state.voiceText,
      speak: () {
        store.dispatch(SpeakTextAction());
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
