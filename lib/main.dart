import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MaterialApp(
    home: OrderTrackingPage(),
  ));
}

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);
  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  @override
  void initState() {
  getPolyPoints();
  getCurrentLocation();
  super.initState();
}

  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

void getCurrentLocation() async {
    Location location = Location();
location.getLocation().then(
      (location) {
        currentLocation = location;
        setState(() {
          
        });
      },
    );
GoogleMapController googleMapController = await _controller.future;
location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
setState(() {});
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDPaLp13yw8jWQdiEI-g0BAJPapm667DBk", // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
  for (PointLatLng point in result.points) {
    polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  }
  setState(() {});
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
  ? const Center(child: Text("Loading"))
  : GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
            currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 13.5,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(
              currentLocation!.latitude!, currentLocation!.longitude!),
        ),
        const Marker(
          markerId: MarkerId("source"),
          position: sourceLocation,
        ),
        const Marker(
          markerId: MarkerId("destination"),
          position: destination,
        ),
      },
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: const Color(0xFF7B61FF),
          width: 6,
        ),
      },
    ),
    );
  }
}
