import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/userState/reducer.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

final Store<UserState> userStateStore = Store<UserState>(
  setUserStateReducer,
  initialState: UserState(),
);