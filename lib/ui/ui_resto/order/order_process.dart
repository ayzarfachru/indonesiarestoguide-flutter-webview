import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderProcess extends StatefulWidget {
  @override
  _OrderProcessState createState() => _OrderProcessState();
}

class _OrderProcessState extends State<OrderProcess> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();


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
  List<Transaction> detTransaction = [];
  String chatroom = 'null';
  String Meja = 'null';
  String note = '';
  String chatRestoCount = '';
  // String s = 'null';
  Future _getDetailTrans(String Id, String name, String status)async{
    List<Transaction> _detTransaction = [];
    List<Menu> _menu = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/trans/$Id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    // for(var v in data['trans']){
    //   Transaction r = Transaction.restoDetail(
    //       type: v['type'],
    //       address: v['status'],
    //       ongkir: v['ongkir'],
    //       total: v['total'],
    //   );
    //   _detTransaction.add(r);
    // }
    if (data['trx']['note'] != null) {
      note = data['trx']['note'].toString().split('[')[1].split(']')[0];
    } else {
      note = '';
    }

    if (data['trx']['chat_user'] != null) {
      chatRestoCount = data['trx']['chat_user'].toString();
    } else {
      chatRestoCount = '0';
    }

    for(var v in data['trx']['item']){
      Menu p = Menu(
        id: v['id'],
        name: v['name'],
        desc: v['desc'],
        qty: v['qty'].toString(),
        urlImg: v['img'],
        type: v['type'],
        is_recommended: v['is_recommended'],
        price: Price(original: int.parse(v['price'].toString()),discounted: int.parse(v['discounted_price'].toString()), delivery: null), restoName: '', distance: null, delivery_price: null, restoId: '',
      );
      _menu.add(p);
    }

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
                                      // height: CustomSize.CustomSizesizeHeight(context) / 4.2,
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
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 3.8,
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
                                            CustomText.textTitle3(text: "Rincian Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.bodyLight16(text: "Harga", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                                ),
                                              ],
                                            ),
                                            (Meja != 'null')?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                                            (Meja != 'null')?ListView.builder(
                                                shrinkWrap: true,
                                                controller: _scrollController,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: 1,
                                                itemBuilder: (_, index){
                                                  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomText.bodyLight16(text: "Meja", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      CustomText.bodyLight16(text: (meja[index].id.toString().startsWith(Meja))?meja[index].name.toString():'', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                                                    ],
                                                  );
                                                }
                                            ):SizedBox(),
                                            (Meja == 'null')?SizedBox(height: CustomSize.sizeHeight(context) / 100,):Container(),
                                            (Meja == 'null')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.bodyLight16(text: "Ongkir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  // totalOngkir
                                                ),
                                              ],
                                            ):Container(),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                            Divider(thickness: 1,),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(all), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                    Container(
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
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):(type == "takeaway")?CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Ambil ditempat",
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Makan ditempat",
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,),
                                                    (type == "delivery")?SizedBox(height: CustomSize.sizeHeight(context) / 138,):Container(),
                                                    (type == "delivery")?CustomText.bodyRegular15(text:
                                                    // (_transCode == 1)?
                                                    "Alamat Pengiriman",
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.038).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.038)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.038)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):Container(),
                                                    (type == "delivery")?CustomText.textHeading7(text:
                                                    // (_transCode == 1)?
                                                    "Jl Jemur Gayungan 1 no 86",
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                                      ,):Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                          Column(
                            children: [
                              // GestureDetector(
                              //   onTap: (){
                              //     Navigator.push(
                              //         context,
                              //         PageTransition(
                              //             type: PageTransitionType.rightToLeft,
                              //             child: new ChatActivity(chatroom, userName, status)));
                              //     print("ini Status "+ status);
                              //   },
                              //   child: Center(
                              //     child: Container(
                              //       width: CustomSize.sizeWidth(context) / 1,
                              //       height: CustomSize.sizeHeight(context) / 14,
                              //       decoration: BoxDecoration(
                              //           color: CustomColor.primaryLight,
                              //           borderRadius: BorderRadius.circular(50)
                              //       ),
                              //       child: Center(
                              //         child: Padding(
                              //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //           child: Column(
                              //             mainAxisAlignment: MainAxisAlignment.center,
                              //             crossAxisAlignment: CrossAxisAlignment.center,
                              //             children: [
                              //               CustomText.textHeading7(text: "Hubungi Customer", color: Colors.white),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                                  _getProcess(operation = "ready", id!);
                                  setStateModal(() {});
                                  Future.delayed(Duration(seconds: 0)).then((_) {
                                    Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: OrderActivity()));
                                  });
                                  setState(() { });
                                },
                                child: Center(
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 1,
                                    height: CustomSize.sizeHeight(context) / 14,
                                    decoration: BoxDecoration(
                                        color: CustomColor.accent,
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CustomText.textHeading7(text: "Selesaikan Transaksi", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
      chatroom = (data['trx']['chatroom'] != null)?(data['trx']['chatroom']['id']??'null').toString():'null';
      Meja = (data['trx']['restaurant_tables_id'] != null)?(data['trx']['restaurant_tables_id']??'null').toString():'null';
      ongkir = int.parse(data['trx']['ongkir']);
      total = int.parse(data['trx']['total']);
      all = total+ongkir;
      type = data['trx']['type'].toString();
      address = data['trx']['address'].toString();
      phone = data['trx']['user_phone'].toString();
      // print(price);
      // detTransaction = _detTransaction;
      menu = _menu;
    });
  }


  String userName = '';
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name'));
    });
  }

  bool ksg = false;

  List<Transaction> transaction = [];
  Future _getTrans()async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/trans', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print(data['trx']['process']??'ksg');

    if (data['trx'].toString().contains('process')) {
      for(var v in data['trx']['process']){
        Transaction r = Transaction.resto2(
            id: v['id'],
            status: v['status'],
            username: v['username'],
            total: int.parse(v['total']),
            // chatroom: v['chatroom'],
            chatroom: '',
            type: v['type'],
            img: v['user_image'],
            chat_user: v['trans']['chat_user']??'0'
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
  Future _getProcess(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/trans/op/$operation/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

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
  Future<void> _getQr()async{
    List<Meja2> _meja = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/table', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['table']){
      Meja2 p = Meja2(
        id: v['id'],
        name: v['name'],
        qr: v['barcode'],
        url: v['img'],
      );
      _meja.add(p);
    }

    setState(() {
      meja = _meja;
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
                              _getDetailTrans(transaction[index].id.toString(), userName, transaction[index].status!);
                              id = transaction[index].id.toString();
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              pref.setString('idnyatrans', transaction[index].id.toString());
                              print(transaction[index].chatroom.toString()+ userName.toString()+ transaction[index].status.toString());
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
                                              CustomText.textHeading4(
                                                  text: transaction[index].username.toString(),
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                  maxLines: 1
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 26,),
                                              Row(
                                                children: [
                                                  CustomText.bodyRegular12(text: transaction[index].total.toString(), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
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
            ):Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
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
