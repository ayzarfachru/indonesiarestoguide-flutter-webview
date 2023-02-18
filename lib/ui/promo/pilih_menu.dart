import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/ui/promo/add_promo.dart';
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
        Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
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
              is_available: a['is_available'].toString(),
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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/menu'), headers: {
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
          is_available: v['is_available'].toString(),
          // is_available: '0',
          is_recommended: v['is_recommended'].toString(),
          price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
          delivery_price: Price(original: int.parse(v['price'].toString()), delivery: null, discounted: null), restoId: '', distance: null, restoName: '', qty: ''
      );
      _menu.add(p);
    }
    setState(() {
      menu = _menu;
      idMenu = (pref.getString('idMenu') != '')?json.decode(pref.getString('idMenu').toString()):[];
      nameMenu = (pref.getString('nameMenu') != '')?json.decode(pref.getString('nameMenu').toString().replaceAll('[', '["').replaceAll(']', '"]').replaceAll(', ', '", "')):[];
      isLoading = false;
    });
  }

  List idMenu = [];
  List nameMenu = [];

  bool tunggu = false;
  Future<void> selectAll()async{
    List<Menu> _menu = [];

    setState(() {
      tunggu = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/menu'), headers: {
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
          is_recommended: v['is_recommended'].toString(),
          is_available: v['is_available'].toString(),
          price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
          delivery_price: Price(original: int.parse(v['price'].toString()), delivery: null, discounted: null), restoId: '', distance: null, restoName: '', qty: ''
      );
      idMenu.add(v['id']);
      nameMenu.add(v['name']);
      pref.setString("idMenu", idMenu.toString());
      pref.setString("nameMenu", nameMenu.toString());
      setState((){});
      print(idMenu);
      print(nameMenu);
      _menu.add(p);
    }
    setState(() {
      // menu = _menu;
      print('idMenu 1');
      print(pref.getString('nameMenu').toString());
      idMenu = (pref.getString('idMenu') != '')?json.decode(pref.getString('idMenu').toString()):[];
      nameMenu = (pref.getString('nameMenu') != '')?json.decode(pref.getString('nameMenu').toString().replaceAll('[', '["').replaceAll(']', '"]').replaceAll(', ', '", "')):[];
      print(idMenu);
      print(nameMenu);
      Fluttertoast.showToast(msg: 'Semua menu telah dipilih!');
      tunggu = false;
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
        TextButton(
          child: Text("Batal", style: TextStyle(color: CustomColor.primary),),
          onPressed: () async{
            setState(() {});
            Navigator.of(context).pop();
          },
          // => Navigator.of(context).pop(),
        ),
        TextButton(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              if (tunggu != true) {
                                selectAll();
                              } else {
                                Fluttertoast.showToast(msg: 'Sedang memilih semua menu!');
                              }
                              // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditViewResto(idResto, name, img, address, phone, desc, lat, long, facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, email, badanU, pemilikU, penanggungJwb, nameRekening, nameBank, nomorRekening, img2, img3)));
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
                                    text: "Pilih Semua",
                                    color: CustomColor.accent,
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                ),
                              ),
                            ),
                          ),
                        )
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
                                // String idMenu = '';
                                // String nameMenu = '';
                                // idMenu = menu[index].id.toString();
                                // nameMenu = menu[index].name;
                                // SharedPreferences pref = await SharedPreferences.getInstance();
                                // pref.setString("idMenu", idMenu);
                                // pref.setString("nameMenu", nameMenu);
                                // Navigator.pushReplacement(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: AddPromo()));
                                if (idMenu.contains(menu[index].id)) {
                                  idMenu.remove(menu[index].id);
                                  nameMenu.remove(menu[index].name.toString());
                                  setState((){});
                                  print(idMenu);
                                  print(nameMenu);
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  pref.setString("idMenu", idMenu.toString());
                                  pref.setString("nameMenu", nameMenu.toString());
                                } else {
                                  idMenu.add(menu[index].id);
                                  nameMenu.add(menu[index].name.toString());
                                  setState((){});
                                  print(idMenu);
                                  print(nameMenu);
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  pref.setString("idMenu", idMenu.toString());
                                  pref.setString("nameMenu", nameMenu.toString());
                                }
                              },
                              child: (idMenu.contains(menu[index].id))?Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
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
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                              CustomText.textHeading4(
                                                  text: menu[index].name,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                  maxLines: 1
                                              ),
                                              CustomText.bodyMedium12(
                                                  text: menu[index].desc,
                                                  maxLines: 3,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
                                              (menu[index].is_recommended != '0')?CustomText.bodyMedium12(
                                                  text: (menu[index].is_recommended == '1')?'Recommended':'',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                  color: CustomColor.accent
                                              ):CustomText.bodyMedium12(
                                                  text: '',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                  color: CustomColor.accent
                                              ),
                                              // SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                              Row(
                                                children: [
                                                  CustomText.bodyRegular12(text: 'Harga: '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(top: 10, right: 5),
                                      child: Icon(Icons.check_circle_outline, color: CustomColor.accent, size: 25,)
                                  ),
                                ],
                              ):Container(
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
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.textHeading4(
                                              text: menu[index].name,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                              maxLines: 1
                                          ),
                                          CustomText.bodyMedium12(
                                              text: menu[index].desc,
                                              maxLines: 3,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
                                          (menu[index].is_recommended != '0')?CustomText.bodyMedium12(
                                              text: (menu[index].is_recommended == '1')?'Recommended':'',
                                              maxLines: 1,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                              color: CustomColor.accent
                                          ):CustomText.bodyMedium12(
                                              text: '',
                                              maxLines: 1,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                              color: CustomColor.accent
                                          ),
                                          // SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                          Row(
                                            children: [
                                              CustomText.bodyRegular12(text: 'Harga: '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original), minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
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
                    SizedBox(height: CustomSize.sizeHeight(context) / 8,)
                  ],
                ),
              ),
            ),
          ),
        floatingActionButton:
        (idMenu.toString() == '[]')?Container():GestureDetector(
          onTap: () async{
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: AddPromo()));
            // setState(() {
            //   isLoading = false;
            // });
            // if (tipeMenu.text != '' && descPromo.text != '' && percentPromo.text != '' && _dateController.text != '' && _Jam.text != '') {
            //   AddPromo().whenComplete((){
            //     _getKaryawan();
            //     Navigator.pop(context);
            //     Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
            //   });
            // } else {
            //   Fluttertoast.showToast(msg: 'Lengkapi data promo terlebih dahulu!');
            // }
            // SharedPreferences pref = await SharedPreferences.getInstance();
            // pref.setString("name", descPromo.text.toString());
            // pref.setString("email", endPromo.text.toString());
            // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
            // pref.setString("gender", gender);
            // pref.setString("tgl", tgl);
            // pref.setString("notelp", percentPromo.text.toString());
            // print(descPromo);
            // print(percentPromo);
            // print(endPromo);
            // print(tipeMenu);
            // print(deskMenu);
            // print(base64Encode(image.readAsBytesSync()).toString());
            // print(favorite);
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: CustomColor.accent
            ),
            child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
