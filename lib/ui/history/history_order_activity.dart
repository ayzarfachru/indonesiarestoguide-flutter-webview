import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/model/Transaction.dart' as trans;
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
import '../detail/detail_transaction_reser.dart';
import '../home/home_activity.dart';

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
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }


  double latitude = 0;
  double longitude = 0;

  Future _getProcess(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    // for(var v in data['trx']['process']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      _getData(latitude.toString(), longitude.toString());
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }

  String NameDriver = 'Tunggu';
  String PhoneDriver = '0';
  String PhotoDriver = '';
  String StatusDriver = 'Tunggu sebentar';
  Future<void> _getDriver(String id)async{
    // List<Menu> _menu = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://qurir.devastic.com/api/borzo?transaction_id=IRG-$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);

    print('driver puki '+apiResult.body.toString());
    // print('driver '+idResto.toString());
    if (apiResult.body.toString() != '"not found"') {
      if (data['courier'].toString().contains('name') == false) {
        StatusDriver = (apiResult.body.toString() != '"not found"')?data['status'].toString():'Tidak Ditemukan';
      } else {
        NameDriver = (apiResult.body.toString() != '"not found"')?data['courier']['name'].toString():'Tidak Ditemukan';
        PhoneDriver = (apiResult.body.toString() != '"not found"')?data['courier']['phone'].toString():'0';
        PhotoDriver = (apiResult.body.toString() != '"not found"')?data['courier']['photo'].toString():'';
        StatusDriver = (apiResult.body.toString() != '"not found"')?(data['status'].toString() != 'active')?'Sudah sampai':data['status'].toString():'Tidak Ditemukan';
      }
    } else {
      NameDriver = 'Tidak Ditemukan';
      PhoneDriver = '0';
      PhotoDriver = '';
      StatusDriver = 'Tidak Ditemukan';
    }
    if (NameDriver != 'Tidak Ditemukan' && NameDriver != 'Tunggu' && NameDriver != '"not found"') {
      // _getProcess(operation = "ready", id);
      print('MOSOK');
      print(NameDriver);
    }
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
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  Future<void> _checkPayFirst(String id)async{
    // List<Menu> _menu = [];

    setState(() {
      // isLoadChekPayFirst = true;
    });
    // Fluttertoast.showToast(
    //   msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    print(apiResult.statusCode);
    if (apiResult.statusCode == 500) {
      // isLoadChekPayFirst = false;
      // if (type == 'dinein') {
      // statusPay = pref.getString("statusPay") ?? "true";
      // } else {
      //   statusPay = 'true';
      // }
      setState((){});
    }
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    // statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
      // Fluttertoast.showToast(
      //   msg: "Anda belum membayar!",);
    } else {
      // statusPay = 'false';
      _getReady('process', id.toString()).whenComplete((){
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: new HistoryOrderActivity()));
      });
      // if (type == 'delivery' && statusTrans == 'pending') {
      //   _getPending('process', id.toString());
      // }
      // _getDetail(idResto).whenComplete((){
      //   _getDetailTrans(id.toString()).whenComplete((){
      //     cariKurir();
      //   });
      // });
      // Navigator.pop(context);
      // _getPending('process', id.toString());
      // Fluttertoast.showToast(
      //   msg: "Pembayaran berhasil",);
    }
    // _base64 = data['response']['qr_image'];
    // Uint8List bytes = Base64Codec().decode(_base64);

    // if (_base64 != '') {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
    //       ),
    //       context: context,
    //       builder: (_){
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
    //               child: Divider(thickness: 4,),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: CustomText.textHeading2(
    //                   text: "Qris",
    //                   minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
    //                   maxLines: 1
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
    //             Center(
    //               child: FullScreenWidget(
    //                 child: Image.memory(bytes,
    //                   width: CustomSize.sizeWidth(context) / 1.2,
    //                   height: CustomSize.sizeWidth(context) / 1.2,
    //                 ),
    //                 backgroundColor: Colors.white,
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     CustomText.textTitle2(
    //                         text: 'Total harga:',
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                     CustomText.textTitle2(
    //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'Scan disini untuk melakukan pembayaran',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 1
    //                 ),
    //               ),
    //             ),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'ke $nameRestoTrans!',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 3
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
    //             GestureDetector(
    //               onTap: ()async{
    //                 Fluttertoast.showToast(
    //                   msg: "Anda belum membayar!",);
    //               },
    //               child: Center(
    //                 child: Container(
    //                   width: CustomSize.sizeWidth(context) / 1.1,
    //                   height: CustomSize.sizeHeight(context) / 14,
    //                   decoration: BoxDecoration(
    //                     // color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
    //                       borderRadius: BorderRadius.circular(50)
    //                   ),
    //                   child: Center(
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                       child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
    //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //           ],
    //         );
    //       }
    //   );
    // }
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
      // isLoadChekPayFirst = false;
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  List<imgBanner> images = [];
  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> qty = [];
  List<Resto> resto = [];
  List<Resto> again = [];
  List<Menu> promo = [];
  List<trans.Transaction> transaction = [];
  Future _getData(String lat, String long)async{
    List<Resto> _resto = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];
    List<trans.Transaction> _transaction = [];
    List<imgBanner> _images = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/home?lat=$lat&long=$long&limit=0'), headers: {
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
        trans.Transaction t = trans.Transaction.all2(
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
        if (v['type_text'] == 'Pesan antar' && v['status'] == 'process') {
          // _getDriver(v['id'].toString()).whenComplete((){
          //   // _getDetail(idResto);
          // });
        } else if (v['type_text'] == 'Pesan antar' && v['status'] == 'pending') {
          _checkPayFirst(v['id'].toString());
        }
        if (v['type_text'].startsWith('Reservasi') == true && v['status'] == '') {

        } else {
          _transaction.add(t);
        }
      }
    }

    // print('ini resto '+data['resto'].toString());
    //
    // for(var v in data['resto']){
    //   Resto r = Resto.all(
    //       id: v['id'],
    //       name: v['name'],
    //       distance: double.parse(v['distance'].toString()),
    //       img: v['img']
    //   );
    //   _resto.add(r);
    // }

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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/promo?lat=$lat&long=$long'), headers: {
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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/promo'), headers: {
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
              latitude = value.latitude!;
              longitude = value.longitude!;
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

  String chatroom = '';
  Future<void> getData(String id)async{
    // List<Menu> _menu = [];
    // List<String> _menu2 = [];
    // List<MenuJson> _menu3 = [];
    // List<String> _menu4 = [];
    // List<String> _menu5 = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/$id'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    print('TRANS?');
    print(id);
    var data = json.decode(apiResult.body);

    // for(var v in data['menu']){
    //   Menu m = Menu(
    //       id: v['menus_id'],
    //       qty: v['qty'].toString(),
    //       price: Price(original: v['price'], discounted: null, delivery: null),
    //       name: v['name'],
    //       urlImg: v['image'],
    //       is_available: '',
    //       desc: v['desc'], is_recommended: '', restoName: '', type: '', distance: null, restoId: '', delivery_price: null
    //   );
    //   _menu.add(m);
    // }
    // for(var v in data['menu']){
    //   MenuJson j = MenuJson(
    //     id: v['menus_id'],
    //     restoId: pref.getString('idnyatransRes')??'',
    //     name: v['name'],
    //     desc: v['desc'],
    //     price: v['price'].toString(),
    //     discount: v['discount'],
    //     pricePlus: (v['pricePlus']??0).toString(),
    //     urlImg: v['image'], restoName: '', distance: null,
    //   );
    //   _menu3.add(j);
    // }
    // for(var v in data['menu']){
    //   // Menu m = Menu.qty(
    //   //     ['qty'].toString(),
    //   // );
    //   _menu2.add(v['qty'].toString());
    // }
    // // _menu3.add(jsonEncode(data['menu']));
    // for(var v in data['menu']){
    //   // Menu m = Menu.qty(
    //   //     ['qty'].toString(),
    //   // );
    //   _menu4.add(v['menus_id'].toString());
    //   print('ini '+v['menus_id'].toString());
    // }
    // for(var v in data['menu']){
    //   // Menu m = Menu.qty(
    //   //     ['qty'].toString(),
    //   // );
    //   _menu5.add(v['name'].toString()+": kam5ia_null}");
    // }
    setState(() {
      // menu = _menu;
      // menu2 = _menu2;
      // menu3 = _menu3;
      // menu4 = _menu4;
      // menu5 = _menu5;
      // type = data['trans']['type'];
      // if (type == 'delivery' && statusTrans == 'process' || statusTrans == 'ready') {
      //   _getDriver().whenComplete((){
      //     _getDetail(idResto);
      //   });
      // } else if (type == 'delivery' && statusTrans == 'pending') {
      //   tungguProses = 'true';
      // }
      // address = data['trans']['address']??'';
      // ongkir = data['trans']['ongkir'];
      // total = data['trans']['total'];
      // totalAll = data['trans']['total']+data['trans']['ongkir'];
      // harga = data['trans']['total'] - data['trans']['ongkir'];
      chatroom = data['chatroom'].toString();
      // _checkPayFirst();
      // phone = data['phone_number'].toString();
      // isLoading = false;
    });
    print(chatroom);
  }

  String operation ='';
  Future _getReady(String operation, String id)async{
    // List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    FirebaseFirestore.instance.collection('room').doc(chatroom).collection('messages').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });

    // try {
    //   FirebaseFirestore.instance.collection("room").doc(chatroom).delete();
    //   // FirebaseFirestore.instance
    //   //     .collection("room")
    //   //     .document(chatroom)
    //   //     // .collection('messages')
    //   //     // .doc()
    //   //     .delete()
    //   //     .then((_) {
    //   //   print("BERHASIL!");
    //   // });
    // }
    // catch (e) {
    //   print("ERROR DURING DELETE");
    // }
    print('delete room chat: '+chatroom);

    // for(var v in data['trx']['process']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }


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
            latitude = value.latitude!;
            longitude = value.longitude!;
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
                                    pref.setString("restoNameTrans99", transaction[index].nameResto.toString());
                                    pref.setString("alamateResto99", transaction[index].address.toString());
                                    pref.setString("statusTrans", transaction[index].status.toString());
                                    pref.setString('rev', '0');
                                    if (transaction[index].type == 'Makan Ditempat') {
                                      if (transaction[index].status != 'pending') {
                                        pref.setString("statusPay", 'false');
                                      } else {
                                        pref.setString("statusPay", 'true');
                                      }
                                    }
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new DetailTransaction(transaction[index].id!, transaction[index].status!, transaction[index].note!, transaction[index].idResto!)));
                                  } else if (transaction[index].type!.startsWith('Reservasi') == true && transaction[index].status == 'pending') {
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString('rev', '1');
                                    pref.setString("chatUserCount", transaction[index].chat_user);
                                    pref.setString("idnyatrans", transaction[index].id.toString());
                                    pref.setString("idnyatransRes", transaction[index].idResto.toString());
                                    pref.setString("restoNameTrans99", transaction[index].nameResto.toString());
                                    pref.setString("alamateResto99", transaction[index].address.toString());
                                    pref.setString("jmlhMeja", transaction[index].type.toString().replaceAll('Reservasi untuk ', '').replaceAll(' orang', ''));
                                    pref.setString("tglReser", transaction[index].date.toString().split(',')[0]);
                                    pref.setString("jamReser", transaction[index].date.toString().split(', ')[1]);
                                    pref.setString("hargaReser", (int.parse(transaction[index].total.toString())/int.parse(transaction[index].type.toString().replaceAll('Reservasi untuk ', '').replaceAll(' orang', '').toString())).toString());
                                    pref.setString("totalReser", transaction[index].total.toString());
                                    print('OL');
                                    print(transaction[0].id!);
                                    print(transaction[0].status!);
                                    print(transaction[0].note!);
                                    print(transaction[0].idResto!);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new DetailTransactionReser(transaction[index].id!, transaction[index].status!, transaction[index].note!, transaction[index].idResto!)));
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
                                                  MediaQuery(
                                                    child: CustomText.bodyLight12(text: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status == 'ready')?(transaction[index].type != 'Pesan antar')?'Pesanan Siap':'Sudah diterima?':'Selesai':(transaction[index].type.toString().contains('Reservasi'))?'Telah disetujui':'Diproses':'Menunggu':'Dibatalkan', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                        // CustomText.bodyLight12(text: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status != 'ready')?Colors.amberAccent:Colors.amberAccent:Colors.green:Colors.blue:CustomColor.redBtn, minSize: 12,
                                                        color: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status != 'ready')?CustomColor.primary:CustomColor.primary:Colors.green:Colors.blue:CustomColor.redBtn),
                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                                  ),
                                          (transaction[index].status == 'ready')?(transaction[index].type != 'Pesan antar')?MediaQuery(child: CustomText.bodyMedium14(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((transaction[index].type!.startsWith('Reservasi'))?(transaction[index].total!):(transaction[index].total!+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),):
                                          GestureDetector(
                                            onTap: (){
                                              // _search(recomMenu[index], '');
                                              // _loginTextName.text = recomMenu[index];
                                              setState(() {
                                                getData(transaction[index].id!.toString()).whenComplete((){
                                                  _getReady(operation = "done", transaction[index].id!.toString()).whenComplete((){
                                                    Navigator.pushReplacement(context, PageTransition(
                                                        type: PageTransitionType.rightToLeft,
                                                        child: HistoryOrderActivity()));
                                                  });
                                                });
                                                // _getReady(operation = "done", transaction[index].id!.toString());
                                                print('hehe');
                                                // isSearch = true;
                                              });
                                            },
                                            child: Container(
                                              // height: CustomSize.sizeHeight(context) / 19,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: CustomColor.accent),
                                                  color: Colors.white
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48, vertical: CustomSize.sizeWidth(context) * 0.01),
                                                child: Center(
                                                  child: CustomText.textTitle2(
                                                      text: 'Iya',
                                                      color:  CustomColor.accent,
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ):
                                          MediaQuery(child: CustomText.bodyMedium14(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((transaction[index].type!.startsWith('Reservasi'))?(transaction[index].total!):(transaction[index].total!+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
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
