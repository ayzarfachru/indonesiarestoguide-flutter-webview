import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/utils/map_cart/map_address.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/utils/search_address_maps.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

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

class FinalTrans extends StatefulWidget {
  @override
  _FinalTransState createState() => _FinalTransState();
}

class _FinalTransState extends State<FinalTrans> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  ScrollController _scrollController = ScrollController();
  TextEditingController _srchAddress = TextEditingController(text: "");
  bool isLoading = false;

  String name = '';
  String nameUser = '';
  String playerId = '';
  String harga2 = '';
  int harga = 0;
  List<String> restoId = [];
  List<String> qty = [];
  List<String> noted = [];
  List<String> noted2 = [];
  List<String> noted3 = [];
  String _restId = '';
  String _qty = '';
  String restoAddress = '';
  bool srchAddress = false;
  bool srchAddress2 = false;
  List<int> indexCart = [];
  List<MenuJson> _tempMenu = [];
  List<String> _tempRestoId = [];
  List<String> _tempQty = [];

  //delivery = 1
  //takeaway = 2
  //dinein = 3
  int _transCode = 1;

  double? latitude;
  double? longitude;

  String? ongkir;
  String totalOngkir = "0";
  String totalHarga = "0";
  String checkId = "";
  String nameRestoTrans = "";
  String phoneRestoTrans = "";

  List<MenuJson> menuJson = [];
  List<bool> menuReady = [];
  String can_delivery = "";
  String can_takeaway = "";
  String delivAddress = "";
  String delivTotalOngkir = "";
  String totalHargaTrans = "";
  Future _getData()async{
    List<MenuJson> _menuJson = [];
    List<String> _menuId = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    _transCode = int.parse(pref2.getString("metodeBeli")??'1');
    delivAddress = (pref2.getString('addressDelivTrans')??"");
    delivTotalOngkir = (pref2.getString('delivTotalOngkir')??"");
    totalHargaTrans = (pref2.getString('totalHargaTrans')??"");
    harga2 = (pref2.getString('totalHarga')??"");
    name = (pref2.getString('menuJson')??"");
    nameUser = (pref2.getString('name')??"");
    playerId = (pref2.getString('playerId')??"");
    restoAddress = (pref2.getString('alamateResto')??"");
    print('ini name '+name.toString());
    restoId.addAll(pref2.getStringList('restoId')??[]);
    nameRestoTrans = pref2.getString("restoNameTrans");
    phoneRestoTrans = pref2.getString("restoPhoneTrans");
    print('nama Rest '+nameRestoTrans);
    qty.addAll(pref2.getStringList('qty')??[]);
    noted.addAll(pref2.getStringList('note')??[]);
    noted2.addAll(pref2.getStringList('note')??[]);
    noted2.removeWhere((element) => element.contains('kam5ia_null}'));
    print('iki noted '+noted2.toString());
    _tempRestoId.addAll(pref2.getStringList('restoId')??[]);
    _tempQty.addAll(pref2.getStringList('qty')??[]);
    var data = json.decode(name);
    print('ini data bos '+noted.toString());

    for(var v in data){
      _menuId.add(v['id'].toString());
      MenuJson j = MenuJson(
          id: v['id'],
          name: v['name'],
          restoName: v['restoName'],
          desc: v['desc'],
          distance: v['distance'],
          price: v['price'],
          pricePlus: v['pricePlus'],
          discount: v['discount'],
          urlImg: v['urlImg'], restoId: ''
      );
      _menuJson.add(j);
      print('hrg '+v.toString());
      harga = (v['discount'].toString() == '' || v['discount'].toString() == 'null' || v['discount'].toString() == v['price'].toString())?(harga + int.parse(v['price']) * int.parse(qty[restoId.indexOf(v['id'].toString())])):(harga + int.parse(v['discount']) * int.parse(qty[restoId.indexOf(v['id'].toString())]));
      totalHarga = harga.toString();
    }
    print(_menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', ''));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    can_delivery = pref.getString('can_deliveryUser');
    can_takeaway = pref.getString('can_take_awayUser');
    checkId = pref.getString('restoIdUsr')??'';
    _getUserDataResto();
    print('ini '+checkId);
    // var apiResult = await http.post(Links.mainUrl + '/trans/check',
    //     body: {'menu': _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '')},
    //     headers: {
    //       "Accept": "Application/json",
    //       "Authorization": "Bearer $token"
    //     }
    // );
    // var data1 = json.decode(apiResult.body);
    // print('tes isi '+data1.toString());

    // for(var v in data1['menu']){
    //   menuReady.add(v['ready']);
    //   // deleteAnimation.add(false);
    // }

    // print(deleteAnimation);
    setState(() {
      // ongkir = data1['ongkir'].toString();
      // restoAddress = data1['address'];
      menuJson = _menuJson;
      print('OY '+restoAddress.toString());
      // print(menuJson);
      _tempMenu = _menuJson;
      _restId = _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('menuJson');
    await preferences.remove('restoId');
    await preferences.remove('qty');
    await preferences.remove('note');
    await preferences.remove('address');
    await preferences.remove('inCart');
    await pref.remove('restoIdUsr');
    pref.remove("addressDelivTrans");
    pref.remove("distan");

    // if (apiResult.statusCode == 200) {
    //   noted2.removeWhere((element) => element.contains('kam5ia_null}'));
    //   isLoading = false;
    // }
  }

  Future _getData2(String qrscan)async{
    List<MenuJson> _menuJson = [];
    List<String> _menuId = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    _transCode = int.parse(pref2.getString("metodeBeli")??'1');
    name = (pref2.getString('menuJson')??"");
    nameUser = (pref2.getString('name')??"");
    playerId = (pref2.getString('playerId')??"");
    restoAddress = (pref2.getString('alamateResto')??"");
    print('ini name '+name.toString());
    restoId.addAll(pref2.getStringList('restoId')??[]);
    qty.addAll(pref2.getStringList('qty')??[]);
    noted.addAll(pref2.getStringList('note')??[]);
    noted2.addAll(pref2.getStringList('note')??[]);
    noted2.removeWhere((element) => element.contains('kam5ia_null}'));
    _tempRestoId.addAll(pref2.getStringList('restoId')??[]);
    _tempQty.addAll(pref2.getStringList('qty')??[]);
    var data = json.decode(name);
    print('ini data bos '+noted.toString());

    for(var v in data){
      _menuId.add(v['id'].toString());
      MenuJson j = MenuJson(
          id: v['id'],
          name: v['name'],
          restoName: v['restoName'],
          desc: v['desc'],
          distance: v['distance'],
          price: v['price'],
          pricePlus: v['pricePlus'],
          discount: v['discount'],
          urlImg: v['urlImg'], restoId: ''
      );
      _menuJson.add(j);
      print('hrg '+v.toString());
      harga = (v['discount'].toString() == '' || v['discount'].toString() == 'null' || v['discount'].toString() == v['price'].toString())?(harga + int.parse(v['price']) * int.parse(qty[restoId.indexOf(v['id'].toString())])):(harga + int.parse(v['discount']) * int.parse(qty[restoId.indexOf(v['id'].toString())]));
      totalHarga = harga.toString();
    }
    print(_menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', ''));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    can_delivery = pref.getString('can_deliveryUser');
    can_takeaway = pref.getString('can_take_awayUser');
    checkId = pref.getString('restoIdUsr')??'';
    print('ini '+checkId);

    var apiResult = await http.post(Links.mainUrl + '/trans/check',
        body: {'menu': _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '')},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    var data1 = json.decode(apiResult.body);
    print('tes isi '+data1.toString());

    // for(var v in data1['menu']){
    //   menuReady.add(v['ready']);
    //   // deleteAnimation.add(false);
    // }

    // print(deleteAnimation);
    setState(() {
      ongkir = (data1['ongkir'].toString() != 'null')?data1['ongkir'].toString():'0';
      // restoAddress = data1['address'];
      menuJson = _menuJson;
      print('OY '+restoAddress.toString());
      // print(menuJson);
      _tempMenu = _menuJson;
      _restId = _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
    });

    if (apiResult.statusCode == 200) {
      isLoading = false;
      Future.delayed(const Duration(seconds: 0), () {
        makeTransaction(qrscan);
        setState(() {
          // Here you can write your code for open new view
        });

      });
    }
  }

  String emailTokoTrans = '';
  String ownerTokoTrans = '';
  String pjTokoTrans = '';
  String bankTokoTrans = '';
  String nameNorekTokoTrans = '';
  String nameRekening = '';
  String nameBank = '';
  String norekTokoTrans = '';
  Future<void> _getUserDataResto()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/userdata/$checkId', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('idRes '+checkId.toString());
    print('pong '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // for(var v in data['menu']){
    //   Menu p = Menu(
    //       id: v['id'],
    //       name: v['name'],
    //       desc: v['desc'],
    //       urlImg: v['img'],
    //       type: v['type'],
    //       is_recommended: v['is_recommended'],
    //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
    //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
    //   );
    //   _menu.add(p);
    // }
    setState(() {
      emailTokoTrans = data['email'].toString();
      ownerTokoTrans = data['name_owner'].toString();
      pjTokoTrans = data['name_pj'].toString();
      // bankTokoTrans = data['bank'].toString();
      // nameNorekTokoTrans = data['namaNorek'].toString();
      nameRekening = data['nama_norek'].toString();
      nameBank = data['bank_norek'].toString();
      norekTokoTrans = data['norek'].toString();
      // isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      // kosong = true;
      isLoading = false;
    }
  }

  Future<String?>? makeTransaction(String qrscan)async{
    print(qrscan);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.post(Links.mainUrl + '/trans',
        body: {
          'address': (_transCode == 1)?_srchAddress.text.toString():'',
          'type': (_transCode == 1)?'delivery':(_transCode == 2)?'takeaway':'dinein',
          'ongkir': totalOngkir,
          'discount': '0',
          'menu': _restId,
          'note': noted2.toString(),
          'qty': _qty,
          'barcode': qrscan
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('OYd2 '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('menuJson');
      await preferences.remove('restoId');
      await preferences.remove('qty');
      await preferences.remove('note');
      await preferences.remove('address');
      await preferences.remove('inCart');
      await pref.remove('restoIdUsr');
      await pref.remove('addressDelivTrans');
      // notif(playerId);
    }
  }

  Future notif(String device)async{
    print('ini '+device.toString());
    List<String> id = [];
    id.add(device);
    await OneSignal.shared.postNotification(OSCreateNotification(
      playerIds: id,
      heading: "$nameUser telah memesan barang di toko Anda",
      content: "Cek sekarang !",
      androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    ));
  }


  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan lagi untuk kembali ke menu utama');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  // Future notif(String device, String sender, String message)async{
  //   List<String> id = [];
  //   id.add(device);
  //   await OneSignal.shared.postNotification(OSCreateNotification(
  //     playerIds: id,
  //     heading: sender,
  //     content: message,
  //     androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
  //   ));
  // }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + restoAddress;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ScreenshotController screenshotController = ScreenshotController();
  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  String noteProduct = "";
  TextEditingController note = TextEditingController(text: '');
  getNote() async {
    note = TextEditingController(text: (noteProduct.split(': ')[1].contains('kam5ia_null}'))?'':noteProduct.split(': ')[1].split('}')[0]);
    print(noteProduct.split(': ')[1]);
  }

  getNote2() async {
    note = TextEditingController(text: '');
    // print(noteProduct.split(': ')[1]);
  }

  @override
  void initState() {
    Location.instance.getLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    _getData();
    // _getUserDataResto();
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
      child: MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: (isLoading)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Container(
                            //   width: CustomSize.sizeWidth(context) / 8,
                            //   height: CustomSize.sizeWidth(context) / 8,
                            //   decoration: BoxDecoration(
                            //       color: CustomColor.primaryLight,
                            //       shape: BoxShape.circle
                            //   ),
                            //   child: Center(
                            //     child: Icon((_transCode == 1)?FontAwesome.motorcycle:(_transCode == 2)?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                            //   ),
                            // ),
                            // SizedBox(width: CustomSize.sizeWidth(context) / 32,),

                            // CustomText.textHeading6(text: (_transCode == 1)?"Pesan Antar":(_transCode == 2)?"Ambil Langsung":"Makan Ditempat",),
                            CustomText.textHeading4(text: "Nota Transaksi", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                          ],
                        ),
                        // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                        //   child: GestureDetector(
                        //     onTap: (){
                        //       showModalBottomSheet(
                        //           isScrollControlled: true,
                        //           shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                        //           ),
                        //           context: context,
                        //           builder: (_){
                        //             return Padding(
                        //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                        //               child: Column(
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 mainAxisSize: MainAxisSize.min,
                        //                 children: [
                        //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                        //                   Padding(
                        //                     padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                        //                     child: Divider(thickness: 4,),
                        //                   ),
                        //                   SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                        //                   GestureDetector(
                        //                     onTap: ()async{
                        //                       SharedPreferences pref = await SharedPreferences.getInstance();
                        //                       setState(() {
                        //                         if (can_delivery == 'true') {
                        //                           _transCode = 1;
                        //                           pref.setString("metodeBeli", '1');
                        //                           // Navigator.pop(context);
                        //                           Navigator.pushReplacement(context, PageTransition(
                        //                               type: PageTransitionType.fade,
                        //                               child: FinalTrans()));
                        //                         } else {
                        //                           Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                        //                         }
                        //                       });
                        //                     },
                        //                     child: Row(
                        //                       children: [
                        //                         Container(
                        //                           width: CustomSize.sizeWidth(context) / 8,
                        //                           height: CustomSize.sizeWidth(context) / 8,
                        //                           decoration: BoxDecoration(
                        //                               color: CustomColor.primaryLight,
                        //                               shape: BoxShape.circle
                        //                           ),
                        //                           child: Center(
                        //                             child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                        //                           ),
                        //                         ),
                        //                         SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        //                         CustomText.textHeading6(text: "Pesan Antar",),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                        //                   GestureDetector(
                        //                     onTap: ()async{
                        //                       SharedPreferences pref = await SharedPreferences.getInstance();
                        //                       setState(() {
                        //                         if (can_takeaway == 'true') {
                        //                           _transCode = 2;
                        //                           pref.setString("metodeBeli", '2');
                        //                           // Navigator.pop(context);
                        //                           Navigator.pushReplacement(context, PageTransition(
                        //                               type: PageTransitionType.fade,
                        //                               child: FinalTrans()));
                        //                         } else {
                        //                           Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                        //                         }
                        //                       });
                        //                     },
                        //                     child: Row(
                        //                       children: [
                        //                         Container(
                        //                           width: CustomSize.sizeWidth(context) / 8,
                        //                           height: CustomSize.sizeWidth(context) / 8,
                        //                           decoration: BoxDecoration(
                        //                               color: CustomColor.primaryLight,
                        //                               shape: BoxShape.circle
                        //                           ),
                        //                           child: Center(
                        //                             child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                        //                           ),
                        //                         ),
                        //                         SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        //                         CustomText.textHeading6(text: "Ambil Langsung",),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                        //                   GestureDetector(
                        //                     onTap: ()async{
                        //                       SharedPreferences pref = await SharedPreferences.getInstance();
                        //                       setState(() {
                        //                         _transCode = 3;
                        //                         pref.setString("metodeBeli", '3');
                        //                         // Navigator.pop(context);
                        //                         Navigator.pushReplacement(context, PageTransition(
                        //                             type: PageTransitionType.fade,
                        //                             child: FinalTrans()));
                        //                       });
                        //                     },
                        //                     child: Row(
                        //                       children: [
                        //                         Container(
                        //                           width: CustomSize.sizeWidth(context) / 8,
                        //                           height: CustomSize.sizeWidth(context) / 8,
                        //                           decoration: BoxDecoration(
                        //                               color: CustomColor.primaryLight,
                        //                               shape: BoxShape.circle
                        //                           ),
                        //                           child: Center(
                        //                             child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                        //                           ),
                        //                         ),
                        //                         SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        //                         CustomText.textHeading6(text: "Makan Ditempat",),
                        //                       ],
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                        //                 ],
                        //               ),
                        //             );
                        //           }
                        //       );
                        //     },
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                  (_transCode == 1 || _transCode == 2 || _transCode == 3)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.bodyRegular18(text: "*Semua proses pembayaran dan transaksi di luar tanggung jawab IRG!", color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()), maxLines: 3),
                  ),
                  (_transCode == 1 || _transCode == 2 || _transCode == 3)?Divider(thickness: 6, color: Colors.transparent):SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Daftar Pembelian", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: menuJson.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(
                            top: CustomSize.sizeWidth(context) / 68,
                            left: CustomSize.sizeWidth(context) / 18,
                            right: CustomSize.sizeWidth(context) / 18,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 1.65,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textHeading7(
                                        text: menuJson[index].name,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                        maxLines: 1
                                    ),
                                    CustomText.bodyRegular14(
                                        text: menuJson[index].desc,
                                        maxLines: 2,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                    ),
                                    // CustomText.bodyRegular16(text: (noted[index].split(': ')[1] != 'kam5ia_null}')?noted[index].split('{')[1].split('}')[0]:''),
                                    // SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                                    (menuJson[index].discount == null || menuJson[index].discount == 'null' || menuJson[index].discount == '')?CustomText.bodyMedium14(
                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].price)),
                                        maxLines: 1,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                    )
                                        :Row(
                                      children: [
                                        CustomText.bodyMedium14(
                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].price)),
                                            maxLines: 1,
                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                            decoration: TextDecoration.lineThrough
                                        ),
                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                        CustomText.bodyMedium14(
                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].discount!)),
                                            maxLines: 1,
                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                        ),
                                      ],
                                    ),
                                    // (menuReady[index])?Container():CustomText.bodyMedium14(
                                    //     text: "Menu tidak tersedia.",
                                    //     maxLines: 1,
                                    //     color: Colors.red
                                    // ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      CustomText.bodyRegular16(text: qty[index], minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      CustomText.bodyRegular16(text: ' Item', minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                  ),

                  // (noted2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  (noted2.toString() != '[]')?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  // (noted2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  (noted2.toString() != '[]')?Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Catatan Pesananmu", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  ):Container(),
                  (noted2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,):Container(),
                  (noted2.toString() != '[]')?ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: noted2.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(
                            left: CustomSize.sizeWidth(context) / 18,
                            right: CustomSize.sizeWidth(context) / 18,
                            bottom: CustomSize.sizeHeight(context) * 0.0075,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CustomText.textHeading7(text: (noted2[index].split(': ')[1] != 'kam5ia_null}')?noted2[index].split('{')[1].split('}')[0].split(':')[0]+': ':'',  maxLines: 4),
                              Container(
                                  width: CustomSize.sizeWidth(context) / 1.4,
                                  child: CustomText.textTitle3(text: (noted2[index].split(': ')[1] != 'kam5ia_null}')?noted2[index].split('{')[1].split('}')[0]:'',  maxLines: 10, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                              ),
                              // (noted2[index].split(': ')[1] == 'kam5ia_null}' || noted2[index].split(': ')[1] == '}')?Container():GestureDetector(
                              //   onTap: (){
                              //     if (noted2[index].contains(noted2[index]) == true) {
                              //       // noteProduct = noted[restoId.indexOf(promo[index].menu!.id.toString())].toString();
                              //       noteProduct = noted2[index].toString();
                              //       getNote();
                              //       setState(() {});
                              //     } else {
                              //       noteProduct = '';
                              //       getNote2();
                              //       setState(() {});
                              //     }
                              //     showDialog(
                              //         context: context,
                              //         builder: (context) {
                              //           return AlertDialog(
                              //             shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.all(Radius.circular(10))
                              //             ),
                              //             title: Text('Catatan'),
                              //             content: TextField(
                              //               autofocus: true,
                              //               keyboardType: TextInputType.text,
                              //               controller: note,
                              //               decoration: InputDecoration(
                              //                 hintText: "Untuk pesananmu",
                              //                 border: OutlineInputBorder(
                              //                   borderRadius: BorderRadius.circular(10.0),
                              //                 ),
                              //                 enabledBorder: OutlineInputBorder(
                              //                   borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                              //                 ),
                              //                 focusedBorder: OutlineInputBorder(
                              //                   borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                              //                 ),
                              //               ),
                              //             ),
                              //             actions: <Widget>[
                              //               Center(
                              //                 child: Row(
                              //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //                   children: [
                              //                     FlatButton(
                              //                       // minWidth: CustomSize.sizeWidth(context),
                              //                       color: CustomColor.redBtn,
                              //                       textColor: Colors.white,
                              //                       shape: RoundedRectangleBorder(
                              //                           borderRadius: BorderRadius.all(Radius.circular(10))
                              //                       ),
                              //                       child: Text('Hapus'),
                              //                       onPressed: () async{
                              //                         String s = noted[noted.indexOf(noted2[index].toString())];
                              //                         String i = s.replaceAll(noted[noted.indexOf(noted2[index].toString())].split(': ')[1], 'kam5ia_null'+'}') ;
                              //                         print(i);
                              //                         noted[noted.indexOf(noted2[index].toString())] = i.toString();
                              //                         // int i = int.parse(s) + 1;
                              //                         // print(i);
                              //                         // noted.add(note.text);
                              //                         SharedPreferences pref = await SharedPreferences.getInstance();
                              //                         pref.setStringList("note", noted);
                              //                         noteProduct = '';
                              //                         // _getData();
                              //                         getNote();
                              //                         setState(() {
                              //                           // codeDialog = valueText;
                              //                           Navigator.pop(context);
                              //                           Navigator.push(context, PageTransition(
                              //                               type: PageTransitionType.fade,
                              //                               child: FinalTrans()));
                              //                         });
                              //                       },
                              //                     ),
                              //                     FlatButton(
                              //                       // minWidth: CustomSize.sizeWidth(context),
                              //                       color: CustomColor.primaryLight,
                              //                       textColor: Colors.white,
                              //                       shape: RoundedRectangleBorder(
                              //                           borderRadius: BorderRadius.all(Radius.circular(10))
                              //                       ),
                              //                       child: Text('Simpan'),
                              //                       onPressed: () async{
                              //                         String s = noted[noted.indexOf(noted2[index].toString())];
                              //                         String i = s.replaceAll(noted[noted.indexOf(noted2[index].toString())].split(': ')[1], (note.text != '')?note.text+'}':'kam5ia_null'+'}') ;
                              //                         print(i);
                              //                         noted[noted.indexOf(noted2[index].toString())] = i.toString();
                              //                         // int i = int.parse(s) + 1;
                              //                         // print(i);
                              //                         // noted.add(note.text);
                              //                         SharedPreferences pref = await SharedPreferences.getInstance();
                              //                         pref.setStringList("note", noted);
                              //                         noteProduct = '';
                              //                         // _getData();
                              //                         getNote();
                              //                         setState(() {
                              //                           // codeDialog = valueText;
                              //                           Navigator.pop(context);
                              //                           Navigator.push(context, PageTransition(
                              //                               type: PageTransitionType.fade,
                              //                               child: FinalTrans()));
                              //                         });
                              //                       },
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //
                              //             ],
                              //           );
                              //         });
                              //   },
                              //   child: Container(
                              //     // height: CustomSize.sizeHeight(context) / 28,
                              //     // width: CustomSize.sizeWidth(context) / 3,
                              //     // decoration: BoxDecoration(
                              //     //     borderRadius: BorderRadius.circular(20),
                              //     //     border: Border.all(color: Colors.grey)
                              //     // ),
                              //     child: Icon(Icons.edit),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      }
                  ):Container(),

                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Tipe Pembelian", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 18,
                      right: CustomSize.sizeWidth(context) / 18,
                    ),
                    child: CustomText.textHeading6(text: (_transCode == 1)?"Pesan Antar":(_transCode == 2)?"Ambil Langsung":"Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  (_transCode != 3)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  (_transCode == 2)?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 32,
                          right: CustomSize.sizeWidth(context) / 32,
                        ),
                        child: CustomText.textHeading4(text: "Alamat Toko", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: CustomText.textHeading6(
                            text: restoAddress,
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                            maxLines: 10
                        ),
                      ),
                    ],
                  ):SizedBox(),
                  (_transCode == 1)?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 32,
                          right: CustomSize.sizeWidth(context) / 32,
                        ),
                        child: CustomText.textHeading4(text: "Alamat Pengiriman", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: CustomText.textHeading6(
                            text: delivAddress.toString(),
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                            maxLines: 10
                        ),
                      )
                      // SizedBox(height: CustomSize.sizeHeight(context) * 0.008,),
                      // Row(
                      //   children: [
                      //     // (_srchAddress.text != '')?GestureDetector(
                      //     //   onTap: () async{
                      //     //     SharedPreferences pref2 = await SharedPreferences.getInstance();
                      //     //     if (srchAddress == false) {
                      //     //       srchAddress = true;
                      //     //     } else {
                      //     //       srchAddress = false;
                      //     //       List<Placemark> placemark = await Geolocator().placemarkFromAddress(_srchAddress.text);
                      //     //       double distan = await Geolocator().distanceBetween( double.parse(pref2.getString('latResto')), double.parse(pref2.getString('longResto')), placemark[0].position.latitude, placemark[0].position.longitude);
                      //     //       int _ongkir = int.parse(ongkir!);
                      //     //       String dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(distan.toString().split('.')[0]));
                      //     //       int _distan = int.parse(dist.split('.')[0]);
                      //     //       if (_distan != 0) {
                      //     //         int _totalOngkir = _ongkir * _distan;
                      //     //         totalOngkir = _totalOngkir.toString();
                      //     //         int _totalHarga = harga + _totalOngkir;
                      //     //         totalHarga = _totalHarga.toString();
                      //     //       } else {
                      //     //         totalOngkir = ongkir!;
                      //     //         int _totalHarga = harga + int.parse(totalOngkir);
                      //     //         totalHarga = _totalHarga.toString();
                      //     //       }
                      //     //     }
                      //     //     setState(() {});
                      //     //   },
                      //     //   child: Container(
                      //     //     width: CustomSize.sizeWidth(context) / 3,
                      //     //     height: CustomSize.sizeHeight(context) / 22,
                      //     //     decoration: BoxDecoration(
                      //     //         borderRadius: BorderRadius.circular(20),
                      //     //         border: Border.all(color: Colors.black, width: 0.5)
                      //     //     ),
                      //     //     child: Center(
                      //     //       child: Row(
                      //     //         mainAxisAlignment: MainAxisAlignment.center,
                      //     //         crossAxisAlignment: CrossAxisAlignment.center,
                      //     //         children: [
                      //     //           (srchAddress != true)?Icon(Octicons.pencil, size: 14,):Container(),
                      //     //           (srchAddress != true)?SizedBox(width: CustomSize.sizeWidth(context) / 86,):Container(),
                      //     //           (srchAddress != true)?CustomText.bodyMedium12(text: "Ganti Alamat"):CustomText.bodyMedium12(text: "Simpan")
                      //     //         ],
                      //     //       ),
                      //     //     ),
                      //     //   ),
                      //     // ):Container(),
                      //     // (_srchAddress.text != '')?SizedBox(width: CustomSize.sizeWidth(context) / 45,):Container(),
                      //     (srchAddress != true)?GestureDetector(
                      //       onTap: () async{
                      //         var result = await Navigator.push(
                      //             context,
                      //             PageTransition(
                      //                 type: PageTransitionType.rightToLeft,
                      //                 child: SearchAddressMaps(latitude!,longitude!)));
                      //         if(result != ""){
                      //           SharedPreferences pref = await SharedPreferences.getInstance();
                      //           _srchAddress = TextEditingController(text: pref.getString('address'));
                      //           int _ongkir = int.parse(ongkir!.toString());
                      //           String dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(double.parse(pref.getString('distan')));
                      //           int _distan = int.parse(dist.split('.')[0]);
                      //           if (_distan != 0) {
                      //             int _totalOngkir = _ongkir * _distan;
                      //             totalOngkir = _totalOngkir.toString();
                      //             int _totalHarga = harga + _totalOngkir;
                      //             totalHarga = _totalHarga.toString();
                      //             setState(() {});
                      //           } else {
                      //             totalOngkir = ongkir!;
                      //             int _totalHarga = harga + int.parse(totalOngkir);
                      //             totalHarga = _totalHarga.toString();
                      //             setState(() {});
                      //           }
                      //           setState(() {});
                      //         }
                      //       },
                      //       child: Container(
                      //         width: CustomSize.sizeWidth(context) / 3,
                      //         height: CustomSize.sizeHeight(context) / 22,
                      //         decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(20),
                      //             border: Border.all(color: Colors.black, width: 0.5)
                      //         ),
                      //         child: Center(
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               (srchAddress2 != true)?Icon(FontAwesome.map_marker, size: 14,):Container(),
                      //               (srchAddress2 != true)?SizedBox(width: CustomSize.sizeWidth(context) / 86,):Container(),
                      //               (srchAddress2 != true)?CustomText.bodyMedium12(text: "Buka maps"):CustomText.bodyMedium12(text: "Simpan")
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ):Container(),
                      //   ],
                      // ),
                    ],
                  ):SizedBox(),
                  // (_transCode == 1 || _transCode == 2)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  // (_transCode != 3)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  // (_transCode != 3)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),

                  // SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                  // (noted2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: CustomSize.sizeWidth(context) / 32,
                  //       vertical: CustomSize.sizeHeight(context) / 86
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Container(
                  //         width: CustomSize.sizeWidth(context) / 1.6,
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             CustomText.textHeading4(text: "Ada lagi pesanannya ?"),
                  //             CustomText.bodyRegular16(text: "Masih bisa tambah lagi loo")
                  //           ],
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                  //         child: GestureDetector(
                  //           onTap: ()async{
                  //             Navigator.push(
                  //                 context,
                  //                 PageTransition(
                  //                     type: PageTransitionType.rightToLeft,
                  //                     child: new DetailResto(checkId)));
                  //           },
                  //           child: Container(
                  //             height: CustomSize.sizeHeight(context) / 24,
                  //             decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(20),
                  //                 border: Border.all(color: Colors.grey)
                  //             ),
                  //             child: Padding(
                  //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  //               child: Center(
                  //                 child: CustomText.textTitle8(
                  //                     text: "Tambah",
                  //                     color: Colors.grey
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomSize.sizeWidth(context) / 32,
                      // vertical: CustomSize.sizeHeight(context) / 55
                    ),
                    child: Container(
                      width: CustomSize.sizeWidth(context),
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText.textHeading4(text: "Data Usaha", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                          SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                          Container(
                            padding: EdgeInsets.only(
                              left: CustomSize.sizeWidth(context) / 18,
                              right: CustomSize.sizeWidth(context) / 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (nameRestoTrans != '' && nameRestoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (restoAddress != '' && restoAddress != 'null')?
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          _launchURL();
                                        },
                                        child: Container(
                                            width: CustomSize.sizeWidth(context) / 2.1,
                                            child: CustomText.bodyRegular17(text: restoAddress, maxLines: 14, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                                        )
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (emailTokoTrans != '' && emailTokoTrans != 'null')?
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          launch('mailto:$emailTokoTrans');
                                        },
                                        child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (phoneRestoTrans != '' && phoneRestoTrans != 'null')?
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          launch('tel:$phoneRestoTrans');
                                        },
                                        child: CustomText.bodyRegular17(text: phoneRestoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (ownerTokoTrans != '' && ownerTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (pjTokoTrans != '' && pjTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (nameRekening != '' && nameRekening != 'null')?
                                CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameRekening, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (nameBank != '' && nameBank != 'null')?
                                CustomText.bodyRegular17(text: "Rekening Bank: "+nameBank, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (norekTokoTrans != '' && norekTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Rincian Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText.bodyLight16(text: "Harga", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(harga2)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                          ],
                        ),
                      ),
                      (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                      (_transCode == 1)?Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText.bodyLight16(text: "Ongkir", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(delivTotalOngkir)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                          ],
                        ),
                      ):SizedBox(),
                      SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText.bodyLight16(text: "Platform Fee", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(1000), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                          ],
                        ),
                      ),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: Divider(thickness: 1,),
                      ),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                      Padding(
                        padding: EdgeInsets.only(
                          left: CustomSize.sizeWidth(context) / 18,
                          right: CustomSize.sizeWidth(context) / 18,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText.textTitle3(text: "Total Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHargaTrans)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.bodyRegular18(text: "*Terimakasih telah melakukan pembelian menggunakan aplikasi kami, terimakasih!", color: CustomColor.accent, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()), maxLines: 3),
                  ),
                  Divider(thickness: 6, color: CustomColor.secondary,),

                  SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                  GestureDetector(
                    onTap: ()async{
                      // _getData();
                      setState((){});
                      // Navigator.push(context, PageTransition(
                      //     type: PageTransitionType.fade,
                      //     child: FinalTrans()));


                      // String qrcode = '';
                      // if(_transCode == 3){
                      //   try {
                      //     qrcode = await BarcodeScanner.scan();
                      //     setState(() {});
                      //     makeTransaction(qrcode);
                      //     // makeTransaction(qrcode);
                      //     Navigator.pushReplacement(
                      //         context,
                      //         PageTransition(
                      //             type: PageTransitionType.leftToRight,
                      //             child: HomeActivity()));
                      //   } on PlatformException catch (error) {
                      //     if (error.code == BarcodeScanner.CameraAccessDenied) {
                      //       print('Izin kamera tidak diizinkan oleh si pengguna');
                      //     } else {
                      //       print('Error: $error');
                      //     }
                      //   }
                      // }else{
                      //   if(_transCode == 1){
                      //     if(_srchAddress.text != ''){
                      //       makeTransaction(qrcode);
                      //       // makeTransaction(qrcode);
                      //       Navigator.pushReplacement(
                      //           context,
                      //           PageTransition(
                      //               type: PageTransitionType.leftToRight,
                      //               child: HomeActivity()));
                      //     }else{
                      //       Fluttertoast.showToast(
                      //         msg: "Alamat tujuan Anda dimana?",);
                      //     }
                      //   }else{
                      //     makeTransaction(qrcode);
                      //     // makeTransaction(qrcode);
                      //     Navigator.pushReplacement(
                      //         context,
                      //         PageTransition(
                      //             type: PageTransitionType.leftToRight,
                      //             child: HomeActivity()));
                      //   }
                      // }


                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: HomeActivity()));
                    },
                    child: Center(
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 14,
                        decoration: BoxDecoration(
                            color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText.textTitle3(text: "Selesai", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                // CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)), color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 54,),

                  // Container(
                  //   width: CustomSize.sizeWidth(context),
                  //   decoration: BoxDecoration(
                  //       color: CustomColor.secondary
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                  //         child: Container(
                  //           width: CustomSize.sizeWidth(context),
                  //           height: CustomSize.sizeHeight(context) / 3.8,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                  //                 CustomText.textTitle3(text: "Rincian Pembayaran"),
                  //                 SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                  //                 Row(
                  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     CustomText.bodyLight16(text: "Harga"),
                  //                     CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)),
                  //                   ],
                  //                 ),
                  //                 (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                  //                 (_transCode == 1)?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     CustomText.bodyLight16(text: "Ongkir"),
                  //                     CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalOngkir))),
                  //                   ],
                  //                 ):SizedBox(),
                  //                 SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                  //                 Divider(thickness: 1,),
                  //                 SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                  //                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                   children: [
                  //                     CustomText.textTitle3(text: "Total Pembayaran"),
                  //                     CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                  //       GestureDetector(
                  //         onTap: ()async{
                  //           // _getData();
                  //           setState((){});
                  //           // Navigator.push(context, PageTransition(
                  //           //     type: PageTransitionType.fade,
                  //           //     child: FinalTrans()));
                  //
                  //
                  //           // String qrcode = '';
                  //           // if(_transCode == 3){
                  //           //   try {
                  //           //     qrcode = await BarcodeScanner.scan();
                  //           //     setState(() {});
                  //           //     makeTransaction(qrcode);
                  //           //     // makeTransaction(qrcode);
                  //           //     Navigator.pushReplacement(
                  //           //         context,
                  //           //         PageTransition(
                  //           //             type: PageTransitionType.leftToRight,
                  //           //             child: HomeActivity()));
                  //           //   } on PlatformException catch (error) {
                  //           //     if (error.code == BarcodeScanner.CameraAccessDenied) {
                  //           //       print('Izin kamera tidak diizinkan oleh si pengguna');
                  //           //     } else {
                  //           //       print('Error: $error');
                  //           //     }
                  //           //   }
                  //           // }else{
                  //           //   if(_transCode == 1){
                  //           //     if(_srchAddress.text != ''){
                  //           //       makeTransaction(qrcode);
                  //           //       // makeTransaction(qrcode);
                  //           //       Navigator.pushReplacement(
                  //           //           context,
                  //           //           PageTransition(
                  //           //               type: PageTransitionType.leftToRight,
                  //           //               child: HomeActivity()));
                  //           //     }else{
                  //           //       Fluttertoast.showToast(
                  //           //         msg: "Alamat tujuan Anda dimana?",);
                  //           //     }
                  //           //   }else{
                  //           //     makeTransaction(qrcode);
                  //           //     // makeTransaction(qrcode);
                  //           //     Navigator.pushReplacement(
                  //           //         context,
                  //           //         PageTransition(
                  //           //             type: PageTransitionType.leftToRight,
                  //           //             child: HomeActivity()));
                  //           //   }
                  //           // }
                  //
                  //
                  //               Navigator.pushReplacement(
                  //                   context,
                  //                   PageTransition(
                  //                       type: PageTransitionType.fade,
                  //                       child: HomeActivity()));
                  //         },
                  //         child: Center(
                  //           child: Container(
                  //             width: CustomSize.sizeWidth(context) / 1.1,
                  //             height: CustomSize.sizeHeight(context) / 14,
                  //             decoration: BoxDecoration(
                  //                 color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
                  //                 borderRadius: BorderRadius.circular(50)
                  //             ),
                  //             child: Center(
                  //               child: Padding(
                  //                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //                 child: Row(
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: [
                  //                     CustomText.textTitle3(text: "Selesai", color: Colors.white),
                  //                     // CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)), color: Colors.white),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
