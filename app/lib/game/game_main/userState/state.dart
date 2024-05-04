import 'dart:async';

class UserState {
  String destination;
  double dstLat;
  double dstLng;
  String gameType;
  String option;
  String action;
  double totalTime;
  double currentTime;
  Timer? timer;

  UserState({
    this.destination = "台北",
    this.dstLat = 0.0,
    this.dstLng = 0.0,
    this.gameType = "Random",
    this.option = "",
    this.action = "create",
    this.totalTime = 0.1,
    this.currentTime = 0.1,
    this.timer,
  });

  UserState copyWith({
    String? destination,
    double? dstLat,
    double? dstLng,
    String? gameType,
    String? option,
    String? action,
    double? totalTime,
    double? currentTime,
    Timer? timer,
  }) {
    return UserState(
      destination: destination ?? this.destination,
      dstLat: dstLat ?? this.dstLat,
      dstLng: dstLng ?? this.dstLng,
      gameType: gameType ?? this.gameType,
      option: option ?? this.option,
      action: action ?? this.action,
      totalTime: totalTime ?? this.totalTime,
      currentTime: currentTime ?? this.currentTime,
      timer: timer ?? this.timer,
    );
  }
}
