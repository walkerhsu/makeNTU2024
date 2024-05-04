import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

// Reducer for the speaking state
AppState setTtsCallbackReducer(AppState state, dynamic action) {
  if (action is SetCancelAction || action is SetErrorAction) {
    print("SetCancelAction");
    return state.copyWith(
        ttsState: TtsState.stopped); // Toggle the speaking state
  } else if (action is SetPauseAction) {
    return state.copyWith(
        ttsState: TtsState.paused); // Toggle the speaking state
  } else if (action is SetContinueAction) {
    return state.copyWith(
        ttsState: TtsState.continued); // Toggle the speaking state
  } else if (action is SetStartAction) {
    return state.copyWith(
        ttsState: TtsState.playing); // Toggle the speaking state
  } else if (action is SetReadStoryAction) {
    return state.copyWith(
        isReadStory: action.isReadStory); // Toggle the speaking state
  } else if (action is SetStorySentencesAction) {
    return state.copyWith(
        storySentences: action.storySentences); // Toggle the speaking state
  } else if (action is SetSentenceIndexAction) {
    print("set sentence index: ${action.sentenceIndex}");
    return state.copyWith(
        sentenceIndex: action.sentenceIndex); // Toggle the speaking state
  } else if (action is SetChangeIndexAction) {
    print("set change index: ${action.changeIndex}");
    return state.copyWith(
        changeIndex: action.changeIndex); // Set the changeIndex state
  }
  return state;
}

// Reducer for the speaking state
AppState setSpeakReducer(AppState state, dynamic action) {
  if (action is SetSpeechParams) {
    return state.copyWith(
        volume: action.volume, pitch: action.pitch, rate: action.rate);
  } else if (action is SetVoiceTextAction) {
    return state.copyWith(voiceText: action.text);
  }
  return state;
}

//  combine the reducers
final rootReducer = combineReducers<AppState>([
  setTtsCallbackReducer,
  setSpeakReducer,
]);
