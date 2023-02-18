import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/ui/reservation/reservation_activity.dart';
import 'package:kam5ia/ui/ui_resto/reservation_resto/reservation_activity.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationPending extends StatefulWidget {
  @override
  _ReservationPendingState createState() => _ReservationPendingState();
}

class _ReservationPendingState extends State<ReservationPending> {
  ScrollController _scrollController = ScrollController();

  bool ksg = false;

  List<Transaction> transaction = [];
  String deposit = '';
  Future _getTrans()async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString('inDetail', '3');
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/reservation'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    if (data['trx'].toString().contains('pending')) {
      for(var v in data['trx']['pending']){
        Transaction r = Transaction.reservation(
          id: v['id'],
          status: v['status'],
          username: v['user_name'],
          datetime: v['datetime'],
          table: v['table'].toString(),
          img: v['user_img'],
          total: int.parse(v['price'].toString()),
            chatroom: '',
            chat_user: (v['chat_user']??0).toString(),
            is_opened: (v['is_opened']??1).toString()
        );
        _transaction.add(r);
      }
    } else {
      ksg = true;
    }

    String id = pref.getString("idHomeResto") ?? "";
    var apiResult2 = await http
        .get(Uri.parse(Links.mainUrl + "/deposit/$id"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data2 = json.decode(apiResult2.body);

    setState(() {
      transaction = _transaction;
      deposit = data2['balance'].toString();
    });
  }


  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name')??'');
    });
  }

  String status = "";
  String datetime = "";
  String table = "";
  String username = "";
  String total = "";
  String? id;
  String chatroom = 'null';
  String userName = '';
  String chatRestoCount = '';
  String phone = '';
  // List<Menu> menu = [];
  List<Transaction> detTransaction = [];
  bool waiting = false;
  Future _getDetailTrans(String Id)async{
    List<Transaction> _detTransaction = [];
    // List<Menu> _menu = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/reservation/$Id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    if (data['trx']['chat_user'] != null) {
      chatRestoCount = data['trx']['chat_user'].toString();
    } else {
      chatRestoCount = '0';
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
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 16),
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
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 2.8,
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
                                CustomText.textTitle3(text: "Rincian", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Nama pemesan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: username,
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                      // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Tanggal", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: datetime.split(' ')[0],
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                      // totalOngkir
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Jam", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: datetime.split(' ')[1].split(':')[0]+':'+datetime.split(' ')[1].split(':')[1],
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                      // totalOngkir
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Jumlah meja", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: table,
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                      // totalOngkir
                                    ),
                                  ],
                                ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Harga per meja", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(10000),
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                      // totalOngkir
                                    ),
                                  ],
                                ),
                                Divider(thickness: 1,),
                                SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total.toString())),
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new ChatActivity(chatroom, userName, status)));
                                    // print(chatroom+ userName+ status);
                                  },
                                  child: Center(
                                    child: Container(
                                      width: CustomSize.sizeWidth(context) / 2.3,
                                      height: CustomSize.sizeHeight(context) / 14,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
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
                                                        child: CustomText.textHeading7(text: "Chat", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                      ),
                                                      Positioned(  // draw a red marble
                                                          top: -2,
                                                          right: 0,
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Icon(Icons.circle, color: (chatRestoCount != '0')?CustomColor.redBtn:Colors.transparent, size: 20,),
                                                              CustomText.bodyMedium12(text: chatRestoCount, color: (chatRestoCount != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()))
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
                                                  CustomText.textHeading7(text: "Telpon", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
                                _Operation(operation = "cancel", id!);
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
                                  width: CustomSize.sizeWidth(context) / 1,
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
                                          CustomText.textHeading7(text: "Tolak", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                          CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //   children: [
                            //     GestureDetector(
                            //       onTap: (){
                            //         _Operation(operation = "cancel", id!);
                            //         setStateModal(() {});
                            //         Future.delayed(Duration(seconds: 0)).then((_) {
                            //           Navigator.pushReplacement(
                            //               context,
                            //               PageTransition(
                            //                   type: PageTransitionType.fade,
                            //                   child: ReservationRestoActivity()));
                            //         });
                            //       },
                            //       child: Center(
                            //         child: Container(
                            //           width: CustomSize.sizeWidth(context) / 2.3,
                            //           height: CustomSize.sizeHeight(context) / 14,
                            //           decoration: BoxDecoration(
                            //               color: CustomColor.redBtn,
                            //               borderRadius: BorderRadius.circular(50)
                            //           ),
                            //           child: Center(
                            //             child: Padding(
                            //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            //               child: Column(
                            //                 mainAxisAlignment: MainAxisAlignment.center,
                            //                 crossAxisAlignment: CrossAxisAlignment.center,
                            //                 children: [
                            //                   CustomText.textHeading7(text: "Tolak", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                            //                   CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     GestureDetector(
                            //       onTap: (){
                            //         if (int.parse(deposit) >= (int.parse(total) / 2)) {
                            //           _Operation(operation = "process", id!);
                            //           setStateModal(() {});
                            //           Future.delayed(Duration(seconds: 0)).then((_) {
                            //             Navigator.pushReplacement(
                            //                 context,
                            //                 PageTransition(
                            //                     type: PageTransitionType.fade,
                            //                     child: ReservationRestoActivity()));
                            //           });
                            //         } else {
                            //           Fluttertoast.showToast(
                            //             msg: 'Saldo deposit anda tidak mencukupi untuk melanjutkan transaksi ini!',);
                            //         }
                            //       },
                            //       child: Center(
                            //         child: Container(
                            //           width: CustomSize.sizeWidth(context) / 2.3,
                            //           height: CustomSize.sizeHeight(context) / 14,
                            //           decoration: BoxDecoration(
                            //               color: CustomColor.accent,
                            //               borderRadius: BorderRadius.circular(50)
                            //           ),
                            //           child: Center(
                            //             child: Padding(
                            //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            //               child: Column(
                            //                 mainAxisAlignment: MainAxisAlignment.center,
                            //                 crossAxisAlignment: CrossAxisAlignment.center,
                            //                 children: [
                            //                   CustomText.textHeading7(text: "Terima", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                            //                   CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
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
      chatroom = data['trx']['chatroom']['id'].toString();
      id = data['trx']['id'].toString();
      status = data['trx']['status'];
      datetime = data['trx']['datetime'];
      table = data['trx']['table'].toString();
      total = data['trx']['price'].toString();
      username = data['trx']['user_name'].toString();
      phone = (data['trx']['no_telp_user']??'').toString();
      // print(price);
      // detTransaction = _detTransaction;
      // menu = _menu;
    });
  }

  Future _open(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/reservation/op/open/$id'), headers: {
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

  String operation ='';
  Future _Operation(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/reservation/op/$operation/$id'), headers: {
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
                          onTap: () async{
                            Fluttertoast.showToast(msg: "Tunggu sebentar");
                            if (waiting == false) {
                              waiting = true;
                              _getDetailTrans(transaction[index].id.toString()).whenComplete(() {
                                _getTrans();
                              });
                            }
                            id = transaction[index].id.toString();
                            _open('', id!);
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            pref.setString('idnyatrans', transaction[index].id.toString());
                            print((transaction[index].id.toString()));
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
                                      Stack(
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
                                          Container(
                                              padding: EdgeInsets.only(top: 9, left: 9),
                                              child: Icon(Icons.circle, color: (transaction[index].is_opened != '1')?CustomColor.redBtn:Colors.transparent, size: 14,)
                                          ),
                                        ],
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
                                                text: transaction[index].datetime!.split(' ')[0],
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ),
                                            Container(
                                              child: CustomText.textHeading4(
                                                  text: transaction[index].username.toString(),
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.05).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.05).toString()),
                                                  maxLines: 1
                                              ),
                                            ),
                                            CustomText.bodyLight12(
                                              // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                                text: 'Pukul: '+transaction[index].datetime!.split(' ')[1].split(':')[0]+':'+transaction[index].datetime!.split(' ')[1].split(':')[1],
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ),
                                            CustomText.bodyLight12(
                                              // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                                text: transaction[index].table!+' meja',
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) * 0.00468,),
                                            CustomText.bodyMedium12(
                                                // text: transaction[index].type.toString(),
                                                text: (transaction[index].total).toString(),
                                                maxLines: 1,
                                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.033).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.033).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.033).toString())
                                            ),
                                            // Row(
                                            //   children: [
                                            //     CustomText.bodyRegular12(text: "Rp "+transaction[index].total.toString(), minSize: 14),
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: CustomSize.sizeWidth(context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(top: 0, left: 5),
                                          child: Icon(Icons.circle, color: Colors.transparent, size: 14,)
                                      ),
                                      (transaction[index].chat_user != '')?Container(
                                          padding: EdgeInsets.only(top: 15, right: 15),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(Icons.circle, color: (transaction[index].chat_user != '0')?CustomColor.redBtn:Colors.transparent, size: 26,),
                                              CustomText.bodyMedium12(text: (transaction[index].chat_user != '0')?transaction[index].chat_user:'', color: (transaction[index].chat_user != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString()))
                                            ],
                                          )
                                      ):Container(
                                          padding: EdgeInsets.only(top: 15, right: 15),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Icon(Icons.circle, color: (transaction[index].chat_user != '0')?CustomColor.redBtn:Colors.transparent, size: 26,),
                                              // CustomText.bodyMedium12(text: transaction[index].chat_user, color: (transaction[index].chat_user != '0')?Colors.white:Colors.transparent)
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
          ):Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
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
