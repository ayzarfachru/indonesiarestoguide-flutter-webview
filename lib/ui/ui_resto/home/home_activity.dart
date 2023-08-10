import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:kam5ia/model/Category.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/history/history_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/maintenance.dart';
import 'package:kam5ia/ui/profile/followers_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
// import 'package:kam5ia/ui/ui_resto/promo_resto/promo_activity.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/payment_resto.dart';
import 'package:kam5ia/ui/ui_resto/detail/detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/employees/employees_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/ui/ui_resto/ngupon_yuk_resto/ngupon_yuk_resto.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:kam5ia/ui/ui_resto/owner/add_owner.dart';
import 'package:kam5ia/ui/ui_resto/reservation_resto/reservation_activity.dart';
import 'package:kam5ia/ui/ui_resto/deposit/deposit_activity.dart';
import 'package:kam5ia/ui/ui_resto/reservation_resto/reservation_pending_page.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/ui/welcome_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kam5ia/ui/ui_resto/schedule_resto/schedule_activity.dart';
import 'package:kam5ia/ui/ui_resto/meja/meja_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:location_platform_interface/location_platform_interface.dart';

import '../../../utils/update_maps_resto.dart';

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

class HomeActivityResto extends StatefulWidget {
  @override
  _HomeActivityRestoState createState() => _HomeActivityRestoState();
}

class _HomeActivityRestoState extends State<HomeActivityResto> with WidgetsBindingObserver{
  String img = "";
  String homepg = "";
  int id = 0;
  String owner = "";
  String nameOwner = "";
  String emailOwner = "";
  int ownerId = 0;
  bool wait = false;

  getOwner() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('inDetail');
    setState(() {
      owner = (pref.getString('owner')??'');
      nameOwner = (pref.getString('nameOwner')??'');
      emailOwner = (pref.getString('emailOwner')??'');
      print(owner);
      print('POOO');
    });
    if (owner != 'true') {
      _getUserResto();
    } else {
      // _getOwnerResto();
      _getUserResto();
      SharedPreferences pref = await SharedPreferences.getInstance();
      print('PUKIII 1');
      id = pref.getInt("ownerId")??0;
    }
  }

  Future _getOwnerOut()async{
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    int idRes = pref.getInt("ownerId") ?? 0;
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner/deactivate'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    print('iki loh rekk');
    print(idRes);
    var data = json.decode(apiResult.body);

    // SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('ownerId');
    pref.remove('owner');
    pref.setString("homepg", "");

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
      // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // // history = _history;
      // openAndClose = (data['status'].toString() == "closed")?'1':'0';
      // isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "success") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ProfileActivity()));
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
        // kosong = '1';
      }
      // else if (data['resto']['id'] == null || id == 'null' || id == '') {
      //   kosong = '1';
      // }
      else {
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      }
    }
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img')??'');
      print(img);
    });
  }


  bool jiitu = true;
  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }


  bool isLoading = false;
  List<Meja> meja = [];
  String? url;
  Future<void> _getQr()async{
    List<Meja> _meja = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/qrcode'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    var link = data['link'];

    // for(var v in data['link']){
    //   QrCode p = QrCode(
    //     id: v['id'],
    //     url: v['link'],
    //   );
    //   _meja.add(p);
    // }
    setState(() {
      url = data['link'];
      // print(url + 'aa');
      meja = _meja;
      isLoading = false;
    });
  }

  _launchURL() async {
    if (await canLaunch(url!)) {
      await launch(url!);
    } else {
      throw 'Error';
    }
  }

  idResto() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("idresto", id.toString());
  }

  String restoName = "";
  String openAndClose = "0";
  String openAndClose2 = "0";
  int idUser = 0;
  int idUserRest = 0;
  Future _getUserResto()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    idUser = pref.getInt("id") ?? 0;
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);
    print(data['resto']['users_id']);
    print(idUser);

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

    // if (apiResult.statusCode == 200) {
    //   _getDetail();
    // }
    setState(() {
      restoName = data['resto']['name'];
      id = data['resto']['id'];
      pref.setString('idHomeResto', id.toString());
      idResto();
      idUserRest = (owner != 'true')?int.parse(data['resto']['users_id'].toString()):idUser;
      // history = _history;
      openAndClose = (data['resto']['status'].toString() == "closed" || data['resto']['status'].toString() == "")?'0':'1';
      isLoading = false;
    });

    if(openAndClose == 'closed' || openAndClose == ''){
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("openclose", '1');
    }else{
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("openclose", '0');
    }

    if (idUserRest.toString() == idUser.toString()) {
      pref.setString("karyawan", '1');
    } else if (owner == 'true') {
      pref.setString("karyawan", '1');
    } else {
      pref.setString("karyawan", '0');
    }

    if (apiResult.statusCode == 200) {
      _getDetail();
    }
  }

  String isOpen = "";
  String tunggu = 'true';
  String phone = '';
  String address = '';
  bool reservation = false;
  String deposit = '';
  String isUpdateMaps = "";
  String oldLat = "";
  String oldLong = "";
  String latitude = '';
  String longitude = '';
  Future _getDetail()async{
    List<String> _facility = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('Open '+apiResult.body.toString());

    // String id = pref.getString("idHomeResto") ?? "";
    var apiResult2 = await http
        .get(Uri.parse(Links.mainUrl + "/deposit/$id"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data2 = json.decode(apiResult2.body);

    for(var v in data['data']['fasilitas']){
      _facility.add(v['name']);
    }

    setState(() {
      oldLat = data['data']['lat'].toString();
      oldLong = data['data']['long'].toString();
      reservation = (data['data']['reservation_fee'].toString() == '0')?false:true;
      // reservation = true;
      deposit = data2['balance'].toString();
      // is_deposit = (int.parse(deposit) >= 1000)?data['data']['is_deposit']:false;
      // is_deposit = true;
      if (data['data']['status'].toString() == 'active') {
        isOpen = data['data']['isOpen'].toString();
      } else {
        isOpen = 'false';
      }
      phone = data['data']['phone_number'].toString();
      address = data['data']['address'].toString();
      // openAndClose = (data['resto']['status'].toString() == "closed")?'0':'1';
    });

    if (apiResult.statusCode == 200) {
      tunggu = 'false';
      if(isOpen == 'true'){
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("isOpen", '1');
        pref.setString("resProm", data['data']['name'].toString());
        print('Name Rest '+pref.getString("resProm").toString());
      }else if(isOpen == 'false'){
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("isOpen", '0');
        pref.setString("resProm", data['data']['name'].toString());
      }
        pref.setString("jUsaha", _facility.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ","));
      Future.delayed(Duration(seconds: 1), () async{
        wait = true;
        isUpdateMaps = pref.getString('isUpdateMaps')??'';
        if (isUpdateMaps == '') {
          if (oldLat != 'null' || oldLong != 'null' || oldLat != '' || oldLong != '' || oldLat != '0' || oldLong != '0') {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: UpdateMapsResto(double.parse(oldLat),double.parse(oldLong))));
          } else {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: UpdateMapsResto(double.parse(latitude),double.parse(longitude))));
          }
        }
        setState((){});
      });
    }
  }

  String initial = "";
  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name')!.substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  String status = 'ongoing';
  bool is_deposit = true;
  Future checkTest() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Uri.parse(Links.mainUrl + '/payment/inquiry'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('inquiry '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // if(data['code'] != null){
    //   setState(() {
    //     code = data['code'];
    //   });
    //
    //   return true;
    // }else{
    //   Fluttertoast.showToast(
    //     msg: "Mohon maaf masih dalam perbaikan",);
    //
    //   return false;
    // }

    status = data['status'];
    // status = 'ongoing';
    setState(() {});
    if (apiResult.statusCode == 200) {
      if (status == 'ongoing') {
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
      }
    }
  }

  bool ksg = false;
  bool ksg2 = false;
  bool ksg3 = false;
  List<Transaction> transaction = [];
  List<Transaction> transactionC1 = [];
  List<Transaction> transaction2 = [];
  List<Transaction> transaction3 = [];
  Future _getTrans()async{
    List<Transaction> _transaction = [];
    List<Transaction> _transaction2 = [];
    List<Transaction> _transaction3 = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('OILO');
    print(data);
    // print(data['trx']['process']);

    if (apiResult.statusCode == 200) {
      // print('PPP '+data['trx']['pending'].toString());
      if (transaction.toString() == '[]') {
        ksg = true;
        if (data['trx'].toString().contains('pending')) {
          for(var v in data['trx']['pending']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transaction.add(r);
          }
        } else {
          ksg = true;
        }

        if (data['trx'].toString().contains('process')) {
          for(var v in data['trx']['process']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transaction2.add(r);
          }
        } else {
          ksg2 = true;
        }

        if (data['trx'].toString().contains('ready')) {
          for(var v in data['trx']['ready']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transaction3.add(r);
          }
        } else {
          ksg3 = true;
        }

        setState(() {
          transaction = _transaction;
          transactionC1 = _transaction.where((element) => element.chat_user != '0').toList();
          transaction2 = _transaction2.where((element) => element.chat_user != '0').toList();
          transaction3 = _transaction3.where((element) => element.chat_user != '0').toList();
          print('length isOpen '+transaction.where((element) => element.is_opened.contains('0')).toString());
          print('chat pending '+transactionC1.length.toString());
        });
      } else {
        ksg = false;
      }
    }
  }

  bool ksgR = false;
  bool ksg2R = false;
  bool ksg3R = false;
  List<Transaction> transactionR = [];
  List<Transaction> transactionC1R = [];
  List<Transaction> transaction2R = [];
  List<Transaction> transaction3R = [];
  Future _getTrans2()async{
    List<Transaction> _transactionR = [];
    List<Transaction> _transaction2R = [];
    List<Transaction> _transaction3R = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/reservation'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);




    if (apiResult.statusCode == 200) {
      // print('PPP2 '+data['trx']['pending'].toString());
      if (transactionR.toString() == '[]') {
        ksg = true;
        if (data['trx'].toString().contains('pending')) {
          for(var v in data['trx']['pending']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transactionR.add(r);
          }
        } else {
          ksg = true;
        }

        if (data['trx'].toString().contains('process')) {
          for(var v in data['trx']['process']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transaction2R.add(r);
          }
        } else {
          ksg2 = true;
        }

        if (data['trx'].toString().contains('ready')) {
          for(var v in data['trx']['ready']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'].toString(),
                is_opened: v['is_opened'].toString()
            );
            _transaction3R.add(r);
          }
        } else {
          ksg3 = true;
        }

        setState(() {
          transactionR = _transactionR;
          transactionC1R = _transactionR.where((element) => element.chat_user != '0').toList();
          transaction2R = _transaction2R.where((element) => element.chat_user != '0').toList();
          transaction3R = _transaction3R.where((element) => element.chat_user != '0').toList();
          print('length isOpen '+transactionR.where((element) => element.is_opened.contains('0')).toString());
          print('chat pending '+transactionC1R.length.toString());
        });
      } else {
        ksg = false;
      }
    }
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "1");
    // pref.setString("homerestoname", restoName);
    setState(() {
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
    });
  }

  int queryData = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString("token"));
    if (pref.getString("token").toString() == 'null') {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: LoginActivity()));
    } else {
      if (state == AppLifecycleState.resumed) {
        queryData = int.parse((MediaQuery.of(context).size.width.toString().contains('.')==true)?MediaQuery.of(context).size.width.toString().split('.')[0]:MediaQuery.of(context).size.width.toString());
        // SharedPreferences pref = await SharedPreferences.getInstance();
        // pref.setString('widthDevice', queryData);
        initDynamicLinks();
        print((MediaQuery.of(context).size.width*0.035)+1);
        print((MediaQuery.of(context).size.width*0.035));
        print(queryData);
        print('ASYU');
      }
      if (state == AppLifecycleState.inactive) {
        print('ASYU2');
      }
      if (state == AppLifecycleState.paused) {
        print('ASYU3');
      }
      if (state == AppLifecycleState.detached) {
        print('ASYU4');
      }
    }
  }


  bool isNgupon = false;

  Future _getNguponYukPaid()async{

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/coupon/resto?restaurant=$id&action=used'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYukPaid');
    print(Links.nguponUrl + '/kupon?action=use&restaurant_id=$id');
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/coupon/resto?restaurant=$id&action=used'), headers: {
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
    print(data);

    var apiResultPaid = await http.get(Uri.parse(Links.nguponUrl + '/coupon/resto?restaurant=$id&action=paid'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYukUnpaid');
    print(Links.nguponUrl + '/kupon?action=use&restaurant_id=$id');
    var dataPaid = json.decode(apiResultPaid.body);
    if (apiResultPaid.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/coupon/resto?restaurant=$id&action=paid'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      dataPaid = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print(dataPaid);

    setState(() {
      if (data['data'].toString() == '[]' && dataPaid['data'].toString() == '[]') {
        isNgupon = false;
      } else {
        isNgupon = true;
      }
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    // _scrollController.dispose();
    // _controller.dispose();
    super.dispose();
  }

  String deepLink2 = '';
  Future<Widget> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null){
      return getRoute(data.link);
    }
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData dynamicLink) async {
      print('pppp');
      print(dynamicLink.link);
      getRoute(dynamicLink.link);
    }
    );
    return HomeActivity();
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  Widget getRoute(deepLink){
    if (deepLink.toString().isEmpty) {
      print('kosong');
      return HomeActivity();
    }
    print(deepLink.path);
    if (deepLink.path == "/open/") {
      final id = deepLink.queryParameters["id"];
      print('id = '+id.toString());
      // if (id != null) {
      //   return DetailResto(id.toString());
      // }
      toDet(id.toString());
    }
    return HomeActivity();
  }

  Future toDet(id) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: DetailResto(id)));
  }

  int balance = 0;
  List<Category> history2 = [];
  Future getDepo() async {
    // initializeDateFormatting();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    history2 = [];
    var apiResult = await http
        .get(Uri.parse(Links.mainUrl + "/page/deposit"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oi');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    var apiResult1 = await http.post(Uri.parse(Links.mainUrl + '/payment/inquiry-deposit'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('inquiry: '+apiResult1.body.toString());

    if (data.toString().contains('history') == true ) {
      for(var h in data['history']){
        Category c = Category(
            id: int.parse(h['amount'].toString()),
            nama: h['trans_code']??"topup",
            created: h['created_at'], img: ''
        );
        history2.add(c);
      }
    }

    setState(() {
      // balance = 0;
      balance = int.parse(data['balance'].toString());
      if (balance < 10000 && balance != 0) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                content: Text('Saldo deposit anda tinggal '+ NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(balance)+','+'\n segera isi sekarang juga!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                          TextButton(
                            // minWidth: CustomSize.sizeWidth(context),
                            style: TextButton.styleFrom(
                              backgroundColor: CustomColor.accent,
                              padding: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                            ),
                            child: Text('Oke', style: TextStyle(color: Colors.white)),
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
    });
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "887058389150-nesf8jr9jdk5n2dtt1t30to2el1v3bbi.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      // 'https://www.googleapis.com/auth/user.birthday.read',
      // 'https://www.googleapis.com/auth/user.gender.read',
      // 'https://www.googleapis.com/auth/user.phonenumbers.read'
    ],
  );

  Future maintenance() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    getHomePg();
    print('token');
    print(token);
    if (token != '') {
      var apiResult = await http.get(Uri.parse('https://irg.devus-sby.com/api/v2/index'), headers: {
      // var apiResult = await http.get(Uri.parse('https://jiitu.co.id/api/irg/index'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      // print('maintenance');
      // print(apiResult.body);
      var data = json.decode(apiResult.body);
      print(apiResult.statusCode);
      print('maintenance');
      print(apiResult.body);
      // if (data['is_open'].toString() == 'true') {
      //   pref.setString("is_open_all", '');
      // pref.remove("is_open_all");
      if (data['is_maintenance'].toString() == 'false') {
        if (data['authenticated'].toString() == 'null') {
          _googleSignIn.signOut();
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.clear();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => WelcomeScreen()));
        } else {
          // _checkForSession().then((status) {
          //   if (status) {
          //     Navigator.of(context).pushReplacement(MaterialPageRoute(
          //         builder: (BuildContext context) => (homepg != "1")?HomeActivity():HomeActivityResto()));
          //   }
          // });
        }
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => Maintenance()));
      }
      // } else {
      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (BuildContext context) => KamsiaClosed()));
      // }
    } else {
      var apiResult = await http.get(Uri.parse('https://irg.devus-sby.com/api/v2/index'), headers: {
      // var apiResult = await http.get(Uri.parse('https://jiitu.co.id/api/irg/index'), headers: {
        "Accept": "Application/json",
      });
      print(apiResult.statusCode);
      var data = json.decode(apiResult.body);
      print('maintenance');
      print(apiResult.body);
      // if (data['is_open'].toString() == 'true') {
      if (data['is_maintenance'].toString() == 'false') {
        if (data['authenticated'].toString() == 'null') {
          _googleSignIn.signOut();
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.clear();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => WelcomeScreen()));
        } else {
          // _checkForSession().then((status) {
          //   if (status) {
          //     Navigator.of(context).pushReplacement(MaterialPageRoute(
          //         builder: (BuildContext context) => (homepg != "1")?HomeActivity():HomeActivityResto()));
          //   }
          // });
        }
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => Maintenance()));
      }
      // } else {
      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (BuildContext context) => KamsiaClosed()));
      // }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    maintenance().whenComplete(() {
      Location.instance.getLocation().then((value) {
        setState(() {
          latitude = value.latitude.toString();
          longitude = value.longitude.toString();
          getHomePg();
        });
      });
      getOwner();
      _getNguponYukPaid();
      // _getUserResto();
      // _getDetail();
      initDynamicLinks();
      _getTrans();
      _getTrans2();
      getImg();
      getHomePg();
      // idResto();
      getInitial();
      // checkTest();
      // getDepo();
      // _getQr();
    });
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
      return Future.value(false);
    }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "");
    pref.setString("idresto", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  Future<bool> onWillPop2() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    int idRes = pref.getInt("ownerId") ?? 0;
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner/deactivate'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    print('iki loh rekk');
    print(idRes);
    var data = json.decode(apiResult.body);

    // SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('ownerId');
    pref.remove('owner');
    pref.setString("homepg", "");

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
      // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // // history = _history;
      // openAndClose = (data['status'].toString() == "closed")?'1':'0';
      // isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "success") {
        // Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ProfileActivity()));
        // kosong = '1';
      }
      // else if (data['resto']['id'] == null || id == 'null' || id == '') {
      //   kosong = '1';
      // }
      else {
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      }
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (owner != 'true')?onWillPop:onWillPop2,
      child: MediaQuery(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context) / 2.8,
                decoration: BoxDecoration(
                  color: CustomColor.primaryLight,
                  borderRadius: BorderRadius.vertical( bottom: Radius.circular(60))
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () async{
                                if (owner == 'true') {
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  pref.remove('ownerId');
                                  pref.remove('owner');
                                  pref.setString("homepg", "");
                                  _getOwnerOut();
                                } else {
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  pref.setString("homepg", "");
                                  setState(() {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivity()));
                                  });
                                }
                              },
                              child: Icon(FontAwesome.sign_out, color: Colors.white, size: 32,)
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                              });
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 8,
                              height: CustomSize.sizeWidth(context) / 8,
                              decoration: (img == "" || img == null || img == 'null')?BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ):BoxDecoration(
                                shape: BoxShape.circle,
                                image: ("$img".substring(0, 8) == '/storage')?DecorationImage(
                                    image: NetworkImage(Links.subUrl +
                                        "$img"),
                                    fit: BoxFit.cover
                                ):DecorationImage(
                                    image: Image.memory(Base64Decoder().convert(img)).image,
                                    fit: BoxFit.cover
                                ),
                              ),
                              child: (img == "" || img == null)?Center(
                                child: CustomText.text(
                                    size: double.parse(((MediaQuery.of(context).size.width*0.065).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.065)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.065)).toString()),
                                    weight: FontWeight.w800,
                                    text: initial,
                                    color: Colors.white
                                ),
                              ):Container(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 10),
                        child: CustomText.textHeading5(
                          text: (wait == true)?"Selamat Datang,":"Selamat Datang",
                          color: Colors.white,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                          maxLines: 1
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 10),
                        child: CustomText.textHeading5(
                          text: (wait == true)?"di "+restoName:"",
                          color: Colors.white,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                            maxLines: 1
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            // print(id.toString());
                            setState(() {
                              if (is_deposit == true) {
                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DetailRestoAdmin(id.toString())));
                              } else {
                                if ((transaction.where((element) => element.is_opened.contains('0')).length) != 0) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),
                                          title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                          content: Text('Segera isi deposit sekarang juga!\nAda '+(transaction.where((element) => element.is_opened.contains('0')).length).toString()+' pesanan sedang menunggu untuk diproses', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                                                    TextButton(
                                                      // minWidth: CustomSize.sizeWidth(context),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: CustomColor.accent,
                                                        padding: EdgeInsets.all(0),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                      ),
                                                      child: Text('Oke', style: TextStyle(color: Colors.white)),
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
                                          content: Text('Segera isi deposit sekarang juga!\nAgar restomu aktif dan dapat berjualan kembali', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                                                    TextButton(
                                                      // minWidth: CustomSize.sizeWidth(context),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: CustomColor.accent,
                                                        padding: EdgeInsets.all(0),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                                        ),
                                                      ),
                                                      child: Text('Oke', style: TextStyle(color: Colors.white)),
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
                              }
                            });
                          },
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 8,
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
                            child: (wait == true)?Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                              child: Row(
                                mainAxisAlignment: (is_deposit == true)?MainAxisAlignment.spaceBetween:MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        (isOpen == 'false')?CustomText.textHeading4(
                                            text: "Restomu sedang tutup.",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                          maxLines: 1,
                                          color: CustomColor.redBtn
                                        ):CustomText.textHeading4(
                                            text: "Restomu",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                          maxLines: 1
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText.bodyRegular14(
                                              text: (is_deposit == true)?"Info yang ditampilkan tentang":"Isi deposit terlebih dahulu untuk",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                            ),
                                            CustomText.bodyRegular14(
                                                text: (is_deposit == true)?"restomu":"mengaktifkan restomu",
                                                maxLines: 2,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  (is_deposit == true)?Icon(MaterialCommunityIcons.home_account, color: CustomColor.primaryLight, size: 49,):Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Icon(FontAwesome.warning, color: CustomColor.primaryLight, size: 39,),
                                      Positioned(
                                        right: -2,
                                        child: (transaction.where((element) => element.is_opened.contains('0')).length != 0)?Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                            CustomText.bodyMedium14(text: (transaction.where((element) => element.is_opened.contains('0')).length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ):Container(),
                                      ),
                                    ],
                                  ),
                               ], 
                              ),
                            ):Container(),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 90,),
                      Expanded(
                        child: SmartRefresher(
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
                            child: (wait == true)?(is_deposit == true)?Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: CustomSize.sizeHeight(context) / 90,),
                            CustomText.bodyMedium16(
                                text: "Kelola Restomu",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                maxLines: 1
                            ),
                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MenuActivity()));
                                      // if (jiitu == true) {
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (context) {
                                      //         return AlertDialog(
                                      //           contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                      //           shape: RoundedRectangleBorder(
                                      //               borderRadius: BorderRadius.all(Radius.circular(10))
                                      //           ),
                                      //           title: Center(child: Text('Perhatian!', style: TextStyle(color: CustomColor.accent))),
                                      //           content: Text('Anda hanya bisa melakukan perubahan menu melalui "JIITU"', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                      //           actions: <Widget>[
                                      //             Center(
                                      //               child: Row(
                                      //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      //                 children: [
                                      //                   TextButton(
                                      //                     // minWidth: CustomSize.sizeWidth(context),
                                      //                     style: TextButton.styleFrom(
                                      //                       backgroundColor: CustomColor.accent,
                                      //                       padding: EdgeInsets.all(0),
                                      //                       shape: const RoundedRectangleBorder(
                                      //                           borderRadius: BorderRadius.all(Radius.circular(10))
                                      //                       ),
                                      //                     ),
                                      //                     child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                      //                     onPressed: () async{
                                      //                       setState(() {
                                      //                         // codeDialog = valueText;
                                      //                         Navigator.pop(context);
                                      //                       });
                                      //                     },
                                      //                   ),
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //
                                      //           ],
                                      //         );
                                      //       });
                                      // } else {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MenuActivity()));
                                      // }
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.shopping, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Menu",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() async{
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      pref.setString('rev', '0');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: OrderActivity()));
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.cart_fill, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Transaksi",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 5, top: 5),
                                        child: (transaction.where((element) => element.is_opened.contains('0')).length != 0 || (transactionC1.length + transaction2.length + transaction3.length) != 0)?
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                            CustomText.bodyMedium14(text: (transaction.where((element) => element.is_opened.contains('0')).length + transactionC1.length + transaction2.length + transaction3.length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ):Container(),
                                      ),
                                    ],
                                  ),
                                ),
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      print(homepg + "oi");
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity(id.toString())));
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.tags, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Promo",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.group, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Followers",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ),


                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() async{
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      pref.setString('rev', '0');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: OrderActivity()));
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.cart_fill, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Transaksi",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 5, top: 5),
                                        child: (transaction.where((element) => element.is_opened.contains('0')).length != 0 || (transactionC1.length + transaction2.length + transaction3.length) != 0)?
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                            CustomText.bodyMedium14(text: (transaction.where((element) => element.is_opened.contains('0')).length + transactionC1.length + transaction2.length + transaction3.length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ):Container(),
                                      ),
                                    ],
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      // _launchURL();
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Meja",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                    // child: Column(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   children: [
                                    //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                    //     CustomText.bodyMedium14(
                                    //         text: "Qr Code",
                                    //         minSize: 14,
                                    //         maxLines: 1
                                    //     ),
                                    //   ],
                                    // ),
                                  ),
                                ),


                                // GestureDetector(
                                //   onTap: (){
                                //     setState(() {
                                //       // _launchURL();
                                //       Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                //     });
                                //   },
                                //   child: Container(
                                //     width: CustomSize.sizeWidth(context) / 3.8,
                                //     height: CustomSize.sizeWidth(context) / 3.8,
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius: BorderRadius.circular(20),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: Colors.grey.withOpacity(0.5),
                                //           spreadRadius: 0,
                                //           blurRadius: 7,
                                //           offset: Offset(0, 7), // changes position of shadow
                                //         ),
                                //       ],
                                //     ),
                                //     child: Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       crossAxisAlignment: CrossAxisAlignment.center,
                                //       children: [
                                //         Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                //         CustomText.bodyMedium14(
                                //             text: "Meja",
                                //             minSize: 14,
                                //             maxLines: 1
                                //         ),
                                //       ],
                                //     ),
                                //     // child: Column(
                                //     //   mainAxisAlignment: MainAxisAlignment.center,
                                //     //   crossAxisAlignment: CrossAxisAlignment.center,
                                //     //   children: [
                                //     //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                //     //     CustomText.bodyMedium14(
                                //     //         text: "Qr Code",
                                //     //         minSize: 14,
                                //     //         maxLines: 1
                                //     //     ),
                                //     //   ],
                                //     // ),
                                //   ),
                                // ),


                              ],
                            ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.group, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Followers",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):(reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() async{
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      pref.setString('rev', '1');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: ReservationRestoActivity()));
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(FontAwesome5.clipboard, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Reservasi",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 5, top: 5),
                                        child: (transactionR.where((element) => element.is_opened.contains('0')).length != 0 || (transactionC1R.length + transaction2R.length + transaction3R.length) != 0)?
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                            CustomText.bodyMedium14(text: (transactionR.where((element) => element.is_opened.contains('0')).length + transactionC1R.length + transaction2R.length + transaction3R.length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ):Container(),
                                      ),
                                    ],
                                  ),
                                ):(status != 'done')?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (tunggu == 'false') {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      } else if (tunggu == 'true'){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.calendar_check_o, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Langganan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      // _launchURL();
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Meja",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                    // child: Column(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   children: [
                                    //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                    //     CustomText.bodyMedium14(
                                    //         text: "Qr Code",
                                    //         minSize: 14,
                                    //         maxLines: 1
                                    //     ),
                                    //   ],
                                    // ),
                                  ),
                                ):(status != 'done' && reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (tunggu == 'false') {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      } else if (tunggu == 'true'){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.calendar_check_o, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Langganan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                (idUserRest == idUser)?(reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() async{
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      pref.setString('rev', '1');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.rightToLeft,
                                              child: ReservationRestoActivity()));
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(FontAwesome5.clipboard, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Reservasi",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 5, top: 5),
                                        child: (transactionR.where((element) => element.is_opened.contains('0')).length != 0 || (transactionC1R.length + transaction2R.length + transaction3R.length) != 0)?
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                            CustomText.bodyMedium14(text: (transactionR.where((element) => element.is_opened.contains('0')).length + transactionC1R.length + transaction2R.length + transaction3R.length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ):Container(),
                                      ),
                                    ],
                                  ),
                                ):(status != 'done')?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (tunggu == 'false') {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      } else if (tunggu == 'true'){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.calendar_check_o, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Langganan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):(status != 'done' && reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):Container(
                                  width: CustomSize.sizeWidth(context) / 3.8,
                                  height: CustomSize.sizeWidth(context) / 3.8,
                                )
                                  //   :Container(
                                  // width: CustomSize.sizeWidth(context) / 3.8,
                                  // height: CustomSize.sizeWidth(context) / 3.8,),


                                // Container(
                                //   width: CustomSize.sizeWidth(context) / 3.8,
                                //   height: CustomSize.sizeWidth(context) / 3.8,
                                //   decoration: BoxDecoration(
                                //     color: Colors.transparent,
                                //   ),
                                //   // child: Column(
                                //   //   mainAxisAlignment: MainAxisAlignment.center,
                                //   //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   //   children: [
                                //   //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                //   //     CustomText.bodyMedium14(
                                //   //         text: "Qr Code",
                                //   //         minSize: 14,
                                //   //         maxLines: 1
                                //   //     ),
                                //   //   ],
                                //   // ),
                                // ),

                                // GestureDetector(
                                //   onTap: (){
                                //     setState(() {
                                //       // _launchURL();
                                //       Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                //     });
                                //   },
                                //   child: Container(
                                //     width: CustomSize.sizeWidth(context) / 3.8,
                                //     height: CustomSize.sizeWidth(context) / 3.8,
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius: BorderRadius.circular(20),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: Colors.grey.withOpacity(0.5),
                                //           spreadRadius: 0,
                                //           blurRadius: 7,
                                //           offset: Offset(0, 7), // changes position of shadow
                                //         ),
                                //       ],
                                //     ),
                                //     child: Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       crossAxisAlignment: CrossAxisAlignment.center,
                                //       children: [
                                //         Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                //         CustomText.bodyMedium14(
                                //             text: "Meja",
                                //             minSize: 14,
                                //             maxLines: 1
                                //         ),
                                //       ],
                                //     ),
                                //     // child: Column(
                                //     //   mainAxisAlignment: MainAxisAlignment.center,
                                //     //   crossAxisAlignment: CrossAxisAlignment.center,
                                //     //   children: [
                                //     //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                //     //     CustomText.bodyMedium14(
                                //     //         text: "Qr Code",
                                //     //         minSize: 14,
                                //     //         maxLines: 1
                                //     //     ),
                                //     //   ],
                                //     // ),
                                //   ),
                                // ),
                              ],
                            ),
                                (idUserRest == idUser)?(reservation == true || status != 'done')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container():Container(),
                                (idUserRest == idUser)?(reservation == true || status != 'done')?Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (status != 'done' && reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (tunggu == 'false') {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      } else if (tunggu == 'true'){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.calendar_check_o, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Langganan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                (status != 'done' && reservation == true)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                      // if (tunggu == 'false') {
                                      //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                      // } else if (tunggu == 'true'){
                                      //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      // }
                                      // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Pendapatan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):Container(
                                  width: CustomSize.sizeWidth(context) / 3.8,
                                  height: CustomSize.sizeWidth(context) / 3.8,
                                ),

                                Container(
                                  width: CustomSize.sizeWidth(context) / 3.8,
                                  height: CustomSize.sizeWidth(context) / 3.8,
                                ),
                                // Container(
                                //   width: CustomSize.sizeWidth(context) / 3.8,
                                //   height: CustomSize.sizeWidth(context) / 3.8,
                                //   decoration: BoxDecoration(
                                //     color: Colors.transparent,
                                //   ),
                                //   // child: Column(
                                //   //   mainAxisAlignment: MainAxisAlignment.center,
                                //   //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   //   children: [
                                //   //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                //   //     CustomText.bodyMedium14(
                                //   //         text: "Qr Code",
                                //   //         minSize: 14,
                                //   //         maxLines: 1
                                //   //     ),
                                //   //   ],
                                //   // ),
                                // ),

                                // GestureDetector(
                                //   onTap: (){
                                //     setState(() {
                                //       // _launchURL();
                                //       Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                //     });
                                //   },
                                //   child: Container(
                                //     width: CustomSize.sizeWidth(context) / 3.8,
                                //     height: CustomSize.sizeWidth(context) / 3.8,
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius: BorderRadius.circular(20),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: Colors.grey.withOpacity(0.5),
                                //           spreadRadius: 0,
                                //           blurRadius: 7,
                                //           offset: Offset(0, 7), // changes position of shadow
                                //         ),
                                //       ],
                                //     ),
                                //     child: Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       crossAxisAlignment: CrossAxisAlignment.center,
                                //       children: [
                                //         Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                //         CustomText.bodyMedium14(
                                //             text: "Meja",
                                //             minSize: 14,
                                //             maxLines: 1
                                //         ),
                                //       ],
                                //     ),
                                //     // child: Column(
                                //     //   mainAxisAlignment: MainAxisAlignment.center,
                                //     //   crossAxisAlignment: CrossAxisAlignment.center,
                                //     //   children: [
                                //     //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                //     //     CustomText.bodyMedium14(
                                //     //         text: "Qr Code",
                                //     //         minSize: 14,
                                //     //         maxLines: 1
                                //     //     ),
                                //     //   ],
                                //     // ),
                                //   ),
                                // ),
                              ],
                            ):Container():Container(),
                            // SizedBox(height: CustomSize.sizeHeight(context) / 58,),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     GestureDetector(
                            //       onTap: (){
                            //         setState(() {
                            //           Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ReservationRestoActivity()));
                            //         });
                            //       },
                            //       child: Container(
                            //         width: CustomSize.sizeWidth(context) / 3.8,
                            //         height: CustomSize.sizeWidth(context) / 3.8,
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(20),
                            //           boxShadow: [
                            //             BoxShadow(
                            //               color: Colors.grey.withOpacity(0.5),
                            //               spreadRadius: 0,
                            //               blurRadius: 7,
                            //               offset: Offset(0, 7), // changes position of shadow
                            //             ),
                            //           ],
                            //         ),
                            //         child: Column(
                            //           mainAxisAlignment: MainAxisAlignment.center,
                            //           crossAxisAlignment: CrossAxisAlignment.center,
                            //           children: [
                            //             Icon(FontAwesome5.clipboard, color: CustomColor.primaryLight, size: 32,),
                            //             CustomText.bodyMedium14(
                            //                 text: "Reservasi",
                            //                 minSize: 14,
                            //                 maxLines: 1
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                            CustomText.bodyMedium16(
                                text: "Lainnya tentang Restomu",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                maxLines: 1
                            ),
                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (id != 0) {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new HistoryActivity()));
                                      } else if (id == 0){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.history, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Riwayat",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      if (tunggu == 'false') {
                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ScheduleActivity(id.toString())));
                                      } else if (tunggu == 'true'){
                                        Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(MaterialCommunityIcons.door_closed, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Jadwal",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                        CustomText.bodyMedium14(
                                            text: "Operasional",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):(isNgupon == true)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new NguponYukRestoActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 0,
                                          blurRadius: 7,
                                          offset: Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesome.ticket, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Ngupon Yuk",
                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):Container(),
                                (idUserRest == idUser)?GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EmployeesActivity()));
                                    });
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 3.8,
                                    height: CustomSize.sizeWidth(context) / 3.8,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.account_box_rounded, color: CustomColor.primaryLight, size: 32,),
                                        CustomText.bodyMedium14(
                                            text: "Karyawan",
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            maxLines: 1
                                        ),
                                      ],
                                    ),
                                  ),
                                ):Container(
                                  width: CustomSize.sizeWidth(context) / 3.8,
                                  height: CustomSize.sizeWidth(context) / 3.8,),
                              ],
                            ),
                                (idUserRest == idUser)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                                (idUserRest == idUser)?Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    (idUserRest == idUser)?GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          print(owner);
                                          if (owner != 'true') {
                                            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new AddOwnerActivity(id.toString())));
                                          } else if (owner == 'true') {
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
                                                            text: "Owner",
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                            maxLines: 1
                                                        ),
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
                                                      Center(
                                                        child: Container(
                                                          width: CustomSize.sizeWidth(context) / 4,
                                                          height: CustomSize.sizeWidth(context) / 4,
                                                          decoration: (img == "" || img == null)?BoxDecoration(
                                                              color: CustomColor.primary,
                                                              shape: BoxShape.circle
                                                          ):BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: ("$img".substring(0, 8) == '/storage')?DecorationImage(
                                                                image: NetworkImage(Links.subUrl +
                                                                    "$img"),
                                                                fit: BoxFit.cover
                                                            ):DecorationImage(
                                                                image: Image.memory(Base64Decoder().convert(img)).image,
                                                                fit: BoxFit.cover
                                                            ),
                                                          ),
                                                          child: (img == "" || img == null)?Center(
                                                            child: CustomText.text(
                                                                size: 26,
                                                                weight: FontWeight.w800,
                                                                text: initial,
                                                                color: Colors.white
                                                            ),
                                                          ):Container(),
                                                        ),
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                                      Center(
                                                        child: CustomText.textTitle2(
                                                            text: nameOwner,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                            maxLines: 1
                                                        ),
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.0015,),
                                                      Center(
                                                        child: CustomText.textTitle1(
                                                            text: emailOwner,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                            maxLines: 1
                                                        ),
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                                    ],
                                                  );
                                                }
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 7,
                                              offset: Offset(0, 7),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.supervised_user_circle, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Owner",
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                    ):Container(
                                      width: CustomSize.sizeWidth(context) / 3.8,
                                      height: CustomSize.sizeWidth(context) / 3.8,),
                                    (isNgupon == true)?GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new NguponYukRestoActivity()));
                                        });
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 7,
                                              offset: Offset(0, 7),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(FontAwesome.ticket, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Ngupon Yuk",
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                    ):Container(
                                      width: CustomSize.sizeWidth(context) / 3.8,
                                      height: CustomSize.sizeWidth(context) / 3.8,),
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 3.8,
                                      height: CustomSize.sizeWidth(context) / 3.8,),
                                  ],
                                ):Container(),
                                SizedBox(height: CustomSize.sizeHeight(context) / 59,),
                              ],
                            ):Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: CustomSize.sizeHeight(context) / 90,),
                                CustomText.bodyMedium16(
                                    text: "Kelola Restomu",
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                    maxLines: 1
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DepositActivity()));
                                          // if (tunggu == 'false') {
                                          //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PaymentResto(restoName, phone, address)));
                                          // } else if (tunggu == 'true'){
                                          //   Fluttertoast.showToast(msg: "Tunggu sebentar",);
                                          // }
                                          // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new FollowersActivity()));
                                        });
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(MaterialCommunityIcons.wallet, color: CustomColor.primaryLight, size: 32,),
                                            CustomText.bodyMedium14(
                                                text: "Pendapatan",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                maxLines: 1
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        // setState(() {
                                        //   print(homepg + "oi");
                                        //   // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity(id.toString())));
                                        //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
                                        // });
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 3.8,
                                        height: CustomSize.sizeWidth(context) / 3.8,
                                        // decoration: BoxDecoration(
                                        //   color: Colors.white,
                                        //   borderRadius: BorderRadius.circular(20),
                                        //   boxShadow: [
                                        //     BoxShadow(
                                        //       color: Colors.grey.withOpacity(0.5),
                                        //       spreadRadius: 0,
                                        //       blurRadius: 7,
                                        //       offset: Offset(0, 7), // changes position of shadow
                                        //     ),
                                        //   ],
                                        // ),
                                        // child: Column(
                                        //   mainAxisAlignment: MainAxisAlignment.center,
                                        //   crossAxisAlignment: CrossAxisAlignment.center,
                                        //   children: [
                                        //     Icon(FontAwesome.tags, color: CustomColor.primaryLight, size: 32,),
                                        //     CustomText.bodyMedium14(
                                        //         text: "Promo",
                                        //         sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                        //         maxLines: 1
                                        //     ),
                                        //   ],
                                        // ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        // setState(() async{
                                        //   SharedPreferences pref = await SharedPreferences.getInstance();
                                        //   pref.setString('rev', '0');
                                        //   Navigator.push(
                                        //       context,
                                        //       PageTransition(
                                        //           type: PageTransitionType.rightToLeft,
                                        //           child: OrderActivity()));
                                        // });
                                      },
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            width: CustomSize.sizeWidth(context) / 3.8,
                                            height: CustomSize.sizeWidth(context) / 3.8,
                                            // decoration: BoxDecoration(
                                            //   color: Colors.white,
                                            //   borderRadius: BorderRadius.circular(20),
                                            //   boxShadow: [
                                            //     BoxShadow(
                                            //       color: Colors.grey.withOpacity(0.5),
                                            //       spreadRadius: 0,
                                            //       blurRadius: 7,
                                            //       offset: Offset(0, 7), // changes position of shadow
                                            //     ),
                                            //   ],
                                            // ),
                                            // child: Column(
                                            //   mainAxisAlignment: MainAxisAlignment.center,
                                            //   crossAxisAlignment: CrossAxisAlignment.center,
                                            //   children: [
                                            //     Icon(CupertinoIcons.cart_fill, color: CustomColor.primaryLight, size: 32,),
                                            //     CustomText.bodyMedium14(
                                            //         text: "Transaksi",
                                            //         sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            //         maxLines: 1
                                            //     ),
                                            //   ],
                                            // ),
                                          ),
                                          // Container(
                                          //   padding: EdgeInsets.only(right: 5, top: 5),
                                          //   child: (transaction.where((element) => element.is_opened.contains('0')).length != 0 || (transactionC1.length + transaction2.length + transaction3.length) != 0)?
                                          //   Stack(
                                          //     alignment: Alignment.center,
                                          //     children: [
                                          //       Icon(Icons.circle, color: CustomColor.redBtn, size: 22,),
                                          //       CustomText.bodyMedium14(text: (transaction.where((element) => element.is_opened.contains('0')).length + transactionC1.length + transaction2.length + transaction3.length).toString(), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          //     ],
                                          //   ):Container(),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   onTap: (){
                                    //     setState(() {
                                    //       // _launchURL();
                                    //       Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     width: CustomSize.sizeWidth(context) / 3.8,
                                    //     height: CustomSize.sizeWidth(context) / 3.8,
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.white,
                                    //       borderRadius: BorderRadius.circular(20),
                                    //       boxShadow: [
                                    //         BoxShadow(
                                    //           color: Colors.grey.withOpacity(0.5),
                                    //           spreadRadius: 0,
                                    //           blurRadius: 7,
                                    //           offset: Offset(0, 7), // changes position of shadow
                                    //         ),
                                    //       ],
                                    //     ),
                                    //     child: Column(
                                    //       mainAxisAlignment: MainAxisAlignment.center,
                                    //       crossAxisAlignment: CrossAxisAlignment.center,
                                    //       children: [
                                    //         Icon(FontAwesome.th, color: CustomColor.primaryLight, size: 32,),
                                    //         CustomText.bodyMedium14(
                                    //             text: "Meja",
                                    //             minSize: 14,
                                    //             maxLines: 1
                                    //         ),
                                    //       ],
                                    //     ),
                                    //     // child: Column(
                                    //     //   mainAxisAlignment: MainAxisAlignment.center,
                                    //     //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //     //   children: [
                                    //     //     Icon(FontAwesome.qrcode, color: CustomColor.primaryLight, size: 32,),
                                    //     //     CustomText.bodyMedium14(
                                    //     //         text: "Qr Code",
                                    //     //         minSize: 14,
                                    //     //         maxLines: 1
                                    //     //     ),
                                    //     //   ],
                                    //     // ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ):Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            // floatingActionButton: GestureDetector(
            //   onTap: (){
            //     Navigator.push(
            //         context,
            //         PageTransition(
            //             type: PageTransitionType.rightToLeft,
            //             child: OrderActivity()));
            //   },
            //   child: Container(
            //     width: CustomSize.sizeWidth(context) / 6.6,
            //     height: CustomSize.sizeWidth(context) / 6.6,
            //     decoration: BoxDecoration(
            //         color: CustomColor.primaryLight,
            //         shape: BoxShape.circle
            //     ),
            //     child: Center(child: Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 28,)),
            //   ),
            // )
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
