class UserState {
  double health;

  UserState({
    this.health = 100.0,
  });

  UserState copyWith({
    double? health,
  }) {
    return UserState(
      health: health ?? this.health,
    );
  }
}
