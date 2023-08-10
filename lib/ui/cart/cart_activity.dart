import 'dart:convert';

// import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan2/gen/protos/protos.pb.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/model/Transaction.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/ui/cart/final_trans.dart';
import 'package:kam5ia/ui/detail/detail_transaction.dart';
import 'package:kam5ia/ui/profile/edit_profile.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
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

class CartActivity extends StatefulWidget {
  @override
  _CartActivityState createState() => _CartActivityState();
}

class _CartActivityState extends State<CartActivity> {
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
  int harga = 0;
  int hargaReal = 0;
  List<String> restoId = [];
  List<String> qty = [];
  List<String> noted = [];
  List<String> noted2 = [];
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

  String ongkir = '0';
  String totalOngkir = "0";
  String totalOngkirBorzo = "0";
  String totalHarga = "0";
  String totalHargaReal = "0";
  String checkId = "";
  String nameRestoTrans = "";
  String phoneRestoTrans = "";

  List<MenuJson> menuJson = [];
  List<bool> menuReady = [];
  String qr_available = "false";
  String can_delivery = "";
  String can_takeaway = "";
  String delivAddress = "";
  String latRes = "";
  String longRes = "";
  String dist = "0";
  String _distan = '0';
  String message = '';
  String _distan5 = '0';
  int _ongkir = 0;
  int _totalOngkir = 0;
  int _totalHarga = 0;
  int _distance = 0;
  int _platformfee = 1000;
  Future _getData()async{
    List<MenuJson> _menuJson = [];
    List<String> _menuId = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    latRes = pref2.getString('latResto1')??'';
    longRes = pref2.getString('longResto1')??'';
    _transCode = int.parse(pref2.getString("metodeBeli")??'1');
    delivAddress = pref2.getString('addressDelivTrans')??'';
    dist = pref2.getString('distan')??'0';
    _distan = pref2.getString('distan')??'0';
    print('diss '+_distan.toString());
    name = (pref2.getString('menuJson')??"");
    nameUser = (pref2.getString('name')??"");
    playerId = (pref2.getString('playerId')??"");
    restoAddress = (pref2.getString('alamateResto')??"");
    print('ini name '+name.toString());
    restoId.addAll(pref2.getStringList('restoId')??[]);
    nameRestoTrans = pref2.getString("restoNameTrans")??'';
    phoneRestoTrans = pref2.getString("restoPhoneTrans")??'';
    print('nama Rest '+nameRestoTrans);
    qty.addAll(pref2.getStringList('qty')??[]);
    print('qty '+qty.toString());
    noted.addAll(pref2.getStringList('note')??[]);
    noted2.addAll(pref2.getStringList('note')??[]);
    noteKurir = TextEditingController(text: pref2.getString("keterangan")??'');
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
          price: v['price'].toString(),
          pricePlus: v['pricePlus'],
          discount: v['discount'],
          urlImg: v['urlImg'], restoId: ''
      );
      _menuJson.add(j);
      print('hrg '+v.toString());
      harga = (v['discount'].toString() == '' || v['discount'].toString() == 'null' || v['discount'].toString() == v['price'].toString())?(harga + int.parse(v['price'].toString()) * int.parse(qty[restoId.indexOf(v['id'].toString())])):(harga + int.parse(v['discount']) * int.parse(qty[restoId.indexOf(v['id'].toString())]));
      if (_transCode != 3) {
        totalHarga = (harga + _platformfee).toString();
      }
    }
    print(_menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', ''));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    can_delivery = pref.getString('can_deliveryUser')??'';
    can_takeaway = pref.getString('can_take_awayUser')??'';
    checkId = pref.getString('restoIdUsr')??'';
    print('ini '+checkId);
    print('tempek '+ checkId);
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/check'),
        body: {'menu': _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '')},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    var data1 = json.decode(apiResult.body);
    print('tes isi '+apiResult.body.toString());

    // for(var v in data1['menu']){
    //   menuReady.add(v['ready']);
    //   // deleteAnimation.add(false);
    // }

    _getUserDataResto();
    if (apiResult.statusCode.toString() == '200') {
      print('kawan');
      print(apiResult.statusCode);
    }

    // print(deleteAnimation);
    setState(() {
      _ongkir = (data1['ongkir'].toString() != 'null')?int.parse(data1['ongkir'].toString()):0;
      message = data1['message'].toString();
      print('buka tutup');
      print(message);
      ongkir = data1['ongkir'].toString();
      // restoAddress = data1['address'];
      menuJson = _menuJson;
      print('OY '+restoAddress.toString());
      // print(menuJson);
      _tempMenu = _menuJson;
      _restId = _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
    });

    // SharedPreferences pref2 = await SharedPreferences.getInstance();
    delivAddress = (message == 'resto tutup')?'Toko tutup!':pref2.getString('addressDelivTrans')??'';
    print(delivAddress);
    if (delivAddress.toString() != 'null') {
      print('oi 1');
      print(delivAddress);
      if (delivAddress.toString() != 'Toko tutup!') {
        print('oi 2');
        if (delivAddress.toString() == "null" || delivAddress.toString() == "") {

        } else {
          totalOngkirBorzo = (pref2.getString('totalOngkirBorzo').toString() != 'null')?pref2.getString('totalOngkirBorzo')??'0':'0';
          totalOngkirDisBorzo = (pref2.getString('totalOngkirDisBorzo') != 'null')?pref2.getString('totalOngkirDisBorzo')??'0':'0';
          print('totalOngkirBorzo1');
          print(totalOngkirBorzo);
        }
      } else {
        totalOngkirBorzo = '0';
      }
      print(totalOngkirBorzo);
      setState((){});
    } else if (delivAddress.toString() == 'null') {
      totalOngkirBorzo = '0';
      setState((){});
    }


    SharedPreferences pref3 = await SharedPreferences.getInstance();
    _distan = pref3.getString('distan')??'0';
    _distan5 = (_distan.contains('.'))?(int.parse(_distan.split('.')[1]) >= 5)?(int.parse(_distan.split('.')[0])+1).toString():_distan.split('.')[0]:_distan;
    _distance = int.parse((_distan.contains('.'))?(_distan.split('.')[0] == '0')?'1':(int.parse(_distan.split('.')[1]) >= 5)?_distan5:_distan.split('.')[0]:_distan);
    if (_transCode == 1) {
      // if (_distan != '0') {
      //   print('ini _distan '+_distan);
      //   _totalOngkir = _ongkir * _distance;
      //   totalOngkir = _totalOngkir.toString();
      //   _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
      //   totalHarga = (_totalHarga + 1000).toString();
      //   setState(() {});
      // }
      if (delivAddress.toString() == "null" || delivAddress.toString() == "") {

      } else {
        if (totalOngkirBorzo != totalOngkirDisBorzo){
          totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirDisBorzo)).toString();
        } else if (totalOngkirBorzo == totalOngkirDisBorzo){
          print('IKI COK');
          print(totalOngkirBorzo);
          print(double.parse(totalOngkirBorzo).toInt());
          print(int.parse(totalOngkirBorzo).toString());
          totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirBorzo)).toString();
        }
        // totalHarga = (pref.getString('totalHarga')??0).toString();
        setState(() {});
      }
      setState(() {});
    } else {
      _distan = '0';
      _ongkir = 0;
      totalHarga = (harga + _platformfee).toString();
    }

    if (apiResult.statusCode == 200) {
      noted2.removeWhere((element) => element.contains('kam5ia_null}'));
      isLoading = false;
    }
  }

  Future _getData2()async{
    List<MenuJson> _menuJson = [];
    List<String> _menuId = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    restoAddress = (pref2.getString('alamateResto')??"");
    latRes = pref2.getString('latResto1')??'';
    longRes = pref2.getString('longResto1')??'';
    print('latRes');
    print(latRes);
    print(longRes);
    print(restoAddress.toString());
    if (latRes == 'null' || longRes == 'null') {
      var addresses = await locationFromAddress(restoAddress.toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latitude = placemarks[0].latitude;
          longitude = placemarks[0].longitude;
          print('latRes');
          print(latitude);
          print(longitude);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
      // Geocoder2.getDataFromAddress(address: restoAddress.toString(), googleMapApiKey: 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE');
      // geoCode.forwardGeocoding(address: restoAddress.toString());
      // print(addresses.toString());
      // var first = addresses.first;
      // setState(() {
      // latRes = first.coordinates.latitude.toString();
      // latRes = addresses.latitude.toString();
      // longRes = first.coordinates.longitude.toString();
      // longRes = addresses.longitude.toString();
      // print('latt');
      // print(latUser);
      // print(longUser);
      // });
    }
    _transCode = int.parse(pref2.getString("metodeBeli")??'1');
    delivAddress = pref2.getString('addressDelivTrans')??'';
    dist = pref2.getString('distan')??'0';
    _distan = pref2.getString('distan')??'0';
    print('diss '+_distan.toString());
    name = (pref2.getString('menuJson')??"");
    nameUser = (pref2.getString('name')??"");
    playerId = (pref2.getString('playerId')??"");
    print('ini name '+name.toString());
    restoId = [];
    restoId.addAll(pref2.getStringList('restoId')??[]);
    nameRestoTrans = pref2.getString("restoNameTrans")??'';
    phoneRestoTrans = pref2.getString("restoPhoneTrans")??'';
    print('nama Rest '+nameRestoTrans);
    qty = [];
    qty.addAll(pref2.getStringList('qty')??[]);
    print('qty '+qty.toString());
    noted = [];
    noted.addAll(pref2.getStringList('note')??[]);
    print('noted');
    print(noted.toString());
    noted2 = [];
    noted2.addAll(pref2.getStringList('note')??[]);
    noted2.removeWhere((element) => element.contains('kam5ia_null}'));
    print('noted2');
    print(noted2.toString());
    noteKurir = TextEditingController(text: pref2.getString("keterangan")??'');
    _tempRestoId = [];
    _tempRestoId.addAll(pref2.getStringList('restoId')??[]);
    _tempQty = [];
    _tempQty.addAll(pref2.getStringList('qty')??[]);
    var data = json.decode(name);
    print('ini data bos '+data.toString());

    for(var v in data){
      _menuId.add(v['id'].toString());
      MenuJson j = MenuJson(
          id: v['id'],
          name: v['name'],
          restoName: v['restoName'],
          desc: v['desc'],
          distance: v['distance'],
          price: v['price'].toString(),
          pricePlus: v['pricePlus'],
          discount: v['discount'],
          urlImg: v['urlImg'], restoId: ''
      );
      _menuJson.add(j);
      print('hrg '+harga.toString());
      print('hrg '+restoId.toString());
      print('hrg '+qty[restoId.indexOf(v['id'].toString())].toString());
      print('hrg '+v['price'].toString().toString());
      harga = (v['discount'].toString() == '' || v['discount'].toString() == 'null' || v['discount'].toString() == v['price'].toString())?(harga + int.parse(v['price'].toString()) * int.parse(qty[restoId.indexOf(v['id'].toString())])):(harga + int.parse(v['discount']) * int.parse(qty[restoId.indexOf(v['id'].toString())]));
      totalHarga = (harga + _platformfee).toString();
      if (delivAddress.toString() != "null" || delivAddress.toString() != "") {
        totalOngkirBorzo = pref2.getString('totalOngkirBorzo')??'0';
        totalOngkirDisBorzo = pref2.getString('totalOngkirDisBorzo')??'0';
        if (totalOngkirBorzo != totalOngkirDisBorzo){
          totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirDisBorzo)).toString();
        } else if (totalOngkirBorzo == totalOngkirDisBorzo){
          totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirBorzo)).toString();
        }
      }
    }
    print(_menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', ''));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    can_delivery = pref.getString('can_deliveryUser')??'';
    can_takeaway = pref.getString('can_take_awayUser')??'';
    checkId = pref.getString('restoIdUsr')??'';
    print('ini '+checkId);
    print('tempek '+ checkId);
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/check'),
        body: {'menu': _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '')},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    var data1 = json.decode(apiResult.body);
    print('tes isi '+apiResult.body.toString());

    // for(var v in data1['menu']){
    //   menuReady.add(v['ready']);
    //   // deleteAnimation.add(false);
    // }

    _getUserDataResto();
    if (apiResult.statusCode.toString() == '200') {
      print('kawan');
      print(apiResult.statusCode);
    }

    // print(deleteAnimation);
    setState(() {
      // _ongkir = (data1['ongkir'].toString() != 'null')?int.parse(data1['ongkir'].toString()):0;
      message = data1['message'].toString();
      print('buka tutup');
      print(message);
      // ongkir = data1['ongkir'].toString();
      // restoAddress = data1['address'];
      menuJson = _menuJson;
      print('OY '+restoAddress.toString());
      // print(menuJson);
      _tempMenu = _menuJson;
      _restId = _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
    });

    // SharedPreferences pref2 = await SharedPreferences.getInstance();
    delivAddress = (message == 'resto tutup')?'Toko tutup!':pref2.getString('addressDelivTrans')??'';
    print(delivAddress);
    if (delivAddress.toString() != 'null') {
      print('oi 1');
      print(delivAddress);
      if (delivAddress.toString() != 'Toko tutup!') {
        print('oi 2');
        if (delivAddress.toString() == "null" || delivAddress.toString() == "") {

        } else {

          print('totalOngkirBorzo1');
          print(totalOngkirBorzo);
        }
      } else {
        totalOngkirBorzo = '0';
      }
      print(totalOngkirBorzo);
      setState((){});
    } else if (delivAddress.toString() == 'null') {
      totalOngkirBorzo = '0';
      setState((){});
    }


    SharedPreferences pref3 = await SharedPreferences.getInstance();
    _distan = pref3.getString('distan')??'0';
    _distan5 = (_distan.contains('.'))?(int.parse(_distan.split('.')[1]) >= 5)?(int.parse(_distan.split('.')[0])+1).toString():_distan.split('.')[0]:_distan;
    _distance = int.parse((_distan.contains('.'))?(_distan.split('.')[0] == '0')?'1':(int.parse(_distan.split('.')[1]) >= 5)?_distan5:_distan.split('.')[0]:_distan);
    if (_transCode == 1) {
      // if (_distan != '0') {
      //   print('ini _distan '+_distan);
      //   _totalOngkir = _ongkir * _distance;
      //   totalOngkir = _totalOngkir.toString();
      //   _totalHarga = harga + int.parse(totalOngkirBorzo);
      //   totalHarga = (_totalHarga + 1000).toString();
      //   setState(() {});
      // }
      if (delivAddress.toString() == "null" || delivAddress.toString() == "") {

      } else {

        // totalHarga = (pref.getString('totalHarga')??0).toString();
        setState(() {});
      }
      setState(() {});
    } else {
      _distan = '0';
      _ongkir = 0;
    }

    print('totalHarga');
    print(totalHarga);

    if (apiResult.statusCode == 200) {
      isLoading = false;
    }
  }

  String emailTokoTrans = '';
  String ownerTokoTrans = '';
  String pjTokoTrans = '';
  String nameNorekTokoTrans = '';
  String bankTokoTrans = '';
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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/userdata/'+checkId), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(Links.mainUrl + '/resto/userdata/'+checkId);
    var data = json.decode(apiResult.body);

    print('id e '+checkId.toString());
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

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }


  List<Transaction> transaction = [];
  // String note = '';
  Future _getDataHome(String lat, String long)async{
    List<Transaction> _transaction = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/home?lat=$lat&long=$long'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('all data'+apiResult.body.toString());
    var data = json.decode(apiResult.body);
    // print('all data'+data['tipename'].toString().split(',').length.toString());
    // print('all data'+data['tipe'][0].toString());
    print('all data'+data['tipe'][0].toString());
    print('all data1'+data['trans'].toString());
    print('all data'+lat.toString());
    print('all data'+long.toString());
    // print(data['resto']);

    // print('ini banner '+data['banner'].toString());
    // for(var v in data['banner']){
    //   imgBanner t = imgBanner(
    //       id: int.parse(v['resto_id'].toString()),
    //       urlImg: v['img']
    //   );
    //   _images.add(t);
    // }

    if (data.toString().contains('trans')) {
      for(var v in data['trans']){
        Transaction t = Transaction.all2(
          id: v['id'],
          idResto: v['restaurants_id'].toString(),
          date: v['date'],
          img: v['img'],
          nameResto: v['resto_name'],
          status: v['status'],
          total: int.parse((v['total']??0).toString()) + int.parse((v['ongkir']??0).toString()),
          type: v['type_text'],
          note: v['note'].toString(),
          chat_user: v['chat_resto'].toString(),
          // address: v['address'].toString(),
        );
        if (v['type_text'].startsWith('Reservasi') != true) {
          _transaction.add(t);
        } else {

        }
      }
    }
    setState(() {
      transaction = _transaction;
      pref.setString("idnyatransRes", transaction[0].idResto.toString());
      pref.setString("chatUserCount", transaction[0].chat_user);
      Navigator.pop(context);
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 700),
              child: new DetailTransaction(transaction[0].id!, transaction[0].status!, transaction[0].note!, transaction[0].idResto!)));
    });
  }


  String homepg = "";
  TextEditingController noteKurir = TextEditingController(text: '');
  Future<String?>? makeTransaction(String qrscan)async{
    if (_transCode == 3) {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(qrscan));
      if (data != null){
        if (data.link.toString().isEmpty) {
          print('kosong');
          // return HomeActivity();
        }
        print(data.link.path);
        if (data.link.path == "/open/") {
          final qr = data.link.queryParameters["id"];
          print('id = '+qr.toString());
          // if (id != null) {
          //   return DetailResto(id.toString());
          // }
          qrscan = qr.toString().split('/?qr=')[1];
        }
      }
    } else {
      qrscan = '';
    }

    setState((){});
    print((codeNguponYukJson.toString() != '[]')?jsonEncode(codeNguponYuk).toString():'[]');
    print('qrscan');
    print(codeNguponYukJson);
    print(codeNguponYuk);
    print(qrscan);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    if (_transCode != 1) {
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans'),
          body: {
            'address': (_transCode == 1)?delivAddress.toString():'',
            'type': (_transCode == 1)?'delivery':(_transCode == 2)?'takeaway':'dinein',
            'ongkir': totalOngkirBorzo,
            'discount': '0',
            'menu': _restId,
            'note': noted2.toString(),
            'qty': _qty,
            'barcode': qrscan,
            'coupon': (codeNguponYukJson.toString() != '[]')?jsonEncode(codeNguponYuk).toString():'[]'
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      var data = json.decode(apiResult.body);
      print('OYd2 '+jsonEncode(codeNguponYuk).toString());
      print('OYd2 '+data.toString());
      print('OYd2 '+apiResult.body.toString());
      if (data['msg'].toString() == 'meja tidak tersedia') {
        Fluttertoast.showToast(msg: 'Gunakan hp sebelumnya yang sama untuk memesan');
      }
      print('status_code');
      print(data['status_code']);

      for(var v in data['device_id']){
        // User p = User.resto(
        //   name: v['device_id'],
        // );
        List<String> id = [];
        id.add(v);
        print('099');
        print(id);
        OneSignal.shared.postNotification(OSCreateNotification(
          playerIds: id,
          heading: "$nameUser telah memesan menu di resto Anda",
          content: "Cek sekarang !",
          androidChannelId: "9af3771b-b272-4757-9902-b23ee8da77f2",
          collapseId: "forAdmin_$checkId",
          androidSound: 'irg_order.wav',
        ));
        // await OneSignal.shared.postNotificationWithJson();
        // user3.add(v['device_id']);
        // _user.add(p);
      }

      if (data.toString().contains('resto tutup') == true) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                title: Center(child: Text('Pemberitahuan!', style: TextStyle(color: Colors.blue))),
                content: Text('Mohon maaf toko ini sedang tutup.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                actions: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // OutlineButton(
                          //   // minWidth: CustomSize.sizeWidth(context),
                          //   shape: StadiumBorder(),
                          //   highlightedBorderColor: CustomColor.secondary,
                          //   borderSide: BorderSide(
                          //       width: 2,
                          //       color: CustomColor.redBtn
                          //   ),
                          //   child: Text('Batal'),
                          //   onPressed: () async{
                          //     setState(() {
                          //       // codeDialog = valueText;
                          //       Navigator.pop(context);
                          //     });
                          //   },
                          // ),
                          OutlinedButton(
                            // minWidth: CustomSize.sizeWidth(context),
                            // shape: StadiumBorder(),
                            // highlightedBorderColor: CustomColor.secondary,
                            // borderSide: BorderSide(
                            //     width: 2,
                            //     color: CustomColor.accent
                            // ),
                            style: OutlinedButton.styleFrom(shape: StadiumBorder(), surfaceTintColor: CustomColor.accent),
                            child: Text('Oke'),
                            onPressed: () async{
                              Navigator.pop(context);
                              // String qrcode = '';
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              );
            });
      }

      if(apiResult.statusCode == 200 && data['message'] != 'resto tutup'){
        if (codeNguponYukJson != []) {
          for (var x in codeNguponYukJson){
            print('bukan delivery');
            print('codeNguponYukJson x');
            print(x);
            _useNguponYuk(x.toString());
          }
        }

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.remove('menuJson');
        await preferences.remove('restoId');
        await preferences.remove('qty');
        await preferences.remove('note');
        await preferences.remove('address');
        await preferences.remove('inCart');
        await preferences.remove('keterangan');
        await pref.remove('restoIdUsr');
        pref.remove("addressDelivTrans");
        pref.remove("distan");
        Location.instance.getLocation().then((value) {
          setState(() {
            _getDataHome(value.latitude.toString(), value.longitude.toString()).whenComplete(() {
              _getData();
            });
            latitude = value.latitude;
            longitude = value.longitude;
          });
        });
        // Navigator.push(
        //     context,
        //     PageTransition(
        //         type: PageTransitionType.fade,
        //         child: FinalTrans()));
        // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
        print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
      }
    } else if (_transCode == 1) {
      pref.setString('addressDelivTrans', delivAddress.toString());
      var latitudeUser = pref.getString("latitudeUser") ?? "";
      var longitudeUser = pref.getString("longitudeUser") ?? "";
      print('TRANS DELIV');
      print((_transCode == 1)?delivAddress.toString():'');
      print((_transCode == 1)?'delivery':(_transCode == 2)?'takeaway':'dinein');
      print((totalOngkirBorzo != totalOngkirDisBorzo)?totalOngkirDisBorzo:totalOngkirBorzo);
      print("0");
      print(_restId);
      print((_transCode == 1)?(noteKurir.text != '')?(noted2.toString() != '[]')?noted2.toString().replaceAll(']', ', '+'{keterangan: '+noteKurir.text+'}]'):noted2.toString().replaceAll(']', '{keterangan: '+noteKurir.text+'}]'):noted2.toString():noted2.toString());
      print(_qty);
      print(latitudeUser);
      print(longitudeUser);
      print(qrscan);
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans'),
          body: {
            'address': (_transCode == 1)?delivAddress.toString():'',
            'type': (_transCode == 1)?'delivery':(_transCode == 2)?'takeaway':'dinein',
            'ongkir': (totalOngkirBorzo != totalOngkirDisBorzo)?totalOngkirDisBorzo:totalOngkirBorzo,
            'discount': '0',
            'menu': _restId,
            'note': (_transCode == 1)?(noteKurir.text != '')?(noted2.toString() != '[]')?noted2.toString().replaceAll(']', ', '+'{keterangan: '+noteKurir.text+'}]'):noted2.toString().replaceAll(']', '{keterangan: '+noteKurir.text+'}]'):noted2.toString():noted2.toString(),
            'qty': _qty,
            'barcode': qrscan,
            'lat': latitudeUser,
            'long': longitudeUser,
            'coupon': (codeNguponYukJson.toString() != '[]')?jsonEncode(codeNguponYuk).toString():'[]'
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      var data = json.decode(apiResult.body);
      print('OYd3 '+jsonEncode(codeNguponYuk).toString());
      print('OYd3 '+data.toString());
      print('OYd3 '+apiResult.body.toString());
      if (data['msg'].toString() == 'meja tidak tersedia') {
        Fluttertoast.showToast(msg: 'Gunakan hp sebelumnya yang sama untuk memesan');
      }

      for(var v in data['device_id']){
        // User p = User.resto(
        //   name: v['device_id'],
        // );
        List<String> id = [];
        id.add(v);
        print('099');
        print(id);
        OneSignal.shared.postNotification(OSCreateNotification(
          playerIds: id,
          heading: "$nameUser telah memesan menu di resto Anda",
          content: "Cek sekarang !",
          androidChannelId: "9af3771b-b272-4757-9902-b23ee8da77f2",
          collapseId: "forAdmin_$checkId",
          androidSound: 'irg_order.wav',
        ));
        // await OneSignal.shared.postNotificationWithJson();
        // user3.add(v['device_id']);
        // _user.add(p);
      }

      if (data.toString().contains('resto tutup') == true) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                title: Center(child: Text('Pemberitahuan!', style: TextStyle(color: Colors.blue))),
                content: Text('Mohon maaf toko ini sedang tutup.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                actions: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // OutlineButton(
                          //   // minWidth: CustomSize.sizeWidth(context),
                          //   shape: StadiumBorder(),
                          //   highlightedBorderColor: CustomColor.secondary,
                          //   borderSide: BorderSide(
                          //       width: 2,
                          //       color: CustomColor.redBtn
                          //   ),
                          //   child: Text('Batal'),
                          //   onPressed: () async{
                          //     setState(() {
                          //       // codeDialog = valueText;
                          //       Navigator.pop(context);
                          //     });
                          //   },
                          // ),
                          OutlinedButton(
                            // minWidth: CustomSize.sizeWidth(context),
                            // shape: StadiumBorder(),
                            // highlightedBorderColor: CustomColor.secondary,
                            // borderSide: BorderSide(
                            //     width: 2,
                            //     color: CustomColor.accent
                            // ),
                            style: OutlinedButton.styleFrom(shape: StadiumBorder(), surfaceTintColor: CustomColor.accent),
                            child: Text('Oke'),
                            onPressed: () async{
                              Navigator.pop(context);
                              // String qrcode = '';
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              );
            });
      }

      if(apiResult.statusCode == 200 && data['message'] != 'resto tutup'){
        if (codeNguponYukJson != []) {
          for (var x in codeNguponYukJson){
            print('bukan delivery');
            print('codeNguponYukJson x');
            print(x);
            _useNguponYuk(x.toString());
          }
        }
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.remove('menuJson');
        await preferences.remove('restoId');
        await preferences.remove('qty');
        await preferences.remove('note');
        await preferences.remove('address');
        await preferences.remove('inCart');
        await preferences.remove('keterangan');
        await pref.remove('restoIdUsr');
        pref.remove("addressDelivTrans");
        pref.remove("distan");
        Location.instance.getLocation().then((value) {
          setState(() {
            _getDataHome(value.latitude.toString(), value.longitude.toString()).whenComplete(() {
              _getData();
            });
            latitude = value.latitude;
            longitude = value.longitude;
          });
        });
        // Navigator.push(
        //     context,
        //     PageTransition(
        //         type: PageTransitionType.fade,
        //         child: FinalTrans()));
        // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
        print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
      }
    }


    // if(data['status_code'] == 200){
    //   Navigator.pop(context);
    //   Navigator.push(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.fade,
    //           child: FinalTrans()));
    //   // SharedPreferences preferences = await SharedPreferences.getInstance();
    //   // await preferences.remove('menuJson');
    //   // await preferences.remove('restoId');
    //   // await preferences.remove('qty');
    //   // await preferences.remove('note');
    //   // await preferences.remove('address');
    //   // await preferences.remove('inCart');
    //   // await pref.remove('restoIdUsr');
    //   // pref.remove("addressDelivTrans");
    //   // pref.remove("distan");
    //   // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
    //   print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
    // }
  }


  Future _useNguponYuk(String qrcode)async{

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    print('qrcode');
    print(qrcode.toString());
    var apiResult = await http.delete(Uri.parse(Links.nguponUrl + '/kupon/${qrcode.replaceAll('#', '')}'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_useNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.delete(Uri.parse(Links.secondNguponUrl + '/kupon/${qrcode.replaceAll('#', '')}'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }

    // if (data['data'].toString().contains('code') == true) {
    //   refCode = data['data']['ref_code'].toString();
    // }
    // for(var v in data['trans']){
    //   History h = History(
    //     id: v['id'],
    //     name: v['resto_name'],
    //     time: v['time'],
    //     price: v['price'],
    //     img: v['resto_img'],
    //     type: v['type'],
    //     status: v['status'],
    //   );
    //   _history.add(h);
    // }

    setState(() {
      // history = _history;
      // isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      // Navigator.pop(context, 'v');
      // if (history.toString() == '[]') {
      //   ksg = true;
      // } else {
      //   ksg = false;
      // }
    }
  }


  bool loadingBorzo = false;
  Future<String?>? cekHarga()async{
    // print(qrscan);
    setState((){
      loadingBorzo = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    print('restoAddress');
    print((int.parse(totalHarga)-int.parse(totalOngkirBorzo)-_platformfee).toString());
    print(totalOngkirBorzo);
    print(totalHarga);
    print(restoAddress);
    print(pjTokoTrans);
    print(phoneRestoTrans);
    print(latRes);
    print(longRes);
    print(delivAddress);
    print(userName);
    print(notelp);
    print(latUser);
    print(longUser);

    var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/borzo/init'),
        body: {
          'app': 'IRG',
          'resto': checkId,
          'price': (int.parse(totalHarga)-int.parse(totalOngkirDisBorzo)-_platformfee).toString(),
          'address_pick_up': restoAddress,
          'name_pick_up': pjTokoTrans,
          'phone_pick_up': phoneRestoTrans,
          'latitude_pick_up': latRes,
          'longitude_pick_up': longRes,
          'address_sender': delivAddress,
          'name_sender': userName,
          'phone_sender': notelp,
          'latitude_sender': latUser,
          'longitude_sender': longUser,
          // 'transaction_id': 'KAM-00001'
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('Cek Harga '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // totalOngkirBorzo = data['price'].toString().split('.')[0];
    totalOngkirBorzo = data['price'].toString();
    totalOngkirDisBorzo = data['discounted_price'].toString();
    pref.setString('totalOngkirBorzo', totalOngkirBorzo);
    pref.setString('totalOngkirDisBorzo', totalOngkirDisBorzo);
    setState((){
      loadingTrans = false;
      loadingBorzo = false;
    });

    // for(var v in data['device_id']){
    //   // User p = User.resto(
    //   //   name: v['device_id'],
    //   // );
    //   List<String> id = [];
    //   id.add(v);
    //   print('099');
    //   print(id);
    //   OneSignal.shared.postNotification(OSCreateNotification(
    //     playerIds: id,
    //     heading: "$nameUser telah memesan produk di toko Anda",
    //     content: "Cek sekarang !",
    //     androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    //   ));
    //   // await OneSignal.shared.postNotificationWithJson();
    //   // user3.add(v['device_id']);
    //   // _user.add(p);
    // }

    if(apiResult.statusCode == 200){
      print(restoAddress);
      print(pjTokoTrans);
      print(phoneRestoTrans);
      print(latRes);
      print(longRes);
      print(delivAddress);
      print(userName);
      print(notelp);
      print(latUser);
      print(longUser);
      totalOngkirBorzo = data['price'].toString();
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('note');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
      // await pref.remove('restoIdUsr');
      // pref.remove("addressDelivTrans");
      // pref.remove("distan");
      // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
      // print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
    }
  }

  bool loadingTrans = false;
  String totalOngkirDisBorzo = "0";
  Future<String?>? cekHarga2()async{
    // print(qrscan);
    setState((){
      // loadingBorzo = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    print('restoAddress');
    print((int.parse(totalHarga)-int.parse(totalOngkirBorzo)-_platformfee).toString());

    if (latRes == 'null' || longRes == 'null') {
      var addresses = await locationFromAddress(restoAddress.toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latRes = placemarks[0].latitude.toString();
          longRes = placemarks[0].longitude.toString();
          print('latRes');
          print(latRes);
          print(longRes);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
      // Geocoder2.getDataFromAddress(address: restoAddress.toString(), googleMapApiKey: 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE');
      // geoCode.forwardGeocoding(address: restoAddress.toString());
      // print(addresses.toString());
      // var first = addresses.first;
      // setState(() {
      // latRes = first.coordinates.latitude.toString();
      // latRes = addresses.latitude.toString();
      // longRes = first.coordinates.longitude.toString();
      // longRes = addresses.longitude.toString();
      // print('latt');
      // print(latUser);
      // print(longUser);
      // });
    }
    print('price ongkir');
    print((int.parse(totalHarga)-int.parse(totalOngkirBorzo.toString())-_platformfee).toString());

    var latitudeUser = pref.getString("latitudeUser") ?? "";
    var longitudeUser = pref.getString("longitudeUser") ?? "";
    var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/borzo/init'),
        body: {
          'app': 'IRG',
          'resto': checkId,
          'price': (int.parse(totalHarga)-int.parse(totalOngkirDisBorzo.toString())-_platformfee).toString(),
          'address_pick_up': restoAddress,
          'name_pick_up': pjTokoTrans,
          'phone_pick_up': phoneRestoTrans,
          'latitude_pick_up': latRes,
          'longitude_pick_up': longRes,
          'address_sender': delivAddress,
          'name_sender': userName,
          'phone_sender': notelp,
          'latitude_sender': latitudeUser,
          'longitude_sender': longitudeUser,
          // 'transaction_id': 'KAM-00001'
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('Cek Harga2 '+apiResult.body.toString());
    print(totalOngkirBorzo);
    print(totalOngkirDisBorzo);
    print(restoAddress);
    print(pjTokoTrans);
    print(phoneRestoTrans);
    print(latRes);
    print(longRes);
    print(delivAddress);
    print(userName);
    print(notelp);
    print(latUser);
    print(longUser);
    var data = json.decode(apiResult.body);

    print(data['price']);
    totalOngkirBorzo = data['price'].toString();
    // data['discounted_price'].toString()
    totalOngkirDisBorzo = data['discounted_price'].toString();
    if (totalOngkirBorzo != totalOngkirDisBorzo){
      totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirDisBorzo)).toString();
    } else if (totalOngkirBorzo == totalOngkirDisBorzo){
      totalHarga = (int.parse(totalHarga) + int.parse(totalOngkirBorzo.toString())).toString();
    }
    pref.setString('totalOngkirBorzo', totalOngkirBorzo);
    pref.setString('totalOngkirDisBorzo', totalOngkirDisBorzo);
    setState((){
      // loadingTrans = false;
      // loadingBorzo = false;
    });

    // for(var v in data['device_id']){
    //   // User p = User.resto(
    //   //   name: v['device_id'],
    //   // );
    //   List<String> id = [];
    //   id.add(v);
    //   print('099');
    //   print(id);
    //   OneSignal.shared.postNotification(OSCreateNotification(
    //     playerIds: id,
    //     heading: "$nameUser telah memesan produk di toko Anda",
    //     content: "Cek sekarang !",
    //     androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    //   ));
    //   // await OneSignal.shared.postNotificationWithJson();
    //   // user3.add(v['device_id']);
    //   // _user.add(p);
    // }

    if(apiResult.statusCode == 200){
      print(restoAddress);
      print(pjTokoTrans);
      print(phoneRestoTrans);
      print(latRes);
      print(longRes);
      print(delivAddress);
      print(userName);
      print(notelp);
      print(latUser);
      print(longUser);
      totalOngkirBorzo = data['price'].toString();
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('note');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
      // await pref.remove('restoIdUsr');
      // pref.remove("addressDelivTrans");
      // pref.remove("distan");
      // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
      // print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
    }
  }

  Future notif(String device)async{
    print(device);
    List<String> id = [];
    id.add(device);
    print('iki '+id.toString());
    await OneSignal.shared.postNotification(OSCreateNotification(
      playerIds: id,
      heading: "$nameUser telah memesan produk di toko Anda",
      content: "Cek sekarang !",
      androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    ));
  }

  String formattedDate = DateFormat('y-MM-dd').format(DateTime.now());
  List<NguponYuk> nguponYuk = [];
  List<String> codeNguponYuk = [];
  List<String> codeNguponYukJson = [];
  String priceNguponYuk = '';
  Future _getNguponYuk()async{

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    restoId.addAll(pref.getStringList('restoId')??[]);
    String inDetailRes = pref.getString('restoIdUsr').toString();
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=use&user=$email'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }

    for (var h in data['data']['paid']) {
      NguponYuk c = NguponYuk.sub(
        id: int.parse(h['id'].toString()),
        code: h['code'].toString(),
        price: h['value'].toString(),
        status: h['status'],
        date: DateFormat('y-MM-dd').format(DateTime.parse(h['updated_at'].toString())).toString(),
        // expired: DateFormat('y-MM-dd').format(DateTime.parse(h['expired_at'].toString())).toString(),
      );
      nguponYuk.add(c);
      // setState((){});
    }

    // for (var h in data['data']['paid']) {
    //   var apiResultCek = await http.get(Uri.parse(Links.nguponUrl + '/kupon/'+h['id'].toString()+'?restaurant_id=$checkId'), headers: {
    //     "Accept": "Application/json",
    //     "Authorization": "Bearer $token"
    //   });
    //   print('apiResultCek');
    //   print(apiResultCek.body);
    //
    //   var dataCek = json.decode(apiResultCek.body);
    //
    //   // if (dataCek['message'].toString().contains('Data saved successfully') && dataCek['data'].toString() != 'null') {
    //   //   NguponYuk c = NguponYuk.sub(
    //   //       id: int.parse(h['id'].toString()),
    //   //       code: h['code'].toString(),
    //   //       price: h['value'].toString(),
    //   //       status: h['status'],
    //   //       date: DateFormat('y-MM-dd').format(DateTime.parse(h['updated_at'].toString())).toString(),
    //   //       // expired: DateFormat('y-MM-dd').format(DateTime.parse(h['expired_at'].toString())).toString(),
    //   //   );
    //   //   nguponYuk.add(c);
    //   //   setState((){});
    //   // }
    // }

    // for(var v in data['trans']){
    //   History h = History(
    //     id: v['id'],
    //     name: v['resto_name'],
    //     time: v['time'],
    //     price: v['price'],
    //     img: v['resto_img'],
    //     type: v['type'],
    //     status: v['status'],
    //   );
    //   _history.add(h);
    // }

    setState(() {
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200) {
    //   if (nguponYuk.toString() == '[]') {
    //     ksg = true;
    //   } else {
    //     ksg = false;
    //   }
    // }
  }

  Future _checkNguponYuk(String kupon_id)async{

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    // String email = (pref.getString('email')??'');
    // restoId.addAll(pref.getStringList('restoId')??[]);
    // String inDetailRes = pref.getString('restoIdUsr').toString();
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon/$kupon_id?restaurant_id=$checkId'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_checkNguponYuk');
    print('kupon_id');
    print(kupon_id);
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon/$kupon_id?restaurant_id=$checkId'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    
    if (data['message'].toString() == 'Data saved successfully') {
      return true;
    } else {
      return false;
    }
    // setState(() {
    //   // isLoading = false;
    // });
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan lagi untuk kembali ke menu utama');
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('totalOngkirBorzo', totalOngkirBorzo);
      return Future.value(false);
    }
//    SystemNavigator.pop();

    SharedPreferences pref = await SharedPreferences.getInstance();
    String inDetailRes = '';
    inDetailRes = pref.getString('inDetailRes')??'';
    if (inDetailRes != '') {
      pref.remove('inDetailRes');
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: DetailResto(inDetailRes)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    }
    return Future.value(true);
  }


  Future<bool> onWillPop2() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan lagi untuk kembali ke menu utama');
    //   return Future.value(false);
    // }
   // SystemNavigator.pop();
   Navigator.pushReplacement(
       context,
       PageTransition(
           type: PageTransitionType.rightToLeft,
           child: DetailResto(checkId)));
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + restoAddress;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  String noteProduct = "";
  TextEditingController note = TextEditingController(text: '');
  getNote() async {
    note = TextEditingController(text: (noteProduct.split(': ')[1].contains('kam5ia_null}'))?'':noteProduct.split(': ')[1].split('}')[0]);
    print(noteProduct.split(': ')[1]);
  }

  String notelp = "";
  String userName = "";
  String latUser = "";
  String longUser = "";
  getNote2() async {
    note = TextEditingController(text: '');
    // print(noteProduct.split(': ')[1]);
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name') == '')?'null':pref.getString('name')??'';
      notelp = pref.getString('notelp')??'null';
      latUser = (pref.getString('latUser') == '')?'null':pref.getString('latUser')??'';
      longUser = (pref.getString('longUser') == '')?'null':pref.getString('longUser')??'';
      print(notelp+' telp');
      if (notelp.toString() == '' && notelp.toString() == 'null') {
        Fluttertoast.showToast(
          msg: "Isi nomor telepon anda terlebih dahulu!",);
        // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditProfile()));
      }
    });
  }

  @override
  void initState() {
    _getNguponYuk();
    getHomePg();
    getPref().whenComplete((){
      if (notelp.toString() == '' && notelp.toString() == 'null') {
        Fluttertoast.showToast(
          msg: "Isi nomor telepon anda terlebih dahulu!",);
        // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditProfile()));
      }
      Location.instance.getLocation().then((value) {
        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });
      });
      _getData();
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
                  SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Row(
                      children: [
                        SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                        GestureDetector(
                            onTap: ()async{
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              String inDetailRes = '';
                              inDetailRes = pref.getString('inDetailRes')??'';
                              if (inDetailRes != '') {
                                pref.remove('inDetailRes');
                                Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: DetailResto(inDetailRes)));
                              } else {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
                              }
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
                              text: "Cart",
                              color: CustomColor.primary,
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                              maxLines: 2
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: CustomSize.sizeWidth(context) / 8,
                              height: CustomSize.sizeWidth(context) / 8,
                              decoration: BoxDecoration(
                                  color: CustomColor.primaryLight,
                                  shape: BoxShape.circle
                              ),
                              child: Center(
                                child: Icon((_transCode == 1)?FontAwesome.motorcycle:(_transCode == 2)?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                              ),
                            ),
                            SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                            CustomText.textHeading6(text: (_transCode == 1)?"Pesan Antar":(_transCode == 2)?"Ambil Langsung":"Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                          child: GestureDetector(
                            onTap: (){
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                  ),
                                  context: context,
                                  builder: (_){
                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                            child: Divider(thickness: 4,),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                          GestureDetector(
                                            onTap: ()async{
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              setState(() {
                                                if (can_delivery == 'true') {
                                                  _transCode = 1;
                                                  pref.setString("metodeBeli", '1');
                                                  // Navigator.pop(context);
                                                  Navigator.pushReplacement(context, PageTransition(
                                                      type: PageTransitionType.fade,
                                                      child: CartActivity()));
                                                } else {
                                                  Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: CustomSize.sizeWidth(context) / 8,
                                                  height: CustomSize.sizeWidth(context) / 8,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primaryLight,
                                                      shape: BoxShape.circle
                                                  ),
                                                  child: Center(
                                                    child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                  ),
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          GestureDetector(
                                            onTap: ()async{
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              setState(() {
                                                if (can_takeaway == 'true') {
                                                  _transCode = 2;
                                                  pref.setString("metodeBeli", '2');
                                                  // Navigator.pop(context);
                                                  Navigator.pushReplacement(context, PageTransition(
                                                      type: PageTransitionType.fade,
                                                      child: CartActivity()));
                                                } else {
                                                  Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: CustomSize.sizeWidth(context) / 8,
                                                  height: CustomSize.sizeWidth(context) / 8,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primaryLight,
                                                      shape: BoxShape.circle
                                                  ),
                                                  child: Center(
                                                    child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                  ),
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          GestureDetector(
                                            onTap: ()async{
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              setState(() {
                                                _transCode = 3;
                                                pref.setString("metodeBeli", '3');
                                                // Navigator.pop(context);
                                                Navigator.pushReplacement(context, PageTransition(
                                                    type: PageTransitionType.fade,
                                                    child: CartActivity()));
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: CustomSize.sizeWidth(context) / 8,
                                                  height: CustomSize.sizeWidth(context) / 8,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primaryLight,
                                                      shape: BoxShape.circle
                                                  ),
                                                  child: Center(
                                                    child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                  ),
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        ],
                                      ),
                                    );
                                  }
                              );
                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey, width: 1),
                                // color: Colors.grey[200]
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                child: Center(
                                  child: CustomText.textTitle8(
                                      text: "Ganti",
                                      color: Colors.grey,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  (_transCode == 1 || _transCode == 2 || _transCode == 3)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  (_transCode != 3)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  (_transCode == 2)?Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                        CustomText.bodyLight12(text: "Alamat Usaha", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                        SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                        CustomText.textHeading6(
                            text: restoAddress,
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                            maxLines: 10
                        ),
                      ],
                    ),
                  ):SizedBox(),
                  (_transCode == 1)?Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                        CustomText.bodyLight12(text: "Alamat Pengiriman", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                        SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                        CustomText.textHeading4(
                            text: (delivAddress.toString() == "null" || delivAddress.toString() == "")?"Masukkan alamat anda.":delivAddress.toString(),
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                            maxLines: 10
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) * 0.008,),
                        Row(
                          children: [
                            (srchAddress != true)?GestureDetector(
                              onTap: () async{
                                var result = await Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: SearchAddressMaps(latitude!,longitude!)));
                                if(result != ""){
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  _srchAddress = TextEditingController(text: pref.getString('address'));
                                  delivAddress = pref.getString('addressDelivTrans')??'';
                                  print('kene bos');
                                  if (delivAddress != '') {
                                    latUser = (pref.getString('latUser') == '')?'null':pref.getString('latUser')??'';
                                    longUser = (pref.getString('longUser') == '')?'null':pref.getString('longUser')??'';
                                    cekHarga()!.whenComplete((){
                                      _ongkir = int.parse(ongkir.toString());
                                      dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(double.parse(pref.getString('distan')??'0'));
                                      _distan = pref.getString('distan')??'0';
                                      _distan5 = (_distan.contains('.'))?(int.parse(_distan.split('.')[1]) >= 5)?(int.parse(_distan.split('.')[0])+1).toString():_distan.split('.')[0]:_distan;
                                      _distance = int.parse((_distan.contains('.'))?(_distan.split('.')[0] == '0')?'1':(int.parse(_distan.split('.')[1]) >= 5)?_distan5:_distan.split('.')[0]:_distan);
                                      print(_distance);
                                      if (totalOngkirBorzo != totalOngkirDisBorzo) {
                                        print('bagi');
                                        // print((int.parse(totalOngkirBorzo.toString().split('.')[0])/int.parse(totalOngkirDisBorzo)));
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                title: Center(child: Text('Selamat!', style: TextStyle(color: CustomColor.primaryLight))),
                                                content: ((int.parse(totalOngkirBorzo.toString())/int.parse(totalOngkirDisBorzo)) == 2)?
                                                Text('Anda mendapatkan diskon ongkir sebesar 50%', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center):
                                                (delivAddress != '' && totalOngkirDisBorzo == '0' || delivAddress != 'null' && totalOngkirDisBorzo == '0')?
                                                Text('Anda mendapatkan promo bebas ongkir!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center):
                                                Text('Anda mendapatkan potongan ongkir senilai Rp' + NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(totalOngkirBorzo.toString())-int.parse(totalOngkirDisBorzo))), style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                actions: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 25, right: 25),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          // OutlineButton(
                                                          //   // minWidth: CustomSize.sizeWidth(context),
                                                          //   shape: StadiumBorder(),
                                                          //   highlightedBorderColor: CustomColor.secondary,
                                                          //   borderSide: BorderSide(
                                                          //       width: 2,
                                                          //       color: CustomColor.redBtn
                                                          //   ),
                                                          //   child: Text('Batal'),
                                                          //   onPressed: () async{
                                                          //     setState(() {
                                                          //       // codeDialog = valueText;
                                                          //       Navigator.pop(context);
                                                          //     });
                                                          //   },
                                                          // ),
                                                          OutlinedButton(
                                                            // minWidth: CustomSize.sizeWidth(context),
                                                            // shape: StadiumBorder(),
                                                            // highlightedBorderColor: CustomColor.secondary,
                                                            // borderSide: BorderSide(
                                                            //     width: 2,
                                                            //     color: CustomColor.accent
                                                            // ),
                                                            style: OutlinedButton.styleFrom(shape: StadiumBorder(), surfaceTintColor: CustomColor.accent),
                                                            child: Text('Terimakasih', style: TextStyle(color: CustomColor.accent)),
                                                            onPressed: () async{
                                                              Navigator.pop(context);
                                                              // setStateModal(() {});
                                                              // String qrcode = '';
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              );
                                            });
                                      }
                                      if (_distan != '0') {
                                        _totalOngkir = _ongkir * _distance;
                                        totalOngkir = _totalOngkir.toString();
                                        print('totalOngkirBorzo');
                                        print(totalOngkirBorzo);
                                        if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                          int _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
                                          totalHarga = (_totalHarga + _platformfee).toString();
                                          pref.setString('totalHarga', totalHarga);
                                          setState(() {});
                                        } else {
                                          int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                          totalHarga = (_totalHarga + _platformfee).toString();
                                          pref.setString('totalHarga', totalHarga);
                                          setState(() {});
                                        }
                                        // int _totalHarga = harga + (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString())?int.parse(totalOngkirBorzo):int.parse(totalOngkirDisBorzo);

                                      } else {
                                        totalOngkir = ongkir!;
                                        if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                          int _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
                                          totalHarga = (_totalHarga + _platformfee).toString();
                                          pref.setString('totalHarga', totalHarga);
                                          setState(() {});
                                        } else {
                                          int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                          totalHarga = (_totalHarga + _platformfee).toString();
                                          pref.setString('totalHarga', totalHarga);
                                          setState(() {});
                                        }
                                      }
                                    });
                                    print('kene bos2');
                                  }
                                  // _ongkir = int.parse(ongkir!.toString());
                                  // dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(double.parse(pref.getString('distan')));
                                  // _distan = pref.getString('distan')??'0';
                                  // _distan5 = (_distan.contains('.'))?(int.parse(_distan.split('.')[1]) >= 5)?(int.parse(_distan.split('.')[0])+1).toString():_distan.split('.')[0]:_distan;
                                  // _distance = int.parse((_distan.contains('.'))?(_distan.split('.')[0] == '0')?'1':(int.parse(_distan.split('.')[1]) >= 5)?_distan5:_distan.split('.')[0]:_distan);
                                  // print(_distance);
                                  // if (_distan != '0') {
                                  //   _totalOngkir = _ongkir * _distance;
                                  //   totalOngkir = _totalOngkir.toString();
                                  //   int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                  //   totalHarga = _totalHarga.toString();
                                  //   setState(() {});
                                  // } else {
                                  //   totalOngkir = ongkir!;
                                  //   int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                  //   totalHarga = _totalHarga.toString();
                                  //   setState(() {});
                                  // }
                                  setState(() {});
                                }
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3,
                                height: CustomSize.sizeHeight(context) / 22,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black, width: 0.5)
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      (srchAddress2 != true)?Icon(FontAwesome.map_marker, size: 14,):Container(),
                                      (srchAddress2 != true)?SizedBox(width: CustomSize.sizeWidth(context) / 86,):Container(),
                                      (srchAddress2 != true)?CustomText.bodyMedium12(text: "Buka maps", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())):CustomText.bodyMedium12(text: "Simpan", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()))
                                    ],
                                  ),
                                ),
                              ),
                            ):Container(),
                          ],
                        ),
                      ],
                    ),
                  ):SizedBox(),
                  (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 98,):(_transCode == 2)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  (_transCode == 1)?Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 32,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 1.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.textHeading4(text: "Ada catatan untuk kurir ?", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                              CustomText.bodyRegular16(text: "Tambah keterangan untuk alamatmu", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                          child: GestureDetector(
                            onTap: ()async{
                              // Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      title: Text('Catatan'),
                                      content: TextField(
                                        autofocus: true,
                                        keyboardType: TextInputType.text,
                                        controller: noteKurir,
                                        decoration: InputDecoration(
                                          hintText: "Untuk keterangan alamat",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                            child: TextButton(
                                              // minWidth: CustomSize.sizeWidth(context),
                                              style: TextButton.styleFrom(
                                                backgroundColor: CustomColor.primaryLight,
                                                padding: EdgeInsets.all(0),
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                              ),
                                              child: Text('Simpan', style: TextStyle(color: Colors.white)),
                                              onPressed: () async{
                                                // String s = noted[restoId.indexOf(menuJson[index].id.toString())];
                                                // String i = s.replaceAll(noted[restoId.indexOf(menuJson[index].id.toString())].split(': ')[1], (note.text != '')?note.text+'}':'kam5ia_null'+'}') ;
                                                // print(i);
                                                // noted[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                // int i = int.parse(s) + 1;
                                                // print(i);
                                                // noted.add(note.text);
                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                print('noted kurir');
                                                print(noteKurir.text);
                                                String plus = '';
                                                plus = noted.toString().replaceAll(']', ', '+'{keterangan: '+noteKurir.text+'}]');
                                                print('plus');
                                                print(plus);
                                                print('noted');
                                                print(noted);
                                                print('noted');
                                                print(noted);
                                                print(noteKurir.text);
                                                pref.setString('keterangan', noteKurir.text);
                                                // pref.setStringList("note", noted);
                                                // noteProduct = '';
                                                // _getData();
                                                // getNote();
                                                setState(() {
                                                  // codeDialog = valueText;
                                                  Navigator.pop(context);
                                                  // Navigator.push(context, PageTransition(
                                                  //     type: PageTransitionType.fade,
                                                  //     child: CartActivity()));
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 24,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                child: Center(
                                  child: CustomText.textTitle8(
                                      text: (noteKurir.text != '')?"Ubah":"Tambah",
                                      color: Colors.grey,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ):Container(),
                  (noteKurir.text != '')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,):Container(),
                  (noteKurir.text != '')?Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 18,
                        bottom: CustomSize.sizeHeight(context) * 0.0075,
                      ),
                      child: Container(
                          width: CustomSize.sizeWidth(context) / 1.6,
                          child: CustomText.textTitle3(text: 'keterangan: '+noteKurir.text,  maxLines: 10, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                      )
                  ):Container(),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  (_transCode != 3)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                  // (_transCode != 3)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: menuJson.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(
                            top: CustomSize.sizeWidth(context) / 32,
                            left: CustomSize.sizeWidth(context) / 32,
                            right: CustomSize.sizeWidth(context) / 32,
                          ),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: CustomSize.sizeWidth(context),
                            height: (int.parse(qty[restoId.indexOf(menuJson[index].id.toString())]) <= 0) ? 0 : CustomSize.sizeHeight(context) / 4,
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                Container(
                                  height: CustomSize.sizeHeight(context) / 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 1.65,
                                        height: CustomSize.sizeWidth(context) / 2.8,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                MediaQuery(
                                                    child: CustomText.textHeading4(
                                                        text: menuJson[index].name,
                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                        maxLines: 1
                                                    ),
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                ),
                                                MediaQuery(
                                                    child: CustomText.bodyRegular14(
                                                      text: menuJson[index].desc,
                                                      maxLines: 2,
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                    ),
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                ),
                                                // CustomText.bodyRegular16(text: (noted[index].split(': ')[1] != 'kam5ia_null}')?noted[index].split('{')[1].split('}')[0]:''),
                                                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                                (menuJson[index].discount == null || menuJson[index].discount == 'null' || menuJson[index].discount == '')?MediaQuery(
                                                    child: CustomText.bodyMedium14(
                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].price)),
                                                        maxLines: 1,
                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                    ),
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                )
                                                    :Row(
                                                  children: [
                                                    MediaQuery(
                                                        child: CustomText.bodyMedium14(
                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].price)),
                                                            maxLines: 1,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                            decoration: TextDecoration.lineThrough
                                                        ),
                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                    MediaQuery(
                                                        child: CustomText.bodyMedium14(
                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].discount!)),
                                                            maxLines: 1,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                        ),
                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // (menuReady[index])?Container():CustomText.bodyMedium14(
                                            //     text: "Menu tidak tersedia.",
                                            //     maxLines: 1,
                                            //     color: Colors.red
                                            // ),
                                            (noted[index].split(': ')[1] != 'kam5ia_null}')?Container():GestureDetector(
                                              onTap: (){
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                        title: Text('Catatan'),
                                                        content: TextField(
                                                          autofocus: true,
                                                          keyboardType: TextInputType.text,
                                                          controller: note,
                                                          decoration: InputDecoration(
                                                            hintText: "Untuk pesananmu",
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                                            ),
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                                              child: TextButton(
                                                                // minWidth: CustomSize.sizeWidth(context),
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: CustomColor.primaryLight,
                                                                  padding: EdgeInsets.all(0),
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                  ),
                                                                ),
                                                                child: Text('Simpan', style: TextStyle(color: Colors.white)),
                                                                onPressed: () async{
                                                                  String s = noted[restoId.indexOf(menuJson[index].id.toString())];
                                                                  String i = s.replaceAll(noted[restoId.indexOf(menuJson[index].id.toString())].split(': ')[1], (note.text != '')?note.text+'}':'kam5ia_null'+'}') ;
                                                                  print(i);
                                                                  noted[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                                  // int i = int.parse(s) + 1;
                                                                  // print(i);
                                                                  // noted.add(note.text);
                                                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                                                  pref.setStringList("note", noted);
                                                                  noteProduct = '';
                                                                  // _getData();
                                                                  getNote();
                                                                  setState(() {
                                                                    // codeDialog = valueText;
                                                                    Navigator.pop(context);
                                                                    Navigator.push(context, PageTransition(
                                                                        type: PageTransitionType.fade,
                                                                        child: CartActivity()));
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),

                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                height: CustomSize.sizeHeight(context) / 28,
                                                width: CustomSize.sizeWidth(context) / 2.8,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: Colors.grey)
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 35),
                                                  child: Center(
                                                    child: MediaQuery(
                                                        child: CustomText.bodyRegular14(
                                                            text: 'Tambah catatan',
                                                            color: Colors.grey,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                        ),
                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: CustomSize.sizeWidth(context) / 2.5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                                onTap: (){
                                                  // Navigator.push(
                                                  //     context,
                                                  //     PageTransition(
                                                  //         type: PageTransitionType.rightToLeft,
                                                  //         child: new DetailResto(checkId)));
                                                },
                                                child: FullScreenWidget(
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 3.4,
                                                    height: CustomSize.sizeWidth(context) / 3.4,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.network(Links.subUrl + menuJson[index].urlImg, fit: BoxFit.fitWidth),
                                                    ),
                                                  ),
                                                )
                                              // child: Container(
                                              //   width: CustomSize.sizeWidth(context) / 3.4,
                                              //   height: CustomSize.sizeWidth(context) / 3.4,
                                              //   decoration: BoxDecoration(
                                              //       image: DecorationImage(
                                              //           image: NetworkImage(Links.subUrl + menuJson[index].urlImg),
                                              //           fit: BoxFit.cover
                                              //       ),
                                              //       borderRadius: BorderRadius.circular(20)
                                              //   ),
                                              // ),
                                            ),
                                            Row(
                                              children: [
                                                (codeNguponYuk.toString() == '[]')?GestureDetector(
                                                  onTap: ()async{
                                                    print(index);
                                                    String s = qty[restoId.indexOf(menuJson[index].id.toString())];
                                                    int i = int.parse(s) - 1;
                                                    print(i);
                                                    qty[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setStringList("qty", qty);
                                                    _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
                                                    harga = (menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == null || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == 'null' || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == '')?harga - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price):harga - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].discount!);
                                                    int _total = (menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == null || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == 'null' || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == '')?int.parse(totalHarga) - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price):int.parse(totalHarga) - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].discount!);
                                                    totalHarga = _total.toString();

                                                    if (harga == 0) {
                                                      // Navigator.pop(context);
                                                      // Navigator.pop(context);
                                                      // onWillPop2();
                                                      Navigator.pushReplacement(
                                                          context,
                                                          PageTransition(
                                                              type: PageTransitionType.rightToLeft,
                                                              child: DetailResto(checkId)));
                                                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
                                                      print('ini name '+name.toString());
                                                      pref.remove('inCart');
                                                      pref.setString("menuJson", "");
                                                      pref.setString("restoId", "");
                                                      pref.setString("qty", "");
                                                      pref.setString("note", "");
                                                      pref.remove("restoIdUsr");
                                                      pref.remove("addressDelivTrans");
                                                      pref.remove("distan");
                                                      // pref.remove("restoId");
                                                      // pref.remove("qty");
                                                    }

                                                    if(i == 0){
                                                      qty.removeAt(index);
                                                      noted.removeAt(index);
                                                      menuJson.removeAt(index);
                                                      restoId.removeAt(index);
                                                      String json = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                      print(json);
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      pref.setString("menuJson", json);
                                                      pref.setStringList("restoId", restoId);
                                                      pref.setStringList("qty", qty);
                                                      pref.setStringList("note", noted);
                                                      // Navigator.push(context, PageTransition(
                                                      //     type: PageTransitionType.fade,
                                                      //     child: CartActivity()));

                                                      if(_tempMenu.length == 0){
                                                        pref.setString("inCart", '');
                                                        pref.setString('restaurantId', '');
                                                      }
                                                    }
                                                    print(harga);
                                                    if(delivAddress.toString() != '' && delivAddress.toString() != 'null'){
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      cekHarga2()?.whenComplete((){
                                                        if (_distan != '0') {
                                                          _totalOngkir = _ongkir * _distance;
                                                          totalOngkir = _totalOngkir.toString();
                                                          print('totalOngkirBorzo');
                                                          print(totalOngkirBorzo);
                                                          if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                            int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          } else {
                                                            int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          }
                                                          // int _totalHarga = harga + (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString())?int.parse(totalOngkirBorzo):int.parse(totalOngkirDisBorzo);

                                                        } else {
                                                          totalOngkir = ongkir!;
                                                          if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                            int _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          } else {
                                                            int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          }
                                                        }
                                                        harga = 0;
                                                        _getData2();
                                                      });
                                                    }
                                                    codeNguponYuk = [];
                                                    priceNguponYuk = '';
                                                    setState(() {});
                                                    // if(deleteAnimation[index] != true){
                                                    // if(int.parse(qty[restoId.indexOf(menuJson[index].id.toString())]) > 1){

                                                    // }else{
                                                    // setState(() {
                                                    //   deleteAnimation[index] = true;
                                                    // });
                                                    // print(deleteAnimation);
                                                    // _tempQty.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // _tempMenu.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // _tempRestoId.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // String json = jsonEncode(_tempMenu.map((m) => m.toJson()).toList());
                                                    // print(json);
                                                    // SharedPreferences pref = await SharedPreferences.getInstance();
                                                    // pref.setString("menuJson", json);
                                                    // pref.setStringList("restoId", _tempRestoId);
                                                    // pref.setStringList("qty", _tempQty);
                                                    //
                                                    // if(_tempMenu.length == 0){
                                                    //   pref.setString("inCart", '');
                                                    // }
                                                    // }
                                                    // }
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 12,
                                                    height: CustomSize.sizeWidth(context) / 12,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(child: MediaQuery(
                                                        child: CustomText.textHeading1(text: "-", color: Colors.grey, minSize: double.parse(((MediaQuery.of(context).size.width*0.08).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.08)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.08)).toString())),
                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                    )),
                                                  ),
                                                ):Container(
                                                  width: CustomSize.sizeWidth(context) / 12,
                                                  height: CustomSize.sizeWidth(context) / 12,
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                MediaQuery(
                                                    child: CustomText.bodyRegular16(text: qty[index], minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                (codeNguponYuk.toString() == '[]')?GestureDetector(
                                                  onTap: ()async{
                                                    String s = qty[restoId.indexOf(menuJson[index].id.toString())];
                                                    print(s);
                                                    int i = int.parse(s) + 1;
                                                    print(i);
                                                    qty[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setStringList("qty", qty);
                                                    _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
                                                    harga = (menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == null || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == 'null' || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == '')?harga + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price):harga + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].discount!);
                                                    int _total = (menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == null || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == 'null' || menuJson[restoId.indexOf(menuJson[index].id.toString())].discount.toString() == '')?int.parse(totalHarga) + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price):int.parse(totalHarga) + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].discount!);
                                                    totalHarga = _total.toString();
                                                    print(harga);
                                                    if(delivAddress.toString() != '' && delivAddress.toString() != 'null'){
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      cekHarga2()?.whenComplete((){
                                                        if (_distan != '0') {
                                                          _totalOngkir = _ongkir * _distance;
                                                          totalOngkir = _totalOngkir.toString();
                                                          print('totalOngkirBorzo');
                                                          print(totalOngkirBorzo);
                                                          if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                            int _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          } else {
                                                            int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          }
                                                          // int _totalHarga = harga + (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString())?int.parse(totalOngkirBorzo):int.parse(totalOngkirDisBorzo);

                                                        } else {
                                                          totalOngkir = ongkir!;
                                                          if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                            int _totalHarga = harga + int.parse(totalOngkirBorzo.toString());
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          } else {
                                                            int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                            totalHarga = (_totalHarga + _platformfee).toString();
                                                            pref.setString('totalHarga', totalHarga);
                                                            setState(() {});
                                                          }
                                                        }
                                                        harga = 0;
                                                        _getData2();
                                                      });
                                                    }
                                                    codeNguponYuk = [];
                                                    priceNguponYuk = '';
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 12,
                                                    height: CustomSize.sizeWidth(context) / 12,
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(child: MediaQuery(
                                                        child: CustomText.textHeading1(text: "+", color: Colors.grey, minSize: double.parse(((MediaQuery.of(context).size.width*0.08).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.08)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.08)).toString())),
                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                    )),
                                                  ),
                                                ):Container(
                                                  width: CustomSize.sizeWidth(context) / 12,
                                                  height: CustomSize.sizeWidth(context) / 12,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 68,),
                                Divider()
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 88,),
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
                            left: CustomSize.sizeWidth(context) / 32,
                            right: CustomSize.sizeWidth(context) / 18,
                            bottom: CustomSize.sizeHeight(context) * 0.0075,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CustomText.textHeading7(text: (noted2[index].split(': ')[1] != 'kam5ia_null}')?noted2[index].split('{')[1].split('}')[0].split(':')[0]+': ':'',  maxLines: 4),
                              Container(
                                  width: CustomSize.sizeWidth(context) / 1.6,
                                  child: CustomText.textTitle3(text: (noted2[index].split(': ')[1] != 'kam5ia_null}')?noted2[index].split('{')[1].split('}')[0]:'',  maxLines: 10, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                              ),
                              (noted2[index].split(': ')[1] == 'kam5ia_null}' || noted2[index].split(': ')[1] == '}')?Container():GestureDetector(
                                onTap: (){
                                  if (noted2[index].contains(noted2[index]) == true) {
                                    // noteProduct = noted[restoId.indexOf(promo[index].menu!.id.toString())].toString();
                                    noteProduct = noted2[index].toString();
                                    getNote();
                                    setState(() {});
                                  } else {
                                    noteProduct = '';
                                    getNote2();
                                    setState(() {});
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),
                                          title: Text('Catatan'),
                                          content: TextField(
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            controller: note,
                                            decoration: InputDecoration(
                                              hintText: "Untuk pesananmu",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  TextButton(
                                                    // minWidth: CustomSize.sizeWidth(context),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: CustomColor.redBtn,
                                                      padding: EdgeInsets.all(0),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                    ),
                                                    child: Text('Hapus', style: TextStyle(color: Colors.white)),
                                                    onPressed: () async{
                                                      String s = noted[noted.indexOf(noted2[index].toString())];
                                                      String i = s.replaceAll(noted[noted.indexOf(noted2[index].toString())].split(': ')[1], 'kam5ia_null'+'}') ;
                                                      print(i);
                                                      noted[noted.indexOf(noted2[index].toString())] = i.toString();
                                                      // int i = int.parse(s) + 1;
                                                      // print(i);
                                                      // noted.add(note.text);
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      pref.setStringList("note", noted);
                                                      noteProduct = '';
                                                      // _getData();
                                                      getNote();
                                                      setState(() {
                                                        // codeDialog = valueText;
                                                        Navigator.pop(context);
                                                        Navigator.push(context, PageTransition(
                                                            type: PageTransitionType.fade,
                                                            child: CartActivity()));
                                                      });
                                                    },
                                                  ),
                                                  TextButton(
                                                    // minWidth: CustomSize.sizeWidth(context),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: CustomColor.primaryLight,
                                                      padding: EdgeInsets.all(0),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                    ),
                                                    child: Text('Simpan', style: TextStyle(color: Colors.white)),
                                                    onPressed: () async{
                                                      String s = noted[noted.indexOf(noted2[index].toString())];
                                                      String i = s.replaceAll(noted[noted.indexOf(noted2[index].toString())].split(': ')[1], (note.text != '')?note.text+'}':'kam5ia_null'+'}') ;
                                                      print(i);
                                                      noted[noted.indexOf(noted2[index].toString())] = i.toString();
                                                      // int i = int.parse(s) + 1;
                                                      // print(i);
                                                      // noted.add(note.text);
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      pref.setStringList("note", noted);
                                                      noteProduct = '';
                                                      // _getData();
                                                      getNote();
                                                      setState(() {
                                                        // codeDialog = valueText;
                                                        Navigator.pop(context);
                                                        Navigator.push(context, PageTransition(
                                                            type: PageTransitionType.fade,
                                                            child: CartActivity()));
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        );
                                      });
                                },
                                child: Container(
                                  // height: CustomSize.sizeHeight(context) / 28,
                                  // width: CustomSize.sizeWidth(context) / 3,
                                  // decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(20),
                                  //     border: Border.all(color: Colors.grey)
                                  // ),
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ):Container(),
                  (noted2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 32,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 1.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.textHeading4(text: "Ada lagi pesanannya ?", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                              CustomText.bodyRegular16(text: "Masih bisa tambah lagi loo", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                          child: GestureDetector(
                            onTap: ()async{
                              // Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: DetailResto(checkId)));
                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 24,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey)
                              ),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                child: Center(
                                  child: CustomText.textTitle8(
                                      text: "Tambah",
                                      color: Colors.grey,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  (nguponYuk.toString() != '[]')?Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 32,
                        vertical: CustomSize.sizeHeight(context) * 0.01
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 1.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.textHeading4(text: "Gunakan Ngupon Yuk !", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                              CustomText.bodyRegular16(text: "Pembayaran pesanan anda bisa", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), maxLines: 5),
                              Container(
                                width: CustomSize.sizeWidth(context) / 1.6,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomText.bodyRegular16(text: "menggunakan Ngupon Yuk", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), maxLines: 5),
                                    GestureDetector(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                                                content: Text('Kupon anda hanya berlaku pada harga menu yang anda pesan.\n\nTidak termasuk biaya ongkir.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                actions: <Widget>[
                                                  Center(
                                                    child: TextButton(
                                                      // minWidth: CustomSize.sizeWidth(context),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: CustomColor.accent,
                                                        padding: EdgeInsets.all(0),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                      ),
                                                      child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                                      onPressed: () async{
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),

                                                ],
                                              );
                                            }
                                        );
                                      },
                                      child: FaIcon(
                                        Icons.info_outline,
                                        color: Colors.grey,
                                        size: double.parse(((MediaQuery.of(context).size.width*0.0425).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.0425)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.0425)).toString()),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                          child: GestureDetector(
                            onTap: ()async{
                              // Navigator.pop(context);
                              if (codeNguponYuk.toString() == '[]') {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                                        content: Text('Pastikan jumlah pesanan anda sudah benar sebelum menggunakan kupon, karena jumlah pesanan anda tidak dapat diubah setelah anda menggunakan kupon!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                        // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                        actions: <Widget>[
                                          Center(
                                            child: TextButton(
                                              // minWidth: CustomSize.sizeWidth(context),
                                              style: TextButton.styleFrom(
                                                backgroundColor: CustomColor.accent,
                                                padding: EdgeInsets.all(0),
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                              ),
                                              child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                              onPressed: () async{
                                                // Navigator.pop(context);
                                                var result = await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                        title: Text('Kuponmu', style: TextStyle(color: CustomColor.primary)),
                                                        content: Container(
                                                          height: CustomSize.sizeHeight(context) / 2.2,
                                                          width: CustomSize.sizeWidth(context) / 1.1,
                                                          child: ListView.builder(
                                                              shrinkWrap: true,
                                                              controller: _scrollController,
                                                              physics: BouncingScrollPhysics(),
                                                              itemCount: nguponYuk.length,
                                                              itemBuilder: (_, index){
                                                                return Padding(
                                                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                                                                  child: GestureDetector(
                                                                    onTap: () async{
                                                                      // codeNguponYuk = nguponYuk[index].code.toString();
                                                                      // priceNguponYuk = nguponYuk[index].price.toString();
                                                                    },
                                                                    child: Container(
                                                                      // width: CustomSize.sizeWidth(context),
                                                                      // height: CustomSize.sizeHeight(context) / 7.5,
                                                                      color: Colors.white,
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                width: CustomSize.sizeWidth(context) / 2.5,
                                                                                // width: CustomSize.sizeWidth(context) / 1.6,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    CustomText.textHeading4(
                                                                                        text: nguponYuk[index].code,
                                                                                        maxLines: 2,
                                                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                                    ),
                                                                                    CustomText.textTitle1(
                                                                                        text: 'Potongan: Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(nguponYuk[index].price.toString())),
                                                                                        maxLines: 12,
                                                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                                    ),
                                                                                    // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                                                    // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: (){
                                                                              // showAlertDialog(user[index].id.toString());

                                                                              print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()));
                                                                              if (int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()) == int.parse(formattedDate!.replaceAll('-', '').toString())) {
                                                                                // Fluttertoast.showToast(
                                                                                //     msg: (DateFormat('yMd').format(DateTime.parse(nguponYuk[index].date.toString()).add(Duration(days: 1)))).toString() +'>'+ (DateFormat('yMd').format(DateTime.parse(formattedDate))).toString());
                                                                                Fluttertoast.showToast(
                                                                                    msg: 'Kupon baru dapat digunakan 1 hari setelah pembelian anda!');
                                                                                print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()).toString() +'>'+ int.parse(formattedDate!.replaceAll('-', '').toString()).toString());
                                                                                print('kecil');
                                                                              } else if (int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()) < int.parse(formattedDate!.replaceAll('-', '').toString())) {
                                                                                _checkNguponYuk(nguponYuk[index].id.toString()).then((value){
                                                                                  if (value == true) {
                                                                                    if (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true) {
                                                                                      codeNguponYuk.remove(nguponYuk[index].code.toString());
                                                                                      Navigator.pop(context, 'x');
                                                                                    } else {
                                                                                      if (harga > 0) {
                                                                                        codeNguponYuk.add(nguponYuk[index].code.toString());
                                                                                        Navigator.pop(context, 'v');
                                                                                      } else if (harga == 0) {
                                                                                        codeNguponYuk = [];
                                                                                        codeNguponYuk.add(nguponYuk[index].code.toString());
                                                                                        Navigator.pop(context, 'v');
                                                                                      }
                                                                                    }
                                                                                    priceNguponYuk = nguponYuk[index].price.toString();
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    Fluttertoast.showToast(
                                                                                      msg: "Kupon tidak berlaku pada resto ini!",);
                                                                                  }
                                                                                });
                                                                                print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()).toString() +'>'+ int.parse(formattedDate!.replaceAll('-', '').toString()).toString());
                                                                                print('besar');
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              height: CustomSize.sizeHeight(context) / 32,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  border: Border.all(color: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?CustomColor.redBtn:CustomColor.accent)
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                                                                child: Center(
                                                                                  child: CustomText.textTitle8(
                                                                                      text: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?"Batal":"Gunakan",
                                                                                      color: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?CustomColor.redBtn:CustomColor.accent,
                                                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      );
                                                    });

                                                if (result == 'v') {
                                                  if (harga < int.parse(priceNguponYuk)) {
                                                    if (priceNguponYuk != '') {
                                                      totalHargaReal = totalHarga;
                                                      hargaReal = harga;
                                                      setState((){});
                                                      if (_transCode != 1) {
                                                        _platformfee = 1000;
                                                        totalHarga = (int.parse(totalHargaReal) - hargaReal - _platformfee).toString();
                                                        _platformfee = 0;
                                                        setState((){});
                                                      } else {
                                                        totalHarga = (int.parse(totalHargaReal) - hargaReal).toString();
                                                        setState((){});
                                                      }
                                                      harga = 0;
                                                      setState((){});
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                                              ),
                                                              title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                                                              content: Text('Kupon tidak dapat memberikan pengembalian pembayaran anda dibawah nilai kupon.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                              // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                              actions: <Widget>[
                                                                Center(
                                                                  child: TextButton(
                                                                    // minWidth: CustomSize.sizeWidth(context),
                                                                    style: TextButton.styleFrom(
                                                                      backgroundColor: CustomColor.accent,
                                                                      padding: EdgeInsets.all(0),
                                                                      shape: const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                                      ),
                                                                    ),
                                                                    child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                                                    onPressed: () async{
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                    },
                                                                  ),
                                                                ),

                                                              ],
                                                            );
                                                          }
                                                      );
                                                    }
                                                  } else if (harga > int.parse(priceNguponYuk)) {
                                                    if (priceNguponYuk != '') {
                                                      totalHargaReal = totalHarga;
                                                      hargaReal = harga;
                                                      setState((){});
                                                      if (_transCode != 1) {
                                                        _platformfee = 1000;
                                                        totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                                        harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                                        // _platformfee = 0;
                                                        setState((){});
                                                      } else {
                                                        totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                                        harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                                        setState((){});
                                                      }
                                                      print('harga');
                                                      print(harga);

                                                      Navigator.pop(context);
                                                    }
                                                  } else if (harga == int.parse(priceNguponYuk)) {
                                                    if (priceNguponYuk != '') {
                                                      totalHargaReal = totalHarga;
                                                      hargaReal = harga;
                                                      setState((){});
                                                      if (_transCode != 1) {
                                                        _platformfee = 1000;
                                                        totalHarga = (int.parse(totalHargaReal) - hargaReal - _platformfee).toString();
                                                        _platformfee = 0;
                                                        setState((){});
                                                      } else {
                                                        totalHarga = (int.parse(totalHargaReal) - hargaReal).toString();
                                                        setState((){});
                                                      }
                                                      harga = 0;
                                                      Navigator.pop(context);
                                                    }
                                                  }

                                                  setState((){});
                                                } else if (result == 'x') {
                                                  if (_transCode != 1) {
                                                    _platformfee = 1000;
                                                    totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length) + _platformfee).toString();
                                                    harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                                    setState((){});
                                                  } else {
                                                    totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                                    harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                                    setState((){});
                                                  }
                                                  print('harga x');
                                                  print(harga);
                                                  setState((){});
                                                }
                                              },
                                            ),
                                          ),

                                        ],
                                      );
                                    }
                                );
                              } else {
                                var result = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        title: Text('Kuponmu', style: TextStyle(color: CustomColor.primary)),
                                        content: Container(
                                          height: CustomSize.sizeHeight(context) / 2.2,
                                          width: CustomSize.sizeWidth(context) / 1.1,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              controller: _scrollController,
                                              physics: BouncingScrollPhysics(),
                                              itemCount: nguponYuk.length,
                                              itemBuilder: (_, index){
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                                                  child: GestureDetector(
                                                    onTap: () async{
                                                      // codeNguponYuk = nguponYuk[index].code.toString();
                                                      // priceNguponYuk = nguponYuk[index].price.toString();
                                                    },
                                                    child: Container(
                                                      // width: CustomSize.sizeWidth(context),
                                                      // height: CustomSize.sizeHeight(context) / 7.5,
                                                      color: Colors.white,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                width: CustomSize.sizeWidth(context) / 2.5,
                                                                // width: CustomSize.sizeWidth(context) / 1.6,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    CustomText.textHeading4(
                                                                        text: nguponYuk[index].code,
                                                                        maxLines: 2,
                                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                    ),
                                                                    CustomText.textTitle1(
                                                                        text: 'Potongan: Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(nguponYuk[index].price.toString())),
                                                                        maxLines: 12,
                                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                    ),
                                                                    // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                                    // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              // showAlertDialog(user[index].id.toString());

                                                              print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()));
                                                              if (int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()) == int.parse(formattedDate!.replaceAll('-', '').toString())) {
                                                                // Fluttertoast.showToast(
                                                                //     msg: (DateFormat('yMd').format(DateTime.parse(nguponYuk[index].date.toString()).add(Duration(days: 1)))).toString() +'>'+ (DateFormat('yMd').format(DateTime.parse(formattedDate))).toString());
                                                                Fluttertoast.showToast(
                                                                    msg: 'Kupon baru dapat digunakan 1 hari setelah pembelian anda!');
                                                                print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()).toString() +'>'+ int.parse(formattedDate!.replaceAll('-', '').toString()).toString());
                                                                print('kecil');
                                                              } else if (int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()) < int.parse(formattedDate!.replaceAll('-', '').toString())) {
                                                                _checkNguponYuk(nguponYuk[index].id.toString()).then((value){
                                                                  if (value == true) {
                                                                    if (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true) {
                                                                      codeNguponYuk.remove(nguponYuk[index].code.toString());
                                                                      Navigator.pop(context, 'x');
                                                                    } else {
                                                                      if (harga > 0) {
                                                                        codeNguponYuk.add(nguponYuk[index].code.toString());
                                                                        Navigator.pop(context, 'v');
                                                                      } else if (harga == 0) {
                                                                        codeNguponYuk = [];
                                                                        codeNguponYuk.add(nguponYuk[index].code.toString());
                                                                        Navigator.pop(context, 'v');
                                                                      }
                                                                    }
                                                                    priceNguponYuk = nguponYuk[index].price.toString();
                                                                    setState(() {});
                                                                  }
                                                                });
                                                                print(int.parse(nguponYuk[index].date!.replaceAll('-', '').toString()).toString() +'>'+ int.parse(formattedDate!.replaceAll('-', '').toString()).toString());
                                                                print('besar');
                                                              }


                                                              //===============================


                                                              // _checkNguponYuk(nguponYuk[index].id.toString()).whenComplete((){
                                                              //   if (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true) {
                                                              //     codeNguponYuk.remove(nguponYuk[index].code.toString());
                                                              //     Navigator.pop(context, 'x');
                                                              //   } else {
                                                              //     if (harga > 0) {
                                                              //       codeNguponYuk.add(nguponYuk[index].code.toString());
                                                              //       Navigator.pop(context, 'v');
                                                              //     } else if (harga == 0) {
                                                              //       codeNguponYuk = [];
                                                              //       codeNguponYuk.add(nguponYuk[index].code.toString());
                                                              //       Navigator.pop(context, 'v');
                                                              //     }
                                                              //   }
                                                              //   priceNguponYuk = nguponYuk[index].price.toString();
                                                              // });

                                                              // if (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true) {
                                                              //   codeNguponYuk.remove(nguponYuk[index].code.toString());
                                                              //   Navigator.pop(context, 'x');
                                                              // } else {
                                                              //   if (harga > 0) {
                                                              //     codeNguponYuk.add(nguponYuk[index].code.toString());
                                                              //     Navigator.pop(context, 'v');
                                                              //   } else if (harga == 0) {
                                                              //     codeNguponYuk = [];
                                                              //     codeNguponYuk.add(nguponYuk[index].code.toString());
                                                              //     Navigator.pop(context, 'v');
                                                              //   }
                                                              // }
                                                              // priceNguponYuk = nguponYuk[index].price.toString();

                                                            },
                                                            child: Container(
                                                              height: CustomSize.sizeHeight(context) / 32,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  border: Border.all(color: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?CustomColor.redBtn:CustomColor.accent)
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                                                child: Center(
                                                                  child: CustomText.textTitle8(
                                                                      text: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?"Batal":"Gunakan",
                                                                      color: (codeNguponYuk.toString().contains(nguponYuk[index].code.toString()) == true)?CustomColor.redBtn:CustomColor.accent,
                                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                          ),
                                        ),
                                      );
                                    });

                                if (result == 'v') {
                                  if (harga < int.parse(priceNguponYuk)) {
                                    if (priceNguponYuk != '') {
                                      // totalHargaReal = totalHarga;
                                      // hargaReal = harga;
                                      if (_transCode != 1) {
                                        _platformfee = 1000;
                                        totalHarga = (int.parse(totalHargaReal) - hargaReal - _platformfee).toString();
                                        _platformfee = 0;
                                        setState((){});
                                      } else {
                                        totalHarga = (int.parse(totalHargaReal) - hargaReal).toString();
                                        setState((){});
                                      }
                                      harga = 0;
                                      setState((){});
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                              title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                                              content: Text('Kupon tidak dapat memberikan pengembalian pembayaran anda dibawah nilai kupon.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                              // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                              actions: <Widget>[
                                                Center(
                                                  child: TextButton(
                                                    // minWidth: CustomSize.sizeWidth(context),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: CustomColor.accent,
                                                      padding: EdgeInsets.all(0),
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                    ),
                                                    child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                                    onPressed: () async{
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),

                                              ],
                                            );
                                          }
                                      );
                                    }
                                  } else if (harga > int.parse(priceNguponYuk)) {
                                    if (priceNguponYuk != '') {
                                      // totalHargaReal = totalHarga;
                                      // hargaReal = harga;
                                      if (_transCode != 1) {
                                        _platformfee = 1000;
                                        totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                        harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                        // _platformfee = 0;
                                        setState((){});
                                      } else {
                                        totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                        harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                        setState((){});
                                      }
                                      print('harga');
                                      print(harga);
                                    }
                                  } else if (harga == int.parse(priceNguponYuk)) {
                                    if (priceNguponYuk != '') {
                                      // totalHargaReal = totalHarga;
                                      // hargaReal = harga;
                                      if (_transCode != 1) {
                                        _platformfee = 1000;
                                        totalHarga = (int.parse(totalHargaReal) - hargaReal - _platformfee).toString();
                                        _platformfee = 0;
                                        setState((){});
                                      } else {
                                        totalHarga = (int.parse(totalHargaReal) - hargaReal).toString();
                                        setState((){});
                                      }
                                      harga = 0;
                                    }
                                  }

                                  setState((){});
                                } else if (result == 'x') {
                                  if (_transCode != 1) {
                                    String totalHargaNew = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                    if (totalHargaNew != totalHargaReal) {
                                      totalHarga = ((int.parse(totalHargaReal) - 1000) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                      harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                      print('in x1');
                                    } else {
                                      _platformfee = 1000;
                                      totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length)).toString();
                                      harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                      print('in x2');
                                    }
                                    print('in x');
                                    setState((){});
                                  } else {
                                    _platformfee = 1000;
                                    totalHarga = (int.parse(totalHargaReal) - (int.parse(priceNguponYuk) * codeNguponYuk.length) + _platformfee).toString();
                                    harga = (hargaReal - (int.parse(priceNguponYuk) * codeNguponYuk.length));
                                    setState((){});
                                  }
                                  print('harga x');
                                  print(harga);
                                  print(hargaReal);
                                  print(codeNguponYuk.length);
                                  setState((){});
                                }
                              }

                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 24,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey)
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                child: Center(
                                  child: CustomText.textTitle8(
                                      text: (codeNguponYuk.toString() == '[]')?"Gunakan":(harga != 0)?"Tambah":"Ganti",
                                      color: Colors.grey,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ):Container(),
                  (codeNguponYuk.toString() != '[]')?Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: CustomSize.sizeWidth(context) / 32,
                      // vertical: CustomSize.sizeHeight(context) * 0.01
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 1.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.textHeading4(text: 'Kupon yang digunakan:', minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ):Container(),
                  (codeNguponYuk.toString() != '[]')?Padding(
                    padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                        bottom: CustomSize.sizeHeight(context) * 0.01
                      // vertical: CustomSize.sizeHeight(context) * 0.01
                    ),
                    child: Container(
                      // width: CustomSize.sizeWidth(context) / 1.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              physics: BouncingScrollPhysics(),
                              itemCount: codeNguponYuk.length,
                              itemBuilder: (_, index){
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.textTitle2(text: codeNguponYuk[index], color: CustomColor.primaryLight, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), maxLines: 1),
                                  CustomText.textTitle2(text: 'Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceNguponYuk)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), maxLines: 1),
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ):Container(),

                  // (nguponYuk.toString() != '[]')?Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: CustomSize.sizeWidth(context) / 32,
                  //       vertical: CustomSize.sizeHeight(context) * 0.01
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
                  //             CustomText.textHeading4(text: "Gunakan Ngupon Yuk !", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  //             CustomText.bodyRegular16(text: "Pembayaran pesanan anda bisa", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), maxLines: 5),
                  //             Container(
                  //               width: CustomSize.sizeWidth(context) / 1.6,
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.start,
                  //                 children: [
                  //                   CustomText.bodyRegular16(text: "menggunakan Ngupon Yuk", minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), maxLines: 5),
                  //                   GestureDetector(
                  //                     onTap: () async {
                  //                       showDialog(
                  //                           context: context,
                  //                           builder: (context) {
                  //                             return AlertDialog(
                  //                               contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  //                               shape: RoundedRectangleBorder(
                  //                                   borderRadius: BorderRadius.all(Radius.circular(10))
                  //                               ),
                  //                               title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                  //                               content: Text('Kupon anda hanya berlaku pada harga menu yang anda pesan.\n\nTidak termasuk biaya ongkir.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                               // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                               actions: <Widget>[
                  //                                 Center(
                  //                                   child: FlatButton(
                  //                                     // minWidth: CustomSize.sizeWidth(context),
                  //                                     color: CustomColor.accent,
                  //                                     textColor: Colors.white,
                  //                                     shape: RoundedRectangleBorder(
                  //                                         borderRadius: BorderRadius.all(Radius.circular(10))
                  //                                     ),
                  //                                     child: Text('Mengerti'),
                  //                                     onPressed: () async{
                  //                                       Navigator.pop(context);
                  //                                     },
                  //                                   ),
                  //                                 ),
                  //
                  //                               ],
                  //                             );
                  //                           }
                  //                       );
                  //                     },
                  //                     child: FaIcon(
                  //                       Icons.info_outline,
                  //                       color: Colors.grey,
                  //                       size: double.parse(((MediaQuery.of(context).size.width*0.0425).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.0425)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.0425)).toString()),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                  //         child: GestureDetector(
                  //           onTap: ()async{
                  //             // Navigator.pop(context);
                  //             if (_platformfee != 0) {
                  //               showDialog(
                  //                   context: context,
                  //                   builder: (context) {
                  //                     return AlertDialog(
                  //                       contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  //                       shape: RoundedRectangleBorder(
                  //                           borderRadius: BorderRadius.all(Radius.circular(10))
                  //                       ),
                  //                       title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                  //                       content: Text('Pastikan jumlah pesanan anda sudah benar sebelum menggunakan kupon, karena jumlah pesanan anda tidak dapat diubah setelah anda menggunakan kupon!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                       // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                       actions: <Widget>[
                  //                         Center(
                  //                           child: FlatButton(
                  //                             // minWidth: CustomSize.sizeWidth(context),
                  //                             color: CustomColor.accent,
                  //                             textColor: Colors.white,
                  //                             shape: RoundedRectangleBorder(
                  //                                 borderRadius: BorderRadius.all(Radius.circular(10))
                  //                             ),
                  //                             child: Text('Mengerti'),
                  //                             onPressed: () async{
                  //                               // Navigator.pop(context);
                  //                               var result = await showDialog(
                  //                                   context: context,
                  //                                   builder: (context) {
                  //                                     return AlertDialog(
                  //                                       contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                  //                                       shape: RoundedRectangleBorder(
                  //                                           borderRadius: BorderRadius.all(Radius.circular(10))
                  //                                       ),
                  //                                       title: Text('Kuponmu', style: TextStyle(color: CustomColor.primary)),
                  //                                       content: Container(
                  //                                         height: CustomSize.sizeHeight(context) / 2.2,
                  //                                         width: CustomSize.sizeWidth(context) / 1.1,
                  //                                         child: ListView.builder(
                  //                                             shrinkWrap: true,
                  //                                             controller: _scrollController,
                  //                                             physics: BouncingScrollPhysics(),
                  //                                             itemCount: nguponYuk.length,
                  //                                             itemBuilder: (_, index){
                  //                                               return Padding(
                  //                                                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                  //                                                 child: GestureDetector(
                  //                                                   onTap: () async{
                  //                                                     // codeNguponYuk = nguponYuk[index].code.toString();
                  //                                                     // priceNguponYuk = nguponYuk[index].price.toString();
                  //                                                   },
                  //                                                   child: Container(
                  //                                                     // width: CustomSize.sizeWidth(context),
                  //                                                     // height: CustomSize.sizeHeight(context) / 7.5,
                  //                                                     color: Colors.white,
                  //                                                     child: Row(
                  //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                                                       crossAxisAlignment: CrossAxisAlignment.start,
                  //                                                       children: [
                  //                                                         Row(
                  //                                                           crossAxisAlignment: CrossAxisAlignment.start,
                  //                                                           children: [
                  //                                                             Container(
                  //                                                               width: CustomSize.sizeWidth(context) / 2.5,
                  //                                                               // width: CustomSize.sizeWidth(context) / 1.6,
                  //                                                               child: Column(
                  //                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                                                                 mainAxisAlignment: MainAxisAlignment.center,
                  //                                                                 children: [
                  //                                                                   CustomText.textHeading4(
                  //                                                                       text: nguponYuk[index].code,
                  //                                                                       maxLines: 2,
                  //                                                                       minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                  //                                                                   ),
                  //                                                                   CustomText.textTitle1(
                  //                                                                       text: 'Potongan: Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(nguponYuk[index].price.toString())),
                  //                                                                       maxLines: 12,
                  //                                                                       minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                  //                                                                   ),
                  //                                                                   // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                  //                                                                   // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                  //                                                                 ],
                  //                                                               ),
                  //                                                             ),
                  //                                                           ],
                  //                                                         ),
                  //                                                         GestureDetector(
                  //                                                           onTap: (){
                  //                                                             // showAlertDialog(user[index].id.toString());
                  //                                                             codeNguponYuk = nguponYuk[index].code.toString();
                  //                                                             priceNguponYuk = nguponYuk[index].price.toString();
                  //                                                             Navigator.pop(context, 'v');
                  //                                                           },
                  //                                                           child: Container(
                  //                                                             height: CustomSize.sizeHeight(context) / 32,
                  //                                                             decoration: BoxDecoration(
                  //                                                                 borderRadius: BorderRadius.circular(20),
                  //                                                                 border: Border.all(color: CustomColor.accent)
                  //                                                             ),
                  //                                                             child: Padding(
                  //                                                               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                  //                                                               child: Center(
                  //                                                                 child: CustomText.textTitle8(
                  //                                                                     text: "Gunakan",
                  //                                                                     color: CustomColor.accent,
                  //                                                                     sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                  //                                                                 ),
                  //                                                               ),
                  //                                                             ),
                  //                                                           ),
                  //                                                         ),
                  //                                                       ],
                  //                                                     ),
                  //                                                   ),
                  //                                                 ),
                  //                                               );
                  //                                             }
                  //                                         ),
                  //                                       ),
                  //                                     );
                  //                                   });
                  //
                  //                               if (result != '') {
                  //                                 if (harga < int.parse(priceNguponYuk)) {
                  //                                   if (priceNguponYuk != '') {
                  //                                     totalHarga = (int.parse(totalHarga) - harga - _platformfee).toString();
                  //                                     _platformfee = 0;
                  //                                     harga = 0;
                  //                                     showDialog(
                  //                                         context: context,
                  //                                         builder: (context) {
                  //                                           return AlertDialog(
                  //                                             contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  //                                             shape: RoundedRectangleBorder(
                  //                                                 borderRadius: BorderRadius.all(Radius.circular(10))
                  //                                             ),
                  //                                             title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                  //                                             content: Text('Disarankan harga pesanan anda senilai dengan nilai kupon anda atau bisa lebih, agar anda tidak mengalami kerugian.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                                             // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                                             actions: <Widget>[
                  //                                               Center(
                  //                                                 child: FlatButton(
                  //                                                   // minWidth: CustomSize.sizeWidth(context),
                  //                                                   color: CustomColor.accent,
                  //                                                   textColor: Colors.white,
                  //                                                   shape: RoundedRectangleBorder(
                  //                                                       borderRadius: BorderRadius.all(Radius.circular(10))
                  //                                                   ),
                  //                                                   child: Text('Mengerti'),
                  //                                                   onPressed: () async{
                  //                                                     Navigator.pop(context);
                  //                                                     Navigator.pop(context);
                  //                                                   },
                  //                                                 ),
                  //                                               ),
                  //
                  //                                             ],
                  //                                           );
                  //                                         }
                  //                                     );
                  //                                   }
                  //                                 } else if (harga > int.parse(priceNguponYuk)) {
                  //                                   if (priceNguponYuk != '') {
                  //                                     totalHarga = (int.parse(totalHarga) - int.parse(priceNguponYuk) - _platformfee).toString();
                  //                                     harga = (harga - int.parse(priceNguponYuk));
                  //                                     print('harga');
                  //                                     print(harga);
                  //                                     _platformfee = 0;
                  //                                     Navigator.pop(context);
                  //                                   }
                  //                                 } else if (harga == int.parse(priceNguponYuk)) {
                  //                                   if (priceNguponYuk != '') {
                  //                                     totalHarga = (int.parse(totalHarga) - harga - _platformfee).toString();
                  //                                     _platformfee = 0;
                  //                                     harga = 0;
                  //                                     Navigator.pop(context);
                  //                                   }
                  //                                 }
                  //
                  //                                 setState((){});
                  //                               }
                  //                             },
                  //                           ),
                  //                         ),
                  //
                  //                       ],
                  //                     );
                  //                   }
                  //               );
                  //             } else {
                  //               var result = await showDialog(
                  //                   context: context,
                  //                   builder: (context) {
                  //                     return AlertDialog(
                  //                       contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                  //                       shape: RoundedRectangleBorder(
                  //                           borderRadius: BorderRadius.all(Radius.circular(10))
                  //                       ),
                  //                       title: Text('Kuponmu', style: TextStyle(color: CustomColor.primary)),
                  //                       content: Container(
                  //                         height: CustomSize.sizeHeight(context) / 2.2,
                  //                         width: CustomSize.sizeWidth(context) / 1.1,
                  //                         child: ListView.builder(
                  //                             shrinkWrap: true,
                  //                             controller: _scrollController,
                  //                             physics: BouncingScrollPhysics(),
                  //                             itemCount: nguponYuk.length,
                  //                             itemBuilder: (_, index){
                  //                               return Padding(
                  //                                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                  //                                 child: GestureDetector(
                  //                                   onTap: () async{
                  //                                     // codeNguponYuk = nguponYuk[index].code.toString();
                  //                                     // priceNguponYuk = nguponYuk[index].price.toString();
                  //                                   },
                  //                                   child: Container(
                  //                                     // width: CustomSize.sizeWidth(context),
                  //                                     // height: CustomSize.sizeHeight(context) / 7.5,
                  //                                     color: Colors.white,
                  //                                     child: Row(
                  //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                                       crossAxisAlignment: CrossAxisAlignment.start,
                  //                                       children: [
                  //                                         Row(
                  //                                           crossAxisAlignment: CrossAxisAlignment.start,
                  //                                           children: [
                  //                                             Container(
                  //                                               width: CustomSize.sizeWidth(context) / 2.5,
                  //                                               // width: CustomSize.sizeWidth(context) / 1.6,
                  //                                               child: Column(
                  //                                                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                                                 mainAxisAlignment: MainAxisAlignment.center,
                  //                                                 children: [
                  //                                                   CustomText.textHeading4(
                  //                                                       text: nguponYuk[index].code,
                  //                                                       maxLines: 2,
                  //                                                       minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                  //                                                   ),
                  //                                                   CustomText.textTitle1(
                  //                                                       text: 'Potongan: Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(nguponYuk[index].price.toString())),
                  //                                                       maxLines: 12,
                  //                                                       minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                  //                                                   ),
                  //                                                   // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                  //                                                   // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                  //                                                 ],
                  //                                               ),
                  //                                             ),
                  //                                           ],
                  //                                         ),
                  //                                         GestureDetector(
                  //                                           onTap: (){
                  //                                             // showAlertDialog(user[index].id.toString());
                  //                                             codeNguponYuk = nguponYuk[index].code.toString();
                  //                                             priceNguponYuk = nguponYuk[index].price.toString();
                  //                                             Navigator.pop(context, 'v');
                  //                                           },
                  //                                           child: Container(
                  //                                             height: CustomSize.sizeHeight(context) / 32,
                  //                                             decoration: BoxDecoration(
                  //                                                 borderRadius: BorderRadius.circular(20),
                  //                                                 border: Border.all(color: CustomColor.accent)
                  //                                             ),
                  //                                             child: Padding(
                  //                                               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                  //                                               child: Center(
                  //                                                 child: CustomText.textTitle8(
                  //                                                     text: "Gunakan",
                  //                                                     color: CustomColor.accent,
                  //                                                     sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                  //                                                 ),
                  //                                               ),
                  //                                             ),
                  //                                           ),
                  //                                         ),
                  //                                       ],
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                               );
                  //                             }
                  //                         ),
                  //                       ),
                  //                     );
                  //                   });
                  //
                  //               if (result != '') {
                  //                 if (harga < int.parse(priceNguponYuk)) {
                  //                   if (priceNguponYuk != '') {
                  //                     totalHarga = (int.parse(totalHarga) - harga - _platformfee).toString();
                  //                     _platformfee = 0;
                  //                     harga = 0;
                  //                     showDialog(
                  //                         context: context,
                  //                         builder: (context) {
                  //                           return AlertDialog(
                  //                             contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  //                             shape: RoundedRectangleBorder(
                  //                                 borderRadius: BorderRadius.all(Radius.circular(10))
                  //                             ),
                  //                             title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                  //                             content: Text('Disarankan harga pesanan anda senilai dengan nilai kupon anda atau bisa lebih, agar anda tidak mengalami kerugian.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                             // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                  //                             actions: <Widget>[
                  //                               Center(
                  //                                 child: FlatButton(
                  //                                   // minWidth: CustomSize.sizeWidth(context),
                  //                                   color: CustomColor.accent,
                  //                                   textColor: Colors.white,
                  //                                   shape: RoundedRectangleBorder(
                  //                                       borderRadius: BorderRadius.all(Radius.circular(10))
                  //                                   ),
                  //                                   child: Text('Mengerti'),
                  //                                   onPressed: () async{
                  //                                     Navigator.pop(context);
                  //                                   },
                  //                                 ),
                  //                               ),
                  //
                  //                             ],
                  //                           );
                  //                         }
                  //                     );
                  //                   }
                  //                 } else if (harga > int.parse(priceNguponYuk)) {
                  //                   if (priceNguponYuk != '') {
                  //                     totalHarga = (int.parse(totalHarga) - int.parse(priceNguponYuk) - _platformfee).toString();
                  //                     harga = (harga - int.parse(priceNguponYuk));
                  //                     print('harga');
                  //                     print(harga);
                  //                     _platformfee = 0;
                  //                   }
                  //                 } else if (harga == int.parse(priceNguponYuk)) {
                  //                   if (priceNguponYuk != '') {
                  //                     totalHarga = (int.parse(totalHarga) - harga - _platformfee).toString();
                  //                     _platformfee = 0;
                  //                     harga = 0;
                  //                   }
                  //                 }
                  //
                  //                 setState((){});
                  //               }
                  //             }
                  //
                  //           },
                  //           child: Container(
                  //             height: CustomSize.sizeHeight(context) / 24,
                  //             decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(20),
                  //                 border: Border.all(color: Colors.grey)
                  //             ),
                  //             child: Padding(
                  //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  //               child: Center(
                  //                 child: CustomText.textTitle8(
                  //                     text: (codeNguponYuk == '')?"Gunakan":"Ganti",
                  //                     color: Colors.grey,
                  //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ):Container(),
                  // (codeNguponYuk != '')?Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: CustomSize.sizeWidth(context) / 32,
                  //       // vertical: CustomSize.sizeHeight(context) * 0.01
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
                  //             CustomText.textHeading4(text: 'Kupon yang digunakan:', minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ):Container(),
                  // (codeNguponYuk != '')?Padding(
                  //   padding: EdgeInsets.only(
                  //       left: CustomSize.sizeWidth(context) / 32,
                  //       right: CustomSize.sizeWidth(context) / 32,
                  //       bottom: CustomSize.sizeHeight(context) * 0.01
                  //       // vertical: CustomSize.sizeHeight(context) * 0.01
                  //   ),
                  //   child: Container(
                  //     // width: CustomSize.sizeWidth(context) / 1.6,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             CustomText.textTitle2(text: codeNguponYuk, color: CustomColor.primaryLight, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), maxLines: 1),
                  //             CustomText.textTitle2(text: 'Rp.'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceNguponYuk)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), maxLines: 1),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ):Container(),

                  Container(
                    width: CustomSize.sizeWidth(context),
                    decoration: BoxDecoration(
                        color: CustomColor.secondary
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                          child: Container(
                            width: CustomSize.sizeWidth(context),
                            height: (_transCode == 1)?CustomSize.sizeHeight(context) / 3.2:CustomSize.sizeHeight(context) / 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                  CustomText.textTitle3(text: "Rincian Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight16(text: "Harga", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      CustomText.bodyLight16(text: (codeNguponYuk.toString() != '[]')?(harga == 0)?
                                      'Free':
                                      NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga):
                                      NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  ),
                                  (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                                  (_transCode == 1)?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight16(text: "Ongkir", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      (totalOngkirBorzo != totalOngkirDisBorzo)?(delivAddress != '' && totalOngkirDisBorzo == '0' || delivAddress != 'null' && totalOngkirDisBorzo == '0')?
                                      CustomText.bodyLight16(decoration: TextDecoration.none, text: 'Gratis Ongkir', minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):
                                      Row(
                                        children: [
                                          CustomText.bodyLight16(decoration: TextDecoration.lineThrough, text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalOngkirBorzo)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                          CustomText.bodyLight16(text: ' ', minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                          CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalOngkirDisBorzo)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                        ],
                                      ):CustomText.bodyLight16(decoration: TextDecoration.none, text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalOngkirBorzo)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  ):SizedBox(),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight16(text: "Platform Fee", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      CustomText.bodyLight16(text: (codeNguponYuk.toString() != '[]')?(_transCode != 1 && harga == 0)?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_platformfee):NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_platformfee), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  ),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                  Divider(thickness: 1,),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.textTitle3(text: "Total Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      CustomText.textTitle3(text: (codeNguponYuk.toString() != '[]')?(totalHarga == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)):NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                        GestureDetector(
                          onTap: ()async{
                            // _getData();
                            print('codeNguponYuk');
                            print(codeNguponYuk);
                            codeNguponYukJson = [];
                            for (var h in codeNguponYuk){
                              codeNguponYukJson.add(h.replaceAll('#', ''));
                            }
                            print(codeNguponYukJson);
                            print(jsonEncode(codeNguponYukJson));
                            if (loadingBorzo == true && int.parse(ongkir.toString()) == 0) {
                              print('loadingBorzo');
                              print(loadingBorzo);
                              Fluttertoast.showToast(msg: 'Sedang menghitung ongkir');
                            } else {
                              SharedPreferences pref2 = await SharedPreferences.getInstance();
                              pref2.setString('delivAddress', pref2.getString('addressDelivTrans')??'');
                              // delivAddress = pref2.getString('addressDelivTrans');
                              pref2.setString('delivTotalOngkir', (totalOngkirBorzo != totalOngkirDisBorzo)?totalOngkirDisBorzo:totalOngkirBorzo);
                              pref2.setString('totalHargaTrans', totalHarga.toString());
                              pref2.setString('hargaTrans', harga.toString());
                              pref2.setInt('_platformfee', int.parse(_platformfee.toString()));
                              // _srchAddress.text.toString()

                              // Navigator.push(context, PageTransition(
                              //     type: PageTransitionType.fade,
                              //     child: CartActivity()));


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

                              print('qr_available');
                              print(qr_available);
                              print('ini loh telp '+notelp);
                              print('ini loh  '+message);
                              if (notelp == '' || notelp == 'null') {
                                Fluttertoast.showToast(
                                  msg: "Isi nomor telepon anda terlebih dahulu!",);
                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                              } else {
                                if (message != 'resto buka') {
                                  Fluttertoast.showToast(
                                    msg: "Toko sedang tutup!",);
                                } else {
                                  if (qr_available == 'true') {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                        ),
                                        context: context,
                                        builder: (_){
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                                child: Divider(thickness: 4,),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                              Center(
                                                child: CustomText.textHeading2(
                                                    text: "Qris",
                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                    maxLines: 1
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
                                              Center(
                                                child: FullScreenWidget(
                                                  child: Image.asset("assets/imajilogo.png",
                                                    width: CustomSize.sizeWidth(context) / 1.2,
                                                    height: CustomSize.sizeWidth(context) / 1.2,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomText.textTitle2(
                                                          text: 'Total harga:',
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                          maxLines: 1
                                                      ),
                                                      CustomText.textTitle2(
                                                          text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)),
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                          maxLines: 1
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: CustomText.textTitle1(
                                                      text: 'Scan disini untuk melakukan pembayaran',
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                      maxLines: 1
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: CustomText.textTitle1(
                                                      text: 'ke $nameRestoTrans!',
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                      maxLines: 3
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                              GestureDetector(
                                                onTap: ()async{
                                                  Fluttertoast.showToast(
                                                    msg: "Anda belum membayar!",);
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
                                                        child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                                              // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                            ],
                                          );
                                        }
                                    );
                                  } else {
                                    if(_transCode == 1){
                                      if(delivAddress.toString() != '' && delivAddress.toString() != 'null'){
                                        // makeTransaction(qrcode);
                                        // makeTransaction(qrcode);
                                        if (loadingTrans == false) {
                                          loadingTrans = true;
                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                          cekHarga()?.whenComplete((){
                                            if (_distan != '0') {
                                              _totalOngkir = _ongkir * _distance;
                                              totalOngkir = _totalOngkir.toString();
                                              print('totalOngkirBorzo');
                                              print(totalOngkirBorzo);
                                              if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              } else {
                                                int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              }
                                              // int _totalHarga = harga + (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString())?int.parse(totalOngkirBorzo):int.parse(totalOngkirDisBorzo);

                                            } else {
                                              totalOngkir = ongkir!;
                                              if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              } else {
                                                int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              }
                                            }
                                            if (loadingTrans == false) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                                      content: Text('Apakah anda sudah yakin dengan pesanan anda? ', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                      // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                      actions: <Widget>[
                                                        Center(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              TextButton(
                                                                // minWidth: CustomSize.sizeWidth(context),
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: CustomColor.redBtn,
                                                                  padding: EdgeInsets.all(0),
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                  ),
                                                                ),
                                                                child: Text('Batal', style: TextStyle(color: Colors.white)),
                                                                onPressed: () async{
                                                                  setState(() {
                                                                    // codeDialog = valueText;
                                                                    Navigator.pop(context);
                                                                  });
                                                                },
                                                              ),
                                                              TextButton(
                                                                // minWidth: CustomSize.sizeWidth(context),
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: CustomColor.primaryLight,
                                                                  padding: EdgeInsets.all(0),
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                  ),
                                                                ),
                                                                child: Text('Setuju', style: TextStyle(color: Colors.white)),
                                                                onPressed: () async{
                                                                  Navigator.pop(context);
                                                                  String qrcode = '';
                                                                  if(_transCode == 3){
                                                                    // try {
                                                                    //   qrcode = await BarcodeScanner.scan();
                                                                    //   setState(() {});
                                                                    //   makeTransaction(qrcode);
                                                                    //   // makeTransaction(qrcode);
                                                                    //   Navigator.push(
                                                                    //       context,
                                                                    //       PageTransition(
                                                                    //           type: PageTransitionType.fade,
                                                                    //           child: FinalTrans()));
                                                                    // } on PlatformException catch (error) {
                                                                    //   if (error.code == BarcodeScanner.CameraAccessDenied) {
                                                                    //     print('Izin kamera tidak diizinkan oleh si pengguna');
                                                                    //   } else {
                                                                    //     print('Error: $error');
                                                                    //   }
                                                                    // }
                                                                    setState(() {});
                                                                    makeTransaction(qrcode);
                                                                    // makeTransaction(qrcode);
                                                                    // Navigator.push(
                                                                    //     context,
                                                                    //     PageTransition(
                                                                    //         type: PageTransitionType.fade,
                                                                    //         child: FinalTrans()));
                                                                  }else{
                                                                    if(_transCode == 1){
                                                                      if(delivAddress != 'null' && delivAddress != ''){
                                                                        makeTransaction(qrcode);
                                                                        // makeTransaction(qrcode);
                                                                        // Navigator.push(
                                                                        //     context,
                                                                        //     PageTransition(
                                                                        //         type: PageTransitionType.fade,
                                                                        //         child: FinalTrans()));
                                                                      }else{
                                                                        Fluttertoast.showToast(
                                                                          msg: "Alamat tujuan Anda dimana?",);
                                                                      }
                                                                    }else{
                                                                      makeTransaction(qrcode);
                                                                      // makeTransaction(qrcode);
                                                                      // Navigator.push(
                                                                      //     context,
                                                                      //     PageTransition(
                                                                      //         type: PageTransitionType.fade,
                                                                      //         child: FinalTrans()));
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      ],
                                                    );
                                                  });
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Sedang menghitung ongkir!",);
                                            }
                                          });
                                        }  else {
                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                          cekHarga()?.whenComplete((){
                                            if (_distan != '0') {
                                              _totalOngkir = _ongkir * _distance;
                                              totalOngkir = _totalOngkir.toString();
                                              print('totalOngkirBorzo');
                                              print(totalOngkirBorzo);
                                              if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              } else {
                                                int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              }
                                              // int _totalHarga = harga + (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString())?int.parse(totalOngkirBorzo):int.parse(totalOngkirDisBorzo);

                                            } else {
                                              totalOngkir = ongkir!;
                                              if (totalOngkirBorzo.toString() == totalOngkirDisBorzo.toString()) {
                                                int _totalHarga = harga + int.parse(totalOngkirBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              } else {
                                                int _totalHarga = harga + int.parse(totalOngkirDisBorzo);
                                                totalHarga = (_totalHarga + _platformfee).toString();
                                                pref.setString('totalHarga', totalHarga);
                                                setState(() {});
                                              }
                                            }
                                            if (loadingTrans == false) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                                      content: Text('Apakah anda sudah yakin dengan pesanan anda? ', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                      // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                      actions: <Widget>[
                                                        Center(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              TextButton(
                                                                // minWidth: CustomSize.sizeWidth(context),
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: CustomColor.redBtn,
                                                                  padding: EdgeInsets.all(0),
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                  ),
                                                                ),
                                                                child: Text('Batal', style: TextStyle(color: Colors.white)),
                                                                onPressed: () async{
                                                                  setState(() {
                                                                    // codeDialog = valueText;
                                                                    Navigator.pop(context);
                                                                  });
                                                                },
                                                              ),
                                                              TextButton(
                                                                // minWidth: CustomSize.sizeWidth(context),
                                                                style: TextButton.styleFrom(
                                                                  backgroundColor: CustomColor.primaryLight,
                                                                  padding: EdgeInsets.all(0),
                                                                  shape: const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                                                  ),
                                                                ),
                                                                child: Text('Setuju', style: TextStyle(color: Colors.white)),
                                                                onPressed: () async{
                                                                  Navigator.pop(context);
                                                                  String qrcode = '';
                                                                  if(_transCode == 3){
                                                                    // try {
                                                                    //   qrcode = await BarcodeScanner.scan();
                                                                    //   setState(() {});
                                                                    //   makeTransaction(qrcode);
                                                                    //   // makeTransaction(qrcode);
                                                                    //   Navigator.push(
                                                                    //       context,
                                                                    //       PageTransition(
                                                                    //           type: PageTransitionType.fade,
                                                                    //           child: FinalTrans()));
                                                                    // } on PlatformException catch (error) {
                                                                    //   if (error.code == BarcodeScanner.CameraAccessDenied) {
                                                                    //     print('Izin kamera tidak diizinkan oleh si pengguna');
                                                                    //   } else {
                                                                    //     print('Error: $error');
                                                                    //   }
                                                                    // }
                                                                    setState(() {});
                                                                    makeTransaction(qrcode);
                                                                    // makeTransaction(qrcode);
                                                                    // Navigator.push(
                                                                    //     context,
                                                                    //     PageTransition(
                                                                    //         type: PageTransitionType.fade,
                                                                    //         child: FinalTrans()));
                                                                  }else{
                                                                    if(_transCode == 1){
                                                                      if(delivAddress != 'null' && delivAddress != ''){
                                                                        makeTransaction(qrcode);
                                                                        // makeTransaction(qrcode);
                                                                        // Navigator.push(
                                                                        //     context,
                                                                        //     PageTransition(
                                                                        //         type: PageTransitionType.fade,
                                                                        //         child: FinalTrans()));
                                                                      }else{
                                                                        Fluttertoast.showToast(
                                                                          msg: "Alamat tujuan Anda dimana?",);
                                                                      }
                                                                    }else{
                                                                      makeTransaction(qrcode);
                                                                      // makeTransaction(qrcode);
                                                                      // Navigator.push(
                                                                      //     context,
                                                                      //     PageTransition(
                                                                      //         type: PageTransitionType.fade,
                                                                      //         child: FinalTrans()));
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                      ],
                                                    );
                                                  });
                                            }
                                          });
                                          Fluttertoast.showToast(
                                            msg: "Sedang menghitung ongkir!",);
                                        }
                                      }else{
                                        Fluttertoast.showToast(
                                          msg: "Alamat tujuan Anda dimana?",);
                                      }
                                    } else {
                                      if(_transCode == 3){
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                                content: Text('Harga sudah termasuk PB1 dan Service Charge sesuai masing-masing Resto. \n \nMau menambah makanan atau minuman lagi?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                actions: <Widget>[
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        TextButton(
                                                          // minWidth: CustomSize.sizeWidth(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: Colors.blue,
                                                            padding: EdgeInsets.all(0),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                          ),
                                                          child: Text('Tambah', style: TextStyle(color: Colors.white)),
                                                          onPressed: () async{
                                                            setState(() {
                                                              // codeDialog = valueText;
                                                              // Navigator.pop(context);
                                                              Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                      type: PageTransitionType.rightToLeft,
                                                                      child: DetailResto(checkId)));
                                                            });
                                                          },
                                                        ),
                                                        TextButton(
                                                          // minWidth: CustomSize.sizeWidth(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: CustomColor.accent,
                                                            padding: EdgeInsets.all(0),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                          ),
                                                          child: Text('Tidak', style: TextStyle(color: Colors.white)),
                                                          onPressed: () async{
                                                            Navigator.pop(context);
                                                            String qrcode = '';
                                                            if(_transCode == 3){
                                                              try {
                                                                var qrScanResult = await BarcodeScanner.scan();
                                                                String qrcode = qrScanResult.rawContent;
                                                                print('SCAN');
                                                                print('KIW');
                                                                print(qrcode);
                                                                makeTransaction(qrcode);
                                                                setState(() {});
                                                                // makeTransaction(qrcode);
                                                              } on PlatformException catch (error) {
                                                                if (error.code == BarcodeScanner.cameraAccessDenied) {
                                                                  print('Izin kamera tidak diizinkan oleh si pengguna');
                                                                } else {
                                                                  print('Error: $error');
                                                                }
                                                              }
                                                              setState(() {});
                                                              // makeTransaction(qrcode);
                                                              // // makeTransaction(qrcode);
                                                              // Navigator.push(
                                                              //     context,
                                                              //     PageTransition(
                                                              //         type: PageTransitionType.fade,
                                                              //         child: FinalTrans()));
                                                            }else{
                                                              if(_transCode == 1){
                                                                if(delivAddress != 'null'){
                                                                  makeTransaction(qrcode);
                                                                  // makeTransaction(qrcode);
                                                                  // Navigator.push(
                                                                  //     context,
                                                                  //     PageTransition(
                                                                  //         type: PageTransitionType.fade,
                                                                  //         child: FinalTrans()));
                                                                }else{
                                                                  Fluttertoast.showToast(
                                                                    msg: "Alamat tujuan Anda dimana?",);
                                                                }
                                                              }else{
                                                                makeTransaction(qrcode);
                                                                // makeTransaction(qrcode);
                                                                // Navigator.push(
                                                                //     context,
                                                                //     PageTransition(
                                                                //         type: PageTransitionType.fade,
                                                                //         child: FinalTrans()));
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              );
                                            });
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                                content: Text('Apakah anda sudah yakin dengan pesanan anda? ', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                    // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                actions: <Widget>[
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        TextButton(
                                                          // minWidth: CustomSize.sizeWidth(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: CustomColor.redBtn,
                                                            padding: EdgeInsets.all(0),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                          ),
                                                          child: Text('Batal', style: TextStyle(color: Colors.white)),
                                                          onPressed: () async{
                                                            setState(() {
                                                              // codeDialog = valueText;
                                                              Navigator.pop(context);
                                                            });
                                                          },
                                                        ),
                                                        TextButton(
                                                          // minWidth: CustomSize.sizeWidth(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: CustomColor.primaryLight,
                                                            padding: EdgeInsets.all(0),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                          ),
                                                          child: Text('Setuju', style: TextStyle(color: Colors.white)),
                                                          onPressed: () async{
                                                            Navigator.pop(context);
                                                            String qrcode = '';
                                                            if(_transCode == 3){
                                                              try {
                                                                qrcode = (await BarcodeScanner.scan().whenComplete((){
                                                                  makeTransaction(qrcode);
                                                                  print('SCAN');
                                                                })).toString() ;
                                                                setState(() {});
                                                                // makeTransaction(qrcode);
                                                              } on PlatformException catch (error) {
                                                                if (error.code == BarcodeScanner.cameraAccessDenied) {
                                                                  print('Izin kamera tidak diizinkan oleh si pengguna');
                                                                } else {
                                                                  print('Error: $error');
                                                                }
                                                              }
                                                              setState(() {});
                                                              // makeTransaction(qrcode);
                                                              // // makeTransaction(qrcode);
                                                              // Navigator.push(
                                                              //     context,
                                                              //     PageTransition(
                                                              //         type: PageTransitionType.fade,
                                                              //         child: FinalTrans()));
                                                            }else{
                                                              if(_transCode == 1){
                                                                if(delivAddress != 'null'){
                                                                  makeTransaction(qrcode);
                                                                  // makeTransaction(qrcode);
                                                                  // Navigator.push(
                                                                  //     context,
                                                                  //     PageTransition(
                                                                  //         type: PageTransitionType.fade,
                                                                  //         child: FinalTrans()));
                                                                }else{
                                                                  Fluttertoast.showToast(
                                                                    msg: "Alamat tujuan Anda dimana?",);
                                                                }
                                                              }else{
                                                                makeTransaction(qrcode);
                                                                // makeTransaction(qrcode);
                                                                // Navigator.push(
                                                                //     context,
                                                                //     PageTransition(
                                                                //         type: PageTransitionType.fade,
                                                                //         child: FinalTrans()));
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              );
                                            });
                                      }
                                    }
                                  }
                                }
                              }
                            }
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.textTitle3(text: "Pesan Sekarang", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      CustomText.textTitle3(text: (codeNguponYuk.toString() != '[]')?(totalHarga == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)):NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)), color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                      ],
                    ),
                  ),
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
