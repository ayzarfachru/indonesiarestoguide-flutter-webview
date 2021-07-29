import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Promo.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/model/Transaction.dart';
import 'package:indonesiarestoguide/model/imgBanner.dart';
import 'package:indonesiarestoguide/ui/bonus/es_activity.dart';
import 'package:indonesiarestoguide/ui/bonus/nasgor_activity.dart';
import 'package:indonesiarestoguide/ui/bookmark/bookmark_activity.dart';
import 'package:indonesiarestoguide/ui/cart/cart_activity.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/detail/detail_transaction.dart';
import 'package:indonesiarestoguide/ui/detail/resto_list_activity.dart';
import 'package:indonesiarestoguide/ui/history/history_activity.dart';
import 'package:indonesiarestoguide/ui/history/history_order_activity.dart';
import 'package:indonesiarestoguide/ui/profile/profile_activity.dart';
import 'package:indonesiarestoguide/ui/promo/promo_activity.dart';
import 'package:indonesiarestoguide/ui/search/search_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  ScrollController _scrollController = ScrollController();
  List<imgBanner> images = [];
  bool isLoading = false;
  bool isSearch = false;
  String inCart = "";
  String name = "";

  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> qty = [];
  List<Resto> resto = [];
  List<Resto> again = [];
  List<Menu> promo = [];
  List<Transaction> transaction = [];
  Future _getDataHome(String lat, String long)async{
    List<Resto> _resto = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];
    List<Transaction> _transaction = [];
    List<imgBanner> _images = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long&limit=10', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print(data['resto']);

    print('ini banner '+data['banner'].toString());
    for(var v in data['banner']){
      imgBanner t = imgBanner(
          id: int.parse(v['resto_id'].toString()),
          urlImg: v['img']
      );
      _images.add(t);
    }

    for(var v in data['trans']){
      Transaction t = Transaction(
          id: v['id'],
          date: v['date'],
          img: v['img'],
          nameResto: v['resto_name'],
          status: v['status_text'],
          total: v['total'],
          type: v['type_text']
      );
      _transaction.add(t);
    }

    print('ini resto '+data['resto'].toString());

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    print('ini again '+data['again'].toString());
    for(var v in data['again']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _again.add(r);
    }

    print('ini jmlh promo'+data['promo'].toString());
    for(var v in data['promo']){
      Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          desc: v['desc']??'',
          urlImg: v['img'],
          price: Price.discounted(int.parse(v['price'].toString()), int.parse(v['discounted_price'].toString())),
          distance: double.parse(v['resto_distance'].toString())
      );
      _promo.add(m);
    }
    setState(() {
      images = _images;
      transaction = _transaction;
      resto = _resto;
      again = _again;
      promo = _promo;
      isLoading = false;
    });
  }

  //resto

  // List<History> history = [];
  Future _getUserResto()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    setState(() {
      // history = _history;
      isLoading = false;
    });
  }

  double latitude = 0;
  double longitude = 0;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getDataHome(value.latitude.toString(), value.longitude.toString());
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
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



  String lat = '';
  String long = '';
  List<Menu> menuNG = [];
  List<Resto> restoSrch = [];
  String ng = '';
  // List<Resto> resto = [];
  Future _search(String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=nasi goreng&type=$type&lat=$lat&long=$long&limit=10',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    ng = data['menu'].toString();
    for(var x in data['menu']){
      Menu z = Menu(
        id: x['id'],
        name: x['name'],
        restoId: x['resto_id'].toString(),
        restoName: x['resto_name'],
        urlImg: x['img'],
        price: Price.discounted(x['price'], x['discounted_price']),
        distance: double.parse(x['resto_distance'].toString()),
      );
      _menu.add(z);
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    setState(() {
      menuNG = _menu;
      restoSrch = _resto;
    });
  }


  List<Menu> menuEs = [];
  List<Resto> restoSrch2 = [];
  String es = '';
  // List<Resto> resto = [];
  Future _search2(String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=es&type=$type&lat=$lat&long=$long&limit=10',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    es = data['menu'].toString();
    for(var x in data['menu']){
      Menu z = Menu(
        id: x['id'],
        name: x['name'],
        restoId: x['resto_id'].toString(),
        restoName: x['resto_name'],
        urlImg: x['img'],
        price: Price.discounted(x['price'], x['discounted_price']),
        distance: double.parse(x['resto_distance'].toString()),
      );
      _menu.add(z);
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    setState(() {
      menuEs = _menu;
      restoSrch2 = _resto;
    });
  }


  DateTime currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
      return Future.value(false);
    }
//    SystemNavigator.pop();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }


  @override
  void initState() {
    _getUserResto();
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      _getDataHome(value.latitude.toString(), value.longitude.toString());
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    lat = latitude.toString();
    long = longitude.toString();
    _search('');
    _search2('');
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: (isLoading)?SmartRefresher(
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
              child: Container(
                  width: CustomSize.sizeWidth(context),
                  height: CustomSize.sizeHeight(context),
                  child: Center(child: CircularProgressIndicator())),
            ),
          ):SmartRefresher(
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
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new DetailResto(e.id.toString())));
                                  print(e.id.toString());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(Links.subUrl + e.urlImg),
                                          fit: BoxFit.cover
                                      )
                                  ),
                                ),
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
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,
                                        PageTransition(type: PageTransitionType.rightToLeft,
                                            child: new SearchActivity(promo, latitude.toString(), longitude.toString(), 'Opening Course')));
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 6.5,
                                    height: CustomSize.sizeWidth(context) / 6.5,
                                    decoration: BoxDecoration(
                                        color: CustomColor.primary,
                                        shape: BoxShape.circle
                                    ),
                                    child: Icon(FontAwesomeIcons.cookieBite, color: Colors.white,),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,
                                        PageTransition(type: PageTransitionType.rightToLeft,
                                            child: new SearchActivity(promo, latitude.toString(), longitude.toString(), 'Main Course')));
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 6.5,
                                    height: CustomSize.sizeWidth(context) / 6.5,
                                    decoration: BoxDecoration(
                                        color: CustomColor.primary,
                                        shape: BoxShape.circle
                                    ),
                                    child: Icon(FontAwesomeIcons.hamburger, color: Colors.white,),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,
                                        PageTransition(type: PageTransitionType.rightToLeft,
                                            child: new SearchActivity(promo, latitude.toString(), longitude.toString(), 'Drink')));
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 6.5,
                                    height: CustomSize.sizeWidth(context) / 6.5,
                                    decoration: BoxDecoration(
                                        color: CustomColor.primary,
                                        shape: BoxShape.circle
                                    ),
                                    child: Icon(FontAwesomeIcons.beer, color: Colors.white,),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context,
                                        PageTransition(type: PageTransitionType.rightToLeft,
                                            child: new SearchActivity(promo, latitude.toString(), longitude.toString(), 'Dessert')));
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 6.5,
                                    height: CustomSize.sizeWidth(context) / 6.5,
                                    decoration: BoxDecoration(
                                        color: CustomColor.primary,
                                        shape: BoxShape.circle
                                    ),
                                    child: Icon(FontAwesomeIcons.iceCream, color: Colors.white,),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Pesananmu",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: ()async{
                                  var i = await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new HistoryOrderActivity()));
                                  if(i == null){
                                    _getData();
                                  }
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 5,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (transaction.length < 10)?transaction.length:10,
                              itemBuilder: (_, index){
                                return Padding(
                                  padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                      top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                                  child: GestureDetector(
                                    onTap: (){
                                      if(transaction[index].type.startsWith('Reservasi') != true){
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailTransaction(transaction[index].id, transaction[index].status)));
                                      }
                                    },
                                    child: Container(
                                      width: CustomSize.sizeWidth(context) / 1.2,
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
                                              width: CustomSize.sizeWidth(context) / 3.4,
                                              height: CustomSize.sizeHeight(context) / 6.8,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  image: DecorationImage(
                                                      image: NetworkImage(Links.subUrl + transaction[index].img),
                                                      fit: BoxFit.cover
                                                  )
                                              ),
                                            ),
                                            SizedBox(width: CustomSize.sizeWidth(context) / 36,),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 63),
                                              child: Container(
                                                width: CustomSize.sizeWidth(context) / 2.2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText.bodyMedium14(text: transaction[index].nameResto.toString(), minSize: 14, maxLines: 1),
                                                        CustomText.bodyLight12(text: transaction[index].date, minSize: 12),
                                                        (transaction[index].type.startsWith('Reservasi'))
                                                            ?CustomText.bodyMedium10(text: transaction[index].type, minSize: 11)
                                                            :CustomText.bodyMedium12(text: transaction[index].type, minSize: 12),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        CustomText.bodyLight12(text: transaction[index].status??'Selesai', minSize: 12,
                                                            color: (transaction[index].status == 'Menunggu')?Colors.amberAccent:(transaction[index].status != 'Diproses')?Colors.green:Colors.blue),
                                                        CustomText.bodyMedium14(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(transaction[index].total), minSize: 14),
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
                                  ),
                                );
                              }
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Resto Dekat Sini",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: ()async{
                                  var i = await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new RestoListActivity()));
                                  if(i == null){
                                    _getData();
                                  }
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                        ),
                        (resto != [])?Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 3.6,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (resto.length <= 10)?resto.length:10,
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
                        (promo != [])?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Lagi Diskon",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: ()async{
                                  var i = await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new PromoActivity()));
                                  if(i == null){
                                    _getData();
                                  }
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                        ):Container(),
                        (promo != [])?Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 5,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // itemCount: promo.length,
                              itemCount: (promo.length < 10)?promo.length:10,
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
                                              child: new DetailResto(promo[index].restoId.toString())));
                                    },
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
                                  ),
                                );
                              }
                          ),
                        ):Container(),
                        (promo != [])?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                        (es != '[]')?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Wah segar nih . . .",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: ()async{
                                  var i = await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new EsActivity()));
                                  if(i == null){
                                    _getData();
                                  }
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                        ):Container(),
                        (es != '[]')?Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 5,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // itemCount: promo.length,
                              itemCount: (menuEs.length < 10)?menuEs.length:10,
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
                                              child: new DetailResto(menuEs[index].restoId.toString())));
                                    },
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
                                                  image: NetworkImage(Links.subUrl + menuEs[index].urlImg),
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
                                                      CustomText.bodyRegular12(text: menuEs[index].distance.toString() + " Km", minSize: 12),
                                                      CustomText.textTitle6(text: menuEs[index].name, minSize: 14, maxLines: 2),
                                                      CustomText.bodyMedium12(text: menuEs[index].restoName, minSize: 12),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuEs[index].price.original), minSize: 12,
                                                          decoration: (menuEs[index].price.discounted != null && menuEs[index].price.discounted.toString() != '0')?TextDecoration.lineThrough:TextDecoration.none),
                                                      SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                      (menuEs[index].price.discounted != null && menuEs[index].price.discounted.toString() != '0')
                                                          ?CustomText.bodyRegular12(
                                                          text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuEs[index].price.discounted), minSize: 12):SizedBox(),
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
                        ):Container(),
                        (es != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                        (ng != '[]')?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Ngidam nasi goreng ya?",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: ()async{
                                  var i = await Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new NasgorActivity()));
                                  if(i == null){
                                    _getData();
                                  }
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                        ):Container(),
                        (ng != '[]')?Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 5,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // itemCount: promo.length,
                              itemCount: (menuNG.length < 10)?menuNG.length:10,
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
                                              child: new DetailResto(menuNG[index].restoId.toString())));
                                    },
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
                                                  image: NetworkImage(Links.subUrl + menuNG[index].urlImg),
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
                                                      CustomText.bodyRegular12(text: menuNG[index].distance.toString() + " Km", minSize: 12),
                                                      CustomText.textTitle6(text: menuNG[index].name, minSize: 14, maxLines: 2),
                                                      CustomText.bodyMedium12(text: menuNG[index].restoName, minSize: 12),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuNG[index].price.original), minSize: 12,
                                                          decoration: (menuNG[index].price.discounted != null && menuNG[index].price.discounted.toString() != '0')?TextDecoration.lineThrough:TextDecoration.none),
                                                      SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                      (menuNG[index].price.discounted != null && menuNG[index].price.discounted.toString() != '0')
                                                          ?CustomText.bodyRegular12(
                                                          text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuNG[index].price.discounted), minSize: 12):SizedBox(),
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
                        ):Container(),
                        (ng != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.textTitle2(
                                  text: "Pesan Lagi",
                                  maxLines: 1
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new HistoryActivity()));
                                },
                                child: CustomText.bodyMedium12(
                                    text: "Lebih banyak",
                                    color: CustomColor.primary,
                                    maxLines: 1
                                ),
                              ),
                            ],
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
                                  padding: EdgeInsets.only(
                                      left: CustomSize.sizeWidth(context) / 20,
                                      top: CustomSize.sizeHeight(context) / 86,
                                      bottom: CustomSize.sizeHeight(context) / 86),
                                  child: GestureDetector(
                                    onTap: (){
                                      // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: new DetailResto(again[index].id.toString())));
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
                GestureDetector(
                    onTap: ()async{
                      var i = await Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: new PromoActivity()));
                      if(i == null){
                        _getData();
                      }
                    },
                    child: Icon(MaterialCommunityIcons.percent, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: new BookmarkActivity()));
                    },
                    child: Icon(MaterialCommunityIcons.bookmark, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: ()async{
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      String _cart = pref.getString('inCart')??'';
                      print(pref.getString('inCart'));
                      if(_cart != ''){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: CartActivity())).then((_) {
                          // This block runs when you have returned back to the 1st Page from 2nd.
                          setState(() {
                            Navigator.pushReplacement(context, PageTransition(
                                type: PageTransitionType.fade,
                                child: HomeActivity()));
                          });
                        });
                      }else{
                        Fluttertoast.showToast(
                          msg: "Tidak ada pesanan di keranjang anda",);
                      }
                    },
                    child: Icon(CupertinoIcons.cart_fill, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: ()async{
                      var i = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new SearchActivity(promo, latitude.toString(), longitude.toString(), '')));
                      if(i == null){
                        _getData();
                      }
                    },
                    child: Icon(FontAwesome.search, size: 32, color: Colors.white,)),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new ProfileActivity()));
                    });
                  },
                  child: Icon(Ionicons.md_person, size: 32, color: Colors.white,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
