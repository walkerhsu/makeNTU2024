import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search/mapbox_search.dart';

import 'location_picker.dart';
import '../my_location.dart';

class DestinationField extends StatefulWidget {
  const DestinationField({
    required this.setValue,
    required this.setShowGameTypeFilters,
    required this.setShowDestinationFilters,
    required this.showFilters,
    required this.textFormKey,
    super.key,
  });

  final void Function(String?, LatLng?) setValue;
  final void Function(bool) setShowGameTypeFilters;
  final void Function(bool) setShowDestinationFilters;
  final bool showFilters;
  final GlobalKey<FormFieldState<String>> textFormKey;

  @override
  State<DestinationField> createState() => _DestinationFieldState();
}

class _DestinationFieldState extends State<DestinationField> {
  final TextEditingController _controller = TextEditingController();
  String? _validationError;
  bool get _hasValidationError => _validationError != null;
  bool get _showErrorBelowField => _hasValidationError;

  List<Map<String, dynamic>> filteredLocations = [];
  late double destLat;
  late double destLng;

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
    List<Map<String, dynamic>> results = [];
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
      double? lat = place.geometry?.coordinates.lat;
      double? long = place.geometry?.coordinates.long;
      if (address == "" && lat != null && long != null) {
        // reverse geocoding
        address = await reverseGeoCoding(lat, long);
      }
      results.add({
        "text": place.text ?? "",
        "address": place.properties?.address ?? address,
        "coordinates": lat != null && long != null ? "$lat, $long" : "",
      });
    }
    setState(() {
      filteredLocations = results;
    });
  }

  Future<String> reverseGeoCoding(double lat, double long) async {
    var reverseGeoCoding = GeoCoding(
      limit: 1,
    );

    Future<ApiResponse<List<MapBoxPlace>>> getAddress() =>
        reverseGeoCoding.getAddress(
          (lat: lat, long: long),
        );

    ApiResponse<List<MapBoxPlace>> addressResponse = await getAddress();
    if (addressResponse.success != null) {
      return addressResponse.success?[0].text ?? "";
    } else {
      log(addressResponse.failure!.error ?? "");
      return "";
    }
  }

  void saveValue(String? value) {
    widget.setValue(value, LatLng(destLat, destLng));
  }

  void setLatLng(LatLng latlng) {
    log(latlng.toString());
    setState(() {
      destLat = latlng.latitude;
      destLng = latlng.longitude;
    });
  }

  @override
  initState() {
    super.initState();
    MyLocation.handleCurrentPosition().then((latlng) => {
      destLat = latlng.latitude,
      destLng = latlng.longitude,
    });
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
                        reverseGeoCoding(destLat, destLng).then((address) {
                          _controller.text =
                              address == "" ? "$destLat, $destLng" : address;
                        });
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
      onSaved: saveValue,
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
                    if (filteredLocations[index]["coordinates"] != "") {
                      log((filteredLocations[index]["coordinates"]
                          .split(", ")[0] as String));
                      log((filteredLocations[index]["coordinates"]
                          .split(", ")[1] as String));
                      setLatLng(LatLng(
                        double.parse((filteredLocations[index]["coordinates"]
                            .split(", ")[0] as String)),
                        double.parse((filteredLocations[index]["coordinates"]
                            .split(", ")[1] as String)),
                      ));
                    }
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
