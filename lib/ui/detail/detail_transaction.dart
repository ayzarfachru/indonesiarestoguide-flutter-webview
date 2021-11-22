import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class DetailTransaction extends StatefulWidget {
  int id;
  String status;
  String note = '';
  String idResto = '';

  DetailTransaction(this.id, this.status, this.note, this.idResto);

  @override
  _DetailTransactionState createState() => _DetailTransactionState(id, status, note, idResto);
}

class _DetailTransactionState extends State<DetailTransaction> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  int id;
  String status;
  String note = '';
  String idResto = '';

  _DetailTransactionState(this.id, this.status, this.note, this.idResto);

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

    var apiResult = await http.get(Links.mainUrl + '/trans/$id',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('chatt '+data['chatroom'].toString());

    for(var v in data['menu']){
      Menu m = Menu(
          id: v['menus_id'],
          qty: v['qty'].toString(),
          price: Price(original: v['price'], discounted: null, delivery: null),
          name: v['name'],
          urlImg: v['image'],
          desc: v['desc'], is_recommended: '', restoName: '', type: '', distance: null, restoId: '', delivery_price: null
      );
      _menu.add(m);
    }
    for(var v in data['menu']){
      MenuJson j = MenuJson(
        id: v['menus_id'],
        restoId: pref.getString('idnyatransRes'),
        name: v['name'],
        desc: v['desc'],
        price: v['price'].toString(),
        discount: v['discount'],
        pricePlus: v['pricePlus'],
        urlImg: v['image'], restoName: '', distance: null,
      );
      _menu3.add(j);
    }
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu2.add(v['qty'].toString());
    }
    // _menu3.add(jsonEncode(data['menu']));
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu4.add(v['menus_id'].toString());
      print('ini '+v['menus_id'].toString());
    }
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu5.add(v['name'].toString()+": kam5ia_null}");
    }
    setState(() {
      menu = _menu;
      menu2 = _menu2;
      menu3 = _menu3;
      menu4 = _menu4;
      menu5 = _menu5;
      type = data['trans']['type'];
      address = data['trans']['address']??'';
      ongkir = data['trans']['ongkir'];
      total = data['trans']['total'];
      totalAll = data['trans']['total']+data['trans']['ongkir'];
      harga = data['trans']['total'] - data['trans']['ongkir'];
      chatroom = data['chatroom']['id'].toString();
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
    var apiResult = await http.get(Links.mainUrl + '/resto/userdata/'+idResto, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    print('id e '+idResto.toString());
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
      phone = data['resto']['phone_number'].toString();
      addressRes = data['resto']['address'].toString();
      nameRestoTrans = data['resto']['name'];
      restoAddress = data['resto']['address'];
      can_delivery = (data['resto']['can_delivery'].toString() == '1')?'true':'false';
      can_takeaway = (data['resto']['can_take_away'].toString() == '1')?'true':'false';
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
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name'));
      timeLog = (pref.getString('timeLog'));
      chatUserCount = (pref.getString('chatUserCount'));
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
    var apiResult = await http.get(Links.mainUrl + '/resto/detail/$id', headers: {
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
      idnyaResto = data['data']['id'].toString();
      nameResto = data['data']['name'];
      address = data['data']['address'];
      phone = data['data']['phone_number'];
      print('iniphone '+phone.toString());
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

    idRes = pref.getString("idnyatransRes");
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99"));
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

    idRes = pref.getString("idnyatransRes");
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99"));
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

  @override
  void initState() {
    // _getUserDataResto();
    _getUserDataResto();
    getUser();
    getData();
    _getData();
    _getData2();
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
                  (type == 'delivery' || type == 'takeaway')?Container(
                    color: Colors.white,
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
                                    text: "Detail Transaction",
                                    color: CustomColor.primary,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                    maxLines: 2
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                        Padding(
                          padding: EdgeInsets.only(
                            left: CustomSize.sizeWidth(context) / 32,
                            right: CustomSize.sizeWidth(context) / 32,
                          ),
                          child: CustomText.textHeading4(text: (type == 'delivery')?"Alamat Pengiriman":"Alamat Pengambilan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString())),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                        Padding(
                          padding: EdgeInsets.only(
                            left: CustomSize.sizeWidth(context) / 18,
                            right: CustomSize.sizeWidth(context) / 18,
                          ),
                          child: CustomText.textHeading6(
                              text: address,
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),
                              maxLines: 10
                          ),
                        ),
                      ],
                    ),
                  ):SizedBox(),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Tipe Pembelian", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 18,
                      right: CustomSize.sizeWidth(context) / 18,
                    ),
                    child: CustomText.textHeading6(text: (type == 'delivery')?"Pesan Antar":(type == 'takeaway')?"Ambil Langsung":"Makan Ditempat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: menu.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(
                            top: CustomSize.sizeWidth(context) / 68,
                            left: CustomSize.sizeWidth(context) / 32,
                            right: CustomSize.sizeWidth(context) / 32,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 1.65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            CustomText.textHeading4(
                                                text: menu[index].name,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                                                maxLines: 1
                                            ),
                                            CustomText.bodyRegular12(
                                                text: menu[index].desc,
                                                maxLines: 2,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                            Row(
                                              children: [
                                                CustomText.bodyMedium14(
                                                    text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original) ,
                                                    maxLines: 1,
                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.0025),
                                            CustomText.bodyMedium14(
                                                text: menu[index].qty.toString()+' Item',
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.4,
                                        height: CustomSize.sizeWidth(context) / 3.4,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                                fit: BoxFit.cover
                                            ),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider()
                            ],
                          ),
                        );
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                  (note != '' && note != '[]' && note != 'null')?Divider(thickness: 6, color: CustomColor.secondary,):Container(),
                  (note != '' && note != '[]' && note != 'null')?Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 32,
                      right: CustomSize.sizeWidth(context) / 32,
                    ),
                    child: CustomText.textHeading4(text: "Catatan mu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                  ):Container(),
                  (note != '' && note != '[]' && note != 'null')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,):Container(),
                  (note != '' && note != '[]' && note != 'null')?Padding(
                    padding: EdgeInsets.only(
                      left: CustomSize.sizeWidth(context) / 18,
                      right: CustomSize.sizeWidth(context) / 18,
                    ),
                    child: CustomText.textHeading6(text: note.replaceAll('[', '').replaceAll(']', '').replaceAll('{', '').replaceAll('}, ', '\n').replaceAll('}', ''), maxLines: 99, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                  ):Container(),
                  (note != '' && note != '[]' && note != 'null')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0075):Container(),
                  Divider(thickness: 6, color: CustomColor.secondary,),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 32,
                        vertical: CustomSize.sizeHeight(context) / 55
                    ),
                    child: Container(
                      width: CustomSize.sizeWidth(context),
                      decoration: BoxDecoration(
                          color: Colors.white
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText.textHeading7(text: "Data Usaha", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                          SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                          Container(
                            padding: EdgeInsets.only(
                              left: CustomSize.sizeWidth(context) / 25,
                              right: CustomSize.sizeWidth(context) / 25,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (nameRestoTrans != '' && nameRestoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (badanRestoTrans != '' && badanRestoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Badan Usaha: "+badanRestoTrans, maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Badan Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (restoAddress != '' && restoAddress != 'null')?
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          _launchURL();
                                        },
                                        child: Container(
                                            width: CustomSize.sizeWidth(context) / 1.8,
                                            child: CustomText.bodyRegular17(text: restoAddress, maxLines: 14, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                                        )
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (emailTokoTrans != '' && emailTokoTrans != 'null')?
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          launch('mailto:$emailTokoTrans');
                                        },
                                        child: Container(
                                            width: CustomSize.sizeWidth(context) / 1.8,
                                            child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                                        )
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (phone != '' && phone != 'null')?
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    GestureDetector(
                                        onTap: (){
                                          launch('tel:$phone');
                                        },
                                        child: CustomText.bodyRegular17(text: phone, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString()))
                                    ),
                                  ],
                                ):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (ownerTokoTrans != '' && ownerTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (pjTokoTrans != '' && pjTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (nameRekening != '' && nameRekening != 'null')?
                                CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameRekening, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (nameBank != '' && nameBank != 'null')?
                                CustomText.bodyRegular17(text: "Rekening Bank: "+nameBank, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),

                                (norekTokoTrans != '' && norekTokoTrans != 'null')?
                                CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())):
                                Row(
                                  children: [
                                    CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                    CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.038).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.038).toString())),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                      CustomText.bodyLight16(text: "Harga", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                      CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    ],
                                  ),
                                  SizedBox(height: (type == 'delivery')?CustomSize.sizeHeight(context) / 100:0,),
                                  (type == 'delivery')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight16(text: "Ongkir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                      CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    ],
                                  ):SizedBox(),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                  Divider(thickness: 1,),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                      CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalAll), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
                        (chatroom != 'null')?GestureDetector(
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
                                                Navigator.pop(context);
                                                Navigator.pushReplacement(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType.rightToLeft,
                                                        child: new ChatActivity(chatroom, userName, status)));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Row(
                                                  // mainAxisAlignment: MainAxisAlignment.spaceAround ,
                                                  children: [
                                                    Icon(FontAwesome.comments_o, color: CustomColor.accent, size: 31,),
                                                    // SizedBox(width: CustomSize.sizeWidth(context) / 72,),
                                                    Stack(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 19.0),
                                                          child: CustomText.textHeading5(
                                                              text: "Chat",
                                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.06).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.06).toString()),
                                                              maxLines: 1,
                                                              color: CustomColor.accent
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
                        ):SizedBox(),
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
                                      new FlatButton(
                                        child: new Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      new FlatButton(
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
