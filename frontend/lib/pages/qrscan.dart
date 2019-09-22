import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:hibus/model/coupon.dart';
import 'package:location/location.dart';

import 'package:http/http.dart' as http;

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  String barcode;
  bool isLoading = false;
  Coupon generatedCoupon;

  var location = new Location();

  LocationData userLocation;

  Future<LocationData> _getLocation() async {
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  void initState() {
    super.initState();
    _getLocation().then((value) {
      setState(() {
        userLocation = value;
      });
    });
  }

  final Map<String, String> listUrl = {
    "uber": "images/uber.png",
    "oyo": "images/oyo.png",
    "bookmyshow": "images/bookmyshow.jpeg",
    "zomato": "images/zomato.png"
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
        child: generatedCoupon == null
            ? Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: barcode != null
                          ? Center(
                              child: FutureBuilder<Coupon>(
                                future: fetchCoupon(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Text(
                                              "You Won",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Image.asset(
                                            listUrl[snapshot.data.brand["name"]
                                                .toString()
                                                .toLowerCase()],
                                            height: 150,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Text(
                                              snapshot.data.brand["discount"] +
                                                  " " +
                                                  snapshot.data.brand["type"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Text(
                                              snapshot
                                                  .data.brand["description"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data.promocode,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 24.0),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20.0),
                                                    child: IconButton(
                                                      icon: Icon(
                                                          Icons.content_copy),
                                                      onPressed: () {
                                                        Clipboard.setData(
                                                            new ClipboardData(
                                                                text: snapshot
                                                                    .data
                                                                    .promocode));
                                                      },
                                                    ))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 80.0),
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            )
                          : Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 40.0, top: 20.0),
                                  child: Text(
                                    'Scan QR code on your bus to avail offers',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Image.asset('images/qr.png'),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: RaisedButton(
                                    onPressed: qrScan,
                                    child: Text('Scan'),
                                  ),
                                ),
                              ],
                            ),
                    )
                  ],
                ),
              )
            : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "You Won",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Image.asset(
                      listUrl[generatedCoupon.brand["name"]
                          .toString()
                          .toLowerCase()],
                      height: 150,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        generatedCoupon.brand["discount"] +
                            " " +
                            generatedCoupon.brand["type"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        generatedCoupon.brand["description"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            generatedCoupon.promocode,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24.0),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () {
                                  Clipboard.setData(new ClipboardData(
                                      text: generatedCoupon.promocode));
                                },
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }

  Future qrScan() async {
    try {
      setState(() {
        isLoading = true;
      });
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      fetchCoupon().then((coupon) {
        setState(() => this.generatedCoupon = coupon);
        setState(() {
          isLoading = false;
        });
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  Future<Coupon> fetchCoupon() async {
    var data = {
      "latitude": userLocation.latitude,
      "longitude": userLocation.longitude,
      "lastSeenAt": DateTime.now().toLocal().toString(),
      "busId": barcode
    };
    var body = json.encode(data);
    final response = await http
        .post('https://hibus.abhijithvijayan.in/api/v1/bus/status', body: body, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return Coupon.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load data');
    }
  }
}
