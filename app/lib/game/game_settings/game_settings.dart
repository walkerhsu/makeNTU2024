import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/game_main/userState/view_model.dart';

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
  LatLng? _destLatLng;
  String? _gameType;

  bool _showDestinationFilters = false;
  bool _showGameTypeFilters = false;

  void setGameType(String? value) {
    setState(() {
      _gameType = value;
    });
  }

  void setDestination(String? value, LatLng? latLng) {
    setState(() {
      _destination = value;
      _destLatLng = latLng;
    });
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
    return StoreProvider<UserState>(
        store: userStateStore,
        child: StoreConnector<UserState, UserViewModel>(
            converter: (Store<UserState> store) {
          return UserViewModel.create(store);
        }, builder: (BuildContext context, UserViewModel viewModel) {
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
                        setValue: setDestination,
                        setShowGameTypeFilters: setShowGameTypeFilters,
                        setShowDestinationFilters: setShowDestinationFilters,
                        showFilters: _showDestinationFilters,
                        textFormKey: _textFormKeyDest),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      } else {
                        return;
                      }
                      bool confirm = false;
                      await QuickAlert.show(
                        context: context,
                        text: "Are you sure you picked the right settings?",
                        // confirmBtnText: 'Yes',
                        cancelBtnText: 'No',
                        confirmBtnColor: Colors.green,
                        cancelBtnTextStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        type: QuickAlertType.confirm,
                        onConfirmBtnTap: () {
                          confirm = true;
                          Navigator.pop(context);
                        },
                      );
                      if (!mounted || !confirm) return;
                      viewModel.destination = _destination!;
                      viewModel.dstLat = _destLatLng!.latitude;
                      viewModel.dstLng = _destLatLng!.longitude;
                      viewModel.gameType = _gameType!;
                      // ignore: use_build_context_synchronously
                      Navigator.popUntil(context, (route) => route.isFirst);
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, '/game/main');
                    },
                    child: const Icon(Icons.check)),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterFloat);
        }));
  }
}
