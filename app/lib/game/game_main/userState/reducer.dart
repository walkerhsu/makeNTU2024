import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

// Reducer for the speaking state
UserState setUserStateReducer(UserState state, dynamic action) {
  if (action is SetHealthAction) {
    return state.copyWith(health: action.health);
  }
  return state;
}
