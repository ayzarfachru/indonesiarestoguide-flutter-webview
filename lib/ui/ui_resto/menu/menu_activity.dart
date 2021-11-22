import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/ui/ui_resto/menu/add_menu.dart';
import 'package:kam5ia/ui/ui_resto/menu/edit_menu.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuActivity extends StatefulWidget {
  @override
  _MenuActivityState createState() => _MenuActivityState();
}

class _MenuActivityState extends State<MenuActivity> {
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
              price: Price.delivery(a['price'], a['delivery_price']),
              urlImg: a['img'], restoId: '', delivery_price: null, distance: null, type: '', qty: '', is_recommended: '', restoName: ''
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


  bool kosong = false;
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
            is_recommended: v['is_recommended'],
            price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
            delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
        );
      _menu.add(p);
    }
    setState(() {
      menu = _menu;
      isLoading = false;
    });
    
    if (apiResult.statusCode == 200 && menu.toString() == '[]') {
      kosong = true;
    }  
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
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary),),
      onPressed:  () {
        _delMenu(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: MediaQuery(child: Text("Hapus Menu"), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
      content: MediaQuery(child: Text("Apakah anda yakin ingin menghapus data ini?"), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
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

  Future _delMenu(String id)async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/menu/delete/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['message'].toString() == 'Success') {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: MenuActivity()));
    }

    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
              child: (kosong.toString() != 'true')?Column(
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
                            text: "Menu di Restomu",
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                      ),
                    ],
                  ),
                  (menu.toString() != '[]')?ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: menu.length,
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
                                FullScreenWidget(
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 2.6,
                                    height: CustomSize.sizeWidth(context) / 2.6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(Links.subUrl + menu[index].urlImg, fit: BoxFit.fitWidth),
                                    ),
                                  ),
                                ),
                                // Container(
                                //   width: CustomSize.sizeWidth(context) / 2.6,
                                //   height: CustomSize.sizeWidth(context) / 2.6,
                                //   decoration: BoxDecoration(
                                //     image: DecorationImage(
                                //         image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                //         fit: BoxFit.cover
                                //     ),
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                // ),
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
                                          Row(
                                            children: [
                                              GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type: PageTransitionType.rightToLeft,
                                                            child: EditMenu(menu[index])));
                                                  },
                                                  child: Icon(Icons.edit, color: Colors.grey,)
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                              GestureDetector(
                                                  onTap: (){
                                                    showAlertDialog(menu[index].id.toString());
                                                  },
                                                  child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
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
                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                                      (menu[index].is_recommended != '0')?CustomText.bodyMedium12(
                                          text: (menu[index].is_recommended == '1')?'Recommended':'',
                                        maxLines: 1,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                        color: CustomColor.accent
                                      ):CustomText.bodyMedium12(
                                          text: '',
                                          maxLines: 1,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                          color: CustomColor.accent
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                      Row(
                                        children: [
                                          CustomText.bodyRegular12(text: 'Harga: '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                        ],
                                      ),
                                      // Row(
                                      //   children: [
                                      //     CustomText.bodyRegular12(text: 'Delivery/Takeaway: '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].delivery_price.delivery), minSize: 12),
                                      //   ],
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ):Container(),
                  (menu.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container()
                ],
              ):Stack(
                children: [
                  Column(
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
                                text: "Menu di Restomu",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                maxLines: 1
                            ),
                          ),
                        ],
                      ),
                      (menu.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container()
                    ],
                  ),
                  Container(height: CustomSize.sizeHeight(context), child: Center(
                    child: CustomText.bodyRegular14(
                        text: 'Menu kosong.',
                        maxLines: 1,
                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                        color: Colors.grey
                    ),
                  ),),
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
                  color: CustomColor.primaryLight,
                  shape: BoxShape.circle
              ),
              child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
            ),
          )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
