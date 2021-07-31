import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/Transaction.dart';
import 'package:indonesiarestoguide/utils/chat_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:indonesiarestoguide/ui/ui_resto/order/order_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  String id;
  List<Menu> menu = [];
  List<Transaction> detTransaction = [];
  String chatroom = 'null';
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

    for(var v in data['trx']['item']){
      Menu p = Menu(
        id: v['id'],
        name: v['name'],
        desc: v['desc'],
        qty: v['qty'].toString(),
        urlImg: v['img'],
        type: v['type'],
        is_recommended: v['is_recommended'],
        price: Price(original: int.parse(v['price'].toString()),discounted: int.parse(v['discounted_price'].toString())),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: CustomSize.sizeHeight(context) / 288,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.6),
                          child: Divider(thickness: 3,),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 4.2,
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
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 4.2,
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
                                                            minSize: 18,
                                                            maxLines: 1
                                                        ),
                                                        CustomText.bodyRegular14(
                                                            text: menu[index].desc,
                                                            maxLines: 2,
                                                            minSize: 14
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                                                        (menu[index].price.discounted == menu[index].price.original || menu[index].price.discounted == 'null' || menu[index].price.discounted == '')?CustomText.bodyMedium14(
                                                            text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original??'0'),
                                                            maxLines: 1,
                                                            minSize: 16
                                                        ):Row(
                                                          children: [
                                                            CustomText.bodyMedium14(
                                                                text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original??'0'),
                                                                maxLines: 1,
                                                                minSize: 16,
                                                                decoration: TextDecoration.lineThrough
                                                            ),
                                                            SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                            CustomText.bodyMedium14(
                                                                text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.discounted),
                                                                maxLines: 1,
                                                                minSize: 16
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) * 0.0015,),
                                                        CustomText.bodyMedium12(
                                                            text: 'Qty: '+menu[index].qty,
                                                            maxLines: 2,
                                                            minSize: 14
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
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                CustomText.textTitle3(text: "Rincian Pembayaran"),
                                SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Harga"),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total)
                                      // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Ongkir"),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir)
                                      // totalOngkir
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                Divider(thickness: 1,),
                                SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Total Pembayaran"),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(all)
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
                                            color: CustomColor.primary,
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
                                        "Pesan antar"
                                          // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                          ,):(type == "takeaway")?CustomText.textHeading7(text:
                                        // (_transCode == 1)?
                                        "Ambil ditempat"
                                          // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                          ,):CustomText.textHeading7(text:
                                        // (_transCode == 1)?
                                        "Makan ditempat"
                                          // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                          ,),
                                        (type == "delivery")?SizedBox(height: CustomSize.sizeHeight(context) / 138,):Container(),
                                        (type == "delivery")?CustomText.bodyRegular15(text:
                                        // (_transCode == 1)?
                                        "Alamat Pengiriman"
                                          // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                                          ,):Container(),
                                        (type == "delivery")?CustomText.textHeading7(text:
                                        // (_transCode == 1)?
                                        "Jl Jemur Gayungan 1 no 86"
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
                        Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: new ChatActivity(chatroom, userName, status)));
                                print("ini Status "+ status);
                              },
                              child: Center(
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 1,
                                  height: CustomSize.sizeHeight(context) / 14,
                                  decoration: BoxDecoration(
                                      color: CustomColor.primary,
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CustomText.textHeading7(text: "Hubungi Customer", color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                            GestureDetector(
                              onTap: (){
                                _getProcess(operation = "ready", id);
                                setStateModal(() {});
                                Future.delayed(Duration(seconds: 0)).then((_) {
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: OrderActivity()));
                                });
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
                                          CustomText.textHeading7(text: "Selesaikan Transaksi", color: Colors.white),
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
      chatroom = data['trx']['chatroom']['id'].toString();
      ongkir = int.parse(data['trx']['ongkir']);
      total = int.parse(data['trx']['total']);
      all = total+ongkir;
      type = data['trx']['type'].toString();
      address = data['trx']['address'].toString();
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


  List<Transaction> transaction = [];
  Future _getTrans()async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/trans', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data['trx']['process']);

    for(var v in data['trx']['process']){
      Transaction r = Transaction.resto(
          id: v['id'],
          status: v['status'],
          username: v['username'],
          total: int.parse(v['total']),
          chatroom: v['chatroom'],
          type: v['type'],
          img: v['user_image']
      );
      _transaction.add(r);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getTrans();
    getUser();
    super.initState();
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
                  ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: transaction.length,
                      itemBuilder: (_, index){
                        return GestureDetector(
                          onTap: (){
                            _getDetailTrans(transaction[index].id.toString(), userName, transaction[index].status);
                            id = transaction[index].id.toString();
                            print(transaction[index].chatroom.toString()+ userName.toString()+ transaction[index].status.toString());
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: Container(
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
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(Links.subUrl + transaction[index].img),
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
                                            text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Pesan Antar":"Ambil Ditempat":transaction[index].type.toString(),
                                            maxLines: 1,
                                            minSize: 12
                                        ),
                                        CustomText.textHeading4(
                                            text: transaction[index].username.toString(),
                                            minSize: 20,
                                            maxLines: 1
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 26,),
                                        Row(
                                          children: [
                                            CustomText.bodyRegular12(text: transaction[index].total.toString(), minSize: 14),
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
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                ],
              ),
            ),
          ),
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
    );
  }
}
