import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:indonesiarestoguide/model/CategoryMenu.dart';
import 'package:indonesiarestoguide/model/Cuisine.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/model/PrefCart.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Promo.dart';
import 'package:indonesiarestoguide/ui/cart/cart_activity.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/ui/reservation/reservation_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/add_resto/add_slider.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indonesiarestoguide/ui/ui_resto/edit_resto/edit_view_resto.dart';

class DetailRestoAdmin extends StatefulWidget {
  String id;

  DetailRestoAdmin(this.id);

  @override
  _DetailRestoAdminState createState() => _DetailRestoAdminState(id);
}

class _DetailRestoAdminState extends State<DetailRestoAdmin> {
  String id;

  _DetailRestoAdminState(this.id);

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  List<String> restoId = [];
  List<String> qty = [];
  String name = "";
  String phone = "";
  String address = "";
  String desc = "";
  String img = "";
  String range = "";
  String openClose = "";
  String reservationFee = "";
  String can_delivery = "";
  String can_takeaway = "";
  String lat = "";
  String long = "";
  bool isFav = false;
  String inCart = "";
  String nameCategory = "";
  String homepg = "";

  bool isSeePromo = false;
  bool isPromo = false;
  int indexPromo = 0;

  List<String> images = [];
  List<Promo> promo = [];
  List<Menu> menu = [];
  List<MenuJson> menuJson = [];
  List<CategoryMenu> categoryMenu = [];
  String facility = '';
  String cuisine = '';
  String idResto = '';
  String reservation_fee = '';
  String ongkir = '';
  Future _getDetail(String id)async{
    List<String> _images = [];
    List<Promo> _promo = [];
    List<Menu> _menu = [];
    List<MenuJson> _menuJson = [];
    List<CategoryMenu> _categoryMenu = [];
    List<String> _facility = [];
    List<String> _cuisine = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/detail/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print(data['data']['can_delivery']);
    // print(data['data']['can_take_away']);
    // print(data['data']['fasilitas']);
    // print(data['data']['type']);

    for(var v in data['data']['type']){
      _cuisine.add(v['name']);
    }

    for(var v in data['data']['fasilitas']){
      _facility.add(v['name']);
    }

    for(var v in data['data']['img']){
      _images.add(v);
    }

    print('ini data menu'+data['data']['menu'].toString());

    if (data['data']['menu'].toString() != '[]') {
      List<Menu> _cateMenu = [];
      for(var v in data['data']['menu']){
        for(var a in v['menu']){
          Menu m = Menu(
              id: a['id'],
              name: a['name'],
              desc: a['desc'],
              price: Price.delivery(a['price'], a['delivery_price']),
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
          name: v['name'],
          desc: v['desc'],
          price: Price.delivery(v['price'], v['delivery_price']),
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

    if (data['data']['promo'] != null) {
      if (homepg != "1") {
        for(var v in data['data']['promo']){
          Promo p = Promo(
            word: v['word'],
            menu: Menu(
                id: v['menu_id'],
                name: v['menu_name'],
                desc: v['menu_desc'],
                urlImg: v['menu_img'],
                price: Price.discounted(v['menu_price'], v['menu_discounted'])
            ),
          );
          _promo.add(p);
        }
      }
    }

    SharedPreferences pref2 = await SharedPreferences.getInstance();
    pref2.setString('latResto', data['data']['lat'].toString());
    pref2.setString('longResto', data['data']['long'].toString());

    setState(() {
      idResto = data['data']['id'].toString();
      name = data['data']['name'];
      phone = data['data']['phone_number'];
      address = data['data']['address'];
      desc = data['data']['desc'];
      img = data['data']['main_img'];
      reservation_fee = data['data']['reservation_fee'].toString();
      ongkir = data['data']['ongkir'].toString();
      range = data['data']['range'];
      isFav = data['data']['is_followed'];
      openClose = data['data']['openclose'];
      reservationFee = data['data']['reservation_fee'].toString();
      can_delivery = data['data']['can_delivery'].toString();
      can_takeaway = data['data']['can_take_away'].toString();
      lat = data['data']['lat'].toString();
      long = data['data']['long'].toString();
      images = _images;
      promo = _promo;
      menu = _menu;
      facility = _facility.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ",");
      print(facility);
      cuisine = _cuisine.toString().split('[')[1].split(']')[0].replaceAll(new RegExp(r",\s+"), ",");
      // print(cuisine);
      if(promo.length <= 3){
        indexPromo = promo.length;
      }else{
        indexPromo = 3;
        isPromo = true;
      }
      isLoading = false;
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + address;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _getData()async{
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    inCart = pref2.getString('inCart')??"";
    if(pref2.getString('inCart') == '1'){
      name = pref2.getString('menuJson')??"";
      print("Ini pref2 " +name+" SP");
      restoId.addAll(pref2.getStringList('restoId')??[]);
      print(restoId);
      qty.addAll(pref2.getStringList('qty')??[]);
      print(qty);
    }
    setState(() {});
  }

  Future triggerToast() async{
    Fluttertoast.showToast(
        msg: "Tekan dan tahan untuk hapus",
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

  Future _delImage(String id)async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/img/delete/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['msg'].toString() == 'Success') {
      // Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new DetailRestoAdmin(idRes.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  List<Menu> imagesSlider = [];
  Future _getImage()async{
    List<Menu> _imagesSlider = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/img', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var p in data['img']){
      Menu v = Menu(
          id: p['id'],
          urlImg: p['img']
      );
      _imagesSlider.add(v);
    }

    setState(() {
      imagesSlider = _imagesSlider;
      // print(imagesSlider);
      isLoading = false;
    });
  }

  showAlertDialog(String id) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary),),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        // Navigator.pop(context);
        _delImage(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Foto"),
      content: Text("Apakah anda yakin ingin menghapus foto ini?"),
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

  String idRes = '';

  @override
  void initState() {
    _getDetail(id);
    idRes = id;
    print(id);
    _getData();
    _getImage();
    getHomePg();
    print(homepg + ' hoi kafir');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (isLoading)?Container(
            width: CustomSize.sizeWidth(context),
            height: CustomSize.sizeHeight(context),
            child: Center(child: CircularProgressIndicator())):SingleChildScrollView(
          controller: _scrollController,
          child: Stack(
            children: [
              Container(
                height: CustomSize.sizeHeight(context) / 3.2,
                width: CustomSize.sizeWidth(context),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(Links.subUrl + img),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CustomSize.sizeHeight(context) / 3.8,),
                  Container(
                    width: CustomSize.sizeWidth(context),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 2,
                                child: CustomText.textHeading5(
                                    text: name,
                                    maxLines: 2,
                                    minSize: 24
                                ),
                              ),
                              (homepg != "1")?Icon(MaterialCommunityIcons.bookmark,
                                color: (isFav)?CustomColor.primary:CustomColor.dividerDark, size: 40,):
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditViewResto(idResto, name, img, address, phone, desc, lat, long, facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee)));
                                  });
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 3.6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: CustomColor.accent, width: 1),
                                    // color: CustomColor.accentLight
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: CustomText.textTitle8(
                                          text: "Edit Restomu",
                                          color: CustomColor.accent
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 24),
                          child: GestureDetector(
                            onTap: _launchURL,
                            child: Container(
                                width: CustomSize.sizeWidth(context),
                                child: CustomText.bodyMedium16(text: address, maxLines: 10)),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 52),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 2.2,
                                decoration: BoxDecoration(
                                  color: CustomColor.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: CustomSize.sizeWidth(context) / 48,
                                      vertical: CustomSize.sizeHeight(context) / 48
                                  ),
                                  child: Column(
                                    children: [
                                      CustomText.bodyMedium12(text: "Kisaran Harga", minSize: 12),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyRegular16(text: range, minSize: 16, color: CustomColor.primary),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: CustomSize.sizeWidth(context) / 2.2,
                                decoration: BoxDecoration(
                                  color: CustomColor.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: CustomSize.sizeWidth(context) / 48,
                                      vertical: CustomSize.sizeHeight(context) / 48
                                  ),
                                  child: Column(
                                    children: [
                                      CustomText.bodyMedium12(text: "Jam Buka & Tutup", minSize: 12),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyRegular16(text: openClose, minSize: 16, color: CustomColor.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        (homepg != "1")?Container():Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                              CustomText.textHeading4(text: "Deskripsi Resto", color: CustomColor.primary),
                            ],
                          ),
                        ),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 24,):SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 14),
                          child: CustomText.bodyMedium16(
                              text: desc,
                              minSize: 14,
                              maxLines: 100
                          ),
                        ),
                        (homepg != '1')?SizedBox(height: CustomSize.sizeHeight(context) / 24,):SizedBox(height: CustomSize.sizeHeight(context) / 94,),
                        (homepg != '1')?Container():Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 24, vertical: CustomSize.sizeHeight(context) / 84),
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new AddSlider(idResto)));
                                  print(idResto);
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: CustomColor.accent, width: 1),
                                  // color: CustomColor.accentLight
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(
                                    child: CustomText.textTitle8(
                                        text: "Tambah Foto",
                                        color: CustomColor.accent
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) * 0.004,),
                        (homepg != '1')?Container(
                          height: CustomSize.sizeWidth(context) / 2.4,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (_, index){
                                return Padding(
                                  padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) * 0.03),
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 2.4,
                                    height: CustomSize.sizeWidth(context) / 2.4,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + images[index]),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                );
                              }
                          ),
                        ):Container(
                          height: CustomSize.sizeWidth(context) / 2.4,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imagesSlider.length,
                              itemBuilder: (_, index){
                                return Padding(
                                  padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) * 0.03),
                                  child: GestureDetector(
                                    onTap: () {
                                      triggerToast();
                                    },
                                    onLongPress: () {
                                      showAlertDialog(imagesSlider[index].id.toString());
                                    },
                                    child: Container(
                                      width: CustomSize.sizeWidth(context) / 2.4,
                                      height: CustomSize.sizeWidth(context) / 2.4,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + imagesSlider[index].urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                        (homepg != "1")?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 8),
                          child: CustomText.bodyMedium16(
                              text: "Penawaran yang Tersedia",
                              color: CustomColor.primary,
                              maxLines: 1
                          ),
                        ):Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 86,):Container(),
                        (homepg != "1")?ListView.builder(
                            controller: _scrollController,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (isSeePromo)?promo.length:indexPromo,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: CustomSize.sizeWidth(context) / 16,
                                    vertical: CustomSize.sizeHeight(context) / 86
                                ),
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
                                                              CustomText.bodyMedium16(
                                                                  text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].menu.price.original),
                                                                  maxLines: 1,
                                                                  minSize: 16
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
                                                                        setStateModal(() {});
                                                                        setState(() {});
                                                                      }
                                                                    },
                                                                    child: Container(
                                                                      width: CustomSize.sizeWidth(context) / 12,
                                                                      height: CustomSize.sizeWidth(context) / 12,
                                                                      decoration: BoxDecoration(
                                                                          color: CustomColor.accentLight,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
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
                                                                          color: CustomColor.accentLight,
                                                                          shape: BoxShape.circle
                                                                      ),
                                                                      child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
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
                                                              MenuJson m = MenuJson(
                                                                id: menu[index].id,
                                                                name: menu[index].name,
                                                                desc: menu[index].desc,
                                                                price: menu[index].price.original.toString(),
                                                                discount: menu[index].price.discounted.toString(),
                                                                urlImg: menu[index].urlImg,
                                                              );
                                                              menuJson.add(m);
                                                              // List<String> _restoId = [];
                                                              // List<String> _qty = [];
                                                              restoId.add(menu[index].id.toString());
                                                              qty.add("1");
                                                              inCart = '1';

                                                              String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                                              pref.setString('inCart', '1');
                                                              pref.setString("menuJson", json1);
                                                              pref.setStringList("restoId", restoId);
                                                              pref.setStringList("qty", qty);

                                                              setStateModal(() {});
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
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Ionicons.ios_wallet, color: CustomColor.primary,),
                                      SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 1.5,
                                        child: CustomText.bodyLight14(
                                            text: promo[index].word,
                                            minSize: 14,
                                            maxLines: 2
                                        ),
                                      ),
                                      SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                      Icon(Icons.chevron_right_sharp, size: 32,),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ):Container(),
                        (homepg != "1")?(isPromo)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox():Container(),
                        (homepg != "1")?(isPromo)?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 8),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                isSeePromo = true;
                              });
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 4,
                              height: CustomSize.sizeHeight(context) / 18,
                              decoration: BoxDecoration(
                                  color: CustomColor.accentLight,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Center(child: CustomText.bodyRegular14(text: "See more", color: CustomColor.accent)),
                            ),
                          ),
                        ):SizedBox():Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 63,):Container(),
                        (homepg != "1")?Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                              CustomText.textHeading4(text: "Rekomendasi Menu", color: CustomColor.primary),
                            ],
                          ),
                        ):Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                        (homepg != "1")?ListView.builder(
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: menu.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(
                                top: CustomSize.sizeWidth(context) / 32,
                                left: CustomSize.sizeWidth(context) / 32,
                                right: CustomSize.sizeWidth(context) / 32,
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                      ),
                                      context: context,
                                      builder: (_){
                                        return StatefulBuilder(builder: (_, setStateModal){
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
                                                        image: NetworkImage(Links.subUrl + menu[index].urlImg),
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
                                                        text: menu[index].name,
                                                        minSize: 18,
                                                        maxLines: 1
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyRegular16(
                                                        text: menu[index].desc,
                                                        maxLines: 100,
                                                        minSize: 16
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        CustomText.bodyMedium16(
                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original),
                                                            maxLines: 1,
                                                            minSize: 16
                                                        ),
                                                        (restoId.contains(menu[index].id.toString()) != true)?SizedBox():Row(
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
                                                                  setStateModal(() {});
                                                                  setState(() {});
                                                                }
                                                              },
                                                              child: Container(
                                                                width: CustomSize.sizeWidth(context) / 12,
                                                                height: CustomSize.sizeWidth(context) / 12,
                                                                decoration: BoxDecoration(
                                                                    color: CustomColor.accentLight,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
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
                                                                    color: CustomColor.accentLight,
                                                                    shape: BoxShape.circle
                                                                ),
                                                                child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
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
                                              (restoId.contains(menu[index].id.toString()) != true)?Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.1,
                                                  height: CustomSize.sizeHeight(context) / 14,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primary,
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  child: GestureDetector(
                                                      onTap: ()async{
                                                        MenuJson m = MenuJson(
                                                          id: menu[index].id,
                                                          name: menu[index].name,
                                                          desc: menu[index].desc,
                                                          price: menu[index].price.original.toString(),
                                                          discount: menu[index].price.discounted.toString(),
                                                          urlImg: menu[index].urlImg,
                                                        );
                                                        menuJson.add(m);
                                                        // List<String> _restoId = [];
                                                        // List<String> _qty = [];
                                                        restoId.add(menu[index].id.toString());
                                                        qty.add("1");
                                                        inCart = '1';

                                                        String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        pref.setString('inCart', '1');
                                                        pref.setString("menuJson", json1);
                                                        pref.setStringList("restoId", restoId);
                                                        pref.setStringList("qty", qty);

                                                        setState(() {});
                                                        setStateModal(() {});
                                                      },
                                                      child: Center(child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white))
                                                  ),
                                                ),
                                              ):SizedBox(),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            ],
                                          );
                                        });
                                      }
                                  );
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 4.2,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
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
                                                    children: [
                                                      CustomText.textHeading4(
                                                          text: menu[index].name,
                                                          minSize: 18,
                                                          maxLines: 1
                                                      ),
                                                      CustomText.bodyRegular12(
                                                          text: menu[index].desc,
                                                          maxLines: 2,
                                                          minSize: 12
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText.bodyMedium16(
                                                          text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original),
                                                          maxLines: 1,
                                                          minSize: 16
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                                                      Icon(Icons.favorite, color: CustomColor.secondary, size: 36,)
                                                    ],
                                                  )
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
                                                (restoId.contains(menu[index].id.toString()) != true)?GestureDetector(
                                                  onTap: () async{
                                                    MenuJson m = MenuJson(
                                                      id: menu[index].id,
                                                      name: menu[index].name,
                                                      desc: menu[index].desc,
                                                      price: menu[index].price.original.toString(),
                                                      discount: menu[index].price.discounted.toString(),
                                                      urlImg: menu[index].urlImg,
                                                    );
                                                    menuJson.add(m);
                                                    // List<String> _restoId = [];
                                                    // List<String> _qty = [];
                                                    restoId.add(menu[index].id.toString());
                                                    qty.add("1");
                                                    inCart = '1';

                                                    String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setString('inCart', '1');
                                                    pref.setString("menuJson", json1);
                                                    pref.setStringList("restoId", restoId);
                                                    pref.setStringList("qty", qty);

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 4.6,
                                                    height: CustomSize.sizeHeight(context) / 18,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.accentLight,
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                    child: Center(child: CustomText.bodyRegular16(text: "Add", color: CustomColor.accent)),
                                                  ),
                                                ):Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: ()async{
                                                        if(int.parse(qty[restoId.indexOf(menu[index].id.toString())]) > 1){
                                                          String s = qty[restoId.indexOf(menu[index].id.toString())];
                                                          print(s);
                                                          int i = int.parse(s) - 1;
                                                          print(i);
                                                          qty[restoId.indexOf(menu[index].id.toString())] = i.toString();
                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                          pref.setStringList("qty", qty);
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 12,
                                                        height: CustomSize.sizeWidth(context) / 12,
                                                        decoration: BoxDecoration(
                                                            color: CustomColor.accentLight,
                                                            shape: BoxShape.circle
                                                        ),
                                                        child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
                                                      ),
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                    CustomText.bodyRegular16(text: qty[restoId.indexOf(menu[index].id.toString())]),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                    GestureDetector(
                                                      onTap: ()async{
                                                        String s = qty[restoId.indexOf(menu[index].id.toString())];
                                                        print(s);
                                                        int i = int.parse(s) + 1;
                                                        print(i);
                                                        qty[restoId.indexOf(menu[index].id.toString())] = i.toString();
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        pref.setStringList("qty", qty);
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 12,
                                                        height: CustomSize.sizeWidth(context) / 12,
                                                        decoration: BoxDecoration(
                                                            color: CustomColor.accentLight,
                                                            shape: BoxShape.circle
                                                        ),
                                                        child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ):Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 63,):Container(),
                        (homepg != "1")?GestureDetector(
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
                                      SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: categoryMenu.length,
                                        itemBuilder: (ctx, index){
                                          return GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                nameCategory = categoryMenu[index].name;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 32),
                                              child: Container(
                                                  width: CustomSize.sizeWidth(context),
                                                  child: CustomText.textHeading7(text: categoryMenu[index].name,)),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                    ],
                                  );
                                }
                            );
                          },
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.textHeading4(text: nameCategory, color: CustomColor.primary),
                                      Icon(FontAwesomeIcons.chevronRight, color: CustomColor.primary,)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ):Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                        (homepg != "1")?ListView.builder(
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu.length,
                          itemBuilder: (_, index){
                            print(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu.length);
                            return Padding(
                              padding: EdgeInsets.only(
                                top: CustomSize.sizeWidth(context) / 32,
                                left: CustomSize.sizeWidth(context) / 32,
                                right: CustomSize.sizeWidth(context) / 32,
                              ),
                              child: GestureDetector(
                                onTap: (){
                                  if (restoId.contains(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString()) != true)
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
                                              SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                              Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  height: CustomSize.sizeWidth(context) / 1.2,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(Links.subUrl + categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].urlImg),
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
                                                        text: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].name,
                                                        minSize: 18,
                                                        maxLines: 1
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyRegular16(
                                                        text: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].desc,
                                                        maxLines: 100,
                                                        minSize: 16
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyMedium16(
                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].price.original),
                                                        maxLines: 1,
                                                        minSize: 16
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                              Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.1,
                                                  height: CustomSize.sizeHeight(context) / 14,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primary,
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  child: GestureDetector(
                                                      onTap: (){
                                                        Navigator.pop(context);
                                                      },
                                                      child: Center(child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white))
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            ],
                                          );
                                        }
                                    );
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 3.8,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
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
                                                    children: [
                                                      CustomText.textHeading4(
                                                          text: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].name,
                                                          minSize: 18,
                                                          maxLines: 1
                                                      ),
                                                      CustomText.bodyRegular12(
                                                          text: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].desc,
                                                          maxLines: 2,
                                                          minSize: 12
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText.bodyMedium16(
                                                          text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].price.original),
                                                          maxLines: 1,
                                                          minSize: 16
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                                                      Icon(Icons.favorite, color: CustomColor.secondary, size: 36,)
                                                    ],
                                                  )
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
                                                          image: NetworkImage(Links.subUrl + categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].urlImg),
                                                          fit: BoxFit.cover
                                                      ),
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                ),
                                                (restoId.contains(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString()) != true)?GestureDetector(
                                                  onTap: () async{
                                                    MenuJson m = MenuJson(
                                                      id: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id,
                                                      name: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].name,
                                                      desc: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].desc,
                                                      price: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].price.original.toString(),
                                                      discount: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].price.discounted.toString(),
                                                      urlImg: categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].urlImg,
                                                    );
                                                    menuJson.add(m);
                                                    // List<String> _restoId = [];
                                                    // List<String> _qty = [];
                                                    restoId.add(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString());
                                                    qty.add("1");
                                                    inCart = '1';

                                                    String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setString('inCart', '1');
                                                    pref.setString("menuJson", json1);
                                                    pref.setStringList("restoId", restoId);
                                                    pref.setStringList("qty", qty);

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 4.6,
                                                    height: CustomSize.sizeHeight(context) / 18,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.accentLight,
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                    child: Center(child: CustomText.bodyRegular16(text: "Add", color: CustomColor.accent)),
                                                  ),
                                                ):Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: ()async{
                                                        if(int.parse(qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())]) > 1){
                                                          String s = qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())];
                                                          print(s);
                                                          int i = int.parse(s) - 1;
                                                          print(i);
                                                          qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())] = i.toString();
                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                          pref.setStringList("qty", qty);
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 12,
                                                        height: CustomSize.sizeWidth(context) / 12,
                                                        decoration: BoxDecoration(
                                                            color: CustomColor.accentLight,
                                                            shape: BoxShape.circle
                                                        ),
                                                        child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
                                                      ),
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                    CustomText.bodyRegular16(text: qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())]),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                    GestureDetector(
                                                      onTap: ()async{
                                                        String s = qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())];
                                                        print(s);
                                                        int i = int.parse(s) + 1;
                                                        print(i);
                                                        qty[restoId.indexOf(categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].id.toString())] = i.toString();
                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                        pref.setStringList("qty", qty);
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 12,
                                                        height: CustomSize.sizeWidth(context) / 12,
                                                        decoration: BoxDecoration(
                                                            color: CustomColor.accentLight,
                                                            shape: BoxShape.circle
                                                        ),
                                                        child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ):Container(),
                        (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 8,):Container(),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 32),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
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
                            offset: Offset(0, 7), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(child: Icon(Icons.chevron_left, size: 38,)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (homepg != "1")?(isLoading != true)?(inCart == '1')?GestureDetector(
        onTap: (){
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: CartActivity()));
        },
        child: Container(
          width: CustomSize.sizeWidth(context) / 8,
          height: CustomSize.sizeWidth(context) / 8,
          decoration: BoxDecoration(
              color: CustomColor.primary,
              shape: BoxShape.circle
          ),
          child: Center(child: Icon(CupertinoIcons.cart_fill, color: Colors.white,)),
        ),
      ):GestureDetector(
        onTap: (){
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: new ReservationActivity(id, address, reservationFee)));
        },
        child: Container(
          width: CustomSize.sizeWidth(context) / 1.1,
          height: CustomSize.sizeHeight(context) / 14,
          decoration: BoxDecoration(
              color: CustomColor.primary,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Center(child: CustomText.bodyRegular16(text: "Reservasi Sekarang", color: Colors.white)),
        ),
      ):SizedBox():Container(),
    );
  }
}
