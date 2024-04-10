import 'package:flutter/material.dart';

class DestinationField extends StatefulWidget {
  const DestinationField({
    required this.setValue,
    super.key,
  });

  final void Function(String?) setValue;

  @override
  State<DestinationField> createState() => _DestinationFieldState();
}

class _DestinationFieldState extends State<DestinationField> {
  RegExp get _usernameRegex => RegExp(
        r'^(?=.{1,20}$)(?![_])(?!.*[_.]{2})[a-zA-Z0-9_]+(?<![_])$',
      );

  String? Function(String?)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'Username cannot be empty';
        }
        if (!_usernameRegex.hasMatch(value)) {
          return 'Username is not valid';
        }
        return null;
      };

  String? _validationError;

  bool get _hasValidationError => _validationError != null;

  bool get _showErrorBelowField =>
      _hasValidationError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destination',
            style: TextStyle(
              fontSize: 12,
              color: _showErrorBelowField ? Colors.red : Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  _showErrorBelowField ? Colors.red.shade100 : Theme.of(context).inputDecorationTheme.fillColor,
              errorText: _showErrorBelowField ? '' : null,
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
            textInputAction: TextInputAction.next,
          ),
          if (_showErrorBelowField)
            Text(
              _validationError!,
              style: TextStyle(
                fontSize: 12,
                color: _showErrorBelowField ? Colors.red : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}