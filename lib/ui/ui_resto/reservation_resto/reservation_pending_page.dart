import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/Transaction.dart';
import 'package:indonesiarestoguide/model/User.dart';
import 'package:indonesiarestoguide/ui/reservation/reservation_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/reservation_resto/reservation_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ReservationPending extends StatefulWidget {
  @override
  _ReservationPendingState createState() => _ReservationPendingState();
}

class _ReservationPendingState extends State<ReservationPending> {
  ScrollController _scrollController = ScrollController();

  List<Transaction> transaction = [];
  Future _getTrans()async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/reservation', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['trx']['pending']){
      Transaction r = Transaction.reservation(
          id: v['id'],
          status: v['status'],
          username: v['user_name'],
          datetime: v['datetime'],
          table: v['table'].toString(),
          img: v['user_img'],
          total: int.parse(v['price']),
      );
      _transaction.add(r);
    }

    setState(() {
      transaction = _transaction;
    });
  }


  String status = "";
  String datetime = "";
  String table = "";
  String username = "";
  String total = "";
  String id;
  // List<Menu> menu = [];
  List<Transaction> detTransaction = [];
  Future _getDetailTrans(String Id)async{
    List<Transaction> _detTransaction = [];
    // List<Menu> _menu = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/reservation/$Id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);


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
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 16),
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
                        height: CustomSize.sizeHeight(context) / 3.2,
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
                              CustomText.textTitle3(text: "Rincian"),
                              SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Nama pemesan"),
                                  CustomText.bodyLight16(text: username
                                    // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                  ),
                                ],
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Tanggal"),
                                  CustomText.bodyLight16(text: datetime.split(' ')[0]
                                    // totalOngkir
                                  ),
                                ],
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Jam"),
                                  CustomText.bodyLight16(text: datetime.split(' ')[1].split(':')[0]+':'+datetime.split(' ')[1].split(':')[1]
                                    // totalOngkir
                                  ),
                                ],
                              ),
                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Jumlah meja"),
                                  CustomText.bodyLight16(text: table
                                    // totalOngkir
                                  ),
                                ],
                              ),
                              Divider(thickness: 1,),
                              SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.textTitle3(text: "Total Pembayaran"),
                                  CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total))
                                    // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))
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
                              Navigator.pop(context);
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _Operation(operation = "cancel", id);
                                  setStateModal(() {});
                                  Future.delayed(Duration(seconds: 0)).then((_) {
                                    Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: ReservationRestoActivity()));
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 2.3,
                                    height: CustomSize.sizeHeight(context) / 14,
                                    decoration: BoxDecoration(
                                        color: CustomColor.redBtn,
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CustomText.textHeading7(text: "Tolak", color: Colors.white),
                                            CustomText.textHeading7(text: "Pesanan", color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  _Operation(operation = "process", id);
                                  setStateModal(() {});
                                  Future.delayed(Duration(seconds: 0)).then((_) {
                                    Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: ReservationRestoActivity()));
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 2.3,
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
                                            CustomText.textHeading7(text: "Terima", color: Colors.white),
                                            CustomText.textHeading7(text: "Pesanan", color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      id = data['trx']['id'].toString();
      status = data['trx']['status'];
      datetime = data['trx']['datetime'];
      table = data['trx']['table'].toString();
      total = data['trx']['price'];
      username = data['trx']['user_name'];
      // print(price);
      // detTransaction = _detTransaction;
      // menu = _menu;
    });
  }

  String operation ='';
  Future _Operation(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/reservation/op/$operation/$id', headers: {
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
                          _getDetailTrans(transaction[index].id.toString());
                          print((transaction[index].id.toString()));
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
                                          // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                          text: transaction[index].datetime.split(' ')[0],
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      CustomText.textHeading4(
                                          text: transaction[index].username.toString(),
                                          minSize: 20,
                                          maxLines: 1
                                      ),
                                      CustomText.bodyLight12(
                                        // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                          text: 'Pukul: '+transaction[index].datetime.split(' ')[1].split(':')[0]+':'+transaction[index].datetime.split(' ')[1].split(':')[1],
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      CustomText.bodyLight12(
                                        // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                          text: transaction[index].table+' meja',
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.00468,),
                                      CustomText.bodyMedium12(
                                          // text: transaction[index].type.toString(),
                                          text: transaction[index].total.toString(),
                                          maxLines: 1,
                                          minSize: 13
                                      ),
                                      // Row(
                                      //   children: [
                                      //     CustomText.bodyRegular12(text: "Rp "+transaction[index].total.toString(), minSize: 14),
                                      //   ],
                                      // )
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
