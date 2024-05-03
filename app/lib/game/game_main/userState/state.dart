class UserState {
  double health;
  String destination;
  double dstLat;
  double dstLng;
  String gameType;

  UserState({
    this.health = 100.0,
    this.destination = "台北",
    this.dstLat = 0.0,
    this.dstLng = 0.0,
    this.gameType = "Random",
  });

  UserState copyWith({
    double? health,
    String? destination,
    double? dstLat,
    double? dstLng,
    String? gameType,
  }) {
    return UserState(
      health: health ?? this.health,
      destination: destination ?? this.destination,
      dstLat: dstLat ?? this.dstLat,
      dstLng: dstLng ?? this.dstLng,
      gameType: gameType ?? this.gameType,
    );
  }
}
