import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({
    required this.mapboxMapKey,
    required this.destLat,
    required this.destLng,
    required this.setLatLng,
    super.key
  });

  final GlobalKey<State> mapboxMapKey;
  final double destLat;
  final double destLng;
  final void Function(LatLng) setLatLng;
  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late MapboxMapController? mapController;

  _onMapCreated(MapboxMapController controller) async {
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
        myLocationEnabled: true,
        trackCameraPosition: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.destLat, widget.destLng),
          zoom: 9.0,
        ),
        onMapClick: (_, latlng) async {
          widget.setLatLng(latlng);
          await mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 0.0,
                target: LatLng(latlng.latitude, latlng.longitude),
                tilt: 20.0,
                zoom: 15.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
