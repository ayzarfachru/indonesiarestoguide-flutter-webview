import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/promo/add_promo.dart';
import 'package:kam5ia/ui/promo/edit_promo.dart';
import 'package:kam5ia/utils/utils.dart';
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
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }

  List<String> restoId = [];
  List<String> qty = [];
  String name = "";
  String nameResto = "";
  String phone = "";
  String address = "";
  String desc = "";
  String img = "";
  String range = "";
  String openClose = "";
  String reservationFee = "";
  bool isFav = false;
  String inCart = "";
  List<String> images = [];
  List<Promo2> promo = [];
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
  String isOpen = "";
  Future _getDetail(String id)async{
    List<String> _images = [];
    List<Promo2> _promo = [];
    List<Menu> _menu = [];
    List<MenuJson> _menuJson = [];
    List<CategoryMenu> _categoryMenu = [];
    List<String> _facility = [];
    List<String> _cuisine = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
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
        _cateMenu = [];
        for(var a in v['menu']){
          Menu m = Menu(
              id: a['id'],
              name: a['name'],
              desc: a['desc'],
              is_available: v['is_available'],
              // is_available: '0',
              price: Price.menu(a['price'], int.parse(a['delivery_price']), a['discounted']??null, int.parse(a['delivery_price'])??null, a['discounted_delivery']??null),
              urlImg: a['img'], delivery_price: null, restoName: '', qty: '', is_recommended: '', distance: null, restoId: '', type: ''
          );
          _cateMenu.add(m);
        }
        CategoryMenu cm = CategoryMenu(
            name: v['name'],
            menu: _cateMenu
        );
        _categoryMenu.add(cm);
      }
      // print(_categoryMenu);
    }

    for(var v in data['data']['recom']){
      Menu m = Menu(
          id: v['id'],
          restoId: v['restaurants_id'].toString(),
          name: v['name'],
          desc: v['desc'],
          is_available: v['is_available'],
          // is_available: '0',
          price: Price.menu(v['price'], int.parse(v['delivery_price']), v['discounted']??null, int.parse(v['delivery_price'])??null, v['discounted_delivery']??null),
          urlImg: v['img'], is_recommended: '', distance: null, type: '', delivery_price: null, qty: '', restoName: ''
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
          urlImg: v['img'], restoName: '', restoId: '', pricePlus: '', distance: null
      );
      _menuJson.add(m);
    }

    for(var v in data['data']['promo']??[]){
      Promo2 p = Promo2(
        word: v['word'],
        menu: Menu3(
            id: v['menu_id'],
            name: v['menu_name'],
            desc: v['menu_desc'],
            urlImg: v['menu_img'],
            is_available: v['is_available'],
            // is_available: '0',
            price: Price(original: v['menu_price']??0, discounted: v['menu_discounted']??0, delivery: null)
            , restoId: '', is_recommended: '', distance: null, type: '', delivery_price: null, qty: '', restoName: '', ex_date: v['expired_at']??''
          // price: Price(original: int.parse(v['menu_price'].toString()??0), discounted: int.parse(v['menu_discounted'].toString()??0), delivery: int.parse(v['menu_delivery_price'].toString()??0), takeaway: int.parse(v['delivery_price'].toString()??0), disctakeaway: int.parse(v['discounted_delivery'].toString()??0))
        ), discountedPrice: null, id: null,
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
      phone = data['data']['phone_number'];
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
      isOpen = data['data']['isOpen'].toString();
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
            is_available: a['menus']['is_available'],
            // is_available: '0',
            price: Price.promo(
                a['menus']['price'].toString(), a['menus']['delivery_price'].toString()),
            distance: null, is_recommended: '', restoId: '', type: '', delivery_price: null, restoName: '', qty: ''
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
      child: Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primaryLight)),
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
              child: DetailPromoResto(id)));
    }

    setState(() {
      isLoading = false;
    });
  }

  DateTime? currentBackPressTime;
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


  List<String> noted = [];
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
      noted.addAll(pref2.getStringList('note')??[]);
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
    cart = pref.getString('inCart')??'';
    checkId = pref.getString('restoIdUsr')??'';
    json2 = pref.getString("menuJson")??'';
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
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primaryLight,
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
                              onTap: () async{
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                pref.setString("homepg", "");
                                pref.setString("idresto", "");
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> DetailResto(id)));
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
                            child: MediaQuery(
                              child: CustomText.textHeading3(
                                  text: "Promo",
                                  color: CustomColor.primary,
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                  maxLines: 2
                              ),
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                            ),
                          ),
                        ],
                      ):MediaQuery(
                        child: CustomText.textHeading3(
                            text: "Promo di Restoranmu",
                            color: CustomColor.primaryLight,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                            maxLines: 1
                        ),
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                      ),
                      // (homepg != "1")?CustomText.textHeading3(
                      //     text: "di Sekitarmu",
                      //     color: CustomColor.primaryLight,
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
                                // int hargaAsli = int.parse(promoResto[index].menu!.price!.oriString!);
                                // int hargaAsliDeliv = int.parse(promoResto[index].menu!.price!.deliString!);
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
                                  if (restoId.contains(promo[index].menu!.id.toString()) == true) {
                                    noteProduct = noted[restoId.indexOf(promo[index].menu!.id.toString())].toString();
                                    getNote();
                                    setState(() {});
                                  } else {
                                    noteProduct = '';
                                    getNote2();
                                    setState(() {});
                                  }
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
                                                  // Hero(
                                                  //   tag: "smallImage",
                                                  //   child: ClipRRect(
                                                  //     borderRadius: BorderRadius.circular(16),
                                                  //     child: NetworkImage(Links.subUrl + promo[index].menu!.urlImg, ),
                                                  //   ),
                                                  // ),
                                                  Center(
                                                    child: (promo[index].menu!.is_available.toString() == '1')?(isOpen == 'false')?FullScreenWidget(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        width: CustomSize.sizeWidth(context) / 1.2,
                                                        height: CustomSize.sizeWidth(context) / 1.2,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: ColorFiltered(
                                                              colorFilter: ColorFilter.mode(
                                                                Colors.grey,
                                                                BlendMode.saturation,
                                                              ),
                                                              child: Image.network(Links.subUrl + promo[index].menu!.urlImg, fit: BoxFit.fitWidth)
                                                          ),
                                                        ),
                                                      ),
                                                    ):FullScreenWidget(
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 1.2,
                                                        height: CustomSize.sizeWidth(context) / 1.2,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: Image.network(Links.subUrl + promo[index].menu!.urlImg, fit: BoxFit.fitWidth),
                                                        ),
                                                      ),
                                                    ):FullScreenWidget(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        width: CustomSize.sizeWidth(context) / 1.2,
                                                        height: CustomSize.sizeWidth(context) / 1.2,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: ColorFiltered(
                                                              colorFilter: ColorFilter.mode(
                                                                Colors.grey,
                                                                BlendMode.saturation,
                                                              ),
                                                              child: Image.network(Links.subUrl + promo[index].menu!.urlImg, fit: BoxFit.fitWidth)
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // child: Container(
                                                    //   width: CustomSize.sizeWidth(context) / 1.2,
                                                    //   height: CustomSize.sizeWidth(context) / 1.2,
                                                    //   decoration: BoxDecoration(
                                                    //     image: DecorationImage(
                                                    //         image: NetworkImage(Links.subUrl + promo[index].menu!.urlImg),
                                                    //         fit: BoxFit.cover
                                                    //     ),
                                                    //     borderRadius: BorderRadius.circular(10),
                                                    //   ),
                                                    // ),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        MediaQuery(
                                                            child: CustomText.textHeading5(
                                                                text: promo[index].menu!.name,
                                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                                                maxLines: 2
                                                            ),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
                                                        MediaQuery(
                                                            child: CustomText.bodyRegular16(
                                                                text: promo[index].menu!.desc,
                                                                maxLines: 100,
                                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                            ),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium14(
                                                                            text: 'Harga:  ',
                                                                            maxLines: 1,
                                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                                            color: Colors.grey
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium16(
                                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.original),
                                                                            maxLines: 1,
                                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                                            decoration: TextDecoration.lineThrough
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                    SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium16(
                                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.discounted),
                                                                            maxLines: 1,
                                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                  ],
                                                                ),
                                                                (promo[index].menu!.ex_date != 'null' || promo[index].menu!.ex_date != '')?Row(
                                                                  children: [
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium14(
                                                                            text: 'Tanggal berakhir:  ',
                                                                            maxLines: 1,
                                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                                            color: Colors.grey
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium16(
                                                                          text: DateFormat('dd-MM-y').format(DateTime.parse(promo[index].menu!.ex_date)).toString(),
                                                                          maxLines: 1,
                                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                  ],
                                                                ):Container(),
                                                                (promo[index].menu!.ex_date != 'null' || promo[index].menu!.ex_date != '')?Row(
                                                                  children: [
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium14(
                                                                            text: 'Jam berakhir:  ',
                                                                            maxLines: 1,
                                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                                                            color: Colors.grey
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                    MediaQuery(
                                                                        child: CustomText.bodyMedium16(
                                                                          text: DateFormat('kk.mm').format(DateTime.parse(promo[index].menu!.ex_date)).toString(),
                                                                          maxLines: 1,
                                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                                        ),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    ),
                                                                  ],
                                                                ):Container(),
                                                                // Row(
                                                                //   children: [
                                                                //     CustomText.bodyMedium14(
                                                                //         text: 'Takeaway:  ',
                                                                //         maxLines: 1,
                                                                //         minSize: 14,
                                                                //         color: Colors.grey
                                                                //     ),
                                                                //     CustomText.bodyMedium16(
                                                                //         text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.takeaway),
                                                                //         maxLines: 1,
                                                                //         minSize: 16,
                                                                //         decoration: TextDecoration.lineThrough
                                                                //     ),
                                                                //     SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                                //     CustomText.bodyMedium16(
                                                                //         text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.disctakeaway),
                                                                //         maxLines: 1,
                                                                //         minSize: 16
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                // Row(
                                                                //   children: [
                                                                //     CustomText.bodyMedium14(
                                                                //         text: 'Delivery:  ',
                                                                //         maxLines: 1,
                                                                //         minSize: 14,
                                                                //         color: Colors.grey
                                                                //     ),
                                                                //     CustomText.bodyMedium16(
                                                                //         text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.delivery),
                                                                //         // text: '',
                                                                //         maxLines: 1,
                                                                //         minSize: 16
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                              ],
                                                            ),
                                                            (promo[index].menu!.is_available.toString() == '1')?(restoId.contains(promo[index].menu!.id.toString()) != true)?SizedBox():Row(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: ()async{
                                                                    if(int.parse(qty[restoId.indexOf(promo[index].menu!.id.toString())]) > 1){
                                                                      String s = qty[restoId.indexOf(promo[index].menu!.id.toString())];
                                                                      print(s);
                                                                      int i = int.parse(s) - 1;
                                                                      print(i);
                                                                      qty[restoId.indexOf(promo[index].menu!.id.toString())] = i.toString();
                                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                                      pref.setStringList("qty", qty);
                                                                      pref.setString("restaurantId", promo[index].menu!.restoId);

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
                                                                    child: Center(child: MediaQuery(child: CustomText.textHeading1(text: "-", color: Colors.grey, minSize: double.parse(((MediaQuery.of(context).size.width*0.08).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.08)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.08)).toString())),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    )),
                                                                  ),
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                                MediaQuery(
                                                                    child: CustomText.bodyRegular16(text: qty[restoId.indexOf(promo[index].menu!.id.toString())], minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),),
                                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                                GestureDetector(
                                                                  onTap: ()async{
                                                                    String s = qty[restoId.indexOf(promo[index].menu!.id.toString())];
                                                                    print(s);
                                                                    int i = int.parse(s) + 1;
                                                                    print(i);
                                                                    qty[restoId.indexOf(promo[index].menu!.id.toString())] = i.toString();
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
                                                                    child: Center(child: MediaQuery(child: CustomText.textHeading1(text: "+", color: Colors.grey, minSize: double.parse(((MediaQuery.of(context).size.width*0.08).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.08)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.08)).toString())),
                                                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                    )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ):Container()
                                                          ],
                                                        ),
                                                        (promo[index].menu!.is_available.toString() == '1')?(restoId.contains(promo[index].menu!.id.toString()) != true)?SizedBox():Column(
                                                          children: [
                                                            SizedBox(height: CustomSize.sizeHeight(context) / 44,),
                                                            Container(
                                                                alignment: Alignment.centerLeft,
                                                                child: MediaQuery(
                                                                    child: CustomText.bodyMedium14(text: "Catatan", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),),
                                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                )
                                                            ),
                                                            SizedBox(
                                                              height: CustomSize.sizeHeight(context) * 0.005,
                                                            ),
                                                            TextField(
                                                              controller: note,
                                                              readOnly: true,
                                                              onTap: () {
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
                                                                              child: FlatButton(
                                                                                minWidth: CustomSize.sizeWidth(context),
                                                                                color: CustomColor.primaryLight,
                                                                                textColor: Colors.white,
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                ),
                                                                                child: Text('Simpan'),
                                                                                onPressed: () async{
                                                                                  String s = noted[restoId.indexOf(promo[index].menu!.id.toString())];
                                                                                  String i = s.replaceAll(noted[restoId.indexOf(promo[index].menu!.id.toString())].split(': ')[1], (note.text != '')?note.text+'}':'kam5ia_null'+'}') ;
                                                                                  print(i);
                                                                                  noted[restoId.indexOf(promo[index].menu!.id.toString())] = i.toString();
                                                                                  // int i = int.parse(s) + 1;
                                                                                  // print(i);
                                                                                  // noted.add(note.text);
                                                                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                  pref.setStringList("note", noted);
                                                                                  pref.setString("restoNameTrans", nameResto);
                                                                                  pref.setString("restoPhoneTrans", phone);
                                                                                  noteProduct = '';
                                                                                  getNote();
                                                                                  setStateModal(() {});
                                                                                  setState(() {
                                                                                    // codeDialog = valueText;
                                                                                    Navigator.pop(context);
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      );
                                                                    });
                                                              },
                                                              keyboardType: TextInputType.text,
                                                              cursorColor: Colors.black,
                                                              style: GoogleFonts.poppins(
                                                                  textStyle:
                                                                  TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                                                              decoration: InputDecoration(
                                                                hintText: 'Untuk pesananmu',
                                                                isDense: true,
                                                                contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                                                                hintStyle: GoogleFonts.poppins(
                                                                    textStyle:
                                                                    TextStyle(fontSize: 14, color: Colors.grey)),
                                                                helperStyle: GoogleFonts.poppins(
                                                                    textStyle: TextStyle(fontSize: 14)),
                                                                // enabledBorder: OutlineInputBorder(
                                                                //   borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                                                // ),
                                                                // focusedBorder: UnderlineInputBorder(),
                                                              ),
                                                            ),
                                                            SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                                                          ],
                                                        ):Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                  (restoId.contains(promo[index].menu!.id.toString()) != true)?Center(
                                                    child: (promo[index].menu!.is_available.toString() == '1')?(isOpen != 'false')?GestureDetector(
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
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu!.id,
                                                                                    restoId: promo[index].menu!.restoId,
                                                                                    name: promo[index].menu!.name,
                                                                                    desc: promo[index].menu!.desc,
                                                                                    price: promo[index].menu!.price!.original.toString(),
                                                                                    discount: promo[index].menu!.price!.discounted.toString(),
                                                                                    pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                    urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu!.id.toString());
                                                                                  qty.add("1");
                                                                                  noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);
                                                                                  pref.setStringList("note", noted);
                                                                                  pref.setString("restoNameTrans", nameResto);
                                                                                  pref.setString("restoPhoneTrans", phone);
                                                                                  menuJson = [];
                                                                                  print('kudune '+menuJson.toString());
                                                                                  json2 = pref.getString("menuJson")??'';
                                                                                  _getData2();
                                                                                  noteProduct = '';
                                                                                  getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                              ),
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
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu!.id,
                                                                                    restoId: promo[index].menu!.restoId,
                                                                                    name: promo[index].menu!.name,
                                                                                    desc: promo[index].menu!.desc,
                                                                                    price: promo[index].menu!.price!.original.toString(),
                                                                                    discount: promo[index].menu!.price!.discounted.toString(),
                                                                                    pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                    urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu!.id.toString());
                                                                                  qty.add("1");
                                                                                  noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);
                                                                                  pref.setStringList("note", noted);
                                                                                  pref.setString("restoNameTrans", nameResto);
                                                                                  pref.setString("restoPhoneTrans", phone);
                                                                                  menuJson = [];
                                                                                  print('kudune '+menuJson.toString());
                                                                                  json2 = pref.getString("menuJson")??'';
                                                                                  _getData2();
                                                                                  noteProduct = '';
                                                                                  getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                              ),
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
                                                                                  id: promo[index].menu!.id,
                                                                                  restoId: promo[index].menu!.restoId,
                                                                                  name: promo[index].menu!.name,
                                                                                  desc: promo[index].menu!.desc,
                                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                );
                                                                                menuJson.add(m);
                                                                                // List<String> _restoId = [];
                                                                                // List<String> _qty = [];
                                                                                restoId.add(promo[index].menu!.id.toString());
                                                                                qty.add("1");
                                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                inCart = '1';

                                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                menuJson = [];
                                                                                print('kudune '+menuJson.toString());
                                                                                json2 = pref.getString("menuJson")??'';
                                                                                pref.setString('inCart', '1');
                                                                                pref.setString("menuJson", json2);
                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                pref.setStringList("restoId", restoId);
                                                                                pref.setStringList("qty", qty);
                                                                                pref.setStringList("note", noted);
                                                                                pref.setString("restoNameTrans", nameResto);
                                                                                pref.setString("restoPhoneTrans", phone);
                                                                                noteProduct = '';
                                                                                getNote();

                                                                                setStateModal(() {});
                                                                                setState(() {});
                                                                              } else {
                                                                                MenuJson m = MenuJson(
                                                                                  id: promo[index].menu!.id,
                                                                                  restoId: promo[index].menu!.restoId,
                                                                                  name: promo[index].menu!.name,
                                                                                  desc: promo[index].menu!.desc,
                                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                );
                                                                                menuJson.add(m);
                                                                                // List<String> _restoId = [];
                                                                                // List<String> _qty = [];
                                                                                restoId.add(promo[index].menu!.id.toString());
                                                                                qty.add("1");
                                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                inCart = '1';

                                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                menuJson = [];
                                                                                print('kudune '+menuJson.toString());
                                                                                json2 = pref.getString("menuJson")??'';
                                                                                pref.setString('inCart', '1');
                                                                                pref.setString("menuJson", json2);
                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                pref.setStringList("restoId", restoId);
                                                                                pref.setStringList("qty", qty);
                                                                                pref.setStringList("note", noted);
                                                                                pref.setString("restoNameTrans", nameResto);
                                                                                pref.setString("restoPhoneTrans", phone);
                                                                                noteProduct = '';
                                                                                getNote();

                                                                                setStateModal(() {});
                                                                                setState(() {});
                                                                              }
                                                                            } else {
                                                                              MenuJson m = MenuJson(
                                                                                id: promo[index].menu!.id,
                                                                                restoId: promo[index].menu!.restoId,
                                                                                name: promo[index].menu!.name,
                                                                                desc: promo[index].menu!.desc,
                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                urlImg: promo[index].menu!.urlImg, restoName: '', distance: null,
                                                                              );
                                                                              menuJson.add(m);
                                                                              // List<String> _restoId = [];
                                                                              // List<String> _qty = [];
                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                              qty.add("1");
                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                              inCart = '1';

                                                                              String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                              pref.setString('inCart', '1');
                                                                              pref.setString("menuJson", json1);
                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                              pref.setStringList("restoId", restoId);
                                                                              pref.setStringList("qty", qty);
                                                                              pref.setStringList("note", noted);
                                                                              pref.setString("restoNameTrans", nameResto);
                                                                              pref.setString("restoPhoneTrans", phone);
                                                                              menuJson = [];
                                                                              print('kudune '+menuJson.toString());
                                                                              json2 = pref.getString("menuJson")??'';
                                                                              _getData2();
                                                                              noteProduct = '';
                                                                              getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                              ),
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
                                                                  id: promo[index].menu!.id,
                                                                  restoId: promo[index].menu!.restoId,
                                                                  name: promo[index].menu!.name,
                                                                  desc: promo[index].menu!.desc,
                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                );
                                                                menuJson.add(m);
                                                                // List<String> _restoId = [];
                                                                // List<String> _qty = [];
                                                                restoId.add(promo[index].menu!.id.toString());
                                                                qty.add("1");
                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                inCart = '1';

                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                menuJson = [];
                                                                print('kudune '+menuJson.toString());
                                                                json2 = pref.getString("menuJson")??'';
                                                                pref.setString('inCart', '1');
                                                                pref.setString("menuJson", json2);
                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                pref.setStringList("restoId", restoId);
                                                                pref.setStringList("qty", qty);
                                                                pref.setStringList("note", noted);
                                                                pref.setString("restoNameTrans", nameResto);
                                                                pref.setString("restoPhoneTrans", phone);
                                                                noteProduct = '';
                                                                getNote();

                                                                setStateModal(() {});
                                                                setState(() {});
                                                              } else {
                                                                MenuJson m = MenuJson(
                                                                  id: promo[index].menu!.id,
                                                                  restoId: promo[index].menu!.restoId,
                                                                  name: promo[index].menu!.name,
                                                                  desc: promo[index].menu!.desc,
                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                );
                                                                menuJson.add(m);
                                                                // List<String> _restoId = [];
                                                                // List<String> _qty = [];
                                                                restoId.add(promo[index].menu!.id.toString());
                                                                qty.add("1");
                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                inCart = '1';

                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                menuJson = [];
                                                                print('kudune '+menuJson.toString());
                                                                json2 = pref.getString("menuJson")??'';
                                                                pref.setString('inCart', '1');
                                                                pref.setString("menuJson", json2);
                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                pref.setStringList("restoId", restoId);
                                                                pref.setStringList("qty", qty);
                                                                pref.setStringList("note", noted);
                                                                pref.setString("restoNameTrans", nameResto);
                                                                pref.setString("restoPhoneTrans", phone);
                                                                noteProduct = '';
                                                                getNote();

                                                                setStateModal(() {});
                                                                setState(() {});
                                                              }
                                                            } else {
                                                              MenuJson m = MenuJson(
                                                                id: promo[index].menu!.id,
                                                                restoId: promo[index].menu!.restoId,
                                                                name: promo[index].menu!.name,
                                                                desc: promo[index].menu!.desc,
                                                                price: promo[index].menu!.price!.original.toString(),
                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                urlImg: promo[index].menu!.urlImg, restoName: '', distance: null,
                                                              );
                                                              menuJson.add(m);
                                                              // List<String> _restoId = [];
                                                              // List<String> _qty = [];
                                                              restoId.add(promo[index].menu!.id.toString());
                                                              qty.add("1");
                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                              inCart = '1';

                                                              String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                              pref.setString('inCart', '1');
                                                              pref.setString("menuJson", json1);
                                                              pref.setString("restoIdUsr", idnyaResto);
                                                              pref.setStringList("restoId", restoId);
                                                              pref.setStringList("qty", qty);
                                                              pref.setStringList("note", noted);
                                                              pref.setString("restoNameTrans", nameResto);
                                                              pref.setString("restoPhoneTrans", phone);
                                                              menuJson = [];
                                                              print('kudune '+menuJson.toString());
                                                              json2 = pref.getString("menuJson")??'';
                                                              _getData2();
                                                              noteProduct = '';
                                                              getNote();

                                                              setStateModal(() {});
                                                              setState(() {});
                                                            }

                                                            print('ini in cart 1 '+pref.getString('inCart').toString());
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
                                                                    child: new Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  new FlatButton(
                                                                    child: new Text("Oke", style: TextStyle(color: CustomColor.primaryLight)),
                                                                    onPressed: () async{
                                                                      SharedPreferences pref = await SharedPreferences.getInstance();
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
                                                                      // json2 = pref.getString("menuJson")??';
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
                                                                                                id: promo[index].menu!.id,
                                                                                                restoId: promo[index].menu!.restoId,
                                                                                                name: promo[index].menu!.name,
                                                                                                desc: promo[index].menu!.desc,
                                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                                urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                                              qty.add("1");
                                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                              inCart = '1';

                                                                                              pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                              menuJson = [];
                                                                                              print('kudune '+menuJson.toString());
                                                                                              json2 = pref.getString("menuJson")??'';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);
                                                                                              pref.setStringList("note", noted);
                                                                                              pref.setString("restoNameTrans", nameResto);
                                                                                              pref.setString("restoPhoneTrans", phone);
                                                                                              noteProduct = '';
                                                                                              getNote();

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            } else {
                                                                                              MenuJson m = MenuJson(
                                                                                                id: promo[index].menu!.id,
                                                                                                restoId: promo[index].menu!.restoId,
                                                                                                name: promo[index].menu!.name,
                                                                                                desc: promo[index].menu!.desc,
                                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                                urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                                              qty.add("1");
                                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                              inCart = '1';

                                                                                              pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                              menuJson = [];
                                                                                              print('kudune '+menuJson.toString());
                                                                                              json2 = pref.getString("menuJson")??'';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);
                                                                                              pref.setStringList("note", noted);
                                                                                              pref.setString("restoNameTrans", nameResto);
                                                                                              pref.setString("restoPhoneTrans", phone);
                                                                                              noteProduct = '';
                                                                                              getNote();

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            }
                                                                                          } else {
                                                                                            MenuJson m = MenuJson(
                                                                                              id: promo[index].menu!.id,
                                                                                              restoId: promo[index].menu!.restoId,
                                                                                              name: promo[index].menu!.name,
                                                                                              desc: promo[index].menu!.desc,
                                                                                              price: promo[index].menu!.price!.original.toString(),
                                                                                              discount: promo[index].menu!.price!.discounted.toString(),
                                                                                              pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                              urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                            );
                                                                                            menuJson.add(m);
                                                                                            // List<String> _restoId = [];
                                                                                            // List<String> _qty = [];
                                                                                            restoId.add(promo[index].menu!.id.toString());
                                                                                            qty.add("1");
                                                                                            noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                            inCart = '1';

                                                                                            String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                            pref.setString('inCart', '1');
                                                                                            pref.setString("menuJson", json1);
                                                                                            pref.setString("restoIdUsr", idnyaResto);
                                                                                            pref.setStringList("restoId", restoId);
                                                                                            pref.setStringList("qty", qty);
                                                                                            pref.setStringList("note", noted);
                                                                                            pref.setString("restoNameTrans", nameResto);
                                                                                            pref.setString("restoPhoneTrans", phone);
                                                                                            menuJson = [];
                                                                                            print('kudune '+menuJson.toString());
                                                                                            json2 = pref.getString("menuJson")??'';
                                                                                            _getData2();
                                                                                            noteProduct = '';
                                                                                            getNote();

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
                                                                                              color: CustomColor.primaryLight,
                                                                                              shape: BoxShape.circle
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                        MediaQuery(
                                                                                            child: CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                                        ),
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
                                                                                                id: promo[index].menu!.id,
                                                                                                restoId: promo[index].menu!.restoId,
                                                                                                name: promo[index].menu!.name,
                                                                                                desc: promo[index].menu!.desc,
                                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                                urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                                              qty.add("1");
                                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                              inCart = '1';

                                                                                              pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                              menuJson = [];
                                                                                              print('kudune '+menuJson.toString());
                                                                                              json2 = pref.getString("menuJson")??'';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);
                                                                                              pref.setStringList("note", noted);
                                                                                              pref.setString("restoNameTrans", nameResto);
                                                                                              pref.setString("restoPhoneTrans", phone);
                                                                                              noteProduct = '';
                                                                                              getNote();

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            } else {
                                                                                              MenuJson m = MenuJson(
                                                                                                id: promo[index].menu!.id,
                                                                                                restoId: promo[index].menu!.restoId,
                                                                                                name: promo[index].menu!.name,
                                                                                                desc: promo[index].menu!.desc,
                                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                                urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                              );
                                                                                              menuJson.add(m);
                                                                                              // List<String> _restoId = [];
                                                                                              // List<String> _qty = [];
                                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                                              qty.add("1");
                                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                              inCart = '1';

                                                                                              pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                              menuJson = [];
                                                                                              print('kudune '+menuJson.toString());
                                                                                              json2 = pref.getString("menuJson")??'';
                                                                                              pref.setString('inCart', '1');
                                                                                              pref.setString("menuJson", json2);
                                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                                              pref.setStringList("restoId", restoId);
                                                                                              pref.setStringList("qty", qty);
                                                                                              pref.setStringList("note", noted);
                                                                                              pref.setString("restoNameTrans", nameResto);
                                                                                              pref.setString("restoPhoneTrans", phone);
                                                                                              noteProduct = '';
                                                                                              getNote();

                                                                                              setStateModal(() {});
                                                                                              setState(() {});
                                                                                            }
                                                                                          } else {
                                                                                            MenuJson m = MenuJson(
                                                                                              id: promo[index].menu!.id,
                                                                                              restoId: promo[index].menu!.restoId,
                                                                                              name: promo[index].menu!.name,
                                                                                              desc: promo[index].menu!.desc,
                                                                                              price: promo[index].menu!.price!.original.toString(),
                                                                                              discount: promo[index].menu!.price!.discounted.toString(),
                                                                                              pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                              urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                            );
                                                                                            menuJson.add(m);
                                                                                            // List<String> _restoId = [];
                                                                                            // List<String> _qty = [];
                                                                                            restoId.add(promo[index].menu!.id.toString());
                                                                                            qty.add("1");
                                                                                            noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                            inCart = '1';

                                                                                            String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                            pref.setString('inCart', '1');
                                                                                            pref.setString("menuJson", json1);
                                                                                            pref.setString("restoIdUsr", idnyaResto);
                                                                                            pref.setStringList("restoId", restoId);
                                                                                            pref.setStringList("qty", qty);
                                                                                            pref.setStringList("note", noted);
                                                                                            pref.setString("restoNameTrans", nameResto);
                                                                                            pref.setString("restoPhoneTrans", phone);
                                                                                            menuJson = [];
                                                                                            print('kudune '+menuJson.toString());
                                                                                            json2 = pref.getString("menuJson")??'';
                                                                                            _getData2();
                                                                                            noteProduct = '';
                                                                                            getNote();

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
                                                                                              color: CustomColor.primaryLight,
                                                                                              shape: BoxShape.circle
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                        MediaQuery(
                                                                                            child: CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                                        ),
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
                                                                                            id: promo[index].menu!.id,
                                                                                            restoId: promo[index].menu!.restoId,
                                                                                            name: promo[index].menu!.name,
                                                                                            desc: promo[index].menu!.desc,
                                                                                            price: promo[index].menu!.price!.original.toString(),
                                                                                            discount: promo[index].menu!.price!.discounted.toString(),
                                                                                            pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                            urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                          );
                                                                                          menuJson.add(m);
                                                                                          // List<String> _restoId = [];
                                                                                          // List<String> _qty = [];
                                                                                          restoId.add(promo[index].menu!.id.toString());
                                                                                          qty.add("1");
                                                                                          noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                          inCart = '1';

                                                                                          pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                          menuJson = [];
                                                                                          print('kudune '+menuJson.toString());
                                                                                          json2 = pref.getString("menuJson")??'';
                                                                                          pref.setString('inCart', '1');
                                                                                          pref.setString("menuJson", json2);
                                                                                          pref.setString("restoIdUsr", idnyaResto);
                                                                                          pref.setStringList("restoId", restoId);
                                                                                          pref.setStringList("qty", qty);
                                                                                          pref.setStringList("note", noted);
                                                                                          pref.setString("restoNameTrans", nameResto);
                                                                                          pref.setString("restoPhoneTrans", phone);
                                                                                          noteProduct = '';
                                                                                          getNote();

                                                                                          setStateModal(() {});
                                                                                          setState(() {});
                                                                                        } else {
                                                                                          MenuJson m = MenuJson(
                                                                                            id: promo[index].menu!.id,
                                                                                            restoId: promo[index].menu!.restoId,
                                                                                            name: promo[index].menu!.name,
                                                                                            desc: promo[index].menu!.desc,
                                                                                            price: promo[index].menu!.price!.original.toString(),
                                                                                            discount: promo[index].menu!.price!.discounted.toString(),
                                                                                            pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                            urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                          );
                                                                                          menuJson.add(m);
                                                                                          // List<String> _restoId = [];
                                                                                          // List<String> _qty = [];
                                                                                          restoId.add(promo[index].menu!.id.toString());
                                                                                          qty.add("1");
                                                                                          noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                          inCart = '1';

                                                                                          pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                          menuJson = [];
                                                                                          print('kudune '+menuJson.toString());
                                                                                          json2 = pref.getString("menuJson")??'';
                                                                                          pref.setString('inCart', '1');
                                                                                          pref.setString("menuJson", json2);
                                                                                          pref.setString("restoIdUsr", idnyaResto);
                                                                                          pref.setStringList("restoId", restoId);
                                                                                          pref.setStringList("qty", qty);
                                                                                          pref.setStringList("note", noted);
                                                                                          pref.setString("restoNameTrans", nameResto);
                                                                                          pref.setString("restoPhoneTrans", phone);
                                                                                          noteProduct = '';
                                                                                          getNote();

                                                                                          setStateModal(() {});
                                                                                          setState(() {});
                                                                                        }
                                                                                      } else {
                                                                                        MenuJson m = MenuJson(
                                                                                          id: promo[index].menu!.id,
                                                                                          restoId: promo[index].menu!.restoId,
                                                                                          name: promo[index].menu!.name,
                                                                                          desc: promo[index].menu!.desc,
                                                                                          price: promo[index].menu!.price!.original.toString(),
                                                                                          discount: promo[index].menu!.price!.discounted.toString(),
                                                                                          pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                          urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                        );
                                                                                        menuJson.add(m);
                                                                                        // List<String> _restoId = [];
                                                                                        // List<String> _qty = [];
                                                                                        restoId.add(promo[index].menu!.id.toString());
                                                                                        qty.add("1");
                                                                                        noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                        inCart = '1';

                                                                                        String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                        pref.setString('inCart', '1');
                                                                                        pref.setString("menuJson", json1);
                                                                                        pref.setString("restoIdUsr", idnyaResto);
                                                                                        pref.setStringList("restoId", restoId);
                                                                                        pref.setStringList("qty", qty);
                                                                                        pref.setStringList("note", noted);
                                                                                        pref.setString("restoNameTrans", nameResto);
                                                                                        pref.setString("restoPhoneTrans", phone);
                                                                                        menuJson = [];
                                                                                        print('kudune '+menuJson.toString());
                                                                                        json2 = pref.getString("menuJson")??'';
                                                                                        _getData2();
                                                                                        noteProduct = '';
                                                                                        getNote();

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
                                                                                              color: CustomColor.primaryLight,
                                                                                              shape: BoxShape.circle
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                                        MediaQuery(child: CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                                        ),
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
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu!.id,
                                                                                    restoId: promo[index].menu!.restoId,
                                                                                    name: promo[index].menu!.name,
                                                                                    desc: promo[index].menu!.desc,
                                                                                    price: promo[index].menu!.price!.original.toString(),
                                                                                    discount: promo[index].menu!.price!.discounted.toString(),
                                                                                    pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                    urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu!.id.toString());
                                                                                  qty.add("1");
                                                                                  noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  menuJson = [];
                                                                                  print('kudune '+menuJson.toString());
                                                                                  json2 = pref.getString("menuJson")??'';
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);
                                                                                  pref.setStringList("note", noted);
                                                                                  pref.setString("restoNameTrans", nameResto);
                                                                                  pref.setString("restoPhoneTrans", phone);
                                                                                  menuJson = [];
                                                                                  print('kudune '+menuJson.toString());
                                                                                  json2 = pref.getString("menuJson")??'';
                                                                                  _getData2();
                                                                                  noteProduct = '';
                                                                                  getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                              ),
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
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  } else {
                                                                                    MenuJson m = MenuJson(
                                                                                      id: promo[index].menu!.id,
                                                                                      restoId: promo[index].menu!.restoId,
                                                                                      name: promo[index].menu!.name,
                                                                                      desc: promo[index].menu!.desc,
                                                                                      price: promo[index].menu!.price!.original.toString(),
                                                                                      discount: promo[index].menu!.price!.discounted.toString(),
                                                                                      pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                      urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                    );
                                                                                    menuJson.add(m);
                                                                                    // List<String> _restoId = [];
                                                                                    // List<String> _qty = [];
                                                                                    restoId.add(promo[index].menu!.id.toString());
                                                                                    qty.add("1");
                                                                                    noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                    inCart = '1';

                                                                                    pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                    menuJson = [];
                                                                                    print('kudune '+menuJson.toString());
                                                                                    json2 = pref.getString("menuJson")??'';
                                                                                    pref.setString('inCart', '1');
                                                                                    pref.setString("menuJson", json2);
                                                                                    pref.setString("restoIdUsr", idnyaResto);
                                                                                    pref.setStringList("restoId", restoId);
                                                                                    pref.setStringList("qty", qty);
                                                                                    pref.setStringList("note", noted);
                                                                                    pref.setString("restoNameTrans", nameResto);
                                                                                    pref.setString("restoPhoneTrans", phone);
                                                                                    noteProduct = '';
                                                                                    getNote();

                                                                                    setStateModal(() {});
                                                                                    setState(() {});
                                                                                  }
                                                                                } else {
                                                                                  MenuJson m = MenuJson(
                                                                                    id: promo[index].menu!.id,
                                                                                    restoId: promo[index].menu!.restoId,
                                                                                    name: promo[index].menu!.name,
                                                                                    desc: promo[index].menu!.desc,
                                                                                    price: promo[index].menu!.price!.original.toString(),
                                                                                    discount: promo[index].menu!.price!.discounted.toString(),
                                                                                    pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                    urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                  );
                                                                                  menuJson.add(m);
                                                                                  // List<String> _restoId = [];
                                                                                  // List<String> _qty = [];
                                                                                  restoId.add(promo[index].menu!.id.toString());
                                                                                  qty.add("1");
                                                                                  noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                  inCart = '1';

                                                                                  String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                                  pref.setString('inCart', '1');
                                                                                  pref.setString("menuJson", json1);
                                                                                  pref.setString("restoIdUsr", idnyaResto);
                                                                                  pref.setStringList("restoId", restoId);
                                                                                  pref.setStringList("qty", qty);
                                                                                  pref.setStringList("note", noted);
                                                                                  pref.setString("restoNameTrans", nameResto);
                                                                                  pref.setString("restoPhoneTrans", phone);
                                                                                  noteProduct = '';
                                                                                  menuJson = [];
                                                                                  print('kudune '+menuJson.toString());
                                                                                  json2 = pref.getString("menuJson")??'';
                                                                                  _getData2();
                                                                                  getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)),
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
                                                                                  id: promo[index].menu!.id,
                                                                                  restoId: promo[index].menu!.restoId,
                                                                                  name: promo[index].menu!.name,
                                                                                  desc: promo[index].menu!.desc,
                                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                );
                                                                                menuJson.add(m);
                                                                                // List<String> _restoId = [];
                                                                                // List<String> _qty = [];
                                                                                restoId.add(promo[index].menu!.id.toString());
                                                                                qty.add("1");
                                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                inCart = '1';

                                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                menuJson = [];
                                                                                print('kudune '+menuJson.toString());
                                                                                json2 = pref.getString("menuJson")??'';
                                                                                pref.setString('inCart', '1');
                                                                                pref.setString("menuJson", json2);
                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                pref.setStringList("restoId", restoId);
                                                                                pref.setStringList("qty", qty);
                                                                                pref.setStringList("note", noted);
                                                                                pref.setString("restoNameTrans", nameResto);
                                                                                pref.setString("restoPhoneTrans", phone);
                                                                                noteProduct = '';
                                                                                getNote();

                                                                                setStateModal(() {});
                                                                                setState(() {});
                                                                              } else {
                                                                                MenuJson m = MenuJson(
                                                                                  id: promo[index].menu!.id,
                                                                                  restoId: promo[index].menu!.restoId,
                                                                                  name: promo[index].menu!.name,
                                                                                  desc: promo[index].menu!.desc,
                                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                                );
                                                                                menuJson.add(m);
                                                                                // List<String> _restoId = [];
                                                                                // List<String> _qty = [];
                                                                                restoId.add(promo[index].menu!.id.toString());
                                                                                qty.add("1");
                                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                                inCart = '1';

                                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                                menuJson = [];
                                                                                print('kudune '+menuJson.toString());
                                                                                json2 = pref.getString("menuJson")??'';
                                                                                pref.setString('inCart', '1');
                                                                                pref.setString("menuJson", json2);
                                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                                pref.setStringList("restoId", restoId);
                                                                                pref.setStringList("qty", qty);
                                                                                pref.setStringList("note", noted);
                                                                                pref.setString("restoNameTrans", nameResto);
                                                                                pref.setString("restoPhoneTrans", phone);
                                                                                noteProduct = '';
                                                                                getNote();

                                                                                setStateModal(() {});
                                                                                setState(() {});
                                                                              }
                                                                            } else {
                                                                              MenuJson m = MenuJson(
                                                                                id: promo[index].menu!.id,
                                                                                restoId: promo[index].menu!.restoId,
                                                                                name: promo[index].menu!.name,
                                                                                desc: promo[index].menu!.desc,
                                                                                price: promo[index].menu!.price!.original.toString(),
                                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                                urlImg: promo[index].menu!.urlImg, restoName: '', distance: null,
                                                                              );
                                                                              menuJson.add(m);
                                                                              // List<String> _restoId = [];
                                                                              // List<String> _qty = [];
                                                                              restoId.add(promo[index].menu!.id.toString());
                                                                              qty.add("1");
                                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                              inCart = '1';

                                                                              String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                                              pref.setString('inCart', '1');
                                                                              pref.setString("menuJson", json1);
                                                                              pref.setString("restoIdUsr", idnyaResto);
                                                                              pref.setStringList("restoId", restoId);
                                                                              pref.setStringList("qty", qty);
                                                                              pref.setStringList("note", noted);
                                                                              pref.setString("restoNameTrans", nameResto);
                                                                              pref.setString("restoPhoneTrans", phone);
                                                                              menuJson = [];
                                                                              print('kudune '+menuJson.toString());
                                                                              json2 = pref.getString("menuJson")??'';
                                                                              _getData2();
                                                                              noteProduct = '';
                                                                              getNote();

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
                                                                                    color: CustomColor.primaryLight,
                                                                                    shape: BoxShape.circle
                                                                                ),
                                                                                child: Center(
                                                                                  child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                              MediaQuery(
                                                                                  child: CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())),
                                                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                                              ),
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
                                                                  id: promo[index].menu!.id,
                                                                  restoId: promo[index].menu!.restoId,
                                                                  name: promo[index].menu!.name,
                                                                  desc: promo[index].menu!.desc,
                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                );
                                                                menuJson.add(m);
                                                                // List<String> _restoId = [];
                                                                // List<String> _qty = [];
                                                                restoId.add(promo[index].menu!.id.toString());
                                                                qty.add("1");
                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                inCart = '1';

                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                menuJson = [];
                                                                print('kudune '+menuJson.toString());
                                                                json2 = pref.getString("menuJson")??'';
                                                                pref.setString('inCart', '1');
                                                                pref.setString("menuJson", json2);
                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                pref.setStringList("restoId", restoId);
                                                                pref.setStringList("qty", qty);
                                                                pref.setStringList("note", noted);
                                                                pref.setString("restoNameTrans", nameResto);
                                                                pref.setString("restoPhoneTrans", phone);
                                                                noteProduct = '';
                                                                getNote();

                                                                setStateModal(() {});
                                                                setState(() {});
                                                              } else {
                                                                MenuJson m = MenuJson(
                                                                  id: promo[index].menu!.id,
                                                                  restoId: promo[index].menu!.restoId,
                                                                  name: promo[index].menu!.name,
                                                                  desc: promo[index].menu!.desc,
                                                                  price: promo[index].menu!.price!.original.toString(),
                                                                  discount: promo[index].menu!.price!.discounted.toString(),
                                                                  pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                  urlImg: promo[index].menu!.urlImg, distance: null, restoName: '',
                                                                );
                                                                menuJson.add(m);
                                                                // List<String> _restoId = [];
                                                                // List<String> _qty = [];
                                                                restoId.add(promo[index].menu!.id.toString());
                                                                qty.add("1");
                                                                noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                                inCart = '1';

                                                                pref.setString("menuJson", json2.toString().split(']')[0]+', '+jsonEncode(menuJson.map((m) => m.toJson()).toList()).split('[')[1].split(']')[0]+']');
                                                                menuJson = [];
                                                                print('kudune '+menuJson.toString());
                                                                json2 = pref.getString("menuJson")??'';
                                                                pref.setString('inCart', '1');
                                                                pref.setString("menuJson", json2);
                                                                pref.setString("restoIdUsr", idnyaResto);
                                                                pref.setStringList("restoId", restoId);
                                                                pref.setStringList("qty", qty);
                                                                pref.setStringList("note", noted);
                                                                pref.setString("restoNameTrans", nameResto);
                                                                pref.setString("restoPhoneTrans", phone);
                                                                noteProduct = '';
                                                                getNote();

                                                                setStateModal(() {});
                                                                setState(() {});
                                                              }
                                                            } else {
                                                              MenuJson m = MenuJson(
                                                                id: promo[index].menu!.id,
                                                                restoId: promo[index].menu!.restoId,
                                                                name: promo[index].menu!.name,
                                                                desc: promo[index].menu!.desc,
                                                                price: promo[index].menu!.price!.original.toString(),
                                                                discount: promo[index].menu!.price!.discounted.toString(),
                                                                pricePlus: promo[index].menu!.price!.delivery.toString(),
                                                                urlImg: promo[index].menu!.urlImg, restoName: '', distance: null,
                                                              );
                                                              menuJson.add(m);
                                                              // List<String> _restoId = [];
                                                              // List<String> _qty = [];
                                                              restoId.add(promo[index].menu!.id.toString());
                                                              qty.add("1");
                                                              noted.add("{${promo[index].menu!.name}: kam5ia_null}");
                                                              inCart = '1';

                                                              String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                              pref.setString('inCart', '1');
                                                              pref.setString("menuJson", json1);
                                                              pref.setString("restoIdUsr", idnyaResto);
                                                              pref.setStringList("restoId", restoId);
                                                              pref.setStringList("qty", qty);
                                                              pref.setStringList("note", noted);
                                                              pref.setString("restoNameTrans", nameResto);
                                                              pref.setString("restoPhoneTrans", phone);
                                                              menuJson = [];
                                                              print('kudune '+menuJson.toString());
                                                              json2 = pref.getString("menuJson")??'';
                                                              _getData2();
                                                              noteProduct = '';
                                                              getNote();

                                                              setStateModal(() {});
                                                              setState(() {});
                                                            }

                                                            print('ini in cart 1 '+pref.getString('inCart').toString());
                                                          }
                                                        }
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        pref.setString("alamateResto", address);

                                                        // print('ini in cart 3 '+pref.getString('menuJson'));
                                                        setState(() {});
                                                        setStateModal(() {});
                                                        SharedPreferences pref2 = await SharedPreferences.getInstance();
                                                        pref2.setString('latResto1', pref2.getString('latResto')??'');
                                                        pref2.setString('longResto1', pref2.getString('longResto')??'');
                                                      },
                                                      child: Container(
                                                          width: CustomSize.sizeWidth(context) / 1.1,
                                                          height: CustomSize.sizeHeight(context) / 14,
                                                          decoration: BoxDecoration(
                                                              color: (promo[index].menu!.is_available.toString() == '1')?(isOpen != 'false')?CustomColor.primaryLight:Colors.grey:Colors.grey,
                                                              borderRadius: BorderRadius.circular(20)
                                                          ),
                                                          child: Center(child: MediaQuery(
                                                              child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                          ))
                                                              // :GestureDetector(
                                                              // onTap: ()async{
                                                              //   Fluttertoast.showToast(msg: 'Maaf toko sedang tutup');
                                                              // },
                                                              // child: Center(child: MediaQuery(
                                                              //     child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                              //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                              // )))
                                                              // :GestureDetector(
                                                              // onTap: ()async{
                                                              //   Fluttertoast.showToast(msg: 'Maaf menu sedang tidak tersedia');
                                                              // },
                                                              // child: Center(child: MediaQuery(
                                                              //     child: CustomText.bodyRegular16(text: "Menu tidak tersedia", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                              //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                              // )))
                                                      ),
                                                    )
                                                        :GestureDetector(
                                                      onTap: ()async{
                                                        Fluttertoast.showToast(msg: 'Maaf toko sedang tutup');
                                                      },
                                                          child: Container(
                                                          width: CustomSize.sizeWidth(context) / 1.1,
                                                          height: CustomSize.sizeHeight(context) / 14,
                                                          decoration: BoxDecoration(
                                                              color: (promo[index].menu!.is_available.toString() == '1')?(isOpen != 'false')?CustomColor.primaryLight:Colors.grey:Colors.grey,
                                                              borderRadius: BorderRadius.circular(20)
                                                          ),
                                                          child: Center(child: MediaQuery(
                                                              child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                          ))
                                                      // :GestureDetector(
                                                      // onTap: ()async{
                                                      //   Fluttertoast.showToast(msg: 'Maaf toko sedang tutup');
                                                      // },
                                                      // child: Center(child: MediaQuery(
                                                      //     child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                      // )))
                                                      // :GestureDetector(
                                                      // onTap: ()async{
                                                      //   Fluttertoast.showToast(msg: 'Maaf menu sedang tidak tersedia');
                                                      // },
                                                      // child: Center(child: MediaQuery(
                                                      //     child: CustomText.bodyRegular16(text: "Menu tidak tersedia", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                      // )))
                                                    ),
                                                        )
                                                    :GestureDetector(
                                                      onTap: ()async{
                                                        Fluttertoast.showToast(msg: 'Maaf menu sedang tidak tersedia');
                                                      },
                                                      child: Container(
                                                          width: CustomSize.sizeWidth(context) / 1.1,
                                                          height: CustomSize.sizeHeight(context) / 14,
                                                          decoration: BoxDecoration(
                                                              color: (promo[index].menu!.is_available.toString() == '1')?(isOpen != 'false')?CustomColor.primaryLight:Colors.grey:Colors.grey,
                                                              borderRadius: BorderRadius.circular(20)
                                                          ),
                                                          child: Center(child: MediaQuery(
                                                              child: CustomText.bodyRegular16(text: "Menu tidak tersedia", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                          ))
                                                        // :GestureDetector(
                                                        // onTap: ()async{
                                                        //   Fluttertoast.showToast(msg: 'Maaf toko sedang tutup');
                                                        // },
                                                        // child: Center(child: MediaQuery(
                                                        //     child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                        //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                        // )))
                                                        // :GestureDetector(
                                                        // onTap: ()async{
                                                        //   Fluttertoast.showToast(msg: 'Maaf menu sedang tidak tersedia');
                                                        // },
                                                        // child: Center(child: MediaQuery(
                                                        //     child: CustomText.bodyRegular16(text: "Menu tidak tersedia", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                        //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0)
                                                        // )))
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
                                      (promo[index].menu!.is_available != '0')?(isOpen == 'false')?Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeWidth(context) / 2.6,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              colorFilter: ColorFilter.mode(
                                                Colors.grey,
                                                BlendMode.saturation,
                                              ),
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + promo[index].menu!.urlImg):NetworkImage(Links.subUrl + promoResto[index].menu!.urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ):Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeWidth(context) / 2.6,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + promo[index].menu!.urlImg):NetworkImage(Links.subUrl + promoResto[index].menu!.urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ):Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeWidth(context) / 2.6,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              colorFilter: ColorFilter.mode(
                                                Colors.grey,
                                                BlendMode.saturation,
                                              ),
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + promo[index].menu!.urlImg):NetworkImage(Links.subUrl + promoResto[index].menu!.urlImg),
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
                                                //   // text: promo[index].menu!.distance.toString().split('.')[0]+' , '+promo[index].menu!.distance.toString().split('')[0]+promo[index].menu!.distance.toString().split('.')[1].split('')[1]+" km",
                                                //     text: promo[index].menu!.distance.toString().split('.')[0]+" km",
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
                                                        child: Icon(Icons.edit, color: CustomColor.primaryLight,)
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                                    // GestureDetector(
                                                    //     onTap: (){
                                                    //       showAlertDialog(promoResto[index].id.toString());
                                                    //     },
                                                    //     child: Icon(Icons.delete, color: CustomColor.primaryLight,)
                                                    // ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                                  ],
                                                )
                                              ],
                                            ),
                                            (homepg != '1')?Container():CustomText.bodyLight12(
                                                text: 'Jam : '+promoResto[index].expired_at!.split(' ')[1].split(':')[0]+':'+promoResto[index].expired_at!.split(' ')[1].split(':')[1],
                                                maxLines: 1,
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00626,),
                                            (homepg != "1")?CustomText.textHeading4(
                                                text: promo[index].menu!.name,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                maxLines: 2
                                            ):CustomText.textHeading4(
                                                text: promoResto[index].menu!.name,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                maxLines: 2
                                            ),
                                            // CustomText.bodyMedium12(text: promo[index].menu!.restoName, minSize: 12),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00126,),
                                            (homepg != "1")?CustomText.bodyMedium12(
                                                text: promo[index].menu!.desc,
                                                maxLines: 1,
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                            ):CustomText.bodyMedium12(
                                                text: promoResto[index].word,
                                                maxLines: 1,
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.015,),
                                            CustomText.bodyLight12(
                                                text: promo[index].word,
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                maxLines: 2
                                            ),
                                            (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 50,):SizedBox(height: CustomSize.sizeHeight(context) / 108,),
                                            Row(
                                              children: [
                                                (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.original), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                    decoration: TextDecoration.lineThrough)
                                                    :Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Harga menu : ', minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        (promoResto[index].discountedPrice != null || promoResto[index].potongan != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), color: CustomColor.redBtn,
                                                            decoration: TextDecoration.lineThrough)
                                                            :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        CustomText.bodyRegular12(text: 'Delivery : ', minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                        (promoResto[index].ongkir != null)?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.deliString!)), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), color: CustomColor.redBtn,
                                                            decoration: TextDecoration.lineThrough)
                                                            :CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.deliString!)), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                (homepg == "1")?Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.discounted), minSize: 12)
                                                    //     :
                                                    CustomText.bodyRegular12(text:
                                                    (promoResto[index].discountedPrice != null)?
                                                    NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu!.price!.oriString!)-(int.parse(promoResto[index].menu!.price!.oriString!)*promoResto[index].discountedPrice!/100)))
                                                        :(promoResto[index].potongan != null)?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(promoResto[index].menu!.price!.oriString!)-promoResto[index].potongan!)
                                                        :'', minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),

                                                    // (homepg != "1")?CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.discounted), minSize: 12)
                                                    //     :
                                                    CustomText.bodyRegular12(text:
                                                    (promoResto[index].menu!.price!.deliString! != null)?
                                                    (promoResto[index].ongkir != null)?
                                                    NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((int.parse(promoResto[index].menu!.price!.deliString!)-promoResto[index].ongkir!))
                                                        :'' :'', minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                                  ],
                                                ):CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu!.price!.discounted), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
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
                  color: CustomColor.primaryLight,
                  shape: BoxShape.circle
              ),
              child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
            ),
          )
      ),
    );
  }
}
