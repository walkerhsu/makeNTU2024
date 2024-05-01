import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';

// ignore_for_file: avoid_print

enum TtsState { playing, stopped, paused, continued }

class AppState {
  final FlutterTts flutterTts = FlutterTts();
  String? language;
  String? engine;
  double volume;
  double pitch;
  double rate;
  bool isCurrentLanguageInstalled = false;

  String voiceText;
  int? inputLength;

  TtsState ttsState;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  AppState({
    this.volume = 1.0,
    this.pitch = 1.0,
    this.rate = 0.5,
    this.voiceText = "This is a book",
    this.inputLength = 0,
    this.ttsState = TtsState.stopped,
  }) {
    Future.delayed(Duration.zero, () {
      store.dispatch(SetAwaitOptionsAction(true));
    });
    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
    flutterTts.setStartHandler(() {
      print("Playing");
      store.dispatch(SetStartAction());
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      store.dispatch(SetCompletedAction());
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
      store.dispatch(SetCancelAction());
    });

    flutterTts.setPauseHandler(() {
      print("Paused");
      store.dispatch(SetPauseAction());
    });

    flutterTts.setContinueHandler(() {
      print("Continued");
      store.dispatch(SetContinueAction());
    });

    flutterTts.setErrorHandler((msg) {
      print("error: $msg");
      store.dispatch(SetErrorAction());
    });
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  AppState copyWith({
    double? volume,
    double? pitch,
    double? rate,
    String? voiceText,
    int? inputLength,
    TtsState? ttsState,
  }) {
    return AppState(
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      voiceText: voiceText ?? this.voiceText,
      inputLength: inputLength ?? this.inputLength,
      ttsState: ttsState ?? this.ttsState,
    );
  }
}
