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

class SetOptionAction {
  final String option;

  SetOptionAction(this.option);
}

class SetTimeAction {
  final double totalTime;
  final double currentTime;

  SetTimeAction(this.totalTime, this.currentTime);
}
