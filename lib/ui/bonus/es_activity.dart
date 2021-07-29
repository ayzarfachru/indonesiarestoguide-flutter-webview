import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/promo/add_promo.dart';
import 'package:indonesiarestoguide/ui/promo/edit_promo.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
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

class EsActivity extends StatefulWidget {
  @override
  EsActivityState createState() => EsActivityState();
}

class EsActivityState extends State<EsActivity> {
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
            desc: v['desc'],
            distance: double.parse(v['distance'].toString()),
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
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString())
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
          _getPromo(value.latitude.toString(), value.longitude.toString());
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
      child: Text("Batal", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary)),
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
              child: EsActivity()));
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

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=es&type=$type&lat=$lat&long=$long&limit=0',
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


  double latitude = 0;
  double longitude = 0;



  @override
  void initState() {
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (homepg != '1') {
        Location.instance.getLocation().then((value) {
          _getPromo(value.latitude.toString(), value.longitude.toString());
        });
      } else {
        _getPromoResto();
        print('ini resto');
        // print(promoResto);
      }
    });
    Location.instance.getLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    lat = latitude.toString();
    long = longitude.toString();
    _search('');
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
                        text: "Minuman Segar",
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
                        itemCount: (homepg != "1")?menuNG.length:menuNG.length,
                        itemBuilder: (_, index){
                          Future.delayed(Duration(seconds: 1)).then((_) {
                            setState(() {
                              // int hargaAsli = int.parse(promoResto[index].menu.price.oriString);
                              // int hargaAsliDeliv = int.parse(promoResto[index].menu.price.deliString);
                              // hargaDiskon = hargaAsli-(hargaAsli*promoResto[index].discountedPrice/100);
                              // hargaPotongan = (promoResto[index].potongan != null)?hargaAsli-promoResto[index].potongan:hargaAsli;
                              // hargaOngkir = (promoResto[index].ongkir != null)?hargaAsliDeliv-promoResto[index].ongkir:hargaAsliDeliv;

                              // print(hargaDiskon.toString().split('.')[0]);
                              // print(hargaOngkir);
                            });
                          });
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: new DetailResto(menuNG[index].restoId.toString())));
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
                                            image: (homepg != "1")?NetworkImage(Links.subUrl + menuNG[index].urlImg):NetworkImage(Links.subUrl + promoResto[index].menu.urlImg),
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
                                              (homepg != '1')?CustomText.bodyLight12(
                                                // text: promo[index].menu.distance.toString().split('.')[0]+' , '+promo[index].menu.distance.toString().split('')[0]+promo[index].menu.distance.toString().split('.')[1].split('')[1]+" km",
                                                  text: menuNG[index].distance.toString().split('.')[0]+" km",
                                                  maxLines: 1,
                                                  minSize: 12
                                              ):CustomText.bodyLight12(
                                                  text: 'Sampai : '+promoResto[index].expired_at.split(' ')[0],
                                                  maxLines: 1,
                                                  minSize: 12
                                              ),
                                              (homepg != "1")?Container():Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType.rightToLeft,
                                                                child: EditPromo(promoResto[index])));
                                                      },
                                                      child: Icon(Icons.edit, color: CustomColor.primary,)
                                                  ),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                                  GestureDetector(
                                                      onTap: (){
                                                        showAlertDialog(promoResto[index].id.toString());
                                                      },
                                                      child: Icon(Icons.delete, color: CustomColor.primary,)
                                                  ),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                                ],
                                              )
                                            ],
                                          ),
                                          (homepg != '1')?Container():CustomText.bodyLight12(
                                              text: 'Jam : '+promoResto[index].expired_at.split(' ')[1].split(':')[0]+':'+promoResto[index].expired_at.split(' ')[1].split(':')[1],
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) * 0.00626,),
                                          (homepg != "1")?CustomText.textHeading4(
                                              text: menuNG[index].name,
                                              minSize: 18,
                                              maxLines: 1
                                          ):CustomText.textHeading4(
                                              text: promoResto[index].menu.name,
                                              minSize: 18,
                                              maxLines: 1
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) * 0.00126,),
                                          (homepg != "1")?CustomText.bodyMedium12(
                                              text: menuNG[index].restoName,
                                              maxLines: 1,
                                              minSize: 12
                                          ):CustomText.bodyMedium12(
                                              text: promoResto[index].word,
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 22,):SizedBox(height: CustomSize.sizeHeight(context) / 108,),
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
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 8,)
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: (homepg != '1')?Container():GestureDetector(
          onTap: ()async{
            SharedPreferences pref = await SharedPreferences.getInstance();
            // pref.remove("idMenu");
            // pref.remove("nameMenu");
            pref.setString("idMenu", '');
            pref.setString("nameMenu", '');
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: AddPromo()));
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
