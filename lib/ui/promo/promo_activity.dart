import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:http/http.dart' as http;

import '../../model/Menu.dart';
import '../../model/Price.dart';
import '../../model/Promo.dart';

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

class PromoActivity extends StatefulWidget {
  @override
  _PromoActivityState createState() => _PromoActivityState();
}

class _PromoActivityState extends State<PromoActivity> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  bool isLoading = false;
  String inCart = "";
  String name = "";

  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> qty = [];

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  List<Promo> promo = [];
  Future<void> _getPromo(String lat, String long)async{
    List<Promo> _promo = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/promo?lat=$lat&long=$long', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['promo']){
      Promo p = Promo(
        menu: Menu(
            id: v['id'],
            name: v['name'],
            restoId: v['resto_id'].toString()??'4',
            desc: v['desc'],
            urlImg: v['img'],
            price: Price.discounted(int.parse(v['price']), v['discounted_price'])
        ),
      );
      _promo.add(p);
    }
    setState(() {
      promo = _promo;
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
      _getPromo(value.latitude.toString(), value.longitude.toString());
    });
    _getData();
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

  Future _getData()async{
    menuJson = [];
    restoId = [];
    qty = [];
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    inCart = pref2.getString('inCart')??"";
    if(pref2.getString('inCart') == '1'){
      name = pref2.getString('menuJson')??"";
      print("Ini pref2 " +name+" SP");
      restoId.addAll(pref2.getStringList('restoId')??[]);
      print(restoId);
      qty.addAll(pref2.getStringList('qty')??[]);
      print(qty);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getPromo(value.latitude.toString(), value.longitude.toString());
    });
    _getData();
    super.initState();
    getHomePg();
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 32,
                  ),
                  (homepg != "1")?CustomText.textHeading3(
                    text: "Penawaran Terbaik",
                    color: CustomColor.primary,
                    minSize: 18,
                    maxLines: 1
                  ):CustomText.textHeading3(
                      text: "Promo di Restoranmu",
                      color: CustomColor.primary,
                      minSize: 18,
                      maxLines: 1
                  ),
                  (homepg != "1")?CustomText.textHeading3(
                      text: "di Sekitarmu",
                      color: CustomColor.primary,
                      minSize: 18,
                      maxLines: 1
                  ):Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: promo.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                          child: GestureDetector(
                            onTap: (){
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                  ),
                                  context: context,
                                  builder: (_){
                                    return StatefulBuilder(
                                        builder: (_, setStateModal){
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                                child: Divider(thickness: 4,),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                              Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  height: CustomSize.sizeWidth(context) / 1.2,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(Links.subUrl + promo[index].menu.urlImg),
                                                        fit: BoxFit.cover
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText.textHeading5(
                                                        text: promo[index].menu.name,
                                                        minSize: 18,
                                                        maxLines: 1
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyRegular16(
                                                        text: promo[index].menu.desc,
                                                        maxLines: 100,
                                                        minSize: 16
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        CustomText.bodyMedium16(
                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.original),
                                                            maxLines: 1,
                                                            minSize: 16
                                                        ),
                                                        (restoId.contains(promo[index].menu.id.toString()) != true)?SizedBox():Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: ()async{
                                                                if(int.parse(qty[restoId.indexOf(promo[index].menu.id.toString())]) > 1){
                                                                  String s = qty[restoId.indexOf(promo[index].menu.id.toString())];
                                                                  print(s);
                                                                  int i = int.parse(s) - 1;
                                                                  print(i);
                                                                  qty[restoId.indexOf(promo[index].menu.id.toString())] = i.toString();
                                                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                                                  pref.setStringList("qty", qty);
                                                                  setStateModal(() {});
                                                                  setState(() {});
                                                                }
                                                              },
                                                              child: Container(
                                                                width: CustomSize.sizeWidth(context) / 12,
                                                                height: CustomSize.sizeWidth(context) / 12,
                                                                decoration: BoxDecoration(
                                                                    color: CustomColor.accentLight,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
                                                              ),
                                                            ),
                                                            SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                            CustomText.bodyRegular16(text: qty[restoId.indexOf(promo[index].menu.id.toString())]),
                                                            SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                            GestureDetector(
                                                              onTap: ()async{
                                                                String s = qty[restoId.indexOf(promo[index].menu.id.toString())];
                                                                print(s);
                                                                int i = int.parse(s) + 1;
                                                                print(i);
                                                                qty[restoId.indexOf(promo[index].menu.id.toString())] = i.toString();
                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                pref.setStringList("qty", qty);
                                                                setStateModal(() {});
                                                                setState(() {});
                                                              },
                                                              child: Container(
                                                                width: CustomSize.sizeWidth(context) / 12,
                                                                height: CustomSize.sizeWidth(context) / 12,
                                                                decoration: BoxDecoration(
                                                                    color: CustomColor.accentLight,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                              (restoId.contains(promo[index].menu.id.toString()) != true)?Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.1,
                                                  height: CustomSize.sizeHeight(context) / 14,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primary,
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  child: GestureDetector(
                                                      onTap: ()async{
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        String checkId = pref.getString('restaurantId')??'';

                                                        if(checkId == promo[index].menu.restoId || checkId == ''){
                                                          MenuJson m = MenuJson(
                                                            id: promo[index].menu.id,
                                                            name: promo[index].menu.name,
                                                            desc: promo[index].menu.desc,
                                                            price: promo[index].menu.price.original.toString(),
                                                            discount: promo[index].menu.price.discounted.toString(),
                                                            urlImg: promo[index].menu.urlImg,
                                                          );
                                                          menuJson.add(m);
                                                          // List<String> _restoId = [];
                                                          // List<String> _qty = [];
                                                          restoId.add(promo[index].menu.id.toString());
                                                          qty.add("1");
                                                          inCart = '1';

                                                          String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                          pref.setString('restaurantId', promo[index].menu.restoId);
                                                          pref.setString('inCart', '1');
                                                          pref.setString("menuJson", json1);
                                                          pref.setStringList("restoId", restoId);
                                                          pref.setStringList("qty", qty);

                                                          setStateModal(() {});
                                                          setState(() {});
                                                        }else{
                                                          Fluttertoast.showToast(
                                                            msg: "Ada menu yang belum checkout di keranjangmu",);
                                                        }
                                                      },
                                                      child: Center(child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white))
                                                  ),
                                                ),
                                              )
                                                  :SizedBox(),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            ],
                                          );
                                        }
                                    );
                                  }
                              );
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              height: CustomSize.sizeWidth(context) / 2.6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 2.6,
                                    height: CustomSize.sizeWidth(context) / 2.6,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(Links.subUrl + promo[index].menu.urlImg),
                                        fit: BoxFit.cover
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  SizedBox(
                                    width: CustomSize.sizeWidth(context) / 32,
                                  ),
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 2.1,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText.bodyLight12(
                                                text: "0.9 km",
                                              maxLines: 1,
                                                minSize: 12
                                            ),
                                            (homepg != "1")?Container():Row(
                                              children: [
                                                Icon(Icons.edit, color: CustomColor.primary,),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                                Icon(Icons.delete, color: CustomColor.primary,),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        CustomText.textHeading4(
                                            text: promo[index].menu.name,
                                            minSize: 18,
                                            maxLines: 1
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        CustomText.bodyMedium12(
                                            text: promo[index].menu.desc,
                                          maxLines: 1,
                                          minSize: 12
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                        Row(
                                          children: [
                                            CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.original), minSize: 12,
                                                decoration: TextDecoration.lineThrough),
                                            SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                            CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                ],
              ),
            ),
          ),
        ),
      ),
        floatingActionButton: (homepg != '1')?Container():GestureDetector(
          onTap: (){
            // Navigator.push(
            //     context,
            //     PageTransition(
            //         type: PageTransitionType.rightToLeft,
            //         child: CartActivity()));
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 6.6,
            height: CustomSize.sizeWidth(context) / 6.6,
            decoration: BoxDecoration(
                color: CustomColor.primary,
                shape: BoxShape.circle
            ),
            child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
          ),
        )
    );
  }
}
