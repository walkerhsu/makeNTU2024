import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import 'destination.dart';
import 'game_mode.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _textFormKeyDest = GlobalKey<FormFieldState<String>>();
  final _textFormKeyGame = GlobalKey<FormFieldState<String>>();

  String? _destination;
  String? _gameType;
  
  bool _showDestinationFilters = false;
  bool _showGameTypeFilters = false;

  void setGameType(String? value) {
    setState(() {
      _gameType = value;
    });
  }

  void setDestination(String? value) {
    setState(() {
      _destination = value;
    });
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: value,
      confirmBtnColor: Colors.red,
    );
  }

  void setShowDestinationFilters(bool value) {
    setState(() {
      _showDestinationFilters = value;
    });
  }

  void setShowGameTypeFilters(bool value) {
    setState(() {
      _showGameTypeFilters = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Game Settings'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              DestinationField(
                  setValue: (value) {
                    setDestination(value);
                  },
                  setShowGameTypeFilters: setShowGameTypeFilters,
                  setShowDestinationFilters: setShowDestinationFilters,
                  showFilters: _showDestinationFilters,
                  textFormKey: _textFormKeyDest
                ),
              const SizedBox(
                height: 20,
              ),
              GameModeMenu(
                setValue: (value) {
                  setGameType(value);
                },
                setShowGameTypeFilters: setShowGameTypeFilters,
                setShowDestinationFilters: setShowDestinationFilters,
                showFilters: _showGameTypeFilters,
                textFormKey: _textFormKeyGame,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.width * 0.15,
          child: FloatingActionButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
                Navigator.pushNamed(context, '/game/main', arguments: {
                  'destination': _destination,
                  'gameType': _gameType,
                });
              },
              child: const Icon(Icons.check)),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat);
  }
}
