import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart' as cart;
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchAddressMapsResto extends StatefulWidget {
  double latitude;
  double longitude;

  SearchAddressMapsResto(this.latitude, this.longitude);

  @override
  _SearchAddressMapsRestoState createState() => _SearchAddressMapsRestoState(latitude, longitude);
}

class _SearchAddressMapsRestoState extends State<SearchAddressMapsResto> {
  double latitude;
  double longitude;
  String address = "";

  TextEditingController _textSearch = TextEditingController(text: "");

  _SearchAddressMapsRestoState(this.latitude, this.longitude);

  var geolocator = Geolocator();
  double? _lat;
  double? _long;
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();
  bool isMove = false;

  @override
  void initState() {
    setState(() {
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
                    // geoCode.reverseGeocoding(latitude: double.parse(_lat.toString()), longitude: double.parse(_long.toString()));
                    // Geocoder2.getDataFromCoordinates(latitude: double.parse(_lat.toString()), longitude: double.parse(_long.toString()), googleMapApiKey: 'AIzaSyB6JZGEaiyrHrG0PvrvHTFr72RMCU9Wn7c');
                    // var first = addresses.first;
                    setState(() {
                      isMove = false;
                      // address = addresses.streetAddress.toString();
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
                              if (address == "Loading") {

                              } else {
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                // latitude = double.parse(pref.getString('latResto'));
                                // longitude = double.parse(pref.getString('longResto'));
                                double distan = await Geolocator.distanceBetween( latitude, longitude, -7.3382452, 112.7271302);
                                print(distan.toInt().toString());
                                pref.setString("address", address);
                                pref.setString("latitudeResto", _lat.toString());
                                pref.setString("longitudeResto", _long.toString());
                                pref.setString("distan", distan.toInt().toString());
                                print(_lat);
                                print(_long);
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
