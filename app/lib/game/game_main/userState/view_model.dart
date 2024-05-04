import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';

class UserViewModel {
  double health;
  String destination;
  double dstLat;
  double dstLng;
  String gameType;
  Function setHealth;
  Function setDestination;

  UserViewModel({
    this.health = 100,
    this.destination = "台北",
    this.dstLat = 0,
    this.dstLng = 0,
    this.gameType = "Random",
    required this.setHealth,
    required this.setDestination,
  });

  factory UserViewModel.create(Store<UserState> store) {
    return UserViewModel(
      health: store.state.health,
      destination: store.state.destination,
      dstLat: store.state.dstLat,
      dstLng: store.state.dstLng,
      gameType: store.state.gameType,
      setHealth: (double health) {
        store.dispatch(SetHealthAction(health));
      },
      setDestination: (double lat, double lng, String destination) {
        store.dispatch(SetDestinationAction(lat, lng, destination));
      },
    );
  }
}
