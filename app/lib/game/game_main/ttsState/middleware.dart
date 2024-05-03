import 'package:flutter_tts/flutter_tts.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

void ttsMiddleware(
    Store<AppState> store, dynamic action, NextDispatcher next) async {
  final FlutterTts flutterTts = store.state.flutterTts;
  if (action is SpeakTextAction) {
    // Perform text-to-speech operation
    print(store.state.volume);
    await flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    await flutterTts.setVolume(store.state.volume);
    await flutterTts.setSpeechRate(store.state.rate);
    await flutterTts.setPitch(store.state.pitch);
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );
    await flutterTts.speak(action.text);
    store.dispatch(SetStartAction());
  } else if (action is StopSpeakAction) {
    // Stop the text-to-speech operation
    var result = await flutterTts.stop();
    if (result == 1) {
      store.dispatch(SetCompletedAction());
    }
  } else if (action is PauseSpeakAction) {
    // Pause the text-to-speech operation
    var result = await flutterTts.pause();
    if (result == 1) {
      store.dispatch(SetPauseAction());
    }
  } else if (action is SetAwaitOptionsAction) {
    await flutterTts.awaitSpeakCompletion(action.awaitOptions);
  }
  // Call the next action
  next(action);
}
