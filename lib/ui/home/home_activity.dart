import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Promo.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/ui/bookmark/bookmark_activity.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/history/history_activity.dart';
import 'package:indonesiarestoguide/ui/profile/profile_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Location {
  /// Initializes the plugin and starts listening for potential platform events.
  factory Location() => instance;

  Location._();

  static final Location instance = Location._();

  /// Change settings of the location request.
  ///
  /// The [accuracy] argument is controlling the precision of the
  /// [LocationData]. The [interval] and [distanceFilter] are controlling how
  /// often a new location is sent through [onLocationChanged].
  ///
  /// [interval] and [distanceFilter] are not used on web.
  Future<bool> changeSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    return LocationPlatform.instance.changeSettings(
      accuracy: accuracy,
      interval: interval,
      distanceFilter: distanceFilter,
    );
  }

  /// Gets the current location of the user.
  ///
  /// Throws an error if the app has no permission to access location.
  /// Returns a [LocationData] object.
  Future<LocationData> getLocation() async {
    return LocationPlatform.instance.getLocation();
  }

  /// Checks if the app has permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> hasPermission() {
    return LocationPlatform.instance.hasPermission();
  }

  /// Requests permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> requestPermission() {
    return LocationPlatform.instance.requestPermission();
  }

  /// Checks if the location service is enabled.
  Future<bool> serviceEnabled() {
    return LocationPlatform.instance.serviceEnabled();
  }

  /// Request the activation of the location service.
  Future<bool> requestService() {
    return LocationPlatform.instance.requestService();
  }

  /// Returns a stream of [LocationData] objects.
  /// The frequency and accuracy of this stream can be changed with
  /// [changeSettings]
  ///
  /// Throws an error if the app has no permission to access location.
  Stream<LocationData> get onLocationChanged {
    return LocationPlatform.instance.onLocationChanged;
  }
}

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  ScrollController _scrollController = ScrollController();
  List<String> images = ["t", "f"];

  List<Resto> resto = [];
  List<Resto> again = [];
  List<Menu> promo = [];
  Future _getDataHome(String lat, String long)async{
    List<Resto> _resto = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: v['distance'],
          img: v['img']
      );
      _resto.add(r);
    }

    for(var v in data['again']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: v['distance'],
          img: v['img']
      );
      _again.add(r);
    }

    for(var v in data['promo']){
      Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoName: v['resto_name'],
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: v['resto_distance']
      );
      _promo.add(m);
    }

    setState(() {
      resto = _resto;
      again = _again;
      promo = _promo;
    });
  }

  @override
  void initState() {
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getDataHome(value.latitude.toString(), value.longitude.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context) / 3,
                child: Stack(
                  children: [
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.8,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          height: CustomSize.sizeHeight(context) / 3.8,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: images.map((e) {
                          return Container(
                            color: (e != "t")?Colors.black:Colors.amber,
                          );
                        }).toList(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 7,
                              offset: Offset(0, 7), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Pesananmu",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.4,
                                height: CustomSize.sizeHeight(context) / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 4.8,
                                        height: CustomSize.sizeHeight(context) / 6.8,
                                        decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                      SizedBox(width: CustomSize.sizeWidth(context) / 36,),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 63),
                                        child: Container(
                                          width: CustomSize.sizeWidth(context) / 2.4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText.bodyMedium14(text: "Rumah Makan Selera Bunda", minSize: 14, maxLines: 2),
                                                  CustomText.bodyLight12(text: "01 Jan 2021, 10:00", minSize: 12),
                                                  CustomText.bodyMedium12(text: "Pesan Antar", minSize: 12),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight12(text: "Diproses", minSize: 12, color: Colors.amberAccent),
                                                  CustomText.bodyMedium14(text: "35.000", minSize: 14),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Resto Dekat Sini",
                          maxLines: 1
                      ),
                    ),
                    (resto != [])?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: resto.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: DetailResto(resto[index].id.toString())));
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 2.3,
                                  height: CustomSize.sizeHeight(context) / 3.6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 5.8,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + resto[index].img),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyRegular14(text: resto[index].distance.toString() + " km"),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyMedium16(text: resto[index].name),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ):Container(),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Lagi Diskon",
                          maxLines: 1
                      ),
                    ),
                    (promo != [])?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: promo.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.3,
                                height: CustomSize.sizeHeight(context) / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 3,
                                      height: CustomSize.sizeHeight(context) / 5,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + promo[index].urlImg),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeHeight(context) / 5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText.bodyRegular12(text: promo[index].distance.toString() + " Km", minSize: 12),
                                                CustomText.textTitle6(text: promo[index].name, minSize: 14, maxLines: 2),
                                                CustomText.bodyMedium12(text: promo[index].restoName, minSize: 12),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price.original), minSize: 12,
                                                    decoration: TextDecoration.lineThrough),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price.discounted), minSize: 12),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ):Container(),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Pesan Lagi",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: again.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 2.3,
                                height: CustomSize.sizeHeight(context) / 3.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.3,
                                      height: CustomSize.sizeHeight(context) / 5.8,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + again[index].img),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyRegular14(text: again[index].distance.toString() + " Km"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyMedium16(text: again[index].name),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 8,)
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
        child: Container(
          width: CustomSize.sizeWidth(context) / 1.12,
          height: CustomSize.sizeHeight(context) / 12,
          decoration: BoxDecoration(
            color: CustomColor.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(MaterialCommunityIcons.percent, size: 32, color: Colors.white,),
              GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: BookmarkActivity()));
                  },
                  child: Icon(MaterialCommunityIcons.bookmark, size: 32, color: Colors.white,)),
              GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: HistoryActivity()));
                  },
                  child: Icon(MaterialCommunityIcons.shopping, size: 32, color: Colors.white,)),
              Icon(FontAwesome.search, size: 32, color: Colors.white,),
              GestureDetector(
                onTap: (){
                  setState(() {
                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                  });
                },
                child: Icon(Ionicons.md_person, size: 32, color: Colors.white,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}