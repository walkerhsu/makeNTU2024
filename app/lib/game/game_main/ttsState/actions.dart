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
class SpeakTextAction {}
class SpeakStoryAction {}
class StopSpeakAction {}
class PauseSpeakAction {}
class SetVoiceTextAction {
  String text;
  SetVoiceTextAction(this.text);
}
class SetSentenceIndexAction {
  final int sentenceIndex;
  SetSentenceIndexAction(this.sentenceIndex);
}

class SetStorySentencesAction {
  final List<String> storySentences;
  SetStorySentencesAction(this.storySentences);
}