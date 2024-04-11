import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search/mapbox_search.dart';

import 'location_picker.dart';

class DestinationField extends StatefulWidget {
  const DestinationField({
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
  State<DestinationField> createState() => _DestinationFieldState();
}

class _DestinationFieldState extends State<DestinationField> {
  String? Function(String?)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'Username cannot be empty';
        }
        return null;
      };

  Future<void> searchPlaces(String? value) async {
    bool containsZhuyin(String input) {
      RegExp zhuyinRegex = RegExp(r'[\u3100-\u312F\u31A0-\u31BF]+');
      return zhuyinRegex.hasMatch(input);
    }

    if (value == null || value.isEmpty || containsZhuyin(value)) {
      return;
    }
    List<Map<String, String>> results = [];
    var geocoding = GeoCoding(
      country: "TW",
      limit: 5,
      language: "zh_TW",
      types: [
        PlaceType.address,
        PlaceType.place,
        PlaceType.region,
        PlaceType.country
      ],
    );
    Future<ApiResponse<List<MapBoxPlace>>> getPlaces() => geocoding.getPlaces(
          value,
          proximity: Proximity.Location((lat: 24, long: 121)),
        );

    var places = await getPlaces();
    if (places.success == null) {
      log(places.failure!.error ?? "");
      return;
    }
    for (MapBoxPlace place in places.success!) {
      String address = place.properties?.address ?? "";
      if (address == "" && place.geometry != null) {
        // reverse geocoding
        double lat = place.geometry!.coordinates.lat;
        double long = place.geometry!.coordinates.long;
        var reverseGeoCoding = GeoCoding(
          limit: 1,
        );

        Future<ApiResponse<List<MapBoxPlace>>> getAddress() =>
            reverseGeoCoding.getAddress(
              (lat: lat, long: long),
            );

        ApiResponse<List<MapBoxPlace>> addressResponse = await getAddress();
        if (addressResponse.success != null) {
          address = addressResponse.success![0].text ?? "";
        } else {
          log(addressResponse.failure!.error ?? "");
          address = "";
        }
      }
      results.add({
        "text": place.text ?? "",
        "address": place.properties?.address ?? address,
      });
    }
    setState(() {
      filteredLocations = results;
    });
  }

  final TextEditingController _controller = TextEditingController();
  String? _validationError;
  bool get _hasValidationError => _validationError != null;
  bool get _showErrorBelowField => _hasValidationError;

  List<Map<String, String>> filteredLocations = [];
  double destLat = 24.0;
  double destLng = 121.0;

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
              if (_showErrorBelowField) errorText(context),
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
            if (_showErrorBelowField) errorText(context),
          ],
        ),
      );
    }
  }

  Widget textHint(BuildContext context) {
    return Text(
      'Destination',
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
        suffixIcon: IconButton(
          icon: const Icon(Icons.map),
          onPressed: () {
            _controller.clear();
            // Open dialog with map
            showDialog(
              context: context,
              builder: (BuildContext context) {
                GlobalKey<State> mapboxMapKey = GlobalKey<State>();
                void setLatLng(LatLng latlng) {
                  setState(() {
                    destLat = latlng.latitude;
                    destLng = latlng.longitude;
                  });
                }
                return AlertDialog(
                  title: const Text('Choose the destination'),
                  content: LocationPickerDialog(
                    mapboxMapKey: mapboxMapKey,
                    destLat: destLat,
                    destLng: destLng,
                    setLatLng: setLatLng,
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      child: const Text('Confirm'),
                      onPressed: () {
                        print(destLat);
                        print(destLng);
                        _controller.text = "$destLat, $destLng";
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      onTap: () {
        widget.setShowDestinationFilters(true);
        widget.setShowGameTypeFilters(false);
      },
      onChanged: searchPlaces,
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
    );
  }

  Widget errorText(BuildContext context) {
    return Text(
      _validationError!,
      style: TextStyle(
        fontSize: 12,
        color: _showErrorBelowField ? Colors.red : Colors.black,
      ),
    );
  }

  Widget filteredResults(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
        child: Scrollbar(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: filteredLocations.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 1,
                child: ListTile(
                  title: Text(filteredLocations[index]["text"]!),
                  subtitle: Text(filteredLocations[index]["address"]!),
                  onTap: () {
                    _controller.text = filteredLocations[index]["text"]!;
                    searchPlaces(filteredLocations[index]["text"]!);
                    widget.setShowDestinationFilters(false);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
