import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

// Reducer for the speaking state
AppState setTtsCallbackReducer(AppState state, dynamic action) {
  if (action is SetCompletedAction || action is SetCancelAction || action is SetErrorAction) {
    return state.copyWith(ttsState:TtsState.stopped); // Toggle the speaking state
  } else if (action is SetPauseAction) {
    return state.copyWith(ttsState:TtsState.paused); // Toggle the speaking state
  } else if (action is SetContinueAction) {
    return state.copyWith(ttsState:TtsState.continued); // Toggle the speaking state
  } else if (action is SetStartAction) {
    return state.copyWith(ttsState:TtsState.playing); // Toggle the speaking state
  } 
  return state;
}

// Reducer for the speaking state
AppState setSpeakReducer(AppState state, dynamic action) {
  if (action is SetSpeechParams) {
    return state.copyWith(volume:action.volume, pitch:action.pitch, rate:action.rate);
  } else if (action is SetVoiceTextAction) {
    return state.copyWith(voiceText:action.text);
  } return state;
}

//  combine the reducers
final rootReducer = combineReducers<AppState>([
  setTtsCallbackReducer,
  setSpeakReducer,
]);