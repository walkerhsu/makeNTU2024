import 'package:flutter/material.dart';

class GameModeMenu extends StatefulWidget {
  const GameModeMenu({
    required this.setValue,
    required this.setShowGameTypeFilters,
    required this.setShowDestinationFilters,
    required this.showFilters,
    required this.textFormKey,
    super.key,
  });

  final void Function(String?) setValue;
  final void Function(bool) setShowGameTypeFilters;
  final void Function(bool) setShowDestinationFilters;
  final bool showFilters;
  final GlobalKey<FormFieldState<String>> textFormKey;

  @override
  State<GameModeMenu> createState() => _GameModeMenuState();
}

class _GameModeMenuState extends State<GameModeMenu> {
  String? Function(String?)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a game mode';
        }
        if (!filteredGameModes.contains(value)) {
          return 'Invalid game mode';
        }
        return null;
      };

  void runFilter(String? value) {
    List<String> results = [];
    if (value == null || value.isEmpty) {
      results = gameModes;
    } else {
      _controller.text = value;
      results = gameModes
          .where(
              (element) => element.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredGameModes = results;
      _validationError = null;
    });
  }

  final TextEditingController _controller = TextEditingController();

  List<String> gameModes = <String>[
    "冒險",
    "動作",
    "射擊",
    "策略",
    "隨機"
  ];
  List<String> filteredGameModes = <String>[];

  String? _validationError;
  bool get _hasValidationError => _validationError != null;
  bool get _showErrorBelowField => _hasValidationError;

  @override
  initState() {
    super.initState();
    filteredGameModes = gameModes;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showFilters) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textHint(context),
              textInput(context),
              filteredResults(context),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textHint(context),
            textInput(context),
          ],
        ),
      );
    }
  }

  Widget textHint(BuildContext context) {
    return Text(
      'Game Type',
      style: TextStyle(
        fontSize: 12,
        color: _showErrorBelowField
            ? Colors.red
            : Theme.of(context).textTheme.bodySmall!.color,
      ),
    );
  }

  Widget textInput(BuildContext context) {
    return TextFormField(
      key: widget.textFormKey,
      controller: _controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: _showErrorBelowField
            ? Colors.red.shade100
            : Theme.of(context).inputDecorationTheme.fillColor,
        errorText: _showErrorBelowField ? '' : null,
      ),
      onTap: () {
        widget.setShowGameTypeFilters(true);
        widget.setShowDestinationFilters(false);
      },
      onChanged: runFilter,
      onSaved: widget.setValue,
      validator: (value) {
        final error = validator?.call(value);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _validationError = error;
          });
        });
        return error;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget filteredResults(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: filteredGameModes.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 1,
              child: ListTile(
                title: Text(filteredGameModes[index]),
                subtitle: Text(filteredGameModes[index]),
                onTap: () {
                  _controller.text = filteredGameModes[index];
                  runFilter(filteredGameModes[index]);
                  widget.setShowGameTypeFilters(false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
