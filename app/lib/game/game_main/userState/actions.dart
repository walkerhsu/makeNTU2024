class SetHealthAction {
  final double health;

  SetHealthAction(this.health);
}

class SetDestinationAction {
  final double lat;
  final double lng;
  final String destination;

  SetDestinationAction(this.lat, this.lng, this.destination);
}

class SetGameTypeAction {
  final String gameType;

  SetGameTypeAction(this.gameType);
}
