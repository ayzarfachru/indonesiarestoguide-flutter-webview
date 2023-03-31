import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:kam5ia/model/Transaction.dart' as trans;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderReady extends StatefulWidget {
  @override
  _OrderReadyState createState() => _OrderReadyState();
}

class _OrderReadyState extends State<OrderReady> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();

  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name')??'');
    });
  }


  String address = "";
  String type = "";
  int all = 0;
  int total = 0;
  int ongkir = 0;
  String harga = '0';
  String qty = '';
  String? id;
  List<Menu> menu = [];
  String phone = '';
  String chatroom = 'null';
  String Meja = 'null';
  List<Transaction> detTransaction = [];
  String userName = '';
  String note = '';
  String chatRestoCount = '';
  bool waiting = false;
  Future _getDetailTrans(String Id, String name, String status)async{
    List<Transaction> _detTransaction = [];
    List<Menu> _menu = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans/$Id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('OIII'+data.toString());

    if (data['trx']['note'] != null) {
      note = data['trx']['note'].toString().split('[')[1].split(']')[0];
    } else {
      note = '';
    }

    if (data['trx']['chat_resto'] != null) {
      chatRestoCount = data['trx']['chat_user'].toString();
    } else {
      chatRestoCount = '0';
    }

    for(var v in data['trx']['item']){
      Menu p = Menu(
        id: v['id'],
        name: v['name'].toString(),
        desc: v['desc'],
        qty: v['qty'].toString(),
        urlImg: v['img'],
        type: v['type'],
        is_available: '',
        is_recommended: v['is_recommended'].toString(),
        price: Price(original: int.parse(v['price'].toString()),discounted: int.parse(v['discounted_price'].toString()), delivery: null), restoName: '', distance: null, delivery_price: null, restoId: '',
      );
      _menu.add(p);
    }

    // for(var v in data['menu']){
    //   Menu p = Menu(
    //     id: v['id'],
    //     name: v['name'],
    //     desc: v['desc'],
    //     qty: v['qty'].toString(),
    //     urlImg: v['img'],
    //     type: v['type'],
    //     is_recommended: v['is_recommended'],
    //     price: Price(original: int.parse(v['price'].toString())),
    //   );
    //   _menu.add(p);
    // }

    if (data['status_code'].toString() == "200") {
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
          ),
          context: context,
          builder: (_){
            return StatefulBuilder(
                builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                    child: MediaQuery(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: CustomSize.sizeHeight(context) / 288,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.6),
                            child: Divider(thickness: 3,),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                          ListView(
                            // physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Container(
                                height: CustomSize.sizeHeight(context) / 1.8,
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      // height: CustomSize.sizeHeight(context) / 3.4,
                                      // height: CustomSize.sizeHeight(context) / 3.8,
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
                                      child: Container(
                                        width: CustomSize.sizeWidth(context),
                                        // height: CustomSize.sizeHeight(context) / 3.4,
                                        padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 88,),
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            controller: _scrollController,
                                            itemCount: menu.length,
                                            itemBuilder: (_, index){
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  top: CustomSize.sizeWidth(context) / 32,
                                                  bottom: CustomSize.sizeWidth(context) / 32,
                                                  left: CustomSize.sizeWidth(context) / 28,
                                                  right: CustomSize.sizeWidth(context) / 28,
                                                ),
                                                child: Container(
                                                  // height: CustomSize.sizeHeight(context) / 5,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: CustomSize.sizeWidth(context) / 3,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                CustomText.textHeading4(
                                                                    text: menu[index].name,
                                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                                    maxLines: 1
                                                                ),
                                                                CustomText.bodyRegular14(
                                                                    text: menu[index].desc,
                                                                    maxLines: 2,
                                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                ),
                                                                SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                                                                (menu[index].price!.discounted == menu[index].price!.original || menu[index].price!.discounted == 'null' || menu[index].price!.discounted == '')?CustomText.bodyMedium14(
                                                                    text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original??'0'),
                                                                    maxLines: 1,
                                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                ):Row(
                                                                  children: [
                                                                    CustomText.bodyMedium14(
                                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original??'0'),
                                                                        maxLines: 1,
                                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                                        decoration: TextDecoration.lineThrough
                                                                    ),
                                                                    SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                                    CustomText.bodyMedium14(
                                                                        text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.discounted),
                                                                        maxLines: 1,
                                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(height: CustomSize.sizeHeight(context) * 0.0015,),
                                                                CustomText.bodyMedium12(
                                                                    text: 'Qty: '+menu[index].qty,
                                                                    maxLines: 2,
                                                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                ),
                                                              ],
                                                            ),
                                                            // (menuReady[index])?Container():CustomText.bodyMedium14(
                                                            //     text: "Menu tidak tersedia.",
                                                            //     maxLines: 1,
                                                            //     color: Colors.red
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          FullScreenWidget(
                                                            child: Container(
                                                              width: CustomSize.sizeWidth(context) / 3.4,
                                                              height: CustomSize.sizeWidth(context) / 3.4,
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(20),
                                                                child: Image.network(Links.subUrl + menu[index].urlImg, fit: BoxFit.fitWidth),
                                                              ),
                                                            ),
                                                          ),
                                                          // Container(
                                                          //   width: CustomSize.sizeWidth(context) / 3.4,
                                                          //   height: CustomSize.sizeWidth(context) / 3.4,
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
                                              );
                                            }
                                        ),
                                      ),
                                    ),

                                    (note != '')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                                    (note != '')?Container(
                                      width: CustomSize.sizeWidth(context),
                                      // height: CustomSize.sizeHeight(context) / 3.8,
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
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                            CustomText.textTitle3(text: "Catatan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                                            CustomText.textTitle3(text: note.replaceAll('{', '').replaceAll('}, ', '\n').replaceAll('}', ''), maxLines: 99, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                          ],
                                        ),
                                      ),
                                    ):Container(),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      // height: (Meja != 'null')?CustomSize.sizeHeight(context) / 3.2:CustomSize.sizeHeight(context) / 3.3,
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
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                            CustomText.textHeading3(
                                                text: "Kode Transaksi: IRG-"+id.toString(),
                                                maxLines: 1,
                                                color: CustomColor.primary,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                            ),
                                            CustomText.textTitle3(text: "Rincian Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                            // CustomText.bodyLight12(
                                            //     text: date_trans.toString().split('T')[1].split(':')[0]+':'+date_trans.toString().split('T')[1].split(':')[1]+', '+DateFormat('dd-MM-y').format(DateTime.parse(date_trans)).toString(),
                                            //     maxLines: 1,
                                            //     minSize: 10
                                            // ),
                                            (Meja != 'null')?ListView.builder(
                                                shrinkWrap: true,
                                                controller: _scrollController,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: 1,
                                                itemBuilder: (_, index){
                                                  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomText.textTitle3(text: "Meja Nomor :", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      CustomText.textTitle3(text: (meja.firstWhere((t) => t.id.toString() == Meja, orElse: (){ return Meja2(id: 0, name: "", url: "", qr: ""); })).name, color: CustomColor.primary, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                                                    ],
                                                  );
                                                }
                                            ):SizedBox(),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                            // (Meja != 'null')?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                                            // (Meja != 'null')?Divider(thickness: 1,):SizedBox(),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.bodyLight16(text: "Harga", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.bodyLight16(text: (total.toString() == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                                ),
                                              ],
                                            ),
                                            (Meja == 'null')?(type == 'delivery')?SizedBox(height: CustomSize.sizeHeight(context) / 100,):Container():Container(),
                                            (Meja == 'null')?(type == 'delivery')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.bodyLight16(text: "Ongkir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  // totalOngkir
                                                ),
                                              ],
                                            ):Container():Container(),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.bodyLight16(text: "Platform Fee", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.bodyLight16(text: (all.toString() == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(1000), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                              ],
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                            Divider(thickness: 1,),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                    CustomText.textTitle3(text: (all.toString() == '0')?'Ngupon Yuk':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((all+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))
                                                    ),
                                                  ],
                                                ),
                                                // SizedBox(height: CustomSize.sizeHeight(context) * 0.0075,),
                                                // GestureDetector(
                                                //   onTap: (){
                                                //
                                                //   },
                                                //     child: CustomText.bodyRegular14(text: "lihat detail")
                                                // ),
                                              ],
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: (type != "delivery")?CustomSize.sizeHeight(context) / 7.2:CustomSize.sizeHeight(context) / 4.8,
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
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 7.6,
                                                    height: CustomSize.sizeWidth(context) / 7.6,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.primaryLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(
                                                      child: Icon((type == "delivery")?FontAwesome.motorcycle:(type == "takeaway")?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    (type == "delivery")?CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Pesan antar",
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):(type == "takeaway")?CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Ambil ditempat",
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Makan ditempat",
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,),
                                                    (type == "delivery")?SizedBox(height: CustomSize.sizeHeight(context) * 0.003,):Container(),
                                                    (type == "delivery")?CustomText.bodyRegular15(text:
                                                    // (_transCode == 1)?
                                                    "Alamat Pengiriman",
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):Container(),
                                                    // (type == "delivery")?SizedBox(height: CustomSize.sizeHeight(context) * 0.005,):Container(),
                                                    (type == "delivery")?Container(
                                                      width: CustomSize.sizeWidth(context) / 1.6,
                                                      child: CustomText.textHeading7(text: address,
                                                        // (_transCode == 1)?
                                                        maxLines: 3,
                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                        // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                        ,),
                                                    ):Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    (type == 'delivery')?SizedBox(height: CustomSize.sizeHeight(context) / 56,):Container(),
                                    (type == 'delivery')?Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 7.2,
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
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                                        child: Row(
                                          children: [
                                            (StatusDriver != 'pending' && StatusDriver != 'Tidak Ditemukan')?Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                width: CustomSize.sizeWidth(context) / 7.2,
                                                height: CustomSize.sizeWidth(context) / 7.2,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(50.0),
                                                  child: FullScreenWidget(
                                                    child: Image.network(
                                                      PhotoDriver,
                                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                        // Appropriate logging or analytics, e.g.
                                                        // myAnalytics.recordError(
                                                        //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                                        //   exception,
                                                        //   stackTrace,
                                                        // );
                                                        return Image.network(
                                                          PhotoDriver,
                                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                            // Appropriate logging or analytics, e.g.
                                                            // myAnalytics.recordError(
                                                            //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                                            //   exception,
                                                            //   stackTrace,
                                                            // );
                                                            return Image.network(
                                                              PhotoDriver,
                                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                // Appropriate logging or analytics, e.g.
                                                                // myAnalytics.recordError(
                                                                //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                                                //   exception,
                                                                //   stackTrace,
                                                                // );
                                                                return Image.asset('assets/default.png');
                                                              },
                                                              loadingBuilder: (BuildContext context, Widget child,
                                                                  ImageChunkEvent? loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return Center(
                                                                  child: CircularProgressIndicator(
                                                                    color: CustomColor.primary,
                                                                    value: loadingProgress.expectedTotalBytes != null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                        loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                  ),
                                                                );
                                                              },
                                                              fit: BoxFit.cover,
                                                              width: CustomSize.sizeWidth(context) / 7.2,
                                                              height: CustomSize.sizeWidth(context) / 7.2,
                                                            );
                                                          },
                                                          fit: BoxFit.cover,
                                                          width: CustomSize.sizeWidth(context) / 7.2,
                                                          height: CustomSize.sizeWidth(context) / 7.2,
                                                        );
                                                      },
                                                      fit: BoxFit.cover,
                                                      width: CustomSize.sizeWidth(context) / 7.2,
                                                      height: CustomSize.sizeWidth(context) / 7.2,
                                                    ),
                                                    backgroundColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                width: CustomSize.sizeWidth(context) / 7.2,
                                                height: CustomSize.sizeWidth(context) / 7.2,
                                                child: Image.asset('assets/default.png'),
                                              ),
                                            ),
                                            SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                // GestureDetector(
                                                //   onTap: (){
                                                //     if (PhoneDriver == '0') {
                                                //
                                                //     } else {
                                                //       launch("tel:$PhoneDriver");
                                                //     }
                                                //   },
                                                //   child: CustomText.bodyRegular15(
                                                //       text: 'Data kurir',
                                                //       maxLines: 1,
                                                //       minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                //   ),
                                                // ),
                                                GestureDetector(
                                                  onTap: (){
                                                    if (PhoneDriver == '0') {

                                                    } else {
                                                      launch("tel:$PhoneDriver");
                                                    }
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 1.6,
                                                    child: CustomText.textHeading7(
                                                        text: (StatusDriver != 'pending')?NameDriver:'Mencari . . .',
                                                        maxLines: 2,
                                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                    ),
                                                  ),
                                                ),
                                                // SizedBox(height: CustomSize.sizeHeight(context) / 138,),
                                                // CustomText.bodyRegular15(
                                                //     text: (StatusDriver != 'pending')?NameDriver:'Mencari . . .',
                                                //     maxLines: 1,
                                                //     minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())
                                                // ),
                                                GestureDetector(
                                                  onTap: (){
                                                    if (PhoneDriver == '0') {

                                                    } else {
                                                      launch("tel:$PhoneDriver");
                                                    }
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: CustomSize.sizeWidth(context) / 1.8,
                                                        child: CustomText.bodyRegular15(
                                                            text: (StatusDriver != 'pending')?(StatusDriver != 'Tidak Ditemukan')?(StatusDriver != 'active')?'Status: $StatusDriver':'Status: Sedang perjalanan':'Status: Transaksi tidak ditemukan':'Status: Sedang mencari driver',
                                                            maxLines: 1,
                                                            minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: (){
                                                    if (PhoneDriver == '0') {

                                                    } else {
                                                      launch("tel:$PhoneDriver");
                                                    }
                                                  },
                                                  child: CustomText.bodyRegular15(
                                                      text: (StatusDriver != 'pending')?(PhoneDriver != '0')?PhoneDriver:'Tunggu':'Mencari . . .',
                                                      maxLines: 1,
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  ),
                                                ),
                                                // CustomText.bodyLight16(text: 'Status', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ):Container(),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      if (chatroom != 'null') {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new ChatActivity(chatroom, userName, status)));
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Chat tidak dapat dilakukan.',);
                                      }
                                      // print(chatroom+ userName+ status);
                                    },
                                    child: Center(
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 14,
                                        decoration: BoxDecoration(
                                            color: (chatroom != 'null')?Colors.blue:Colors.grey,
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 9),
                                                      child: Icon(FontAwesome.comments_o, color: Colors.white , size: 25,),
                                                    ),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 72,),
                                                    Stack(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 7.0, right: 16),
                                                          child: CustomText.textHeading7(text: "Chat", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                        ),
                                                        Positioned(  // draw a red marble
                                                            top: -2,
                                                            right: 0,
                                                            child: Stack(
                                                              alignment: Alignment.center,
                                                              children: [
                                                                Icon(Icons.circle, color: (chatRestoCount != '0')?CustomColor.redBtn:Colors.transparent, size: 20,),
                                                                CustomText.bodyMedium12(text: chatRestoCount, color: (chatRestoCount != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                                              ],
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      launch("tel:$phone");
                                      // Navigator.push(
                                      //     context,
                                      //     PageTransition(
                                      //         type: PageTransitionType.rightToLeft,
                                      //         child: new ChatActivity(chatroom, userName, status)));
                                      // print(chatroom+ userName+ status);
                                    },
                                    child: Center(
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 14,
                                        decoration: BoxDecoration(
                                            color: CustomColor.primaryLight,
                                            borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(FontAwesome.phone, color: Colors.white , size: 22.5,),
                                                    SizedBox(width: CustomSize.sizeWidth(context) / 88,),
                                                    CustomText.textHeading7(text: "Telpon", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                              GestureDetector(
                                onTap: (){
                                  // _getReady(operation = "done", id!);
                                  // setStateModal(() {});
                                  // Future.delayed(Duration(seconds: 0)).then((_) {
                                  //   Navigator.pushReplacement(
                                  //       context,
                                  //       PageTransition(
                                  //           type: PageTransitionType.fade,
                                  //           child: OrderActivity()));
                                  // });
                                  if (type != 'delivery') {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                            title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                            content: Text('Apakah pesanan ini sudah diterima konsumen?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                            actions: <Widget>[
                                              Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 25, right: 25),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      // OutlineButton(
                                                      //   // minWidth: CustomSize.sizeWidth(context),
                                                      //   shape: StadiumBorder(),
                                                      //   highlightedBorderColor: CustomColor.secondary,
                                                      //   borderSide: BorderSide(
                                                      //       width: 2,
                                                      //       color: CustomColor.redBtn
                                                      //   ),
                                                      //   child: Text('Batal'),
                                                      //   onPressed: () async{
                                                      //     setState(() {
                                                      //       // codeDialog = valueText;
                                                      //       Navigator.pop(context);
                                                      //     });
                                                      //   },
                                                      // ),
                                                      OutlinedButton(
                                                        // minWidth: CustomSize.sizeWidth(context),
                                                        // shape: StadiumBorder(),
                                                        // highlightedBorderColor: CustomColor.secondary,
                                                        // borderSide: BorderSide(
                                                        //     width: 2,
                                                        //     color: CustomColor.accent
                                                        // ),
                                                        style: OutlinedButton.styleFrom(shape: StadiumBorder(), surfaceTintColor: CustomColor.redBtn),
                                                        child: Text('Belum', style: TextStyle(color: CustomColor.redBtn)),
                                                        onPressed: () async{
                                                          Navigator.pop(context);
                                                          // _getProcess(operation = "ready", id.toString());
                                                          // setStateModal(() {});
                                                          // String qrcode = '';
                                                        },
                                                      ),
                                                      OutlinedButton(
                                                        // minWidth: CustomSize.sizeWidth(context),
                                                        // shape: StadiumBorder(),
                                                        // highlightedBorderColor: CustomColor.secondary,
                                                        // borderSide: BorderSide(
                                                        //     width: 2,
                                                        //     color: CustomColor.accent
                                                        // ),
                                                        style: OutlinedButton.styleFrom(shape: StadiumBorder(), surfaceTintColor: CustomColor.accent),
                                                        child: Text('Sudah', style: TextStyle(color: CustomColor.accent)),
                                                        onPressed: () async{
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                          _getReady(operation = "done", id!);
                                                          setStateModal(() {});
                                                          Future.delayed(Duration(seconds: 0)).then((_) async{
                                                            // var collection = FirebaseFirestore.instance.collection('room');
                                                            // var snapshot = await collection.where(chatroom).get();
                                                            // for (var doc in snapshot.docs) {
                                                            //   await doc.reference.delete();
                                                            // }
                                                            // var collection = _firestore.collection('room');

                                                            //   _onDeleteItemPressed(index);
                                                            // await _firestore.collection("room").document(chatroom).delete().then((_) {
                                                            //   print("BERHASIL!");
                                                            // });

                                                            Navigator.pushReplacement(
                                                                context,
                                                                PageTransition(
                                                                    type: PageTransitionType.fade,
                                                                    child: OrderActivity()));
                                                          });
                                                          // setStateModal(() {});
                                                          // String qrcode = '';
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                            ],
                                          );
                                        });
                                  } else {
                                    Fluttertoast.showToast(msg: 'Status hanya bisa di ubah oleh customer');
                                  }

                                  // if (int.parse(deposit) >= (1000)) {
                                  //   _getReady(operation = "done", id!);
                                  //   setStateModal(() {});
                                  //   Future.delayed(Duration(seconds: 0)).then((_) {
                                  //     Navigator.pushReplacement(
                                  //         context,
                                  //         PageTransition(
                                  //             type: PageTransitionType.fade,
                                  //             child: OrderActivity()));
                                  //   });
                                  // } else {
                                  //   Fluttertoast.showToast(
                                  //     msg: 'Saldo deposit anda tidak mencukupi untuk melanjutkan transaksi ini!',);
                                  // }
                                  setState(() { });
                                },
                                child: Center(
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 1,
                                    height: CustomSize.sizeHeight(context) / 14,
                                    decoration: BoxDecoration(
                                        color: (type == 'delivery')?Colors.grey:CustomColor.accent,
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CustomText.textHeading7(text: (type == 'delivery')?"Belum diterima customer":"Telah di terima konsumen", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 94,),
                        ],
                      ),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    ),
                  );
                }
            );
          }
      );
    }else{
      Fluttertoast.showToast(
        msg: data['message'],);
    }

    setState(() {
      waiting = false;
      chatroom = (data['trx']['chatroom'] != null)?(data['trx']['chatroom']['id']??'null').toString():'null';
      Meja = (data['trx']['restaurant_tables_id'] != null)?(data['trx']['restaurant_tables_id']??'null').toString():'null';
      ongkir = int.parse(data['trx']['ongkir'].toString());
      total = int.parse(data['trx']['total'].toString());
      all = total+ongkir;
      type = data['trx']['type'].toString();
      address = data['trx']['address'].toString();
      phone = data['trx']['user_phone'].toString();
      // print(price);
      // detTransaction = _detTransaction;
      menu = _menu;
    });
  }


  String NameDriver = 'Tunggu';
  String PhoneDriver = '0';
  String PhotoDriver = '';
  String StatusDriver = 'Tunggu sebentar';
  Future<void> _getDriver()async{
    // List<Menu> _menu = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://qurir.devastic.com/api/borzo?transaction_id=IRG-$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);

    print('driver '+apiResult.body.toString());
    // print('driver '+idResto.toString());
    if (apiResult.body.toString() != '"not found"') {
      if (data['courier'].toString().contains('name') == false) {
        StatusDriver = (apiResult.body.toString() != '"not found"')?data['status'].toString():'Tidak Ditemukan';
        PhoneDriver = 'Tunggu';
      } else {
        NameDriver = (apiResult.body.toString() != '"not found"')?data['courier']['name'].toString():'Tidak Ditemukan';
        PhoneDriver = (apiResult.body.toString() != '"not found"')?data['courier']['phone'].toString():'0';
        PhotoDriver = (apiResult.body.toString() != '"not found"')?data['courier']['photo'].toString():'';
        StatusDriver = (apiResult.body.toString() != '"not found"')?(data['status'].toString() != 'active')?'Sudah sampai':data['status'].toString():'Tidak Ditemukan';
      }
    } else {
      NameDriver = 'Tidak Ditemukan';
      PhoneDriver = 'Tidak Ditemukan';
      PhotoDriver = '';
      StatusDriver = 'Tidak Ditemukan';
    }
    // for(var v in data['menu']){
    //   Menu p = Menu(
    //       id: v['id'],
    //       name: v['name'],
    //       desc: v['desc'],
    //       urlImg: v['img'],
    //       type: v['type'],
    //       is_recommended: v['is_recommended'],
    //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
    //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
    //   );
    //   _menu.add(p);
    // }
    setState(() {
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }


  bool ksg = false;
  List<trans.Transaction> transaction = [];
  Future _getTrans()async{
    List<trans.Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print(data['trx']['ready']??'ksg');

    // if (data['trx']['chat_resto'] != null) {
    //   chatRestoCount = data['trx']['chat_user'].toString();
    // } else {
    //   chatRestoCount = '0';
    // }

    if (data['trx'].toString().contains('ready')) {
      for(var v in data['trx']['ready']){
        trans.Transaction r = trans.Transaction.resto2(
            id: v['id'],
            status: v['status'],
            username: v['username'],
            total: int.parse(v['total'].toString()),
            type: v['type'],
            img: v['user_image'],
            chatroom: '',
            chat_user: (v['chat_user']??0).toString()
        );
        _transaction.add(r);
      }
    } else {
      ksg = true;
    }

    setState(() {
      transaction = _transaction;
    });
  }

  String operation ='';
  Future _getReady(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    FirebaseFirestore.instance.collection('room').doc(chatroom).collection('messages').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
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

  List<Meja2> meja = [];
  String deposit = '';
  Future<void> _getQr()async{
    List<Meja2> _meja = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/table'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['table']){
      Meja2 p = Meja2(
        id: v['id'],
        name: v['name'].toString(),
        qr: v['barcode'],
        url: v['img'],
      );
      _meja.add(p);
    }

    String id = pref.getString("idHomeResto") ?? "";
    var apiResult2 = await http
        .get(Uri.parse(Links.mainUrl + "/deposit/$id"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data2 = json.decode(apiResult2.body);

    setState(() {
      meja = _meja;
      deposit = data2['balance'].toString();
      // isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getQr();
    _getTrans();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
          body: SafeArea(
            child: (ksg != true)?SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: transaction.length,
                        itemBuilder: (_, index){
                          return GestureDetector(
                            onTap: ()async{
                              Fluttertoast.showToast(msg: "Tunggu sebentar");
                              if (waiting == false) {
                                waiting = true;
                                _getDriver().whenComplete((){
                                  _getDetailTrans(transaction[index].id.toString(), userName, transaction[index].status!);
                                });
                              }
                              id = transaction[index].id.toString();
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              pref.setString('idnyatrans', transaction[index].id.toString());
                              // print((transaction[index].id.toString()));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context),
                                    height: CustomSize.sizeWidth(context) / 3.3,
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
                                          width: CustomSize.sizeWidth(context) / 3.3,
                                          height: CustomSize.sizeWidth(context) / 3.3,
                                          decoration: (transaction[index].img.toString() != 'null')?BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + transaction[index].img!),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ):BoxDecoration(
                                            image: new DecorationImage(
                                                image: AssetImage('assets/default.png') as ImageProvider,
                                                fit: BoxFit.cover
                                            ),
                                            color: Color.fromRGBO(231,236,237, 1),
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
                                                  text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Pesan Antar":"Ambil Ditempat":transaction[index].type.toString(),
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              CustomText.textHeading3(
                                                  text: "Kode Transaksi: IRG-"+transaction[index].id.toString(),
                                                  maxLines: 1,
                                                  color: CustomColor.primary,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              CustomText.textHeading4(
                                                  text: transaction[index].username.toString(),
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                  maxLines: 1
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 26,),
                                              Row(
                                                children: [
                                                  CustomText.bodyRegular12(text: (transaction[index].type.toString() != "Pesan antar")?(transaction[index].total.toString() == '0')?'"Ngupon Yuk" Free':(transaction[index].total!+1000).toString():((transaction[index].total == 0)?'"Ngupon Yuk" + Ongkir':transaction[index].total!+1000).toString(), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: CustomSize.sizeWidth(context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(top: 2.5, left: 2.5),
                                            child: Icon(Icons.circle, color: Colors.transparent, size: 22,)
                                        ),
                                        Container(
                                            padding: EdgeInsets.only(top: 15, right: 15),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(Icons.circle, color: (transaction[index].chat_user != '0')?CustomColor.redBtn:Colors.transparent, size: 26,),
                                                CustomText.bodyMedium12(text: transaction[index].chat_user, color: (transaction[index].chat_user != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                              ],
                                            )
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
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                  ],
                ),
              ),
            ):Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
          ),
          // floatingActionButton: GestureDetector(
          //   onTap: (){
          //     // Navigator.push(
          //     //     context,
          //     //     PageTransition(
          //     //         type: PageTransitionType.rightToLeft,
          //     //         child: CartActivity()));
          //   },
          //   child: Container(
          //     width: CustomSize.sizeWidth(context) / 6.6,
          //     height: CustomSize.sizeWidth(context) / 6.6,
          //     decoration: BoxDecoration(
          //         color: CustomColor.primary,
          //         shape: BoxShape.circle
          //     ),
          //     child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 30,)),
          //   ),
          // )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
