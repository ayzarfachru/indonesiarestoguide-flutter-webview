import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/model/Cuisine.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchActivity extends StatefulWidget {
  List<Menu> promo;
  String lat;
  String long;
  String cui;

  SearchActivity(this.promo, this.lat, this.long, this.cui);

  @override
  _SearchActivityState createState() => _SearchActivityState(promo, lat, long, cui);
}

class _SearchActivityState extends State<SearchActivity> {
  List<Menu> promo;
  String lat;
  String long;
  String cui;

  _SearchActivityState(this.promo, this.lat, this.long, this.cui);

  TextEditingController _loginTextName = TextEditingController(text: "");
  ScrollController _scrollController = ScrollController();

  bool isSearch = false;
  List<String> recomMenu = ["Nasi Goreng", "Geprek", "Jus Buah", "Soto", "Es Campur"];
  String inCart = "";
  String name = "";

  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> qty = [];

  List<Menu> menu = [];
  List<Resto> resto = [];
  Future _search(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$type&lat=$lat&long=$long',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['menu']){
      Menu m = Menu(
        id: v['id'],
        name: v['name'],
        restoName: v['resto_name'],
        urlImg: v['img'],
        price: Price.discounted(v['price'], v['discounted_price']),
        distance: double.parse(v['resto_distance'].toString()),
      );
      _menu.add(m);
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: v['distance'],
          img: v['img']
      );
      _resto.add(r);
    }
    setState(() {
      menu = _menu;
      resto = _resto;
    });
  }

  List<Cuisine> cuisine = [];
  Future getUtil()async{
    List<Cuisine> _cuisine = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/util/data',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['data']){
      Cuisine c = Cuisine(
          id: v['id'],
          name: v['name']
      );
      _cuisine.add(c);
    }
    setState(() {
      cuisine = _cuisine;
    });
  }

  Future searchHome()async{
    _search('', cui);
    setState(() {
      isSearch = true;
    });
  }

  Future _getData()async{
    menuJson = [];
    restoId = [];
    qty = [];
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

  @override
  void initState() {
    if(cui != ''){
      searchHome();
    }
    _getData();
    getUtil();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                Container(
                  width: CustomSize.sizeWidth(context),
                  height: CustomSize.sizeHeight(context) / 16,
                  decoration: BoxDecoration(
                    color: CustomColor.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesome.search, size: 24, color: Colors.grey,),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        Expanded(
                          child: TextField(
                            controller: _loginTextName,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v){
                              _search(_loginTextName.text, '');
                              setState(() {
                                isSearch = true;
                              });
                            },
                            onChanged: (v){
                              print(v.length);
                              if(v.length == 0){
                                setState(() {
                                  isSearch = false;
                                });
                              }
                            },
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintText: "Apa yang kamu cari hari ini",
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (isSearch != true)?Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Paling banyak Dicari"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 18,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: recomMenu.length,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                                child: GestureDetector(
                                  onTap: (){
                                    _search(recomMenu[index], '');
                                    _loginTextName.text = recomMenu[index];
                                    setState(() {
                                      isSearch = true;
                                    });
                                  },
                                  child: Container(
                                    height: CustomSize.sizeHeight(context) / 19,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: CustomColor.accent)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                      child: Center(
                                        child: CustomText.bodyRegular14(
                                            text: recomMenu[index],
                                            color: CustomColor.accent
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Jelajahi"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 7,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: cuisine.length,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                                child: GestureDetector(
                                  onTap: (){
                                    _search('', cuisine[index].name);
                                    setState(() {
                                      isSearch = true;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 6,
                                        height: CustomSize.sizeWidth(context) / 6,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: CustomColor.secondary
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyMedium16(
                                          text: cuisine[index].name
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Rekomendasi"
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: promo.length,
                        itemBuilder: (_, index){
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
                                                          image: NetworkImage(Links.subUrl + promo[index].urlImg),
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
                                                          text: promo[index].name,
                                                          minSize: 18,
                                                          maxLines: 1
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                      CustomText.bodyRegular16(
                                                          text: promo[index].desc,
                                                          maxLines: 100,
                                                          minSize: 16
                                                      ),
                                                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText.bodyMedium16(
                                                              text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price.original),
                                                              maxLines: 1,
                                                              minSize: 16
                                                          ),
                                                          (restoId.contains(promo[index].id.toString()) != true)?SizedBox():Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: ()async{
                                                                  if(int.parse(qty[restoId.indexOf(promo[index].id.toString())]) > 1){
                                                                    String s = qty[restoId.indexOf(promo[index].id.toString())];
                                                                    print(s);
                                                                    int i = int.parse(s) - 1;
                                                                    print(i);
                                                                    qty[restoId.indexOf(promo[index].id.toString())] = i.toString();
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
                                                              CustomText.bodyRegular16(text: qty[restoId.indexOf(promo[index].id.toString())]),
                                                              SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                              GestureDetector(
                                                                onTap: ()async{
                                                                  String s = qty[restoId.indexOf(promo[index].id.toString())];
                                                                  print(s);
                                                                  int i = int.parse(s) + 1;
                                                                  print(i);
                                                                  qty[restoId.indexOf(promo[index].id.toString())] = i.toString();
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
                                                (restoId.contains(promo[index].id.toString()) != true)?Center(
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 1.1,
                                                    height: CustomSize.sizeHeight(context) / 14,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.primary,
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                    child: GestureDetector(
                                                        onTap: ()async{
                                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                                          String checkId = pref.getString('restaurantId')??'';

                                                          if(checkId == promo[index].restoId || checkId == ''){
                                                            MenuJson m = MenuJson(
                                                              id: promo[index].id,
                                                              name: promo[index].name,
                                                              desc: promo[index].desc,
                                                              price: promo[index].price.original.toString(),
                                                              discount: promo[index].price.discounted.toString(),
                                                              urlImg: promo[index].urlImg,
                                                            );
                                                            menuJson.add(m);
                                                            // List<String> _restoId = [];
                                                            // List<String> _qty = [];
                                                            restoId.add(promo[index].id.toString());
                                                            qty.add("1");
                                                            inCart = '1';

                                                            String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                            pref.setString('restaurantId', promo[index].restoId);
                                                            pref.setString('inCart', '1');
                                                            pref.setString("menuJson", json1);
                                                            pref.setStringList("restoId", restoId);
                                                            pref.setStringList("qty", qty);

                                                            setStateModal(() {});
                                                            setState(() {});
                                                          }else{
                                                            Fluttertoast.showToast(
                                                              msg: "Ada menu yang belum checkout di keranjangmu",);
                                                          }
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
                                            image: NetworkImage(Links.subUrl + promo[index].urlImg),
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
                                          CustomText.bodyLight12(
                                              text: promo[index].distance.toString() + " km",
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.textHeading4(
                                              text: promo[index].name,
                                              minSize: 18,
                                              maxLines: 1
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.bodyMedium12(
                                              text: promo[index].restoName,
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                          Row(
                                            children: [
                                              CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price.original), minSize: 12,
                                                  decoration: TextDecoration.lineThrough),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                              CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price.discounted), minSize: 12),
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
                        },
                      ),
                    ],
                  ),
                )
                    :Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isSearch = false;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.chevronLeft, size: 18,),
                          SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          CustomText.textTitle3(
                              text: "Kembali ke search",
                              maxLines: 1
                          )
                        ],
                      ),
                    ),
                    (menu.isNotEmpty)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                    (menu.isNotEmpty)?Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Menu",
                          maxLines: 1
                      ),
                    ):SizedBox(),
                    (menu.isNotEmpty)?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: menu.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.3,
                                height: CustomSize.sizeHeight(context) / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 3,
                                      height: CustomSize.sizeHeight(context) / 5,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeHeight(context) / 5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText.bodyRegular12(text: menu[index].distance.toString() + " Km", minSize: 12),
                                                CustomText.textTitle6(text: menu[index].name, minSize: 14, maxLines: 2),
                                                CustomText.bodyMedium12(text: menu[index].restoName, minSize: 12),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original), minSize: 12,
                                                    decoration: (menu[index].price.discounted != null)?TextDecoration.lineThrough:TextDecoration.none),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                (menu[index].price.discounted != null)
                                                    ?CustomText.bodyRegular12(
                                                    text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.discounted), minSize: 12):SizedBox(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ):SizedBox(),
                    (resto.isNotEmpty)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                    (resto.isNotEmpty)?Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Resto",
                          maxLines: 1
                      ),
                    ):SizedBox(),
                    (resto.isNotEmpty)?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: resto.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: DetailResto(resto[index].id.toString())));
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 2.3,
                                  height: CustomSize.sizeHeight(context) / 3.6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 5.8,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + resto[index].img),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyRegular14(text: resto[index].distance.toString() + " km"),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyMedium16(text: resto[index].name),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ):SizedBox(),
                  ],
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
