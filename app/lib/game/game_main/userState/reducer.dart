import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

// Reducer for the speaking state
UserState setUserStateReducer(UserState state, dynamic action) {
  if (action is SetDestinationAction) {
    return state.copyWith(
        dstLat: action.lat,
        dstLng: action.lng,
        destination: action.destination);
  } else if (action is SetGameTypeAction) {
    return state.copyWith(gameType: action.gameType);
  } else if (action is SetOptionAction) {
    return state.copyWith(option: action.option);
  } else if (action is SetTimeAction) {
    print("setTimeAction: ${action.totalTime} / ${action.currentTime}");
    return state.copyWith(
        totalTime: action.totalTime, currentTime: action.currentTime);
  }
  return state;
}
