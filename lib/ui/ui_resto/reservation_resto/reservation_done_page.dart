import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/Transaction.dart';
import 'package:indonesiarestoguide/model/User.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReservationDone extends StatefulWidget {
  @override
  _ReservationDoneState createState() => _ReservationDoneState();
}

class _ReservationDoneState extends State<ReservationDone> {
  ScrollController _scrollController = ScrollController();

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
    print(data);

    for(var v in data['trx']['pending']){
      Transaction r = Transaction.resto(
          id: v['id'],
          status: v['status'],
          username: v['username'],
          total: int.parse(v['total']),
          type: v['type']
      );
      _transaction.add(r);
    }

    setState(() {
      transaction = _transaction;
    });
  }

  String id;
  List<Transaction> detTransaction = [];
  Future _getDetailTrans(String Id)async{
    List<Transaction> _detTransaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/trans/'+'24', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['trans']){
      Transaction r = Transaction.restoDetail(
        type: v['type'],
        address: v['status'],
        ongkir: v['ongkir'],
        total: v['total'],
      );
      _detTransaction.add(r);
    }

    setState(() {
      detTransaction = _detTransaction;
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
    _getDetailTrans(id);
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
                          showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                              ),
                              context: context,
                              builder: (_){
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
                                                  CustomText.bodyLight16(text: "Nama Pemesan"),
                                                  CustomText.bodyLight16(text: 'Chifuyu'
                                                    // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight16(text: "Tanggal"),
                                                  CustomText.bodyLight16(text: '20-06-2021'
                                                    // totalOngkir
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight16(text: "Jam"),
                                                  CustomText.bodyLight16(text: '14:00'
                                                    // totalOngkir
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight16(text: "Meja Nomor"),
                                                  CustomText.bodyLight16(text: '08'
                                                    // totalOngkir
                                                  ),
                                                ],
                                              ),
                                              Divider(thickness: 1,),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.textTitle3(text: "Total Pembayaran"),
                                                  CustomText.textTitle3(text: '10'
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
                                                        CustomText.textHeading7(text: "Selesaikan Reservasi", color: Colors.white),
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
                                    color: Colors.amber,
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
                                          text: "Tanggal "+"20-06-2021",
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      CustomText.textHeading4(
                                          text: transaction[index].username.toString(),
                                          minSize: 20,
                                          maxLines: 1
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                                      CustomText.bodyMedium12(
                                        // text: transaction[index].type.toString(),
                                          text: "Jam "+"14:00",
                                          maxLines: 1,
                                          minSize: 13
                                      ),
                                      CustomText.bodyLight12(
                                        // text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Isi nya Alamat":"Ambil Ditempat":transaction[index].type.toString(),
                                          text: "Meja Nomor "+"08",
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      // Row(
                                      //   children: [
                                      //     CustomText.bodyRegular12(text: "Total "+transaction[index].total.toString(), minSize: 14),
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
