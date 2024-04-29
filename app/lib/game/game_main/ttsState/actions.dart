class ToggleSpeakAction {}
class SetCompletedAction {}
class SetCancelAction {}
class SetErrorAction {}
class SetPauseAction {}
class SetContinueAction {}
class SetStartAction {}
class SetAwaitOptionsAction {
  final bool awaitOptions;
  SetAwaitOptionsAction(this.awaitOptions);
}
class SetSpeechParams {
  final double volume;
  final double pitch;
  final double rate;
  SetSpeechParams(this.volume, this.pitch, this.rate);
}
class SpeakTextAction {
  final String text;

  SpeakTextAction(this.text);
}
class StopSpeakAction {}
class PauseSpeakAction {}
