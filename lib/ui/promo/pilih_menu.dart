import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/ui/promo/add_promo.dart';
import 'package:kam5ia/ui/ui_resto/menu/add_menu.dart';
import 'package:kam5ia/ui/ui_resto/menu/edit_menu.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PilihMenuActivity extends StatefulWidget {
  @override
  _PilihMenuActivityState createState() => _PilihMenuActivityState();
}

class _PilihMenuActivityState extends State<PilihMenuActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

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
              is_available: a['is_available'],
              // is_available: '0',
              price: Price.delivery(a['price'], a['delivery_price']),
              urlImg: a['img'], type: '', restoId: '', delivery_price: null, distance: null, restoName: '', qty: '', is_recommended: ''
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


  Future<void> _getMenu()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/menu', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['menu']){
      Menu p = Menu(
          id: v['id'],
          name: v['name'],
          desc: v['desc'],
          urlImg: v['img'],
          type: v['type'],
          is_available: v['is_available'],
          // is_available: '0',
          is_recommended: v['is_recommended'],
          price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
          delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', distance: null, restoName: '', qty: ''
      );
      _menu.add(p);
    }
    setState(() {
      menu = _menu;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getMenu();
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
                    child: PilihMenuActivity()));
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
    return MediaQuery(
      child: Scaffold(
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
                    Row(
                      children: [
                        GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                        ),
                        SizedBox(
                          width: CustomSize.sizeWidth(context) / 88,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: CustomText.textHeading4(
                              text: "Pilih menu",
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                              maxLines: 1
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: menu.length,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: GestureDetector(
                              onTap: () async {
                                String idMenu = '';
                                String nameMenu = '';
                                idMenu = menu[index].id.toString();
                                nameMenu = menu[index].name;
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                pref.setString("idMenu", idMenu);
                                pref.setString("nameMenu", nameMenu);
                                Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: AddPromo()));
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
                                    (menu[index].is_available != '0')?Container(
                                      width: CustomSize.sizeWidth(context) / 2.6,
                                      height: CustomSize.sizeWidth(context) / 2.6,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(Links.subUrl + menu[index].urlImg),
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
                                              image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                              fit: BoxFit.fitWidth
                                          ),
                                          borderRadius: BorderRadius.circular(20)
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
                                                  text: menu[index].type,
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.textHeading4(
                                              text: menu[index].name,
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                              maxLines: 1
                                          ),
                                          CustomText.bodyMedium12(
                                              text: menu[index].desc,
                                              maxLines: 1,
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
                                          (menu[index].is_recommended != '0')?CustomText.bodyMedium12(
                                              text: (menu[index].is_recommended == '1')?'Recommended':'',
                                              maxLines: 1,
                                              minSize: 12,
                                              color: CustomColor.accent
                                          ):CustomText.bodyMedium12(
                                              text: '',
                                              maxLines: 1,
                                              minSize: 12,
                                              color: CustomColor.accent
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                          Row(
                                            children: [
                                              CustomText.bodyRegular12(text: 'Harga: '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                            ],
                                          ),
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
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                  ],
                ),
              ),
            ),
          ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
