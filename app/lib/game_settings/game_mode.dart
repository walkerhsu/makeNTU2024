import 'package:flutter/material.dart';

class GameModeMenu extends StatefulWidget {
  const GameModeMenu({
    required this.setValue,
    super.key,
  });

  final void Function(String?) setValue;

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

  void _runFilter(String? value) {
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
      _showFilters = true;
      _validationError = null;
    });
  }

  final TextEditingController _controller = TextEditingController();

  List<String> gameModes = <String>[
    "Fantasy",
    "Mystery",
    "Action",
    "Adventure",
    "Horror",
    "A",
    "B",
    "C",
    "D",
    "E"
  ];
  List<String> filteredGameModes = <String>[];

  bool _showFilters = false;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Mode',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: _showErrorBelowField
                  ? Colors.red.shade100
                  : Theme.of(context).inputDecorationTheme.fillColor,
              errorText: _showErrorBelowField ? '' : null,
              suffixIcon: const Icon(Icons.search),
            ),
            onSaved: widget.setValue,
            validator: (value) {
              final error = validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _validationError = error;
                });
              });
              return null;
            },
            onChanged: _runFilter,
            onTap: () {
              setState(() {
                _showFilters = true;
              });
            },
          ),
          if (_showErrorBelowField)
            Text(
              _validationError!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          if (_showFilters)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Scrollbar(
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: filteredGameModes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 1,
                        child: ListTile(
                          title: Text(filteredGameModes[index]),
                          onTap: () {
                            _controller.text = filteredGameModes[index];
                            _runFilter(filteredGameModes[index]);
                            setState(() {
                              _showFilters = false;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
