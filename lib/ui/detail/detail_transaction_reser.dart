import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTransactionReser extends StatefulWidget {
  int id;
  String status;
  String note = '';
  String idResto = '';

  DetailTransactionReser(this.id, this.status, this.note, this.idResto);

  @override
  _DetailTransactionReserState createState() => _DetailTransactionReserState(id, status, note, idResto);
}

class _DetailTransactionReserState extends State<DetailTransactionReser> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  int id;
  String status;
  String note = '';
  String idResto = '';

  _DetailTransactionReserState(this.id, this.status, this.note, this.idResto);

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  String type = '';
  String address = '';
  int ongkir = 0;
  int harga = 0;
  int total = 0;
  int totalAll = 0;
  String chatroom = 'null';
  String phone = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Menu> menu = [];
  List<String> menu2 = [];
  List<MenuJson> menu3 = [];
  List<String> menu4 = [];
  List<String> menu5 = [];
  String nameRestoTrans = '';
  String badanRestoTrans = '';
  String restoAddress = '';
  Future<void> getData()async{
    List<Menu> _menu = [];
    List<String> _menu2 = [];
    List<MenuJson> _menu3 = [];
    List<String> _menu4 = [];
    List<String> _menu5 = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    pref.setString('inDetail', '1');

    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/reservation/$id'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    print('WOL');
    print(id);
    var data = json.decode(apiResult.body);

    // for(var v in data['menu']){
    //   Menu m = Menu(
    //       id: v['menus_id'],
    //       qty: v['qty'].toString(),
    //       price: Price(original: v['price'], discounted: null, delivery: null),
    //       name: v['name'],
    //       urlImg: v['image'],
    //       desc: v['desc'], is_recommended: '', restoName: '', type: '', distance: null, restoId: '', delivery_price: null
    //   );
    //   _menu.add(m);
    // }
    // for(var v in data['menu']){
    //   MenuJson j = MenuJson(
    //     id: v['menus_id'],
    //     restoId: pref.getString('idnyatransRes'),
    //     name: v['name'],
    //     desc: v['desc'],
    //     price: v['price'].toString(),
    //     discount: v['discount'],
    //     pricePlus: v['pricePlus'],
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
      // address = data['trans']['address']??'';
      // ongkir = data['trans']['ongkir'];
      // total = data['trans']['total'];
      // totalAll = data['trans']['total']+data['trans']['ongkir'];
      // harga = data['trans']['total'] - data['trans']['ongkir'];
      chatroom = data['trx']['chatroom']['id'].toString();
      _checkPayFirst();
      // phone = data['phone_number'].toString();
      isLoading = false;
    });
    print(chatroom);
  }

  String emailTokoTrans = '';
  String ownerTokoTrans = '';
  String pjTokoTrans = '';
  String nameNorekTokoTrans = '';
  String bankTokoTrans = '';
  String nameRekening = '';
  String nameBank = '';
  String norekTokoTrans = '';
  String addressRes = '';
  Future<void> _getUserDataResto()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/userdata/'+idResto), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    print('id e '+apiResult.body.toString());
    print('id e '+id.toString());
    print('id e2 '+data['badan_usaha'].toString());
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
      badanRestoTrans = data['badan_usaha'].toString();
      emailTokoTrans = data['email'].toString();
      ownerTokoTrans = data['name_owner'].toString();
      pjTokoTrans = data['name_pj'].toString();
      // bankTokoTrans = data['bank'].toString();
      // nameNorekTokoTrans = data['namaNorek'].toString();
      nameRekening = data['nama_norek'].toString();
      nameBank = data['bank_norek'].toString();
      norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      _getDetail(idResto);
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  // _launchURL() async {
  //   var url = 'https://www.google.co.id/maps/place/' + restoAddress;
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // Future<void> _getUserDataResto()async{
  //   // List<Menu> _menu = [];
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String token = pref.getString("token") ?? "";
  //   var apiResult = await http.get(Links.mainUrl + '/resto/userdata/$checkId', headers: {
  //     "Accept": "Application/json",
  //     "Authorization": "Bearer $token"
  //   });
  //   print(apiResult.body);
  //   var data = json.decode(apiResult.body);
  //
  //   // for(var v in data['menu']){
  //   //   Menu p = Menu(
  //   //       id: v['id'],
  //   //       name: v['name'],
  //   //       desc: v['desc'],
  //   //       urlImg: v['img'],
  //   //       type: v['type'],
  //   //       is_recommended: v['is_recommended'],
  //   //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
  //   //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
  //   //   );
  //   //   _menu.add(p);
  //   // }
  //   setState(() {
  //     emailTokoTrans = data['email'].toString();
  //     ownerTokoTrans = data['name_owner'].toString();
  //     pjTokoTrans = data['name_pj'].toString();
  //     // bankTokoTrans = data['bank'].toString();
  //     // nameNorekTokoTrans = data['namaNorek'].toString();
  //     norekTokoTrans = data['norek'].toString();
  //     // isLoading = false;
  //   });
  // }

  String userName = '';
  String timeLog = '';
  String chatUserCount = '';
  String jmlhMeja = "";
  String tglReser = "";
  String jamReser = "";
  String hargaReser = "";
  String totalReser = "";
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name')??'');
      timeLog = (pref.getString('timeLog')??'');
      jmlhMeja = (pref.getString('jmlhMeja')??"");
      tglReser = (pref.getString('tglReser')??"");
      jamReser = (pref.getString('jamReser')??"");
      hargaReser = (pref.getString('hargaReser')??"");
      totalReser = (pref.getString('totalReser')??"");
      chatUserCount = (pref.getString('chatUserCount')??'');
    });
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // countChat();
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  String inCart = "";
  Future _getData()async{
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    inCart = pref2.getString('inCart')??"";
    // if(checkId == idnyaResto && inCart == '1'){
    //   name = pref2.getString('menuJson')??"";
    //   print("Ini pref2 " +name+" SP");
    //   restoId.addAll(pref2.getStringList('restoId')??[]);
    //   print(restoId);
    //   qty.addAll(pref2.getStringList('qty')??[]);
    //   print('qty '+qty.toString());
    //   noted.addAll(pref2.getStringList('note')??[]);
    //   print('notednya '+noted.toString());
    // } else if (checkId != idnyaResto && inCart == '1') {
    //   print(restoId.toString()+'ididi');
    //   print(qty);
    // } else {
    //   pref2.remove('inCart');
    //   // pref2.setString("menuJson", "[]");
    //   pref2.remove("restoIdUsr");
    //   pref2.remove("restoId");
    //   pref2.remove("qty");
    //   print('cukimay');
    // }
    setState(() {});
  }

  Future _getData2()async{
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // cart = pref.getString('inCart');
    // checkId = pref.getString('restoIdUsr')??'';
    // json2 = pref.getString("menuJson");
    // print('cokk '+json2);
    setState(() {});
  }

  String can_delivery = "";
  String can_takeaway = "";
  String idnyaResto = "";
  String isOpen = "";
  List<String> noted = [];
  String nameResto = "";
  Future _getDetail(String id)async{
    setState(() {
      // schedule = _schedule;
      isLoading = true;
    });
    List<String> _images = [];
    // List<Promo> _promo = [];
    List<Menu> _menu = [];
    // List<MenuJson> _menuJson = [];
    // List<CategoryMenu> _categoryMenu = [];
    List<String> _facility = [];
    List<String> _cuisine = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('ini loh sob '+data['data'].toString());


    SharedPreferences pref2 = await SharedPreferences.getInstance();
    pref2.setString('latResto', data['data']['lat'].toString());
    pref2.setString('longResto', data['data']['long'].toString());
    pref2.setString('can_deliveryUser', data['data']['can_delivery'].toString());
    pref2.setString('can_take_awayUser', data['data']['can_take_away'].toString());


    setState(() {
      print('iniphone '+phone.toString());
      isLoading = false;
      idnyaResto = data['data']['id'].toString();
      nameRestoTrans = data['data']['name'];
      restoAddress = data['data']['address'];
      phone = data['data']['phone_number'];
      can_delivery = data['data']['can_delivery'].toString();
      can_takeaway = data['data']['can_take_away'].toString();
      // can_delivery = data['data']['can_delivery'].toString();
      // can_takeaway = data['data']['can_take_away'].toString();
      isOpen = data['data']['isOpen'].toString();
    });
  }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + restoAddress;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  toCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    inCart = '1';
    String idRes = '';

    idRes = pref.getString("idnyatransRes")??'';
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99")??'');
    pref.setString("alamateResto", addressRes);
    pref.setString("restoPhoneTrans", phone);
    pref.setString("restoIdUsr", idRes);
    // menuJson = [];
    // print('kudune '+pref.getString("alamateResto99"));
    // json2 = pref.getString("menuJson");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    // setStateModal(() {});
    setState(() {});
  }

  toCart2() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    inCart = '1';
    String idRes = '';

    idRes = pref.getString("idnyatransRes")??'';
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99")??'');
    pref.setString("alamateResto", addressRes);
    pref.setString("restoPhoneTrans", phone);
    pref.setString("restoIdUsr", idRes);
    // menuJson = [];
    // print('kudune '+pref.getString("alamateResto99"));
    // json2 = pref.getString("menuJson");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    Future.delayed(Duration(seconds: 1)).whenComplete((){
      Navigator.push(context, PageTransition(
          type: PageTransitionType.rightToLeft,
          child: CartActivity()));
    });
    // setStateModal(() {});
    setState(() {});
  }

  delCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    pref.setString("menuJson", "");
    pref.setString("restoId", "");
    pref.setString("qty", "");
    pref.setString("note", "");
    pref.remove('address');
    pref.remove('inCart');
    pref.remove('restoIdUsr');
    pref.remove("addressDelivTrans");
    pref.remove("distan");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    // setStateModal(() {});
    setState(() {});
  }

  String statusPay = '';
  bool isLoadChekPayFirst = true;
  String statusTrans = '';
  Future<void> _checkPayFirst()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPayFirst = true;
    });
    // Fluttertoast.showToast(
    //   msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    statusTrans = (pref.getString('statusTrans')??'');
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    print(apiResult.statusCode);
    if (apiResult.statusCode == 500) {
      isLoadChekPayFirst = false;
      statusPay = 'true';
      setState((){});
    } else {
      var data = json.decode(apiResult.body);
      print('QR CODE 2');
      print(data);
      print(data['response']['detail_info'].toString().contains('Unpaid').toString());
      statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
      if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
        Fluttertoast.showToast(
          msg: "Anda belum membayar!",);
      } else {
        statusPay = 'false';
        if (statusTrans == 'pending') {
          _getPending('process', id.toString());
          setState((){});
        }
        // Navigator.pop(context);
        // _getPending('process', id.toString());
        Fluttertoast.showToast(
          msg: "Pembayaran berhasil",);
      }
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
      isLoadChekPayFirst = false;
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

  Future _getPending(String operation, String id)async{
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
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }

  bool isLoadChekPay = false;
  Future<void> _checkPayBCA()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
    } else {
      statusPay = 'false';
      Navigator.pop(context);
      _getPending('process', id.toString());
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
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
      isLoadChekPay = false;
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

  late String _base64="";

  bool loadQr = false;
  Future<void> _getQrBCA()async{
    // List<Menu> _menu = [];

    print('XIXI');
    print(totalReser.toString());
    print(id.toString());

    setState(() {
      loadQr = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/bca/generate'),
        body: {'app_id': 'IRG', 'trx_id': id.toString(), 'name_resto': nameRestoTrans.toString(), 'amount': totalReser.toString()},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    var data = json.decode(apiResult.body);
    print('QR CODE');
    print(data);
    print(data['response']['qr_image']);
    _base64 = data['response']['qr_image'];
    Uint8List bytes = Base64Codec().decode(_base64);

    if (_base64 != '') {
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
                // Center(
                //   child: CustomText.textHeading2(
                //       text: "Qris",
                //       minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                //       maxLines: 1
                //   ),
                // ),
                // SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
                Center(
                  child: FullScreenWidget(
                    child: Image.memory(bytes,
                      width: CustomSize.sizeWidth(context) / 1.2,
                      height: CustomSize.sizeWidth(context) / 1.2,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 88,),
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
                            text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalReser.toString()).toString())),
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
                    if (isLoadChekPay != true) {
                      _checkPayBCA();
                    }
                    // Fluttertoast.showToast(
                    //   msg: "Anda belum membayar!",);
                  },
                  child: Center(
                    child: Container(
                      width: CustomSize.sizeWidth(context) / 1.1,
                      height: CustomSize.sizeHeight(context) / 14,
                      decoration: BoxDecoration(
                          color: CustomColor.primaryLight,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomText.textTitle3(text: "Cek Pembayaran", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
      loadQr = false;
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

  @override
  void initState() {
    _getUserDataResto();
    getUser();
    getData();
    // getData();
    _getData();
    // _getDetail(id);
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
      onWillPop: () => onWillPop(),
      child: MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: (isLoadChekPayFirst == true)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Row(
                      children: [
                        GestureDetector(
                            onTap: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
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
                              text: "Detail Reservation",
                              color: CustomColor.primary,
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                              maxLines: 2
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                      ),
                      child: CustomText.textHeading4(text: "Kode Transaksi: IRG-$id", color: CustomColor.primary, minSize: double.parse(((MediaQuery.of(context).size.width*0.0375).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.0375)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.0375)).toString())),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Tipe Pemesanan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 18,
                      right: CustomSize.sizeWidth(context) / 18,
                    ),
                    child: CustomText.textHeading6(text: "Reservasi", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Data Reservasi", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  Padding(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText.textTitle3(text: 'Jumlah Meja: '+jmlhMeja,  maxLines: 10, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                CustomText.textTitle3(text: 'Tanggal: '+tglReser,  maxLines: 10, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                CustomText.textTitle3(text: 'Jam: '+jamReser,  maxLines: 10, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                              ],
                            )
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
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  // Divider(thickness: 6, color: CustomColor.secondary,),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: CustomSize.sizeWidth(context) / 32,
                  //       vertical: CustomSize.sizeHeight(context) / 55
                  //   ),
                  //   child: Container(
                  //     width: CustomSize.sizeWidth(context),
                  //     decoration: BoxDecoration(
                  //         color: Colors.white
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         CustomText.textHeading7(text: "Data Usaha", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                  //         SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                  //         Container(
                  //           padding: EdgeInsets.only(
                  //             left: CustomSize.sizeWidth(context) / 25,
                  //             right: CustomSize.sizeWidth(context) / 25,
                  //           ),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               (nameRestoTrans != '' && nameRestoTrans != 'null')?
                  //               CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (badanRestoTrans != '' && badanRestoTrans != 'null')?
                  //               CustomText.bodyRegular17(text: "Badan Usaha: "+badanRestoTrans, maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Badan Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (restoAddress != '' && restoAddress != 'null')?
                  //               Row(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         _launchURL();
                  //                       },
                  //                       child: Container(
                  //                           width: CustomSize.sizeWidth(context) / 1.8,
                  //                           child: CustomText.bodyRegular17(text: restoAddress, maxLines: 14, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                  //                       )
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (emailTokoTrans != '' && emailTokoTrans != 'null')?
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         launch('mailto:$emailTokoTrans');
                  //                       },
                  //                       child: Container(
                  //                           width: CustomSize.sizeWidth(context) / 1.8,
                  //                           child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                  //                       )
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (phone != '' && phone != 'null')?
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         launch('tel:$phone');
                  //                       },
                  //                       child: CustomText.bodyRegular17(text: phone, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               // (ownerTokoTrans != '' && ownerTokoTrans != 'null')?
                  //               // CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               // Row(
                  //               //   children: [
                  //               //     CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //               //     CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //               //   ],
                  //               // ),
                  //               // SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //               //
                  //               // (pjTokoTrans != '' && pjTokoTrans != 'null')?
                  //               // CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               // Row(
                  //               //   children: [
                  //               //     CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //               //     CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //               //   ],
                  //               // ),
                  //               // SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (nameRekening != '' && nameRekening != 'null')?
                  //               CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameRekening, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (nameBank != '' && nameBank != 'null')?
                  //               CustomText.bodyRegular17(text: "Rekening Bank: "+nameBank, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (norekTokoTrans != '' && norekTokoTrans != 'null')?
                  //               CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Divider(thickness: 6, color: CustomColor.secondary,),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: CustomSize.sizeWidth(context) / 32,
                  //       vertical: CustomSize.sizeHeight(context) / 55
                  //   ),
                  //   child: Container(
                  //     width: CustomSize.sizeWidth(context),
                  //     decoration: BoxDecoration(
                  //         color: Colors.white
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         CustomText.textHeading7(text: "Data Usaha"),
                  //         SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                  //         Container(
                  //           padding: EdgeInsets.only(
                  //             left: CustomSize.sizeWidth(context) / 25,
                  //             right: CustomSize.sizeWidth(context) / 25,
                  //           ),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               (nameRestoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (restoAddress != '')?
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         _launchURL();
                  //                       },
                  //                       child: Container(
                  //                           width: CustomSize.sizeWidth(context) / 1.8,
                  //                           child: CustomText.bodyRegular17(text: restoAddress, maxLines: 1, minSize: 15)
                  //                       )
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (emailTokoTrans != '')?
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         launch('mailto:$emailTokoTrans');
                  //                       },
                  //                       child: Container(
                  //                           width: CustomSize.sizeWidth(context) / 1.8,
                  //                           child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 1)
                  //                       )
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (phoneRestoTrans != '')?
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2),
                  //                   GestureDetector(
                  //                       onTap: (){
                  //                         launch('tel:$phoneRestoTrans');
                  //                       },
                  //                       child: CustomText.bodyRegular17(text: phoneRestoTrans, maxLines: 2)
                  //                   ),
                  //                 ],
                  //               ):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (ownerTokoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (pjTokoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (nameNorekTokoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameNorekTokoTrans, maxLines: 2):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (bankTokoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Rekening Bank: "+bankTokoTrans, maxLines: 2):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                  //
                  //               (norekTokoTrans != '')?
                  //               CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2):
                  //               Row(
                  //                 children: [
                  //                   CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2),
                  //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
                            height: CustomSize.sizeHeight(context) / 3.8,
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
                                  CustomText.textTitle3(text: "Rincian Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight16(text: "Harga per meja x "+jmlhMeja, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                      CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(hargaReser.split('.')[0].toString())), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    ],
                                  ),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                  Divider(thickness: 1,),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                      CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalReser.toString())), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    ],
                                  ),
                                  // SizedBox(height: CustomSize.sizeHeight(context) / 34,),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                        // (phone == '')?GestureDetector(
                        //   onTap: (){
                        //     // Navigator.push(
                        //     //     context,
                        //     //     PageTransition(
                        //     //         type: PageTransitionType.rightToLeft,
                        //     //         child: new ChatActivity(chatroom, userName, status)));
                        //   },
                        //   child: Center(
                        //     child: Container(
                        //       width: CustomSize.sizeWidth(context) / 1.1,
                        //       height: CustomSize.sizeHeight(context) / 14,
                        //       decoration: BoxDecoration(
                        //           color: CustomColor.accent,
                        //           borderRadius: BorderRadius.circular(50)
                        //       ),
                        //       child: Center(
                        //         child: Padding(
                        //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        //           child: CustomText.textTitle2(text: "Telpon Penjual", color: Colors.white),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ):SizedBox(),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        (statusPay == 'true')?GestureDetector(
                          onTap: (){
                            if (loadQr == false) {
                              if (type != 'dinein') {
                                _getQrBCA();
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        title: Center(child: Text('Transaksi', style: TextStyle(color: CustomColor.primary))),
                                        content: Text('Pilih metode pembayaran!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                        // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                                                  child: Text('Qris', style: TextStyle(color: Colors.white)),
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
                                                  child: Text('Tunai / Debit', style: TextStyle(color: Colors.white)),
                                                  onPressed: () async{
                                                    Navigator.pop(context);
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
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         type: PageTransitionType.rightToLeft,
                            //         child: new ChatActivity(chatroom, userName, status)));
                          },
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                                color: CustomColor.accent,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                      child: CustomText.textTitle2(text: "Bayar Sekarang", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                    ),
                                    // Positioned(  // draw a red marble
                                    //   top: 0,
                                    //   right: 0,
                                    //   child: Stack(
                                    //     alignment: Alignment.center,
                                    //     children: [
                                    //       Icon(Icons.circle, color: (chatUserCount != '0')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                    //       CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0')?Colors.white:Colors.transparent, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ):Container(),
                        (statusPay == 'true')?SizedBox(height: CustomSize.sizeHeight(context) / 96,):Container(),
                        GestureDetector(
                          onTap: (){
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
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                if (chatroom != 'null') {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type: PageTransitionType.rightToLeft,
                                                          child: new ChatActivity(chatroom, userName, status)));
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg: 'Chat tidak dapat dilakukan.',);
                                                }
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    Icon(FontAwesome.comments_o, color: (chatroom != 'null')?CustomColor.accent:Colors.grey, size: 31,),
                                                    // SizedBox(width: CustomSize.sizeWidth(context) / 72,),
                                                    Stack(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 19.0),
                                                          child: CustomText.textHeading5(
                                                              text: "Chat",
                                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.06).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.06).toString()),
                                                              maxLines: 1,
                                                              color: (chatroom != 'null')?CustomColor.accent:Colors.grey
                                                          ),
                                                        ),
                                                        Positioned(  // draw a red marble
                                                          top: 1,
                                                          right: 0,
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Icon(Icons.circle, color: (chatUserCount != '0' && chatUserCount != 'null')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                                              CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0' && chatUserCount != 'null')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                // Navigator.pop(context);
                                                print(phone);
                                                launch("tel:$phone");
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Row(
                                                  children: [
                                                    Icon(FontAwesome.phone, color: CustomColor.redBtn, size: 27.5,),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 88,),
                                                    CustomText.textHeading5(
                                                        text: "Telpon",
                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.06).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.06).toString()),
                                                        maxLines: 1,
                                                        color: CustomColor.redBtn
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 42,),
                                    ],
                                  );
                                }
                            );
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         type: PageTransitionType.rightToLeft,
                            //         child: new ChatActivity(chatroom, userName, status)));
                          },
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                                color: CustomColor.primaryLight,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                      child: CustomText.textTitle2(text: "Hubungi Penjual", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                    ),
                                    Positioned(  // draw a red marble
                                      top: 0,
                                      right: 0,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.circle, color: (chatUserCount != '0' && chatUserCount != 'null')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                          CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0' && chatUserCount != 'null')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        (status == 'cancel')?SizedBox(height: CustomSize.sizeHeight(context) / 88,):SizedBox(),
                        (status == 'cancel')?GestureDetector(
                          onTap: (){
                            if (inCart.toString() == '') {
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
                                                  toCart().whenComplete((){
                                                    Navigator.push(context, PageTransition(
                                                        type: PageTransitionType.rightToLeft,
                                                        child: CartActivity()));
                                                  });
                                                  setState(() {});

                                                  pref.setString("metodeBeli", '1');
                                                } else {
                                                  Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                }
                                              });
                                              Navigator.pop(_);
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
                                                CustomText.textHeading6(text: "Pesan Antar", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          GestureDetector(
                                            onTap: ()async{
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              setState(() {
                                                if (can_takeaway == 'true') {
                                                  toCart().whenComplete((){
                                                    Navigator.push(context, PageTransition(
                                                        type: PageTransitionType.rightToLeft,
                                                        child: CartActivity()));
                                                  });
                                                  setState(() {});

                                                  pref.setString("metodeBeli", '2');
                                                } else {
                                                  Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                }
                                              });
                                              Navigator.pop(_);
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
                                                CustomText.textHeading6(text: "Ambil Langsung", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          GestureDetector(
                                            onTap: ()async{
                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                              toCart().whenComplete((){
                                                Navigator.push(context, PageTransition(
                                                    type: PageTransitionType.rightToLeft,
                                                    child: CartActivity()));
                                              });

                                              setState(() {
                                                pref.setString("metodeBeli", '3');
                                              });
                                              Navigator.pop(_);
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
                                                CustomText.textHeading6(text: "Makan Ditempat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        ],
                                      ),
                                    );
                                  }
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: new Text("Hapus cart"),
                                    content: new Text("Apakah anda ingin mengganti item di cart dengan item yang baru ?"),
                                    actions: <Widget>[
                                      new TextButton(
                                        child: new Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      new TextButton(
                                        child: new Text("Oke", style: TextStyle(color: CustomColor.primaryLight)),
                                        onPressed: () async{
                                          delCart().whenComplete((){
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
                                                                // Navigator.pop(_);
                                                                toCart2().whenComplete((){
                                                                });
                                                                // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                                //   Navigator.push(context, PageTransition(
                                                                //       type: PageTransitionType.rightToLeft,
                                                                //       child: CartActivity()));
                                                                // });

                                                                setState(() {});

                                                                pref.setString("metodeBeli", '1');
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
                                                              CustomText.textHeading6(text: "Pesan Antar", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                        GestureDetector(
                                                          onTap: ()async{
                                                            SharedPreferences pref = await SharedPreferences.getInstance();
                                                            setState(() {
                                                              if (can_takeaway == 'true') {
                                                                // Navigator.pop(_);
                                                                toCart2().whenComplete((){
                                                                });
                                                                // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                                //   Navigator.push(context, PageTransition(
                                                                //       type: PageTransitionType.rightToLeft,
                                                                //       child: CartActivity()));
                                                                // });

                                                                setState(() {});

                                                                pref.setString("metodeBeli", '2');
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
                                                              CustomText.textHeading6(text: "Ambil Langsung", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                        GestureDetector(
                                                          onTap: ()async{
                                                            SharedPreferences pref = await SharedPreferences.getInstance();
                                                            // Navigator.pop(_);
                                                            toCart2().whenComplete((){
                                                            });
                                                            // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                            //   Navigator.push(context, PageTransition(
                                                            //       type: PageTransitionType.rightToLeft,
                                                            //       child: CartActivity()));
                                                            // });

                                                            // setState(() {});

                                                            setState(() {
                                                              pref.setString("metodeBeli", '3');
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
                                                              CustomText.textHeading6(text: "Makan Ditempat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                      ],
                                                    ),
                                                  );
                                                }
                                            );
                                          });
                                          // await Future.delayed(Duration(seconds: 2));
                                          Navigator.of(context).pop();
                                          // Navigator.pushReplacement(
                                          //     context,
                                          //     PageTransition(
                                          //         type: PageTransitionType.rightToLeft,
                                          //         child: new DetailResto(id)));
                                          // pref.remove('inCart');
                                          // pref.setString("menuJson", "");
                                          // inCart = pref.getString("inCart");
                                          // cart = pref.getString("inCart");
                                          // qty.addAll([]);
                                          // json2 = pref.getString("menuJson");
                                          // pref.setString("qty", "");
                                          // pref.remove("restoIdUsr");

                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                                color: CustomColor.accent,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                      child: CustomText.textTitle2(text: "Lanjut Lagi", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                    ),
                                    // Positioned(  // draw a red marble
                                    //   top: 0,
                                    //   right: 0,
                                    //   child: Stack(
                                    //     alignment: Alignment.center,
                                    //     children: [
                                    //       Icon(Icons.circle, color: (chatUserCount != '0')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                    //       CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0')?Colors.white:Colors.transparent)
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: (chatroom != 'null')?GestureDetector(
          //   onTap: (){
          //     showModalBottomSheet(
          //         isScrollControlled: true,
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
          //         ),
          //         context: context,
          //         builder: (_){
          //           return Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               SizedBox(height: CustomSize.sizeHeight(context) / 86,),
          //               Padding(
          //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
          //                 child: Divider(thickness: 4,),
          //               ),
          //               SizedBox(height: CustomSize.sizeHeight(context) / 106,),
          //               Padding(
          //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
          //                 child: Row(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //                   children: [
          //                     GestureDetector(
          //                       onTap: (){
          //                         // Navigator.pop(context);
          //                         Navigator.push(
          //                             context,
          //                             PageTransition(
          //                                 type: PageTransitionType.rightToLeft,
          //                                 child: new ChatActivity(chatroom, userName, status)));
          //                       },
          //                       child: Padding(
          //                         padding: const EdgeInsets.symmetric(vertical: 8.0),
          //                         child: Row(
          //                           children: [
          //                             Icon(FontAwesome.comments_o, color: CustomColor.accent, size: 31,),
          //                             SizedBox(width: CustomSize.sizeWidth(context) / 72,),
          //                             CustomText.textHeading5(
          //                                 text: "Chat",
          //                                 minSize: 17,
          //                                 maxLines: 1,
          //                                 color: CustomColor.accent
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: (){
          //                         // Navigator.pop(context);
          //                         launch("tel:$phone");
          //                       },
          //                       child: Padding(
          //                         padding: const EdgeInsets.symmetric(vertical: 8.0),
          //                         child: Row(
          //                           children: [
          //                             Icon(FontAwesome.phone, color: CustomColor.redBtn, size: 27.5,),
          //                             SizedBox(width: CustomSize.sizeWidth(context) / 88,),
          //                             CustomText.textHeading5(
          //                                 text: "Telpon",
          //                                 minSize: 17,
          //                                 maxLines: 1,
          //                                 color: CustomColor.redBtn
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               SizedBox(height: CustomSize.sizeHeight(context) / 42,),
          //             ],
          //           );
          //         }
          //     );
          //     // Navigator.push(
          //     //     context,
          //     //     PageTransition(
          //     //         type: PageTransitionType.rightToLeft,
          //     //         child: new ChatActivity(chatroom, userName, status)));
          //   },
          //   child: Container(
          //     width: CustomSize.sizeWidth(context) / 1.1,
          //     height: CustomSize.sizeHeight(context) / 14,
          //     decoration: BoxDecoration(
          //         color: CustomColor.accent,
          //         borderRadius: BorderRadius.circular(50)
          //     ),
          //     child: Center(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //         child: CustomText.textTitle2(text: "Hubungi Penjual", color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ):SizedBox(),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
