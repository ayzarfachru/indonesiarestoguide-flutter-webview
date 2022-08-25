import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/history/history_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailHistory extends StatefulWidget {
  int id;

  DetailHistory(this.id);

  @override
  _DetailHistoryState createState() => _DetailHistoryState(id);
}

class _DetailHistoryState extends State<DetailHistory> {
  int id;

  _DetailHistoryState(this.id);

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  String type = '';
  String address = '';
  int ongkir = 0;
  int harga = 0;
  int total = 0;
  int? restoId;
  String homepg = "";
  String karyawan = "";

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      karyawan = (pref.getString("karyawan")??'');
      print(homepg);
    });
  }

  List<Menu> menu = [];
  Future<void> getData()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    print(karyawan);

    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/history?id=$id'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menus'] != null) {
      for(var v in data['menus']){
        Menu m = Menu(
            id: v['menus_id'],
            qty: v['qty'].toString(),
            price: Price(original: v['price'], discounted: null, delivery: null),
            name: v['name'],
            is_available: '',
            urlImg: v['img'],
            desc: v['desc'], delivery_price: null, restoId: '', type: '', distance: null, restoName: '', is_recommended: ''
        );
        _menu.add(m);
      }
    }

    setState(() {
      menu = _menu;
      restoId = data['resto'];
      type = data['type'];
      address = data['address']??'';
      ongkir = data['ongkir']??0;
      total = data['total']??0;
      harga = (data['total']??0) - (data['ongkir']??0);
      isLoading = false;
    });
  }

  String operation ='';
  Future _deleteHistory(String operation, String id)async{
    // List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('oi2002');

    if (apiResult.statusCode == 200) {
      print('oi200');
    }

    // for(var v in data['trx']['process']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }

  @override
  void initState() {
    getHomePg();
    getData();
    // print(karyawan);
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
              SizedBox(height: CustomSize.sizeHeight(context) / 38,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Row(
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
                          text: "Detail Riwayat",
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                          maxLines: 1
                      ),
                    ),
                  ],
                ),
              ),
              (type == 'delivery' || type == 'Pesan antar')?Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                    MediaQuery(
                        child: CustomText.bodyLight12(text: "Alamat Pengiriman", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    MediaQuery(
                      child: CustomText.textHeading4(
                          text: (address != '')?address:'kosong.',
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                          maxLines: 10
                      ),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    ),
                  ],
                ),
              ):Container(),
              SizedBox(height: (type == 'delivery' || type == 'Pesan antar')?CustomSize.sizeHeight(context) / 48:0,),
              (type == 'delivery' || type == 'Pesan antar')?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 8,
                          height: CustomSize.sizeWidth(context) / 8,
                          decoration: BoxDecoration(
                              color: CustomColor.primaryLight,
                              shape: BoxShape.circle
                          ),
                          child: Center(
                            child: Icon((type == 'delivery' || type == 'Pesan antar')?FontAwesome.motorcycle:(type == 'takeaway' || type == 'Ambil Langsung')?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                          ),
                        ),
                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        MediaQuery(
                            child: CustomText.textHeading6(text: (type == 'delivery' || type == 'Pesan antar')?"Pesan Antar":(type == 'takeaway' || type == 'Ambil Langsung')?"Ambil Langsung":"Makan Ditempat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Divider(thickness: 6, color: CustomColor.secondary,),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: (menu.toString() != '[]')?menu.length:1,
                  itemBuilder: (_, index){
                    return Padding(
                      padding: EdgeInsets.only(
                        top: CustomSize.sizeWidth(context) / 32,
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                      ),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 5.8,
                        child: Column(
                          children: [
                            Container(
                              // height: CustomSize.sizeHeight(context) / 4,
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
                                            MediaQuery(
                                              child: CustomText.textHeading4(
                                                  text: (menu.toString() != '[]')?menu[index].name:'Kosong',
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                  maxLines: 1
                                              ),
                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                            ),
                                            MediaQuery(
                                              child: CustomText.bodyRegular14(
                                                  text: (menu.toString() != '[]')?menu[index].desc:'Menu tidak ditemukan.',
                                                  maxLines: 2,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                              ),
                                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                            Row(
                                              children: [
                                                // CustomText.bodyMedium14(
                                                //     text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original) ,
                                                //     maxLines: 1,
                                                //     minSize: 16
                                                // ),
                                                // CustomText.bodyLight14(
                                                //     text: "  x  ",
                                                //     maxLines: 1,
                                                //     minSize: 14
                                                // ),
                                                MediaQuery(
                                                  child: CustomText.bodyMedium14(
                                                      text: (menu.toString() != '[]')?menu[index].qty.toString()+' Items':'',
                                                      maxLines: 1,
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                                  ),
                                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                                ),
                                              ],
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
                                      FullScreenWidget(
                                        child: Container(
                                          width: CustomSize.sizeWidth(context) / 3.8,
                                          height: CustomSize.sizeWidth(context) / 3.8,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: (menu.toString() != '[]')?Image.network(Links.subUrl + menu[index].urlImg, fit: BoxFit.fitWidth):Container(color: CustomColor.primary,),
                                          ),
                                        ),
                                      ),
                                      // Container(
                                      //   width: CustomSize.sizeWidth(context) / 3.8,
                                      //   height: CustomSize.sizeWidth(context) / 3.8,
                                      //   decoration: BoxDecoration(
                                      //       image: DecorationImage(
                                      //           image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                      //           fit: BoxFit.cover
                                      //       ),
                                      //       borderRadius: BorderRadius.circular(20)
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
              Container(
                width: CustomSize.sizeWidth(context),
                decoration: BoxDecoration(
                    color: Colors.white
                ),
                child: Column(
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 85,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        height: (type != 'Pesan antar')?(type != 'Ambil Langsung')?CustomSize.sizeHeight(context) / 3.8:CustomSize.sizeHeight(context) / 3.8:CustomSize.sizeHeight(context) / 3.4,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                              MediaQuery(
                                  child: CustomText.textTitle3(text: "Rincian Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MediaQuery(
                                      child: CustomText.bodyLight16(text: "Harga", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                  MediaQuery(
                                      child: CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: (type == 'Pesan antar')?CustomSize.sizeHeight(context) / 100:0,),
                              (type == 'Pesan antar')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MediaQuery(
                                      child: CustomText.bodyLight16(text: "Ongkir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                  MediaQuery(
                                      child: CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ],
                              ):SizedBox(),
                              SizedBox(height: CustomSize.sizeHeight(context) / 100),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MediaQuery(
                                    child: CustomText.bodyLight16(text: "Platform Fee", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                  MediaQuery(
                                    child: CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(1000), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ],
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                              Divider(thickness: 1,),
                              SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MediaQuery(
                                      child: CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                  MediaQuery(
                                      child: CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((type != 'Pesan antar')?(type != 'Ambil Langsung')?total:(total+1000):(total+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                    (homepg != "1")?Center(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: new DetailResto(restoId.toString())));
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
                              child: MediaQuery(
                                  child: CustomText.textTitle2(text: "Pesan Lagi", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ):Container(),
                    (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 88,):Container(),
                    (homepg != "1")?Center(
                      child: GestureDetector(
                        onTap: (){
                          // Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: new DetailResto(restoId.toString())));
                          _deleteHistory(operation = "delete", id.toString()).whenComplete((){
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: new HistoryActivity()));
                          });
                        },
                        child: Container(
                          width: CustomSize.sizeWidth(context) / 1.1,
                          height: CustomSize.sizeHeight(context) / 14,
                          decoration: BoxDecoration(
                              color: CustomColor.redBtn,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: MediaQuery(
                                  child: CustomText.textTitle2(text: "Hapus", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ):Container(),
                    (homepg != "1")?Container():(karyawan != "1")?Container():GestureDetector(
                      onTap: () async{
                        setState(() {
                          isLoading = false;
                        });
                        _deleteHistory(operation = "delete", id.toString());
                        Navigator.pop(context);
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HistoryActivity()));
                      },
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 14,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: CustomColor.redBtn
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: MediaQuery(
                                child: CustomText.textTitle2(text: "Hapus", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
