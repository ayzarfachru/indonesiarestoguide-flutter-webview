import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/imgBanner.dart';
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

class HistoryOrderActivity extends StatefulWidget {
  @override
  _HistoryOrderActivityState createState() => _HistoryOrderActivityState();
}

class _HistoryOrderActivityState extends State<HistoryOrderActivity> {
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
  List<Resto> again = [];
  List<Menu> promo = [];
  List<Transaction> transaction = [];
  Future _getData(String lat, String long)async{
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
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long&limit=0', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data['trans']);

    print('ini banner '+data['banner'].toString());
    // for(var v in data['banner']){
    //   imgBanner t = imgBanner(
    //       id: int.parse(v['resto_id'].toString()),
    //       urlImg: v['img']
    //   );
    //   _images.add(t);
    // }

    if (data['trans'].toString() != '[]') {
      for(var v in data['trans']){
        Transaction t = Transaction.all2(
          id: v['id'],
          idResto: v['restaurants_id'].toString(),
          date: v['date'],
          img: v['img'],
          nameResto: v['resto_name'],
          status: v['status'],
          total: int.parse((v['total']??0).toString())+int.parse((v['ongkir']??0).toString()),
          type: v['type_text'],
          note: v['note'].toString(),
          chat_user: v['chat_resto'].toString(),
          // address: v['address'].toString(),
        );
        _transaction.add(t);
      }
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
          is_available: '',
          price: Price.discounted(int.parse(v['price'].toString()), int.parse(v['discounted_price'].toString())),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, is_recommended: '', qty: ''
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
            is_available: '',
            price: Price.discounted(int.parse(v['price']), v['discounted_price']), delivery_price: null, restoId: '', type: '', is_recommended: '', qty: '', restoName: ''
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
            is_available: '',
            price: Price.promo(
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString()),
            type: '', distance: null, restoName: '', is_recommended: '', qty: '', delivery_price: null, restoId: ''
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
              child: HistoryOrderActivity()));
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
                                text: "Semua Pesananmu",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ):CustomText.textHeading3(
                          text: "Promo di Restoranmu",
                          color: CustomColor.primary,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                          maxLines: 1
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: transaction.length,
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
                                onTap: ()async{
                                  if(transaction[index].type!.startsWith('Reservasi') != true){
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("chatUserCount", transaction[index].chat_user);
                                    pref.setString("idnyatrans", transaction[index].id.toString());
                                    pref.setString("idnyatransRes", transaction[index].idResto.toString());
                                    pref.setString("restoNameTrans99", transaction[index].nameResto);
                                    pref.setString("alamateResto99", transaction[index].address);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new DetailTransaction(transaction[index].id!, transaction[index].status!, transaction[index].note!, transaction[index].idResto!)));
                                  }
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
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + transaction[index].img!):NetworkImage(Links.subUrl + promoResto[index].menu!.urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      SizedBox(
                                        width: CustomSize.sizeWidth(context) / 32,
                                      ),
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
                                                  CustomText.bodyMedium14(text: transaction[index].nameResto.toString(), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()), maxLines: 1),
                                                  CustomText.bodyLight12(text: transaction[index].date, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                                                  (transaction[index].type!.startsWith('Reservasi'))
                                                      ?CustomText.bodyMedium10(text: transaction[index].type, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.025).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.025)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.025)).toString()))
                                                      :CustomText.bodyMedium12(text: transaction[index].type, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight12(text: transaction[index].status??'Selesai', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()),
                                                      color: (transaction[index].status == 'Menunggu')?Colors.amberAccent:(transaction[index].status != 'Diproses')?Colors.green:Colors.blue),
                                                  CustomText.bodyMedium14(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(transaction[index].total!+1000), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
                      SizedBox(height: CustomSize.sizeHeight(context) / 38,)
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
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
