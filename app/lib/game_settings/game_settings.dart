import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quickalert/quickalert.dart';

import './destination.dart';
import 'game_mode.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  String? _destination;
  String? _gameType;

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
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: GameModeMenu(setValue: (value) {
                setGameType(value);
              }),
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
            print('Destination: $_destination');
            print('Game Type: $_gameType');
          },
          child: const Icon(Icons.check)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat
    );
  }
}
