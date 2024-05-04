import 'package:flutter_tts/flutter_tts.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

void ttsMiddleware(
    Store<AppState> store, dynamic action, NextDispatcher next) async {
  final FlutterTts flutterTts = store.state.flutterTts;
  if (action is SetCompletedAction) {
    print(
        '${store.state.sentenceIndex} / ${store.state.storySentences.length - 1}');
    if (store.state.isReadStory) {
      if (store.state.changeIndex == ChangeIndex.next) {
        if (store.state.sentenceIndex < store.state.storySentences.length - 1) {
          store.dispatch(SetSentenceIndexAction(store.state.sentenceIndex + 1));
          store.dispatch(SpeakTextAction());
        } else {
          store.dispatch(SetSentenceIndexAction(0));
          store.dispatch(SetCancelAction());
        }
      } else {
        if (store.state.sentenceIndex > 0) {
          store.dispatch(SetSentenceIndexAction(store.state.sentenceIndex - 1));
          store.dispatch(SpeakTextAction());
        } else {
          store.dispatch(
              SetSentenceIndexAction(store.state.storySentences.length - 1));
          store.dispatch(SetCancelAction());
        }
      }
      store.dispatch(SetChangeIndexAction(ChangeIndex.next));
    } else {
      store.dispatch(SetCancelAction());
    }
  }
  if (action is SpeakTextAction) {
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setVoice({"name": "Karen", "locale": "zh-TW"});
    await flutterTts.setVolume(store.state.volume);
    await flutterTts.setSpeechRate(store.state.rate);
    await flutterTts.setPitch(store.state.pitch);
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );
    if (store.state.isReadStory) {
      print(
          "read sentence: ${store.state.storySentences[store.state.sentenceIndex]}");
      await flutterTts
          .speak(store.state.storySentences[store.state.sentenceIndex]);
    } else {
      print("read voiceText: ${store.state.voiceText}");
      await flutterTts.speak(store.state.voiceText);
    }
    // store.dispatch(SetStartAction());
  } else if (action is StopSpeakAction) {
    // Stop the text-to-speech operation
    print("stop speak");
    var result = await flutterTts.stop();
    print("stopped");
    if (result == 1) {
      print("cancel");
      await store.dispatch(SetCancelAction());
      print("cancelled");
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
