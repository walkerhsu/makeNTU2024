import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

class UserViewModel {
  String destination;
  double dstLat;
  double dstLng;
  double totalTime;
  double currentTime;
  String gameType;
  Function setDestination;

  UserViewModel({
    this.destination = "台北",
    this.dstLat = 0,
    this.dstLng = 0,
    this.totalTime = 0.1,
    this.currentTime = 0.1,
    this.gameType = "Random",
    required this.setDestination,
  });

  factory UserViewModel.create(Store<UserState> store) {
    return UserViewModel(
      destination: store.state.destination,
      dstLat: store.state.dstLat,
      dstLng: store.state.dstLng,
      totalTime: store.state.totalTime,
      currentTime: store.state.currentTime,
      gameType: store.state.gameType,
      setDestination: (double lat, double lng, String destination) {
        store.dispatch(SetDestinationAction(lat, lng, destination));
      },
    );
  }
}
