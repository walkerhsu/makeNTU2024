import 'dart:async';

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

class SetHTTPAction {
  final String action;

  SetHTTPAction(this.action);
}

class SetTimeAction {
  final double totalTime;
  final double currentTime;

  SetTimeAction(this.totalTime, this.currentTime);
}

class SetTimerAction {
  final Timer timer;

  SetTimerAction(this.timer);
}

class StopTimerAction {}