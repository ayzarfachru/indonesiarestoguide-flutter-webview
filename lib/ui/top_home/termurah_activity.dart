import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kam5ia/model/Resto.dart';
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

class TermurahActivity extends StatefulWidget {
  @override
  _TermurahActivityState createState() => _TermurahActivityState();
}

class _TermurahActivityState extends State<TermurahActivity> {
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

  List<Resto> promo = [];
  List<String> promo2 = [];
  Future<void> _getPromo(String lat, String long)async{
    List<Resto> _promo = [];
    List<String> _promo2 = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/special/terbaru?lat=$lat&long=$long', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['resto']['data']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']??null
      );
      _promo.add(r);
    }

    // for(var v in data['menu']){
    //   Menu2 d = Menu2(
    //       id: v['id'],
    //       name: v['name'],
    //       restoId: '',
    //       restoName: '',
    //       desc: v['desc']??'',
    //       urlImg: v['img'],
    //       usaha: Resto.all(
    //           id: v['restaurants']['id'],
    //           name: v['restaurants']['name'],
    //           distance: double.parse(v['restaurants']['distance'].toString()),
    //           img: v['restaurants']['img']
    //       ),
    //       price: Price.discounted(int.parse(v['price'].toString()), (v['discounted_price'] != null)?int.parse(v['discounted_price'].toString()):null),
    //       distance: null, delivery_price: null, qty: '', is_recommended: '', type: ''
    //   );
    //   _promo.add(d);
    // }
    setState(() {
      // _promo2 = _promo.toList();
      // _promo = _promo.map((item) => jsonEncode(item));
      // _promo = _promo.toSet().toList();
      promo = _promo;
      // print('ini '+_promo..toString());
      // promo.retainWhere((element) => promo.remove(element.id));
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (promo.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

  bool ksg = false;

  bool kosong = false;
  List<Promo> promoResto = [];
  // Future<void> _getPromoResto()async {
  //   List<Promo> _promoResto = [];
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String token = pref.getString("token") ?? "";
  //   var apiResult = await http.get(Links.mainUrl + '/promo', headers: {
  //     "Accept": "Application/json",
  //     "Authorization": "Bearer $token"
  //   });
  //   print(apiResult.body);
  //   var data = json.decode(apiResult.body);
  //   // print(data['promo']);
  //
  //   for (var a in data['promo']) {
  //     Promo b = Promo.resto(
  //       id: a['id'],
  //       menus_id: int.parse(a['menus_id']),
  //       word: a['description'],
  //       discountedPrice: (a['discount'] != null)?int.parse(a['discount']):a['discount'],
  //       potongan: (a['potongan'] != null)?int.parse(a['potongan']):a['potongan'],
  //       ongkir: (a['ongkir'] != null)?int.parse(a['ongkir']):a['ongkir'],
  //       expired_at: a['expired_at'],
  //       menu: Menu(
  //           id: a['menus']['id']??null,
  //           name: a['menus']['name']??null,
  //           desc: a['menus']['desc']??null,
  //           urlImg: a['menus']['img'],
  //           price: Price.promo(
  //               a['menus']['price'].toString(), a['menus']['delivery_price'].toString()), type: '', distance: null, delivery_price: null, restoId: '', restoName: '', is_recommended: '', qty: '', usaha: []
  //       ),
  //     );
  //     _promoResto.add(b);
  //   }
  //
  //   setState(() {
  //     promoResto = _promoResto;
  //     // print(promoResto);
  //     isLoading = false;
  //   });
  //
  //   if (apiResult.statusCode == 200 && promoResto.toString() == '[]') {
  //     kosong = true;
  //   }
  //
  // }

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
        // _getPromoResto();
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
              child: TermurahActivity()));
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
        // _getPromoResto();
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
    return Scaffold(
        body: SafeArea(
          child: (isLoading)?Container(
              width: CustomSize.sizeWidth(context),
              height: CustomSize.sizeHeight(context),
              child: Center(child: CircularProgressIndicator(
                color: CustomColor.primaryLight,
              ))):(ksg != true)?SmartRefresher(
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
                    (homepg != "1")?CustomText.textHeading3(
                        text: "Berdasarkan Resto",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ):CustomText.textHeading3(
                        text: "Promo di Tokomu",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ),
                    (homepg != "1")?CustomText.textHeading3(
                        text: "Terbaru",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ):Container(),
                    StaggeredGridView.countBuilder(
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, 1.2);
                      },
                      crossAxisCount: 2,
                      controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: promo.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 48),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: new DetailResto(promo[index].id.toString())));
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
                                  Container(
                                    width: CustomSize.sizeWidth(context),
                                    height: CustomSize.sizeHeight(context) / 5.8,
                                    decoration: (promo[index].img != null)?BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(Links.subUrl + promo[index].img!),
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
                                    child: CustomText.bodyRegular14(text: promo[index].distance.toString() + " Km"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                    child: CustomText.bodyMedium16(text: promo[index].name),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
                        CustomText.textHeading3(
                            text: "Promo di Tokomu",
                            color: CustomColor.primary,
                            minSize: 18,
                            maxLines: 1
                        ),
                      ],
                    ),
                    Container(height: CustomSize.sizeHeight(context), child: Center(
                      child: CustomText.bodyRegular14(
                          text: 'Promo kosong.',
                          maxLines: 1,
                          minSize: 12,
                          color: Colors.grey
                      ),
                    ),),
                  ],
                ),
              ),
            ),
          ):Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 32,
                    ),
                    (homepg != "1")?CustomText.textHeading3(
                        text: "Berdasarkan Produk",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ):CustomText.textHeading3(
                        text: "Promo di Tokomu",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ),
                    (homepg != "1")?CustomText.textHeading3(
                        text: "Terbaru",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ):Container(),
                  ],
                ),
              ),
              Container(child: CustomText.bodyMedium12(text: "kosong", minSize: 12), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
            ],
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
    );
  }
}
