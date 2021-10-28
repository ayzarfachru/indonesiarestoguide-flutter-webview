import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/imgBanner.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/detail/detail_transaction.dart';
import 'package:kam5ia/ui/promo/add_promo.dart';
import 'package:kam5ia/ui/promo/edit_promo.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
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

class OtherActivity extends StatefulWidget {
  @override
  _OtherActivityState createState() => _OtherActivityState();
}

class _OtherActivityState extends State<OtherActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  bool isLoading = false;

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }


  double latitude = 0;
  double longitude = 0;

  List<imgBanner> images = [];
  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> qty = [];
  List<Resto> resto = [];
  List<Resto> kakilima = [];
  List<Resto> foodstall = [];
  List<Resto> foodtruck = [];
  List<Resto> other = [];
  List<Resto> tokoroti = [];
  List<Resto> tokooleh = [];
  List<Resto> again = [];
  List<Menu> promo = [];
  List<Transaction> transaction = [];
  Future _getData(String lat, String long)async{
    List<Resto> _resto = [];
    List<Resto> _kakilima = [];
    List<Resto> _foodstall = [];
    List<Resto> _foodtruck = [];
    List<Resto> _other = [];
    List<Resto> _tokoroti = [];
    List<Resto> _tokooleh = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];
    List<Transaction> _transaction = [];
    List<imgBanner> _images = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long&limit=0', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('222 '+data['tipe']['TokoOlehOleh'].toString());

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
          type: v['type_text'], menus: [], ongkir: null, method: '', username: '', datetime: '', address: '', chatroom: ''
      );
      _transaction.add(t);
    }

    print('ini resto '+data['resto'].toString());

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']??null
      );
      _resto.add(r);
    }
    if (data['tipe']['KakiLima'] != null) {
      for(var v in data['tipe']['KakiLima']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img']
        );
        _kakilima.add(r);
      }
    }
    if (data['tipe']['FoodStall'] != null) {
      for(var v in data['tipe']['FoodStall']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img']
        );
        _foodstall.add(r);
      }
    }
    if (data['tipe']['FoodTruck'] != null) {
      for(var v in data['tipe']['FoodTruck']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img']
        );
        _foodtruck.add(r);
      }
    }
    if (data['tipe']['TokoRoti'] != null) {
      for(var v in data['tipe']['TokoRoti']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img']
        );
        _tokoroti.add(r);
      }
    }
    if (data['tipe']['TokoOlehOleh'] != null) {
      for(var v in data['tipe']['TokoOlehOleh']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img']
        );
        _tokooleh.add(r);
      }
    }
    if (data['tipe']['Other'] != null) {
      for(var v in data['tipe']['Other']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img'],
            isOpen: v['isOpen'].toString(),
        );
        _other.add(r);
      }
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
          distance: double.parse(v['resto_distance'].toString()), delivery_price: null, type: '', is_recommended: '', qty: ''
      );
      _promo.add(m);
    }
    setState(() {
      images = _images;
      transaction = _transaction;
      resto = _resto;
      kakilima = _kakilima;
      foodstall = _foodstall;
      foodtruck = _foodtruck;
      tokoroti = _tokoroti;
      tokooleh = _tokooleh;
      other = _other;
      again = _again;
      promo = _promo;
      isLoading = false;
    });
  }



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
            desc: v['desc'],
            distance: double.parse(v['distance'].toString()),
            urlImg: v['img'],
            price: Price.discounted(int.parse(v['price']), v['discounted_price']), type: '', delivery_price: null, restoId: '', restoName: '', is_recommended: '', qty: ''
        ), word: '', discountedPrice: null, id: null,
      );
      _promo.add(p);
    }
    setState(() {
      // promo = _promo;
      isLoading = false;
    });
  }

  List<Promo> promoResto = [];
  Future<void> _getPromoResto()async {
    List<Promo> _promoResto = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/promo', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print(data['promo']);

    for (var a in data['promo']) {
      Promo b = Promo.resto(
        id: a['id'],
        menus_id: int.parse(a['menus_id']),
        word: a['description'],
        discountedPrice: (a['discount'] != null)?int.parse(a['discount']):a['discount'],
        potongan: (a['potongan'] != null)?int.parse(a['potongan']):a['potongan'],
        ongkir: (a['ongkir'] != null)?int.parse(a['ongkir']):a['ongkir'],
        expired_at: a['expired_at'],
        menu: Menu(
            id: a['menus']['id'],
            name: a['menus']['name'],
            desc: a['menus']['desc'],
            urlImg: a['menus']['img'],
            price: Price.promo(
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString()),
            restoName: '', type: '', restoId: '', delivery_price: null, distance: null, qty: '', is_recommended: ''
        ),
      );
      _promoResto.add(b);
    }
    setState(() {
      promoResto = _promoResto;
      // print(promoResto);
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
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (homepg != '1') {
        Location.instance.getLocation().then((value) {
          _getData(value.latitude.toString(), value.longitude.toString());
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
          });
          // _getPromo(value.latitude.toString(), value.longitude.toString());
        });
      } else {
        _getPromoResto();
        print('ini resto');
      }
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

  showAlertDialog(String id) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primaryLight)),
      onPressed:  () {
        _delPromo(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Promo"),
      content: Text("Apakah anda yakin ingin menghapus data ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _delPromo(String id)async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/promo/delete/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['msg'].toString() == 'success') {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: OtherActivity()));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double hargaDiskon = 0;
  int hargaPotongan = 0;
  int hargaOngkir = 0;

  @override
  void initState() {
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (homepg != '1') {
        Location.instance.getLocation().then((value) {
          _getData(value.latitude.toString(), value.longitude.toString());
          setState(() {
            latitude = value.latitude;
            longitude = value.longitude;
          });
          // _getPromo(value.latitude.toString(), value.longitude.toString());
        });
      } else {
        _getPromoResto();
        print('ini resto');
        // print(promoResto);
      }
    });
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
            child: Center(child: CircularProgressIndicator(
              color: CustomColor.primaryLight,
            ))):SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            distance: 30,
            backgroundColor: Colors.white,
            color: CustomColor.primaryLight,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 32,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: CustomText.textHeading3(
                      text: "Other",
                      color: CustomColor.primary,
                      minSize: 18,
                      maxLines: 1
                  ),
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 62,
                ),
                StaggeredGridView.countBuilder(
                  staggeredTileBuilder: (index) {
                    return StaggeredTile.count(1, 1.2);
                  },
                  crossAxisCount: 2,
                  controller: _scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: other.length,
                  itemBuilder: (_, index){
                    return Padding(
                      padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 48),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: new DetailResto(other[index].id.toString())));
                        },
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
                              (other[index].isOpen == 'false')?Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 5.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      Colors.grey,
                                      BlendMode.saturation,
                                    ),
                                    child: Container(
                                      decoration: (other[index].img != null)?BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + other[index].img!),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ):BoxDecoration(
                                          color: CustomColor.primaryLight
                                      ),
                                    ),
                                  ),
                                ),
                              ):Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 5.8,
                                decoration: (other[index].img != null)?BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(Links.subUrl + other[index].img!),
                                      fit: BoxFit.cover
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ):BoxDecoration(
                                    color: CustomColor.primaryLight
                                ),
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                              Padding(
                                padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                child: CustomText.bodyRegular14(text: other[index].distance.toString() + " Km"),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                child: CustomText.bodyMedium16(text: other[index].name),
                              ),
                            ],
                          ),
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
