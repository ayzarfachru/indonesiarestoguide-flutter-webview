import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesiarestoguide/model/CategoryMenu.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/ui/cart/cart_activity.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/promo/add_promo.dart';
import 'package:indonesiarestoguide/ui/promo/edit_promo.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../model/Menu.dart';
import '../../model/Price.dart';
import '../../model/Promo.dart';


class DetailPromoResto extends StatefulWidget {
  String id;

  DetailPromoResto(this.id);

  @override
  _DetailPromoResto createState() => _DetailPromoResto(id);
}

class _DetailPromoResto extends State<DetailPromoResto> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  String id;
  _DetailPromoResto(this.id);

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

  List<String> restoId = [];
  List<String> qty = [];
  String name = "";
  String nameResto = "";
  String address = "";
  String desc = "";
  String img = "";
  String range = "";
  String openClose = "";
  String reservationFee = "";
  bool isFav = false;
  String inCart = "";
  List<String> images = [];
  List<Promo> promo = [];
  List<Menu> menu = [];
  List<MenuJson> menuJson = [];
  List<CategoryMenu> categoryMenu = [];
  String nameCategory = "";
  String cekMenu = '';
  String cart = '';
  String json2 = '';
  String can_delivery = "";
  String can_takeaway = "";
  String idnyaResto = "";
  String checkId = "";
  List<String> facility = [];
  List<String> cuisine = [];
  Future _getDetail(String id)async{
    List<String> _images = [];
    List<Promo> _promo = [];
    List<Menu> _menu = [];
    List<MenuJson> _menuJson = [];
    List<CategoryMenu> _categoryMenu = [];
    List<String> _facility = [];
    List<String> _cuisine = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/detail/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('ini loh sob '+data['data']['recom'].toString());

    for(var v in data['data']['img']){
      _images.add(v);
    }

    for(var v in data['data']['type']){
      _cuisine.add(v['name']);
    }

    for(var v in data['data']['fasilitas']){
      _facility.add(v['name']);
    }

    cekMenu = apiResult.statusCode.toString();
    // print('rekom nih '+data['data']['recom'].toString());
    if (data['data']['menu'].toString() != '[]') {
      List<Menu> _cateMenu = [];
      for(var v in data['data']['menu']){
        for(var a in v['menu']){
          Menu m = Menu(
              id: a['id'],
              name: a['name'],
              desc: a['desc'],
              price: Price.menu(a['price'], a['delivery_price'], a['discounted']??null),
              urlImg: a['img']
          );
          _cateMenu.add(m);
        }
        CategoryMenu cm = CategoryMenu(
            name: v['name'],
            menu: _cateMenu
        );
        _cateMenu = [];
        _categoryMenu.add(cm);
      }
      // print(_categoryMenu);
    }

    for(var v in data['data']['recom']){
      Menu m = Menu(
          id: v['id'],
          restoId: v['restaurants_id'],
          name: v['name'],
          desc: v['desc'],
          price: Price.menu(v['price'], v['delivery_price'], v['discounted']??null),
          urlImg: v['img']
      );
      _menu.add(m);
    }

    for(var v in data['data']['recom']){
      MenuJson m = MenuJson(
          id: v['id'],
          name: v['name'],
          desc: v['desc'],
          price: v['price'].toString(),
          discount: v['discounted_price'].toString(),
          urlImg: v['img']
      );
      _menuJson.add(m);
    }

    for(var v in data['data']['promo']??[]){
      Promo p = Promo(
        word: v['word'],
        menu: Menu(
            id: v['menu_id'],
            name: v['menu_name'],
            desc: v['menu_desc'],
            urlImg: v['menu_img'],
            price: Price(original: int.parse(v['menu_price'].toString()??0), discounted: int.parse(v['menu_discounted'].toString()??0), delivery: int.parse(v['menu_delivery_price'].toString()??0))
        ),
      );
      _promo.add(p);
    }

    SharedPreferences pref2 = await SharedPreferences.getInstance();
    pref2.setString('latResto', data['data']['lat'].toString());
    pref2.setString('longResto', data['data']['long'].toString());
    pref2.setString('can_deliveryUser', data['data']['can_delivery'].toString());
    pref2.setString('can_take_awayUser', data['data']['can_take_away'].toString());


    setState(() {
      idnyaResto = data['data']['id'].toString();
      nameResto = data['data']['name'];
      address = data['data']['address'];
      desc = data['data']['desc'];
      img = data['data']['main_img']??data['data']['img'].toString().split('[')[1].split(']')[0].split(',')[0];
      range = data['data']['range'];
      isFav = data['data']['is_followed'];
      openClose = data['data']['openclose'];
      reservationFee = data['data']['reservation_fee'].toString();
      images = _images;
      promo = _promo;
      menu = _menu;
      facility = _facility;
      // facility = _facility.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ", ");
      // print(facility);
      cuisine = _cuisine;
      // cuisine = _cuisine.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ", ");
      // print(cuisine);
      categoryMenu = _categoryMenu;
      // print('ini awal'+categoryMenu.toString());
      nameCategory = (_categoryMenu.toString() != '[]')?_categoryMenu[0].name:'';
      can_delivery = data['data']['can_delivery'].toString();
      print(can_delivery.toString());
      can_takeaway = data['data']['can_take_away'].toString();
      print(can_takeaway.toString());
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
            price: Price.promo(
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString())
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
    // Location.instance.requestPermission().then((value) {
    //   print(value);
    // });
    Future.delayed(Duration(seconds: 1)).then((_) {
      _getDetail(id);
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
              child: DetailPromoResto(id)));
    }

    setState(() {
      isLoading = false;
    });
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Press Back Again to Back');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "");
    pref.setString("idresto", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> DetailResto(id)));
    return Future.value(true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double hargaDiskon = 0;
  int hargaPotongan = 0;
  int hargaOngkir = 0;


  Future _getData()async{
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    inCart = pref2.getString('inCart')??"";
    if(checkId == idnyaResto && inCart == '1'){
      name = pref2.getString('menuJson')??"";
      print("Ini pref2 " +name+" SP");
      restoId.addAll(pref2.getStringList('restoId')??[]);
      print(restoId);
      qty.addAll(pref2.getStringList('qty')??[]);
      print(qty);
    } else if (checkId != idnyaResto && inCart == '1') {
      print(restoId.toString()+'ididi');
      print(qty);
    } else {
      pref2.remove('inCart');
      // pref2.setString("menuJson", "[]");
      pref2.remove("restoIdUsr");
      pref2.remove("restoId");
      pref2.remove("qty");
    }
    setState(() {});
  }

  Future _getData2()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    cart = pref.getString('inCart');
    checkId = pref.getString('restoIdUsr')??'';
    json2 = pref.getString("menuJson");
    setState(() {});
  }


  @override
  void initState() {
    _getDetail(id);
    _getData2();
    Future.delayed(const Duration(milliseconds: 1500), () {
      _getData();
    });
    super.initState();
    getHomePg();
    print(homepg);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          body: SafeArea(
            child: (isLoading)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator())):SmartRefresher(
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
                      (homepg != "1")?CustomText.textHeading3(
                          text: "Promo",
                          color: CustomColor.primary,
                          minSize: 18,
                          maxLines: 1
                      ):CustomText.textHeading3(
                          text: "Promo di Restoranmu",
                          color: CustomColor.primary,
                          minSize: 18,
                          maxLines: 1
                      ),
                      // (homepg != "1")?CustomText.textHeading3(
                      //     text: "di Sekitarmu",
                      //     color: CustomColor.primary,
                      //     minSize: 18,
                      //     maxLines: 1
                      // ):Container(),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: promo.length,
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
                                onTap: (){
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                      ),
                                      context: context,
                                      builder: (_){
                                        return StatefulBuilder(
                                            builder: (_, setStateModal){
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                                    child: Divider(thickness: 4,),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                                  Center(
                                                    child: Container(
                                                      width: CustomSize.sizeWidth(context) / 1.2,
                                                      height: CustomSize.sizeWidth(context) / 1.2,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: NetworkImage(Links.subUrl + promo[index].menu.urlImg),
                                                            fit: BoxFit.cover
                                                        ),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText.textHeading5(
                                                            text: promo[index].menu.name,
                                                            minSize: 18,
                                                            maxLines: 1
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                        CustomText.bodyRegular16(
                                                            text: promo[index].menu.desc,
                                                            maxLines: 100,
                                                            minSize: 16
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    CustomText.bodyMedium14(
                                                                        text: 'Normal: ',
                                                                        maxLines: 1,
                                                                        minSize: 14,
                                                                        color: Colors.grey
                                                                    ),
                                                                    CustomText.bodyMedium16(
                                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.original),
                                                                        maxLines: 1,
                                                                        minSize: 16,
                                                                        decoration: TextDecoration.lineThrough
                                                                    ),
                                                                    SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                                    CustomText.bodyMedium16(
                                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted),
                                                                        maxLines: 1,
                                                                        minSize: 16
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    CustomText.bodyMedium14(
                                                                        text: 'Delivery: ',
                                                                        maxLines: 1,
                                                                        minSize: 14,
                                                                        color: Colors.grey
                                                                    ),
                                                                    CustomText.bodyMedium16(
                                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.delivery),
                                                                        // text: '',
                                                                        maxLines: 1,
                                                                        minSize: 16
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            (restoId.contains(promo[index].menu.id.toString()) != true)?SizedBox():Row(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: ()async{
                                                                    if(int.parse(qty[restoId.indexOf(promo[index].menu.id.toString())]) > 1){
                                                                      String s = qty[restoId.indexOf(promo[index].menu.id.toString())];
                                                                      print(s);
                                                                      int i = int.parse(s) - 1;
                                                                      print(i);
                                                                      qty[restoId.indexOf(promo[index].menu.id.toString())] = i.toString();
                                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                                      pref.setStringList("qty", qty);
                                                                      pref.setString("restaurantId", promo[index].menu.restoId);

                                                                      setStateModal(() {});
                                                                      setState(() {});
                                                                    } else {
                                                                      Fluttertoast.showToast(msg: "Hapus item melalui cart");
                                                                      Navigator.pushReplacement(context, PageTransition(
                                                                          type: PageTransitionType.fade,
                                                                          child: CartActivity()));
                                                                      setState(() {});
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    width: CustomSize.sizeWidth(context) / 12,
                                                                    height: CustomSize.sizeWidth(context) / 12,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[200],
                                                                        shape: BoxShape.circle
                                                                    ),
                                                                    child: Center(child: CustomText.textHeading1(text: "-", color: Colors.grey)),
                                                                  ),
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                                CustomText.bodyRegular16(text: qty[restoId.indexOf(promo[index].menu.id.toString())]),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                                GestureDetector(
                                                                  onTap: ()async{
                                                                    String s = qty[restoId.indexOf(promo[index].menu.id.toString())];
                                                                    print(s);
                                                                    int i = int.parse(s) + 1;
                                                                    print(i);
                                                                    qty[restoId.indexOf(promo[index].menu.id.toString())] = i.toString();
                                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                                    pref.setStringList("qty", qty);
                                                                    setStateModal(() {});
                                                                    setState(() {});
                                                                  },
                                                                  child: Container(
                                                                    width: CustomSize.sizeWidth(context) / 12,
                                                                    height: CustomSize.sizeWidth(context) / 12,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[200],
                                                                        shape: BoxShape.circle
                                                                    ),
                                                                    child: Center(child: CustomText.textHeading1(text: "+", color: Colors.grey)),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                  (restoId.contains(promo[index].menu.id.toString()) != true)?Center(
                                                    child: Container(
                                                      width: CustomSize.sizeWidth(context) / 1.1,
                                                      height: CustomSize.sizeHeight(context) / 14,
                                                      decoration: BoxDecoration(
                                                          color: CustomColor.primary,
                                                          borderRadius: BorderRadius.circular(20)
                                                      ),
                                                      child: GestureDetector(
                                                          onTap: ()async{
                                                            if (checkId == '') {
                                                              if (inCart == "") {
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
                                                                                    print('ini json '+json2.toString()+ cart.toString());
                                                                                    if (cart.toString() == '1') {
                                                                                      if (json2.toString() != '[]') {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      } else {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      }
                                                                                    } else {
                                                                                      MenuJson m = MenuJson(
                                                                                        id: promo[index].menu.id,
                                                                                        restoId: promo[index].menu.restoId,
                                                                                        name: promo[index].menu.name,
                                                                                        desc: promo[index].menu.desc,
                                                                                        price: promo[index].menu.price.original.toString(),
                                                                                        discount: promo[index].menu.price.discounted.toString(),
                                                                                        pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                        urlImg: promo[index].menu.urlImg,
                                                                                      );
                                                                                      menuJson.add(m);
                                                                                      // List<String> _restoId = [];
                                                                                      // List<String> _qty = [];
                                                                                      restoId.add(promo[index].menu.id.toString());
                                                                                      qty.add("1");
                                                                                      inCart = '1';

                                                                                      String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                      pref.setString('inCart', '1');
                                                                                      pref.setString("menuJson", json1);
                                                                                      pref.setString("restoIdUsr", idnyaResto);
                                                                                      pref.setStringList("restoId", restoId);
                                                                                      pref.setStringList("qty", qty);

                                                                                      setStateModal(() {});
                                                                                      setState(() {});
                                                                                    }

                                                                                    pref.setString("metodeBeli", '1');
                                                                                  } else {
                                                                                    Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                                                  }
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Pesan Antar",),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                            GestureDetector(
                                                                              onTap: ()async{
                                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                setState(() {
                                                                                  if (can_takeaway == 'true') {
                                                                                    print('ini json '+json2.toString()+ cart.toString());
                                                                                    if (cart.toString() == '1') {
                                                                                      if (json2.toString() != '[]') {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      } else {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      }
                                                                                    } else {
                                                                                      MenuJson m = MenuJson(
                                                                                        id: promo[index].menu.id,
                                                                                        restoId: promo[index].menu.restoId,
                                                                                        name: promo[index].menu.name,
                                                                                        desc: promo[index].menu.desc,
                                                                                        price: promo[index].menu.price.original.toString(),
                                                                                        discount: promo[index].menu.price.discounted.toString(),
                                                                                        pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                        urlImg: promo[index].menu.urlImg,
                                                                                      );
                                                                                      menuJson.add(m);
                                                                                      // List<String> _restoId = [];
                                                                                      // List<String> _qty = [];
                                                                                      restoId.add(promo[index].menu.id.toString());
                                                                                      qty.add("1");
                                                                                      inCart = '1';

                                                                                      String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                      pref.setString('inCart', '1');
                                                                                      pref.setString("menuJson", json1);
                                                                                      pref.setString("restoIdUsr", idnyaResto);
                                                                                      pref.setStringList("restoId", restoId);
                                                                                      pref.setStringList("qty", qty);

                                                                                      setStateModal(() {});
                                                                                      setState(() {});
                                                                                    }

                                                                                    pref.setString("metodeBeli", '2');
                                                                                  } else {
                                                                                    Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                                                  }
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Ambil Langsung",),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                            GestureDetector(
                                                                              onTap: ()async{
                                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                print('ini json '+json2.toString()+ cart.toString());
                                                                                if (cart.toString() == '1') {
                                                                                  if (json2.toString() != '[]') {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu.id,
                                                                                      restoId: promo[index].menu.restoId,
                                                                                      name: promo[index].menu.name,
                                                                                      desc: promo[index].menu.desc,
                                                                                      price: promo[index].menu.price.original.toString(),
                                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                      urlImg: promo[index].menu.urlImg,
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu.id.toString());
                                                                                    qty.add("1");
                                                                                    inCart = '1';

                                                                                    json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu.id,
                                                                                      restoId: promo[index].menu.restoId,
                                                                                      name: promo[index].menu.name,
                                                                                      desc: promo[index].menu.desc,
                                                                                      price: promo[index].menu.price.original.toString(),
                                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                      urlImg: promo[index].menu.urlImg,
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu.id.toString());
                                                                                    qty.add("1");
                                                                                    inCart = '1';

                                                                                    json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu.id,
                                                                                    restoId: promo[index].menu.restoId,
                                                                                    name: promo[index].menu.name,
                                                                                    desc: promo[index].menu.desc,
                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                  qty.add("1");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);

                                                                                  setStateModal(() {});
                                                                                  setState(() {});
                                                                                }

                                                                                setState(() {
                                                                                  pref.setString("metodeBeli", '3');
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Makan Ditempat",),
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
                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                print('ini json '+json2.toString()+ cart.toString());
                                                                if (cart.toString() == '1') {
                                                                  if (json2.toString() != '[]') {
                                                                    MenuJson m = MenuJson(
                                                                      id: promo[index].menu.id,
                                                                      restoId: promo[index].menu.restoId,
                                                                      name: promo[index].menu.name,
                                                                      desc: promo[index].menu.desc,
                                                                      price: promo[index].menu.price.original.toString(),
                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                      urlImg: promo[index].menu.urlImg,
                                                                    );
                                                                    menuJson.add(m);
                                                                    // List<String> _restoId = [];
                                                                    // List<String> _qty = [];
                                                                    restoId.add(promo[index].menu.id.toString());
                                                                    qty.add("1");
                                                                    inCart = '1';

                                                                    json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                    pref.setString('inCart', '1');
                                                                    pref.setString("menuJson", json2);
                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                    pref.setStringList("restoId", restoId);
                                                                    pref.setStringList("qty", qty);

                                                                    setStateModal(() {});
                                                                    setState(() {});
                                                                  } else {
                                                                    MenuJson m = MenuJson(
                                                                      id: promo[index].menu.id,
                                                                      restoId: promo[index].menu.restoId,
                                                                      name: promo[index].menu.name,
                                                                      desc: promo[index].menu.desc,
                                                                      price: promo[index].menu.price.original.toString(),
                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                      urlImg: promo[index].menu.urlImg,
                                                                    );
                                                                    menuJson.add(m);
                                                                    // List<String> _restoId = [];
                                                                    // List<String> _qty = [];
                                                                    restoId.add(promo[index].menu.id.toString());
                                                                    qty.add("1");
                                                                    inCart = '1';

                                                                    json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                    pref.setString('inCart', '1');
                                                                    pref.setString("menuJson", json2);
                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                    pref.setStringList("restoId", restoId);
                                                                    pref.setStringList("qty", qty);

                                                                    setStateModal(() {});
                                                                    setState(() {});
                                                                  }
                                                                } else {
                                                                  MenuJson m = MenuJson(
                                                                    id: promo[index].menu.id,
                                                                    restoId: promo[index].menu.restoId,
                                                                    name: promo[index].menu.name,
                                                                    desc: promo[index].menu.desc,
                                                                    price: promo[index].menu.price.original.toString(),
                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                    urlImg: promo[index].menu.urlImg,
                                                                  );
                                                                  menuJson.add(m);
                                                                  // List<String> _restoId = [];
                                                                  // List<String> _qty = [];
                                                                  restoId.add(promo[index].menu.id.toString());
                                                                  qty.add("1");
                                                                  inCart = '1';

                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                  pref.setString('inCart', '1');
                                                                  pref.setString("menuJson", json1);
                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                  pref.setStringList("restoId", restoId);
                                                                  pref.setStringList("qty", qty);

                                                                  setStateModal(() {});
                                                                  setState(() {});
                                                                }

                                                                print('ini in cart 1 '+pref.getString('inCart'));
                                                              }
                                                            } else if (checkId != idnyaResto) {
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
                                                                        child: new Text("Batal", style: TextStyle(color: CustomColor.primary),),
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                      ),
                                                                      new FlatButton(
                                                                        child: new Text("Oke", style: TextStyle(color: CustomColor.primary)),
                                                                        onPressed: () async{
                                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                                          pref.setString("menuJson", "");
                                                                          pref.setString("restoId", "");
                                                                          pref.setString("qty", "");
                                                                          pref.remove('address');
                                                                          pref.remove('inCart');
                                                                          pref.remove('restoIdUsr');
                                                                          _getData2();
                                                                          _getData();
                                                                          await Future.delayed(Duration(seconds: 2));
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
                                                                                              print('ini json '+json2.toString()+ cart.toString());
                                                                                              if (cart.toString() == '1') {
                                                                                                if (json2.toString() != '[]') {
                                                                                                  MenuJson m = MenuJson(
                                                                                                    id: promo[index].menu.id,
                                                                                                    restoId: promo[index].menu.restoId,
                                                                                                    name: promo[index].menu.name,
                                                                                                    desc: promo[index].menu.desc,
                                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                                  );
                                                                                                  menuJson.add(m);
                                                                                                  // List<String> _restoId = [];
                                                                                                  // List<String> _qty = [];
                                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                                  qty.add("1");
                                                                                                  inCart = '1';

                                                                                                  json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                                  pref.setString('inCart', '1');
                                                                                                  pref.setString("menuJson", json2);
                                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                                  pref.setStringList("restoId", restoId);
                                                                                                  pref.setStringList("qty", qty);

                                                                                                  setStateModal(() {});
                                                                                                  setState(() {});
                                                                                                } else {
                                                                                                  MenuJson m = MenuJson(
                                                                                                    id: promo[index].menu.id,
                                                                                                    restoId: promo[index].menu.restoId,
                                                                                                    name: promo[index].menu.name,
                                                                                                    desc: promo[index].menu.desc,
                                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                                  );
                                                                                                  menuJson.add(m);
                                                                                                  // List<String> _restoId = [];
                                                                                                  // List<String> _qty = [];
                                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                                  qty.add("1");
                                                                                                  inCart = '1';

                                                                                                  json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                                  pref.setString('inCart', '1');
                                                                                                  pref.setString("menuJson", json2);
                                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                                  pref.setStringList("restoId", restoId);
                                                                                                  pref.setStringList("qty", qty);

                                                                                                  setStateModal(() {});
                                                                                                  setState(() {});
                                                                                                }
                                                                                              } else {
                                                                                                MenuJson m = MenuJson(
                                                                                                  id: promo[index].menu.id,
                                                                                                  restoId: promo[index].menu.restoId,
                                                                                                  name: promo[index].menu.name,
                                                                                                  desc: promo[index].menu.desc,
                                                                                                  price: promo[index].menu.price.original.toString(),
                                                                                                  discount: promo[index].menu.price.discounted.toString(),
                                                                                                  pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                  urlImg: promo[index].menu.urlImg,
                                                                                                );
                                                                                                menuJson.add(m);
                                                                                                // List<String> _restoId = [];
                                                                                                // List<String> _qty = [];
                                                                                                restoId.add(promo[index].menu.id.toString());
                                                                                                qty.add("1");
                                                                                                inCart = '1';

                                                                                                String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                                pref.setString('inCart', '1');
                                                                                                pref.setString("menuJson", json1);
                                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                                pref.setStringList("restoId", restoId);
                                                                                                pref.setStringList("qty", qty);

                                                                                                setStateModal(() {});
                                                                                                setState(() {});
                                                                                              }

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
                                                                                                  color: CustomColor.primary,
                                                                                                  shape: BoxShape.circle
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                            CustomText.textHeading6(text: "Pesan Antar",),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                                      GestureDetector(
                                                                                        onTap: ()async{
                                                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                          setState(() {
                                                                                            if (can_takeaway == 'true') {
                                                                                              print('ini json '+json2.toString()+ cart.toString());
                                                                                              if (cart.toString() == '1') {
                                                                                                if (json2.toString() != '[]') {
                                                                                                  MenuJson m = MenuJson(
                                                                                                    id: promo[index].menu.id,
                                                                                                    restoId: promo[index].menu.restoId,
                                                                                                    name: promo[index].menu.name,
                                                                                                    desc: promo[index].menu.desc,
                                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                                  );
                                                                                                  menuJson.add(m);
                                                                                                  // List<String> _restoId = [];
                                                                                                  // List<String> _qty = [];
                                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                                  qty.add("1");
                                                                                                  inCart = '1';

                                                                                                  json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                                  pref.setString('inCart', '1');
                                                                                                  pref.setString("menuJson", json2);
                                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                                  pref.setStringList("restoId", restoId);
                                                                                                  pref.setStringList("qty", qty);

                                                                                                  setStateModal(() {});
                                                                                                  setState(() {});
                                                                                                } else {
                                                                                                  MenuJson m = MenuJson(
                                                                                                    id: promo[index].menu.id,
                                                                                                    restoId: promo[index].menu.restoId,
                                                                                                    name: promo[index].menu.name,
                                                                                                    desc: promo[index].menu.desc,
                                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                                  );
                                                                                                  menuJson.add(m);
                                                                                                  // List<String> _restoId = [];
                                                                                                  // List<String> _qty = [];
                                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                                  qty.add("1");
                                                                                                  inCart = '1';

                                                                                                  json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                                  pref.setString('inCart', '1');
                                                                                                  pref.setString("menuJson", json2);
                                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                                  pref.setStringList("restoId", restoId);
                                                                                                  pref.setStringList("qty", qty);

                                                                                                  setStateModal(() {});
                                                                                                  setState(() {});
                                                                                                }
                                                                                              } else {
                                                                                                MenuJson m = MenuJson(
                                                                                                  id: promo[index].menu.id,
                                                                                                  restoId: promo[index].menu.restoId,
                                                                                                  name: promo[index].menu.name,
                                                                                                  desc: promo[index].menu.desc,
                                                                                                  price: promo[index].menu.price.original.toString(),
                                                                                                  discount: promo[index].menu.price.discounted.toString(),
                                                                                                  pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                  urlImg: promo[index].menu.urlImg,
                                                                                                );
                                                                                                menuJson.add(m);
                                                                                                // List<String> _restoId = [];
                                                                                                // List<String> _qty = [];
                                                                                                restoId.add(promo[index].menu.id.toString());
                                                                                                qty.add("1");
                                                                                                inCart = '1';

                                                                                                String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                                pref.setString('inCart', '1');
                                                                                                pref.setString("menuJson", json1);
                                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                                pref.setStringList("restoId", restoId);
                                                                                                pref.setStringList("qty", qty);

                                                                                                setStateModal(() {});
                                                                                                setState(() {});
                                                                                              }

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
                                                                                                  color: CustomColor.primary,
                                                                                                  shape: BoxShape.circle
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                            CustomText.textHeading6(text: "Ambil Langsung",),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                                      GestureDetector(
                                                                                        onTap: ()async{
                                                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                          print('ini json '+json2.toString()+ cart.toString());
                                                                                          if (cart.toString() == '1') {
                                                                                            if (json2.toString() != '[]') {
                                                                                              MenuJson m = MenuJson(
                                                                                                id: promo[index].menu.id,
                                                                                                restoId: promo[index].menu.restoId,
                                                                                                name: promo[index].menu.name,
                                                                                                desc: promo[index].menu.desc,
                                                                                                price: promo[index].menu.price.original.toString(),
                                                                                                discount: promo[index].menu.price.discounted.toString(),
                                                                                                pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                urlImg: promo[index].menu.urlImg,
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu.id.toString());
                                                                                              qty.add("1");
                                                                                              inCart = '1';

                                                                                              json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            } else {
                                                                                              MenuJson m = MenuJson(
                                                                                                id: promo[index].menu.id,
                                                                                                restoId: promo[index].menu.restoId,
                                                                                                name: promo[index].menu.name,
                                                                                                desc: promo[index].menu.desc,
                                                                                                price: promo[index].menu.price.original.toString(),
                                                                                                discount: promo[index].menu.price.discounted.toString(),
                                                                                                pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                                urlImg: promo[index].menu.urlImg,
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu.id.toString());
                                                                                              qty.add("1");
                                                                                              inCart = '1';

                                                                                              json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            }
                                                                                          } else {
                                                                                            MenuJson m = MenuJson(
                                                                                              id: promo[index].menu.id,
                                                                                              restoId: promo[index].menu.restoId,
                                                                                              name: promo[index].menu.name,
                                                                                              desc: promo[index].menu.desc,
                                                                                              price: promo[index].menu.price.original.toString(),
                                                                                              discount: promo[index].menu.price.discounted.toString(),
                                                                                              pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                              urlImg: promo[index].menu.urlImg,
                                                                                            );
                                                                                            menuJson.add(m);
                                                                                            // List<String> _restoId = [];
                                                                                            // List<String> _qty = [];
                                                                                            restoId.add(promo[index].menu.id.toString());
                                                                                            qty.add("1");
                                                                                            inCart = '1';

                                                                                            String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                            pref.setString('inCart', '1');
                                                                                            pref.setString("menuJson", json1);
                                                                                            pref.setString("restoIdUsr", idnyaResto);
                                                                                            pref.setStringList("restoId", restoId);
                                                                                            pref.setStringList("qty", qty);

                                                                                            setStateModal(() {});
                                                                                            setState(() {});
                                                                                          }

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
                                                                                                  color: CustomColor.primary,
                                                                                                  shape: BoxShape.circle
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                            CustomText.textHeading6(text: "Makan Ditempat",),
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
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            } else if (checkId == idnyaResto) {
                                                              if (inCart == "") {
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
                                                                                    print('ini json '+json2.toString()+ cart.toString());
                                                                                    if (cart.toString() == '1') {
                                                                                      if (json2.toString() != '[]') {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      } else {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      }
                                                                                    } else {
                                                                                      MenuJson m = MenuJson(
                                                                                        id: promo[index].menu.id,
                                                                                        restoId: promo[index].menu.restoId,
                                                                                        name: promo[index].menu.name,
                                                                                        desc: promo[index].menu.desc,
                                                                                        price: promo[index].menu.price.original.toString(),
                                                                                        discount: promo[index].menu.price.discounted.toString(),
                                                                                        pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                        urlImg: promo[index].menu.urlImg,
                                                                                      );
                                                                                      menuJson.add(m);
                                                                                      // List<String> _restoId = [];
                                                                                      // List<String> _qty = [];
                                                                                      restoId.add(promo[index].menu.id.toString());
                                                                                      qty.add("1");
                                                                                      inCart = '1';

                                                                                      String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                      pref.setString('inCart', '1');
                                                                                      pref.setString("menuJson", json1);
                                                                                      pref.setString("restoIdUsr", idnyaResto);
                                                                                      pref.setStringList("restoId", restoId);
                                                                                      pref.setStringList("qty", qty);

                                                                                      setStateModal(() {});
                                                                                      setState(() {});
                                                                                    }

                                                                                    pref.setString("metodeBeli", '1');
                                                                                  } else {
                                                                                    Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                                                  }
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Pesan Antar",),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                            GestureDetector(
                                                                              onTap: ()async{
                                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                setState(() {
                                                                                  if (can_takeaway == 'true') {
                                                                                    print('ini json '+json2.toString()+ cart.toString());
                                                                                    if (cart.toString() == '1') {
                                                                                      if (json2.toString() != '[]') {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      } else {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu.id,
                                                                                          restoId: promo[index].menu.restoId,
                                                                                          name: promo[index].menu.name,
                                                                                          desc: promo[index].menu.desc,
                                                                                          price: promo[index].menu.price.original.toString(),
                                                                                          discount: promo[index].menu.price.discounted.toString(),
                                                                                          pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                          urlImg: promo[index].menu.urlImg,
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu.id.toString());
                                                                                        qty.add("1");
                                                                                        inCart = '1';

                                                                                        json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json2);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);

                                                                                        setStateModal(() {});
                                                                                        setState(() {});
                                                                                      }
                                                                                    } else {
                                                                                      MenuJson m = MenuJson(
                                                                                        id: promo[index].menu.id,
                                                                                        restoId: promo[index].menu.restoId,
                                                                                        name: promo[index].menu.name,
                                                                                        desc: promo[index].menu.desc,
                                                                                        price: promo[index].menu.price.original.toString(),
                                                                                        discount: promo[index].menu.price.discounted.toString(),
                                                                                        pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                        urlImg: promo[index].menu.urlImg,
                                                                                      );
                                                                                      menuJson.add(m);
                                                                                      // List<String> _restoId = [];
                                                                                      // List<String> _qty = [];
                                                                                      restoId.add(promo[index].menu.id.toString());
                                                                                      qty.add("1");
                                                                                      inCart = '1';

                                                                                      String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                      pref.setString('inCart', '1');
                                                                                      pref.setString("menuJson", json1);
                                                                                      pref.setString("restoIdUsr", idnyaResto);
                                                                                      pref.setStringList("restoId", restoId);
                                                                                      pref.setStringList("qty", qty);

                                                                                      setStateModal(() {});
                                                                                      setState(() {});
                                                                                    }

                                                                                    pref.setString("metodeBeli", '2');
                                                                                  } else {
                                                                                    Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                                                  }
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Ambil Langsung",),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                                            GestureDetector(
                                                                              onTap: ()async{
                                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                print('ini json '+json2.toString()+ cart.toString());
                                                                                if (cart.toString() == '1') {
                                                                                  if (json2.toString() != '[]') {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu.id,
                                                                                      restoId: promo[index].menu.restoId,
                                                                                      name: promo[index].menu.name,
                                                                                      desc: promo[index].menu.desc,
                                                                                      price: promo[index].menu.price.original.toString(),
                                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                      urlImg: promo[index].menu.urlImg,
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu.id.toString());
                                                                                    qty.add("1");
                                                                                    inCart = '1';

                                                                                    json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu.id,
                                                                                      restoId: promo[index].menu.restoId,
                                                                                      name: promo[index].menu.name,
                                                                                      desc: promo[index].menu.desc,
                                                                                      price: promo[index].menu.price.original.toString(),
                                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                      urlImg: promo[index].menu.urlImg,
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu.id.toString());
                                                                                    qty.add("1");
                                                                                    inCart = '1';

                                                                                    json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu.id,
                                                                                    restoId: promo[index].menu.restoId,
                                                                                    name: promo[index].menu.name,
                                                                                    desc: promo[index].menu.desc,
                                                                                    price: promo[index].menu.price.original.toString(),
                                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                                    urlImg: promo[index].menu.urlImg,
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu.id.toString());
                                                                                  qty.add("1");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);

                                                                                  setStateModal(() {});
                                                                                  setState(() {});
                                                                                }

                                                                                setState(() {
                                                                                  pref.setString("metodeBeli", '3');
                                                                                });
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: CustomSize.sizeWidth(context) / 8,
                                                                                    height: CustomSize.sizeWidth(context) / 8,
                                                                                    decoration: BoxDecoration(
                                                                                        color: CustomColor.primary,
                                                                                        shape: BoxShape.circle
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                  CustomText.textHeading6(text: "Makan Ditempat",),
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
                                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                                print('ini json '+json2.toString()+ cart.toString());
                                                                if (cart.toString() == '1') {
                                                                  if (json2.toString() != '[]') {
                                                                    MenuJson m = MenuJson(
                                                                      id: promo[index].menu.id,
                                                                      restoId: promo[index].menu.restoId,
                                                                      name: promo[index].menu.name,
                                                                      desc: promo[index].menu.desc,
                                                                      price: promo[index].menu.price.original.toString(),
                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                      urlImg: promo[index].menu.urlImg,
                                                                    );
                                                                    menuJson.add(m);
                                                                    // List<String> _restoId = [];
                                                                    // List<String> _qty = [];
                                                                    restoId.add(promo[index].menu.id.toString());
                                                                    qty.add("1");
                                                                    inCart = '1';

                                                                    json2 = json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                    pref.setString('inCart', '1');
                                                                    pref.setString("menuJson", json2);
                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                    pref.setStringList("restoId", restoId);
                                                                    pref.setStringList("qty", qty);

                                                                    setStateModal(() {});
                                                                    setState(() {});
                                                                  } else {
                                                                    MenuJson m = MenuJson(
                                                                      id: promo[index].menu.id,
                                                                      restoId: promo[index].menu.restoId,
                                                                      name: promo[index].menu.name,
                                                                      desc: promo[index].menu.desc,
                                                                      price: promo[index].menu.price.original.toString(),
                                                                      discount: promo[index].menu.price.discounted.toString(),
                                                                      pricePlus: promo[index].menu.price.delivery.toString(),
                                                                      urlImg: promo[index].menu.urlImg,
                                                                    );
                                                                    menuJson.add(m);
                                                                    // List<String> _restoId = [];
                                                                    // List<String> _qty = [];
                                                                    restoId.add(promo[index].menu.id.toString());
                                                                    qty.add("1");
                                                                    inCart = '1';

                                                                    json2 = json2.toString().split(']')[0]+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']';
                                                                    pref.setString('inCart', '1');
                                                                    pref.setString("menuJson", json2);
                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                    pref.setStringList("restoId", restoId);
                                                                    pref.setStringList("qty", qty);

                                                                    setStateModal(() {});
                                                                    setState(() {});
                                                                  }
                                                                } else {
                                                                  MenuJson m = MenuJson(
                                                                    id: promo[index].menu.id,
                                                                    restoId: promo[index].menu.restoId,
                                                                    name: promo[index].menu.name,
                                                                    desc: promo[index].menu.desc,
                                                                    price: promo[index].menu.price.original.toString(),
                                                                    discount: promo[index].menu.price.discounted.toString(),
                                                                    pricePlus: promo[index].menu.price.delivery.toString(),
                                                                    urlImg: promo[index].menu.urlImg,
                                                                  );
                                                                  menuJson.add(m);
                                                                  // List<String> _restoId = [];
                                                                  // List<String> _qty = [];
                                                                  restoId.add(promo[index].menu.id.toString());
                                                                  qty.add("1");
                                                                  inCart = '1';

                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                  pref.setString('inCart', '1');
                                                                  pref.setString("menuJson", json1);
                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                  pref.setStringList("restoId", restoId);
                                                                  pref.setStringList("qty", qty);

                                                                  setStateModal(() {});
                                                                  setState(() {});
                                                                }

                                                                print('ini in cart 1 '+pref.getString('inCart'));
                                                              }
                                                            }
                                                            SharedPreferences pref = await SharedPreferences.getInstance();
                                                            print('Ini menujson'+pref.getString("menuJson"));

                                                            // print('ini in cart 3 '+pref.getString('menuJson'));
                                                            setState(() {});
                                                          },
                                                          child: Center(child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white))
                                                      ),
                                                    ),
                                                  )
                                                      :SizedBox(),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                  );
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
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + promo[index].menu.urlImg):NetworkImage(Links.subUrl + promoResto[index].menu.urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      SizedBox(
                                        width: CustomSize.sizeWidth(context) / 32,
                                      ),
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 2.1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // (homepg != '1')?CustomText.bodyLight12(
                                                //   // text: promo[index].menu.distance.toString().split('.')[0]+' , '+promo[index].menu.distance.toString().split('')[0]+promo[index].menu.distance.toString().split('.')[1].split('')[1]+" km",
                                                //     text: promo[index].menu.distance.toString().split('.')[0]+" km",
                                                //     maxLines: 1,
                                                //     minSize: 12
                                                // ):CustomText.bodyLight12(
                                                //     text: 'Sampai : '+promoResto[index].expired_at.split(' ')[0],
                                                //     maxLines: 1,
                                                //     minSize: 12
                                                // ),
                                                (homepg != "1")?Container():Row(
                                                  children: [
                                                    GestureDetector(
                                                        onTap: (){
                                                          Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type: PageTransitionType.rightToLeft,
                                                                  child: EditPromo(promoResto[index])));
                                                        },
                                                        child: Icon(Icons.edit, color: CustomColor.primary,)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                                    GestureDetector(
                                                        onTap: (){
                                                          showAlertDialog(promoResto[index].id.toString());
                                                        },
                                                        child: Icon(Icons.delete, color: CustomColor.primary,)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                                  ],
                                                )
                                              ],
                                            ),
                                            (homepg != '1')?Container():CustomText.bodyLight12(
                                                text: 'Jam : '+promoResto[index].expired_at.split(' ')[1].split(':')[0]+':'+promoResto[index].expired_at.split(' ')[1].split(':')[1],
                                                maxLines: 1,
                                                minSize: 12
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00626,),
                                            (homepg != "1")?CustomText.textHeading4(
                                                text: promo[index].menu.name,
                                                minSize: 18,
                                                maxLines: 1
                                            ):CustomText.textHeading4(
                                                text: promoResto[index].menu.name,
                                                minSize: 18,
                                                maxLines: 1
                                            ),
                                            // CustomText.bodyMedium12(text: promo[index].menu.restoName, minSize: 12),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00126,),
                                            (homepg != "1")?CustomText.bodyMedium12(
                                                text: promo[index].menu.desc,
                                                maxLines: 1,
                                                minSize: 12
                                            ):CustomText.bodyMedium12(
                                                text: promoResto[index].word,
                                                maxLines: 1,
                                                minSize: 12
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.015,),
                                            CustomText.bodyLight12(
                                                text: promo[index].word,
                                                minSize: 12,
                                                maxLines: 2
                                            ),
                                            (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 50,):SizedBox(height: CustomSize.sizeHeight(context) / 108,),
                                            Row(
                                              children: [
                                                (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.original), minSize: 12,
                                                    decoration: TextDecoration.lineThrough)
                                                    :Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Harga menu : ', minSize: 12),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        (promoResto[index].discountedPrice != null || promoResto[index].potongan != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.oriString)), minSize: 12, color: CustomColor.redBtn,
                                                            decoration: TextDecoration.lineThrough)
                                                            :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.oriString)), minSize: 12,),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Delivery : ', minSize: 12),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        (promoResto[index].ongkir != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.deliString)), minSize: 12, color: CustomColor.redBtn,
                                                            decoration: TextDecoration.lineThrough)
                                                            :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.deliString)), minSize: 12,),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                (homepg == "1")?Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12)
                                                    //     :
                                                    CustomText.bodyRegular12(text:
                                                    (promoResto[index].discountedPrice != null)?
                                                    NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu.price.oriString)-(int.parse(promoResto[index].menu.price.oriString)*promoResto[index].discountedPrice/100)))
                                                        :(promoResto[index].potongan != null)?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu.price.oriString)-promoResto[index].potongan)
                                                        :'', minSize: 12),

                                                    // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12)
                                                    //     :
                                                    CustomText.bodyRegular12(text:
                                                    (promoResto[index].menu.price.deliString != null)?
                                                    (promoResto[index].ongkir != null)?
                                                    NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu.price.deliString)-promoResto[index].ongkir))
                                                        :'' :'', minSize: 12),
                                                  ],
                                                ):CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.discounted), minSize: 12),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 8,)
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
    );
  }
}
