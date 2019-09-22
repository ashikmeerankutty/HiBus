import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hibus/model/bus.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final Map<String, Marker> _markers = {};

  LatLng center = const LatLng(10.0271222, 76.3059966);

  var location = new Location();

  LocationData userLocation;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    LocationData loc = await _getLocation();
    setState(() {
      loading = true;
      userLocation = loc;
    });
    List<Bus> data = await _fetchData();
    setState(() {
      // _markers.clear();
      busRoutes = data;
      for (int i = 0; i < data.length; i++) {
        final marker = Marker(
          markerId: MarkerId(data[i].regId),
          position: LatLng(
              data[i].lastKnown["longitude"], data[i].lastKnown["latitude"]),
          infoWindow: InfoWindow(
            title: data[i].type,
            snippet: data[i].distance.toInt().toString() + "m away",
          ),
        ).copyWith(iconParam: myIcon);
        _markers[data[i].regId] = marker;
      }
    });
  }

  List<Bus> busRoutes;

  Future<LocationData> _getLocation() async {
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  MarkerId selectedMarker;

  bool loading = false;

  Future<List<Bus>> _fetchData() async {
    print(userLocation.latitude);
    print(userLocation.longitude);
    Map<String,dynamic> data = {
      "latitude": userLocation.latitude,
      "longitude": userLocation.longitude,
      "requestedAt": 1234
    };

    // Map<String, dynamic> data = {
    //   "latitude": 10.0271222,
    //   "longitude": 76.3059966,
    //   "requestedAt": 12334
    // };
    var body = json.encode(data);
    final response = await http.post(
        'https://hibus.abhijithvijayan.in/api/v1/bus/fetch',
        body: body,
        headers: {"Content-Type": "application/json"});
    print(response.body);
    if (response.statusCode == 403) return [];
    if (response.statusCode == 200) {
      final rawData = json.decode(response.body);
      final rawDataList = rawData["busRecords"] as List;
      return rawDataList.map((rawData) {
        return Bus.fromJson(rawData);
      }).toList();
    }
    return [];
  }

  BitmapDescriptor myIcon;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)), 'assets/bus.jpg')
        .then((onValue) {
      myIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 2,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 11.0,
            ),
            markers: _markers.values.toSet(),
          ),
        ),
        busRoutes != null
            ? busRoutes.length == 0
                ? Padding(
                  padding: EdgeInsets.only(top:20),
                  child:
                  Text('No buses available',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),))
                : Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: busRoutes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return busListItem(busRoutes[index]);
                        }))
            : Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator()),
      ],
    );
  }
}

Widget busListItem(Bus bus) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 0.1),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.directions_bus),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Text(bus.regId),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top:5.0,bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(bus.route["source"].toString()+ " - ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                    Text(bus.route["destination"].toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 3.0, top: 2.0, bottom: 2.0),
                    child: Text(
                      bus.type,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(bus.distance.toInt().toString() + "m away"),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text("Last seen at " + bus.lastSeenAt),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
