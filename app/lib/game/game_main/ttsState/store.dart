import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/ttsState/middleWare.dart';
import 'package:rpg_game/game/game_main/ttsState/reducer.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';

final Store<AppState> appStateStore = Store<AppState>(
  rootReducer,
  middleware: [ttsMiddleware],
  initialState: AppState(),
);