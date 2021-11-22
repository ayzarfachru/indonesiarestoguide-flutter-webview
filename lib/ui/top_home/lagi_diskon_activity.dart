import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
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

class LagiDiskonActivity extends StatefulWidget {
  @override
  _LagiDiskonActivityState createState() => _LagiDiskonActivityState();
}

class _LagiDiskonActivityState extends State<LagiDiskonActivity> {
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

  List<Menu> promo = [];
  Future<void> _getPromo(String lat, String long)async{
    List<Menu> _promo = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long&limit=0', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data['promo']);

    for(var v in data['promo']){
      Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          desc: v['desc']??'',
          urlImg: v['img'],
          price: Price.discounted(int.parse(v['price'].toString()), int.parse(v['discounted_price'].toString())),
          distance: double.parse(v['resto_distance'].toString()), is_recommended: '', qty: '', type: '', delivery_price: null
      );
      _promo.add(m);
    }
    setState(() {
      promo = _promo;
      isLoading = false;
    });
  }

  bool kosong = false;
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
            id: a['menus']['id']??null,
            name: a['menus']['name']??null,
            desc: a['menus']['desc']??null,
            urlImg: a['menus']['img'],
            price: Price.promo(
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString()), type: '', distance: null, delivery_price: null, restoId: '', restoName: '', is_recommended: '', qty: ''
        ),
      );
      _promoResto.add(b);
    }

    setState(() {
      promoResto = _promoResto;
      // print(promoResto);
      isLoading = false;
    });

    if (apiResult.statusCode == 200 && promoResto.toString() == '[]') {
      kosong = true;
    }

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
              child: LagiDiskonActivity()));
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
          _getPromo(value.latitude.toString(), value.longitude.toString());
        });
      } else {
        _getPromoResto();
        print('ini resto');
        // print(promoResto);
      }
    });
    super.initState();
    getHomePg();
    print(homepg);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: (kosong.toString() != 'true')?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 32,
                      ),
                      (homepg != "1")?Row(
                        children: [
                          GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: CustomSize.sizeWidth(context) / 7,
                                  height: CustomSize.sizeWidth(context) / 7,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 7,
                                        offset: Offset(0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Icon(Icons.chevron_left, size: 38,)))
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 48,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context) / 1.5,
                            child: CustomText.textHeading3(
                                text: "Lagi Diskon",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ):CustomText.textHeading3(
                          text: "Promo di Tokomu",
                          color: CustomColor.primary,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                          maxLines: 1
                      ),
                      // (homepg != "1")?CustomText.textHeading3(
                      //     text: "di Sekitarmu",
                      //     color: CustomColor.primary,
                      //     minSize: 18,
                      //     maxLines: 1
                      // ):Container(),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: (homepg != "1")?promo.length:promoResto.length,
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
                                          child: new DetailResto(promo[index].restoId.toString())));
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
                                        decoration: (homepg == "1")?(promoResto[index].menu != null)?BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + promoResto[index].menu!.urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ):BoxDecoration(
                                          color: CustomColor.primaryLight,
                                          borderRadius: BorderRadius.circular(20),
                                        ):BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + promo[index].urlImg),
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
                                                    text: promo[index].distance.toString().split('.')[0]+" km",
                                                    maxLines: 1,
                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                ):CustomText.bodyLight12(
                                                    text: 'Sampai : '+promoResto[index].expired_at!.split(' ')[0],
                                                    maxLines: 1,
                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
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
                                                        child: Icon(Icons.edit, color: Colors.grey,)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                                    GestureDetector(
                                                        onTap: (){
                                                          showAlertDialog(promoResto[index].id.toString());
                                                        },
                                                        child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                                  ],
                                                )
                                              ],
                                            ),
                                            (homepg != '1')?Container():CustomText.bodyLight12(
                                                text: 'Jam : '+promoResto[index].expired_at!.split(' ')[1].split(':')[0]+':'+promoResto[index].expired_at!.split(' ')[1].split(':')[1],
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                            ),
                                            (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) * 0.00426,):Container(),
                                            (homepg != "1")?CustomText.textHeading4(
                                                text: promo[index].name,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                maxLines: 1
                                            ):(promoResto[index].menu != null)?CustomText.textHeading4(
                                                text: promoResto[index].menu!.name,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                maxLines: 1
                                            ):CustomText.textHeading6(
                                                text: 'Menu tidak tersedia',
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                            ),
                                            (homepg != "1")?CustomText.bodyMedium12(
                                                text: promo[index].restoName,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),
                                                maxLines: 1
                                            ):Container(),
                                            // CustomText.bodyMedium12(text: promo[index].restoName, minSize: 12),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00126,),
                                            (homepg != "1")?CustomText.bodyMedium12(
                                                text: promo[index].desc,
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ):CustomText.bodyMedium12(
                                                text: promoResto[index].word,
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ),
                                            (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 22,):SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                            Row(
                                              children: [
                                                (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.original), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),
                                                    decoration: TextDecoration.lineThrough)
                                                    :Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    (promoResto[index].menu != null)?Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Harga :', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        (promoResto[index].discountedPrice != null || promoResto[index].potongan != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()), color: CustomColor.redBtn,
                                                            decoration: TextDecoration.lineThrough)
                                                            :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)),sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),),
                                                      ],
                                                    ):Container(),
                                                    (promoResto[index].ongkir != null)?Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Potongan Ongkir :', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].ongkir.toString())), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),),
                                                      ],
                                                    ):Container(),
                                                    // (promoResto[index].menu != null)?Row(
                                                    //   children: [
                                                    //     CustomText.bodyRegular12(text: 'Delivery : ', minSize: 12),
                                                    //     SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                    //     (promoResto[index].ongkir != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.deliString)), minSize: 12, color: CustomColor.redBtn,
                                                    //         decoration: TextDecoration.lineThrough)
                                                    //         :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.deliString)), minSize: 12,),
                                                    //   ],
                                                    // ):Container(),
                                                  ],
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                (homepg == "1")?(promoResto[index].menu != null)?Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12)
                                                    //     :
                                                    CustomText.bodyRegular12(text:
                                                    (promoResto[index].discountedPrice != null)?
                                                    NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu!.price!.oriString!)-(int.parse(promoResto[index].menu!.price!.oriString!)*promoResto[index].discountedPrice!/100)))
                                                        :(promoResto[index].potongan != null)?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)-promoResto[index].potongan!)
                                                        :'', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),

                                                    // // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12)
                                                    // //     :
                                                    // CustomText.bodyRegular12(text:
                                                    // (promoResto[index].menu.price.deliString != null)?
                                                    // (promoResto[index].ongkir != null)?
                                                    //     NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu.price.deliString)-promoResto[index].ongkir))
                                                    //     :'' :'', minSize: 12),
                                                  ],
                                                ):Container():CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.discounted), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
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
                  ):Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 32,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      width: CustomSize.sizeWidth(context) / 7,
                                      height: CustomSize.sizeWidth(context) / 7,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 0,
                                            blurRadius: 7,
                                            offset: Offset(0, 0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(child: Icon(Icons.chevron_left, size: 38,)))
                              ),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 48,
                              ),
                              Container(
                                width: CustomSize.sizeWidth(context) / 1.5,
                                child: CustomText.textHeading3(
                                    text: "Lagi Diskon",
                                    color: CustomColor.primary,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                    maxLines: 2
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(height: CustomSize.sizeHeight(context), child: Center(
                        child: CustomText.bodyRegular14(
                            text: 'kosong.',
                            maxLines: 1,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),
                            color: Colors.grey
                        ),
                      ),),
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
                  color: CustomColor.primaryLight,
                  shape: BoxShape.circle
              ),
              child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
            ),
          )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
