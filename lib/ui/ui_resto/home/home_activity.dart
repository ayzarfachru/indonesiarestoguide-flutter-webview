import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/history/history_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/profile/followers_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
// import 'package:kam5ia/ui/ui_resto/promo_resto/promo_activity.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/payment_resto.dart';
import 'package:kam5ia/ui/ui_resto/detail/detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/employees/employees_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:kam5ia/ui/ui_resto/owner/add_owner.dart';
import 'package:kam5ia/ui/ui_resto/reservation_resto/reservation_activity.dart';
import 'package:kam5ia/ui/ui_resto/reservation_resto/reservation_pending_page.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kam5ia/ui/ui_resto/schedule_resto/schedule_activity.dart';
import 'package:kam5ia/ui/ui_resto/meja/meja_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    setState(() {
      owner = (pref.getString('owner'));
      nameOwner = (pref.getString('nameOwner'));
      emailOwner = (pref.getString('emailOwner'));
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
      id = pref.getInt("ownerId");
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
    var apiResult = await http.get(Links.mainUrl + '/owner/deactivate', headers: {
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
      img = (pref.getString('img'));
      print(img);
    });
  }


  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
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
    var apiResult = await http.get(Links.mainUrl + '/resto/qrcode', headers: {
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
    if (await canLaunch(url)) {
      await launch(url);
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
    var apiResult = await http.get(Links.mainUrl + '/resto', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
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

    if (apiResult.statusCode == 200) {
      _getDetail();
    }
    setState(() {
      restoName = data['resto']['name'];
      id = data['resto']['id'];
      pref.setString('idHomeResto', id.toString());
      idResto();
      idUserRest = (owner != 'true')?int.parse(data['resto']['users_id']):idUser;
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
  Future _getDetail()async{
    List<String> _facility = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/detail/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('Open '+data.toString());

    for(var v in data['data']['fasilitas']){
      _facility.add(v['name']);
    }

    setState(() {
      reservation = (data['data']['reservation_fee'].toString() == '0')?false:true;
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
      }
        pref.setString("jUsaha", _facility.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ","));
      Future.delayed(Duration(seconds: 1), () async{
        wait = true;
        setState((){});
      });
    }
  }

  String initial = "";
  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  String status = 'ongoing';
  Future checkTest() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Links.mainUrl + '/payment/inquiry', headers: {
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
    var apiResult = await http.get(Links.mainUrl + '/resto/trans', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('OILO');
    print(data['trx']['process']);

    if (apiResult.statusCode == 200) {
      // print('PPP '+data['trx']['pending'].toString());
      if (transaction.toString() == '[]') {
        ksg = true;
        if (data['trx'].toString().contains('pending')) {
          for(var v in data['trx']['pending']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
            );
            _transaction.add(r);
          }
        } else {
          ksg = true;
        }

        if (data['trx'].toString().contains('process')) {
          for(var v in data['trx']['process']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
            );
            _transaction2.add(r);
          }
        } else {
          ksg2 = true;
        }

        if (data['trx'].toString().contains('ready')) {
          for(var v in data['trx']['ready']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
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
    var apiResult = await http.get(Links.mainUrl + '/resto/reservation', headers: {
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
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
            );
            _transactionR.add(r);
          }
        } else {
          ksg = true;
        }

        if (data['trx'].toString().contains('process')) {
          for(var v in data['trx']['process']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
            );
            _transaction2R.add(r);
          }
        } else {
          ksg2 = true;
        }

        if (data['trx'].toString().contains('ready')) {
          for(var v in data['trx']['ready']){
            Transaction r = Transaction.home(
                chat_user: v['chat_user'],
                is_opened: v['is_opened']
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
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          print('pppp');
          print(dynamicLink.link);
          return getRoute(dynamicLink.link);
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      return e.message;
    });
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

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    getOwner();
    // _getUserResto();
    // _getDetail();
    initDynamicLinks();
    _getTrans();
    _getTrans2();
    getImg();
    getHomePg();
    // idResto();
    getInitial();
    checkTest();
    // _getQr();
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
    var apiResult = await http.get(Links.mainUrl + '/owner/deactivate', headers: {
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
                          text: "Selamat Datang,",
                          color: Colors.white,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                          maxLines: 1
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 10),
                        child: CustomText.textHeading5(
                          text: "di "+restoName,
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
                              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DetailRestoAdmin(id.toString())));
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
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              text: "Info yang ditampilin tentang",
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                            ),
                                            CustomText.bodyRegular14(
                                                text: "restomu",
                                                maxLines: 2,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(MaterialCommunityIcons.home_account, color: CustomColor.primaryLight, size: 49,)
                                ],
                              ),
                            ),
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
                            child: (wait == true)?Column(
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
                                      Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MenuActivity()));
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
                                ),
                                GestureDetector(
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
                                ),


                                GestureDetector(
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
                                GestureDetector(
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

                                GestureDetector(
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

                                (reservation == true)?GestureDetector(
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
                                ):Container(
                                  width: CustomSize.sizeWidth(context) / 3.8,
                                  height: CustomSize.sizeWidth(context) / 3.8,),


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
                                (reservation == true)?(status != 'done')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container():Container(),
                                (reservation == true)?(status != 'done')?Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
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
                                ),
                                Container(
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
                                GestureDetector(
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
                                ),
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
                                  ],
                                ):Container(),
                                SizedBox(height: CustomSize.sizeHeight(context) / 59,),
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
