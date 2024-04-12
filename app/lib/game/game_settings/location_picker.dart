import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog(
      {required this.mapboxMapKey,
      required this.destLat,
      required this.destLng,
      required this.setLatLng,
      super.key});

  final GlobalKey<State> mapboxMapKey;
  final double destLat;
  final double destLng;
  final void Function(LatLng) setLatLng;
  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late MapboxMapController mapController;
  Symbol? symbol;

  Future<void> moveCamera(LatLng latlng, double zoom,
      {double bearing = 0.0, double tilt = 0.0}) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: bearing,
          target: LatLng(latlng.latitude, latlng.longitude),
          tilt: tilt,
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> addMarker(LatLng latlng) async {
    if (symbol != null) {
      await mapController.removeSymbol(symbol!);
    }
    symbol = await mapController.addSymbol(SymbolOptions(
      geometry: latlng,
      iconImage: "assets/images/map_mark.png",
      iconSize: 0.2,
    ));
  }

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.5,
      child: MapboxMap(
        key: widget.mapboxMapKey,
        styleString: 'mapbox://styles/walkerhsu/clmx0qvh1023701r940xsdpnb',
        accessToken: dotenv.get('MAPBOX_ACCESS_TOKEN'),
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: () {
          addMarker(LatLng(widget.destLat, widget.destLng));
        },
        myLocationEnabled: true,
        trackCameraPosition: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.destLat, widget.destLng),
          zoom: 15.0,
        ),
        onMapClick: (_, latlng) async {
          widget.setLatLng(latlng);
          addMarker(latlng);
          moveCamera(latlng, 18.0, tilt: 20.0);
        },
      ),
    );
  }
}
