import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart' as cart;
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show cos, sqrt, asin;

class SearchAddressMaps extends StatefulWidget {
  double latitude;
  double longitude;

  SearchAddressMaps(this.latitude, this.longitude);

  @override
  _SearchAddressMapsState createState() => _SearchAddressMapsState(latitude, longitude);
}

class Secrets {
  // Add your Google Maps API Key here
  static const API_KEY = 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE';
}

class _SearchAddressMapsState extends State<SearchAddressMaps> {
  double latitude;
  double longitude;
  String address = "";

  TextEditingController _textSearch = TextEditingController(text: "");

  _SearchAddressMapsState(this.latitude, this.longitude);

  var geolocator = Geolocator();
  double? _lat;
  double? _long;
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();
  bool isMove = false;

  String restoAddress = '';

  Future addressTok() async{
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    restoAddress = (pref2.getString('alamateResto')??"");
  }

  late Position _currentPosition;
  String _currentAddress = '';

  Set<Marker> markers = {};

  List<dynamic> data = [];
  Future<bool> _calculateDistance(lat1, lon1, lat2, lon2) async {
    try {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 - c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) *
              (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }
    double totalDistance = 0;
    for(var i = 0; i < data.length-1; i++){
      totalDistance += calculateDistance(data[i+1]["lat"], data[i+1]["long"], data[i]["lat"], data[i]["long"]);
    }
    print('iki loh cok '+totalDistance.toString().split('.')[0]+'.'+totalDistance.toString().split('.')[1].split('')[0]+totalDistance.toString().split('.')[1].split('')[1]);
    print('iki loh cok2 '+totalDistance.toString());
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("distan", totalDistance.toString().split('.')[0]+'.'+totalDistance.toString().split('.')[1].split('')[0]+totalDistance.toString().split('.')[1].split('')[1]);
    return true;
    } catch (e) {
      print(e);
    }
    return false;
  }


  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }


    _createPolylines(
      double latitude,
      double longitude,
      double _lat,
      double _long,
      ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(latitude, longitude),
      PointLatLng(_lat, _long),
      travelMode: TravelMode.transit,
    );
    print('opi ap api oyy');
    print(result.points);

    if (result.points.isNotEmpty) {
      print(result.points);
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }
  double distan = 0.0;

  Map<PolylineId, Polyline> polylines = {};
  late PolylinePoints polylinePoints;

  List<LatLng> polylineCoordinates = [];
  String? _placeDistance;


  double lat1 = 0.0;
  double long1 = 0.0;
  Future getLatLong()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    lat1 = double.parse(pref.getString('latResto1')??'');
    long1 = double.parse(pref.getString('longResto1')??'');
  }

  @override
  void initState() {
    getLatLong();
    setState(() {
      addressTok();
      _lat = latitude;
      _long = longitude;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(latitude, longitude),
                    zoom: 18,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                  onCameraIdle: () async{
                    var addresses = await
                    placemarkFromCoordinates(double.parse(_lat.toString()), double.parse(_long.toString()),
                        localeIdentifier: 'id_ID').then((placemarks) async {
                      setState(() {
                        // latitude = widget.lat!;
                        // longitude = widget.long!;
                        address = placemarks[0].street! +
                            ', ' +
                            placemarks[0].subLocality! +
                            ', ' +
                            placemarks[0].locality! +
                            ', ' +
                            placemarks[0].subAdministrativeArea! +
                            ', ' +
                            placemarks[0].administrativeArea! +
                            ' ' +
                            placemarks[0].postalCode! +
                            ', ' +
                            placemarks[0].country!;
                      });
                    });
                    var first = addresses.streetAddress;
                    setState(() {
                      isMove = false;
                      address = first.toString();
                    });
                  },
                  onCameraMoveStarted: (){
                    setState(() {
                      isMove = true;
                      address = "Loading";
                    });
                  },
                  onCameraMove: (position){
                    setState(() {
                      print(position);
                      _lat = position.target.latitude;
                      _long = position.target.longitude;
                    });
                  },
                ),
              ),
              Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: MediaQuery.of(context).size.height / 16,
                        decoration: BoxDecoration(
                            color: Colors.white,
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Center(child: Text(address)),
                        ),
                      ),
                      Icon((isMove != true)?Icons.location_on:Icons.location_off, size: 32, color: Colors.grey,),
                      SizedBox(height: MediaQuery.of(context).size.height / 11,)
                    ],
                  )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.6,
                    height: MediaQuery.of(context).size.height / 18,
                    decoration: BoxDecoration(
                      color: CustomColor.primary,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(6.0),
                      color: Colors.transparent,
                      child: AnimatedSwitcher(
                          duration: Duration.zero,
                          child: InkWell(
                            onTap: () async{
                              if (address == 'Loading') {

                              } else {
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                latitude = lat1;
                                longitude = long1;
                                distan = await Geolocator.distanceBetween( latitude, longitude, double.parse(_lat.toString()), double.parse(_long.toString()),);
                                print(distan.toString());
                                print(distan.toString().length);
                                pref.setString("addressDelivTrans", address);
                                pref.setString("lat", latitude.toString());
                                pref.setString("long", longitude.toString());
                                pref.setString("latUser", _lat.toString());
                                pref.setString("longUser", _long.toString());
                                // pref.setString("distan", distan.toString());
                                // if (distan.toString().split('.')[0].length == 3) {
                                //   pref.setString("distan", distan.toString().split('.')[0].split('')[0]);
                                // } else {
                                //   pref.setString("distan", '1');
                                // }
                                // polylineCoordinates.add(LatLng(latitude, longitude));
                                // polylineCoordinates.add(LatLng(_lat, _long));
                                data = [{'lat':latitude,'long':longitude},{'lat':_lat,'long':_long}];
                                _calculateDistance(latitude,longitude,_lat,_long);
                                print(address);
                                print(latitude.toString() +" "+ longitude.toString() +" "+ _lat.toString() +" "+ _long.toString() );
                                Navigator.pop(context, "v");
                                // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade,
                                //     child:new CartActivity(token, inCart, order, address,
                                //         (distan.toInt() < 1000)?"1000":distan.toInt().toString(),ongkir)));
                              }
                            },
                            splashColor: Colors.white,
                            borderRadius: BorderRadius.circular(6.0),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 4.0),
                                child: Text("Choose Location", style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          )
                      ),
                    )
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: CustomSize.sizeWidth(context) / 1.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.6),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _textSearch,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v)async{
                          // var addresses = await Geocoder.local.findAddressesFromQuery(v);
                          List<Location> addresses = await locationFromAddress(v);

                          CameraPosition cPosition = CameraPosition(
                            zoom: 18,
                            // tilt: 80,
                            // bearing: 30,
                            target: LatLng(addresses[0].latitude,
                                addresses[0].longitude),
                          );

                          final GoogleMapController controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
                        },
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(0),
                          hintText: "Cari alamat",
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 16)),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
