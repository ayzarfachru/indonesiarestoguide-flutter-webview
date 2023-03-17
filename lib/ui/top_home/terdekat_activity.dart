import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/promo/add_promo.dart';
import 'package:kam5ia/utils/utils.dart';
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

class TerdekatActivity extends StatefulWidget {
  @override
  _TerdekatActivityState createState() => _TerdekatActivityState();
}

class _TerdekatActivityState extends State<TerdekatActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  bool isLoading = true;

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }

  List<Resto> promo = [];
  List<String> promo2 = [];
  String doubleRes = '';
  Future<void> _getPromo(String lat, String long)async{
    List<Resto> _promo = [];
    List<String> _promo2 = [];

    setState(() {
      page = 1;
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/special/terdekat?lat=$lat&long=$long'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data['resto']['last_page']);
    print(data);

    for(var v in data['resto']['data']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']??null,
          isOpen: v['isOpen'].toString()
      );
      if (doubleRes == '') {
        doubleRes = v['name'];
      } else {
        doubleRes = doubleRes + ', ' + v['name'];
      }
      _promo.add(r);
    }
    print('doubleRes');
    print(doubleRes);

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
      last_page = data['resto']['last_page'];
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
    Widget cancelButton = TextButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/promo/delete/$id'), headers: {
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
              child: TerdekatActivity()));
    }

    setState(() {
      isLoading = false;
    });
  }

  bool isLoading2 = false;
  int page = 1;
  int last_page = 0;
  ScrollController _controller = ScrollController();

  Future<void> _getPromo2(String lat, String long)async{
    List<Resto> _promo = [];
    List<String> _promo2 = [];

    setState(() {
      isLoading2 = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/special/terdekat?page=$page&lat=$lat&long=$long'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);
    print(data['resto']['from']);
    print(data['resto']['last_page']);

    for(var v in data['resto']['data']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']??null,
          isOpen: v['isOpen'].toString()
      );
      if (doubleRes.contains(v['name']) == false) {
        promo.add(r);
        doubleRes = doubleRes + ', ' + v['name'];
        print('doubleRes2');
        print(doubleRes);
      }
    }

    setState(() {
      // _promo2 = _promo.toList();
      // _promo = _promo.map((item) => jsonEncode(item));
      // _promo = _promo.toSet().toList();
      promo = promo;
      if (page == int.parse(data['resto']['last_page'].toString())) {
        Fluttertoast.showToast(msg: "Semua data telah ditampilkan");
      }
      // print('ini '+_promo..toString());
      // promo.retainWhere((element) => promo.remove(element.id));
      isLoading2 = false;
    });

    if (apiResult.statusCode == 200) {
      if (promo.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
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
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0 && isLoading2 == true && page != last_page) {
          // print(startCuisine.toString().split(',').length.toString());
          // print(totalCuisine.toString());
          // _page(lat,long);
          page = page + 1;
          Location.instance.getLocation().then((value) {
            _getPromo2(value.latitude.toString(), value.longitude.toString());
          });
        } else {
          isLoading2 = false;
          print(isLoading2.toString());
          print(_scrollController.position.pixels.toString());
          print("You're at the top.");
          setState(() {});
        }
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
                ))):(ksg != true)?SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primaryLight,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              scrollController: _scrollController,
              physics: BouncingScrollPhysics(),
              footer: CustomFooter(builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if(mode==LoadStatus.idle){
                  body =  MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else if(mode==LoadStatus.loading){
                  body = Text("");
                  isLoading2 = true;
                }
                else if(mode == LoadStatus.failed){
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else if(mode == LoadStatus.canLoading){
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else{
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                return Container(
                  height: CustomSize.sizeHeight(context) / 48,
                  alignment: Alignment.topCenter,
                  child: Center(child: body),
                );
              },
              ),
              child: SingleChildScrollView(
                controller: _controller,
                child: (kosong.toString() != 'true')?Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 32,
                    ),
                    (homepg != "1")?Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: Row(
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
                                text: "Berdasarkan Resto Terdekat",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.06).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.06).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ),
                    ):Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textHeading3(
                          text: "Promo di Tokomu",
                          color: CustomColor.primary,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                          maxLines: 1
                      ),
                    ),
                    // (homepg != "1")?Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    //   child: CustomText.textHeading3(
                    //       text: "Terbaru",
                    //       color: CustomColor.primary,
                    //       sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                    //       maxLines: 1
                    //   ),
                    // ):Container(),
                    StaggeredGridView.countBuilder(
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, 1.2);
                      },
                      crossAxisCount: 2,
                      controller: _controller,
                      // physics: NeverScrollableScrollPhysics(),
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
                            // child: (promo[index].isOpen.toString() == 'true')?Container(
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
                                  // (promo[index].isOpen != 'false')?Container(
                                  (promo[index].isOpen != 'x')?Container(
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
                                  ):ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        Colors.grey,
                                        BlendMode.saturation,
                                      ),
                                      child: Container(
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
                                    ),
                                  ),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                  Padding(
                                    padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                    child: CustomText.bodyRegular14(text: promo[index].distance.toString() + " Km", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24, right: CustomSize.sizeWidth(context) / 34),
                                    child: Container(
                                        height: CustomSize.sizeWidth(context) / 12,
                                        child: CustomText.bodyMedium16(maxLines: 2, text: promo[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))),
                                  ),
                                ],
                              ),
                            ),
                            //       :Container(
                            //   width: CustomSize.sizeWidth(context) / 2.3,
                            //   height: CustomSize.sizeHeight(context) / 3,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(20),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.grey.withOpacity(0.5),
                            //         spreadRadius: 0,
                            //         blurRadius: 4,
                            //         offset: Offset(0, 3), // changes position of shadow
                            //       ),
                            //     ],
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       ClipRRect(
                            //         borderRadius: BorderRadius.circular(20),
                            //         child: ColorFiltered(
                            //           colorFilter: ColorFilter.mode(
                            //             Colors.grey,
                            //             BlendMode.saturation,
                            //           ),
                            //           child: Container(
                            //             width: CustomSize.sizeWidth(context),
                            //             height: CustomSize.sizeHeight(context) / 5.8,
                            //             decoration: (promo[index].img != null)?BoxDecoration(
                            //               image: DecorationImage(
                            //                   image: NetworkImage(Links.subUrl + promo[index].img!),
                            //                   fit: BoxFit.cover
                            //               ),
                            //               borderRadius: BorderRadius.circular(20),
                            //             ):BoxDecoration(
                            //                 color: CustomColor.primaryLight
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //       SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                            //       Padding(
                            //         padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                            //         child: CustomText.bodyRegular14(text: promo[index].distance.toString() + " Km", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                            //       ),
                            //       Padding(
                            //         padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                            //         child: CustomText.bodyMedium16(text: promo[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ),
                        );
                      },
                    ),
                    // SizedBox(height: CustomSize.sizeHeight(context) / 8,)
                    (isLoading2 == true)?Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 14,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(30),
                        //     color: CustomColor.accent
                        // ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
                          ),
                        ),
                      ),
                    ):Container(),
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
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                            maxLines: 1
                        ),
                      ],
                    ),
                    Container(height: CustomSize.sizeHeight(context), child: Center(
                      child: CustomText.bodyRegular14(
                          text: 'Promo kosong.',
                          maxLines: 1,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),
                          color: Colors.grey
                      ),
                    ),),
                  ],
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
                                text: "Berdasarkan Resto Terdekat",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.06).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.06).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ):CustomText.textHeading3(
                          text: "Promo di Tokomu",
                          color: CustomColor.primary,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                          maxLines: 1
                      ),
                    ],
                  ),
                ),
                Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
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
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}