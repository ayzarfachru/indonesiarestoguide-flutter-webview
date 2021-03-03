import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indonesiarestoguide/ui/cart/cart_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchAddressMaps extends StatefulWidget {
  double latitude;
  double longitude;

  SearchAddressMaps(this.latitude, this.longitude);

  @override
  _SearchAddressMapsState createState() => _SearchAddressMapsState(latitude, longitude);
}

class _SearchAddressMapsState extends State<SearchAddressMaps> {
  double latitude;
  double longitude;
  String address = "";

  _SearchAddressMapsState(this.latitude, this.longitude);

  var geolocator = Geolocator();
  double _lat;
  double _long;
  GoogleMapController mapController;
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
                    var addresses = await Geocoder.local.findAddressesFromCoordinates(new Coordinates(_lat, _long));
                    var first = addresses.first;
                    setState(() {
                      isMove = false;
                      address = first.addressLine ;
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
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              latitude = double.parse(pref.getString('latResto'));
                              longitude = double.parse(pref.getString('longResto'));
                              double distan = await Geolocator().distanceBetween( latitude, longitude, -7.3323158, 112.7989505);
                              print(distan.toInt().toString());
                              pref.setString("address", address);
                              pref.setString("lat", latitude.toString());
                              pref.setString("long", longitude.toString());
                              pref.setString("distan", distan.toInt().toString());
                              print(address);
                              print(latitude.toString() +" "+ longitude.toString() +" "+ _lat.toString() +" "+ _long.toString() );
                              Navigator.pop(context, "v");
                              // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade,
                              //     child:new CartActivity(token, inCart, order, address,
                              //         (distan.toInt() < 1000)?"1000":distan.toInt().toString(),ongkir)));
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
            ],
          ),
        )
    );
  }
}
