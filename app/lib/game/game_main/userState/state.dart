class UserState {
  String destination;
  double dstLat;
  double dstLng;
  String gameType;
  String option;
  double totalTime;
  double currentTime;

  UserState({
    this.destination = "台北",
    this.dstLat = 0.0,
    this.dstLng = 0.0,
    this.gameType = "Random",
    this.option = "",
    this.totalTime = 0.1,
    this.currentTime = 0.1,
  });

  UserState copyWith({
    String? destination,
    double? dstLat,
    double? dstLng,
    String? gameType,
    String? option,
    double? totalTime,
    double? currentTime,
  }) {
    return UserState(
      destination: destination ?? this.destination,
      dstLat: dstLat ?? this.dstLat,
      dstLng: dstLng ?? this.dstLng,
      gameType: gameType ?? this.gameType,
      option: option ?? this.option,
      totalTime: totalTime ?? this.totalTime,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}
