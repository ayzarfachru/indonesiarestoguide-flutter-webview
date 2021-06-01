import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/CategoryMenu.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Promo.dart';
import 'package:indonesiarestoguide/ui/ui_resto/menu/add_menu.dart';
import 'package:indonesiarestoguide/ui/ui_resto/menu/edit_menu.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuActivity extends StatefulWidget {
  @override
  _MenuActivityState createState() => _MenuActivityState();
}

class _MenuActivityState extends State<MenuActivity> {
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  List<Menu> menu = [];
  List<MenuJson> menuJson = [];
  List<CategoryMenu> categoryMenu = [];
  Future _getDetail(String id)async {
    List<String> _images = [];
    List<Promo> _promo = [];
    List<Menu> _menu = [];
    List<MenuJson> _menuJson = [];
    List<CategoryMenu> _categoryMenu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(
        Links.mainUrl + '/resto/detail/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    for (var v in data['data']['img']) {
      _images.add(v);
    }

    List<Menu> _cateMenu = [];
    if (data['data']['menu'] != null) {
      for (var v in data['data']['menu']) {
        for (var a in v['menu']) {
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
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  showAlertDialog() {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Menu"),
      content: Text("Apakah anda ingin menghapus menu?"),
      actions: [
        FlatButton(
          child: Text("Batal", style: TextStyle(color: CustomColor.primary),),
          onPressed: () async{
            setState(() {});
            Navigator.of(context).pop();
          },
          // => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text("Oke", style: TextStyle(color: CustomColor.primary),),
          onPressed: () async{
            setState(() {});
            Navigator.of(context).pop();
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: MenuActivity()));
          },
          // => Navigator.of(context).pop(),
        )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                CustomText.textHeading3(
                  text: "Menu di Restoranmu",
                  color: CustomColor.primary,
                  minSize: 18,
                  maxLines: 1
                ),
                ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 6,
                    itemBuilder: (_, index){
                      return Padding(
                        padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
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
                                  color: Colors.amber,
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
                                        CustomText.bodyLight12(
                                            text: "Western Food",
                                          maxLines: 1,
                                            minSize: 12
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type: PageTransitionType.rightToLeft,
                                                          child: EditMenu()));
                                                },
                                                child: Icon(Icons.edit, color: CustomColor.primary,)
                                            ),
                                            SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                            GestureDetector(
                                                onTap: (){
                                                  showAlertDialog();
                                                },
                                                child: Icon(Icons.delete, color: CustomColor.primary,)
                                            ),
                                            SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    CustomText.textHeading4(
                                        text: "Burger Enak",
                                        minSize: 18,
                                        maxLines: 1
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    CustomText.bodyMedium12(
                                        text: "Ini desc",
                                      maxLines: 1,
                                      minSize: 12
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    Row(
                                      children: [
                                        CustomText.bodyRegular12(text: "IDR 15.000", minSize: 12,
                                            decoration: TextDecoration.lineThrough),
                                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                        CustomText.bodyRegular12(text: "IDR 12.000", minSize: 12),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,)
              ],
            ),
          ),
        ),
      ),
        floatingActionButton: GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: AddMenu()));
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
    );
  }
}
