import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:kam5ia/model/Category.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/ui/ui_resto/menu/sub_kategori/add_sub_kategori.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'edit_sub_kategori.dart';

class SubKategoriActivity extends StatefulWidget {
  @override
  SubKategoriActivityState createState() => SubKategoriActivityState();
}

class SubKategoriActivityState extends State<SubKategoriActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  List<Category> sub = [];
  List<MenuJson> menuJson = [];
  List<CategoryMenu> categoryMenu = [];
  // Future _getDetail(String id)async {
  //   List<String> _images = [];
  //   List<Promo> _promo = [];
  //   List<Menu> _menu = [];
  //   List<MenuJson> _menuJson = [];
  //   List<CategoryMenu> _categoryMenu = [];
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String token = pref.getString("token") ?? "";
  //   var apiResult = await http.get(
  //       Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
  //     "Accept": "Application/json",
  //     "Authorization": "Bearer $token"
  //   });
  //   // print(apiResult.body);
  //   var data = json.decode(apiResult.body);
  //   for (var v in data['data']['img']) {
  //     _images.add(v);
  //   }
  //
  //   List<Menu> _cateMenu = [];
  //   if (data['data']['sub'] != null) {
  //     for (var v in data['data']['sub']) {
  //       for (var a in v['sub']) {
  //         Menu m = Menu(
  //             id: a['id'],
  //             name: a['name'],
  //             desc: a['desc'],
  //             is_available: a['is_available'],
  //             // is_available: '0',
  //             price: Price.delivery(a['price'], a['delivery_price']),
  //             urlImg: a['img'], restoId: '', delivery_price: null, distance: null, type: '', qty: '', is_recommended: '', restoName: ''
  //         );
  //         _cateMenu.add(m);
  //       }
  //       CategoryMenu cm = CategoryMenu(
  //           name: v['name'],
  //           sub: _cateMenu
  //       );
  //       _cateMenu = [];
  //       _categoryMenu.add(cm);
  //     }
  //   }
  // }


  bool kosong = false;
  Future<void> _getMenu()async{
    List<Category> _sub = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/category'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['data']){
      Category p = Category.sub(
          id: v['id'],
          nama: v['name'],
      );
      _sub.add(p);
    }
    setState(() {
      sub = _sub;
      isLoading = false;
    });

    if (apiResult.statusCode == 200 && sub.toString() == '[]') {
      kosong = true;
    }
  }

  showAlertDialog(String id) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary),),
      onPressed:  () {
        _delMenu(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: MediaQuery(child: Text("Hapus Sub Kategori"), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
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
    var apiResult = await http.delete(Uri.parse(Links.mainUrl + '/category/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (apiResult.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: SubKategoriActivity()));
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
                              text: "Sub Kategori",
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                              maxLines: 1
                          ),
                        ),
                      ],
                    ),
                    (sub.toString() != '[]')?ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: sub.length,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: Container(
                              // width: CustomSize.sizeWidth(context),
                              // height: CustomSize.sizeWidth(context) / 6,
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
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24, vertical: CustomSize.sizeWidth(context) / 24),
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 2.1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.bodyLight12(
                                          text: sub[index].nama,
                                          maxLines: 1,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                      ),
                                      (sub[index].id! <= 7)?Container():Row(
                                        children: [
                                          GestureDetector(
                                              onTap: (){
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType.rightToLeft,
                                                        child: EditSubKategori(sub[index])));
                                              },
                                              child: Icon(Icons.edit, color: Colors.grey,)
                                          ),
                                          SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                          GestureDetector(
                                              onTap: (){
                                                showAlertDialog(sub[index].id.toString());
                                              },
                                              child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                          ),
                                          SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    ):Container(),
                    (sub.toString() != '[]')?(sub.length > 3)?SizedBox(height: CustomSize.sizeHeight(context) / 6):SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container()
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
                                  text: "Sub Kategori",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  maxLines: 1
                              ),
                            ),
                          ],
                        ),
                        (sub.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container()
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
                      child: AddSubKategoriActivity()));
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
