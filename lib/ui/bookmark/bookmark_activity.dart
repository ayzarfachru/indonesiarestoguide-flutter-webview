import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../utils/utils.dart';
import '../../utils/utils.dart';

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

class BookmarkActivity extends StatefulWidget {
  @override
  _BookmarkActivityState createState() => _BookmarkActivityState();
}

class _BookmarkActivityState extends State<BookmarkActivity> {
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  List<Resto> resto = [];
  Future _getBookmark(String lat, String long)async{
    List<Resto> _resto = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/favresto?lat=$lat&long=$long', headers: {
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

    setState(() {
      resto = _resto;
      isLoading = false;
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getBookmark(value.latitude.toString(), value.longitude.toString());
    });
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }


  @override
  void initState() {
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getBookmark(value.latitude.toString(), value.longitude.toString());
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
        child: (isLoading)?Container(
          width: CustomSize.sizeWidth(context),
            height: CustomSize.sizeHeight(context),
            child: Center(child: CircularProgressIndicator())):SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            distance: 30,
            backgroundColor: Colors.white,
            color: CustomColor.primary,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
              child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 32,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: CustomText.textHeading3(
                      text: "Restoran Favoritmu Nih !",
                      minSize: 18,
                      maxLines: 1
                  ),
                ),
                StaggeredGridView.countBuilder(
                  staggeredTileBuilder: (index) {
                    return StaggeredTile.count(1, 1.2);
                  },
                  crossAxisCount: 2,
                  controller: _scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: resto.length,
                  itemBuilder: (_, index){
                    return Padding(
                      padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 52),
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 2.3,
                        height: CustomSize.sizeHeight(context) / 3,
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
                              width: CustomSize.sizeWidth(context),
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
                              child: CustomText.bodyRegular14(text: resto[index].distance.toString() + " Km"),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                              child: CustomText.bodyMedium16(text: resto[index].name),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
          ),
        ),
            ),
      ),
    );
  }
}
