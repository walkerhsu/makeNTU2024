import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

// Reducer for the speaking state
UserState setUserStateReducer(UserState state, dynamic action) {
  if (action is SetHealthAction) {
    return state.copyWith(health: action.health);
  } else if (action is SetDestinationAction) {
    return state.copyWith(dstLat: action.lat, dstLng: action.lng, destination: action.destination);
  } else if (action is SetGameTypeAction) {
    return state.copyWith(gameType: action.gameType);
  }
  return state;
}
