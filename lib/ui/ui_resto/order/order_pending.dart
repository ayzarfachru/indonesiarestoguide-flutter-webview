import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:full_screen_image/full_screen_image.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPending extends StatefulWidget {
  @override
  _OrderPendingState createState() => _OrderPendingState();
}

class _OrderPendingState extends State<OrderPending> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();

  bool ksg = false;

  List<Transaction> transaction = [];
  Future _getTrans()async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    checkId = pref.getString('idHomeResto')??'';
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    // print('kuntul');
    print('data oi');
    print(data);

    if (data['trx'].toString().contains('pending')) {
      for(var v in data['trx']['pending']){
        Transaction r = Transaction.resto3(
            id: int.parse(v['id'].toString()),
            status: v['status'].toString(),
            username: v['username'].toString(),
            total: (v['total'] != null)?int.parse(v['total'].toString()):0,
            type: v['type'].toString(),
            img: v['user_image'].toString(), chatroom: '', chat_user: (v['chat_user']??0).toString(),
            is_opened: (v['is_opened']??1).toString(),
            date_trans: ''
        );
        _transaction.add(r);
        if (v['type'] != 'Pesan antar' && v['status'] == 'pending') {
          if ((v['total']??0).toString() == '0') {
            _getPending('process', v['id'].toString());
            print('(v[total]??0).toString()');
            print((v['total']??0).toString());
          }
          // if (v['total'].toString() == '0') {
          //   _getPending('process', v['id'].toString());
          // }
        }
      }
    } else {
      ksg = true;
    }

    setState(() {
      transaction = _transaction;
    });

    if (apiResult.statusCode == 200) {
      if (transaction.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }


  Future _getTransDetRes(String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    // for(var v in data['trx']['pending']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type'],
    //       img: v['user_image']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      // transaction = _transaction;
    });
  }

  String userName = '';
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name')??'');
    });
  }

  Future<void> _checkPayBCA(String idTransaction)async {
    // List<Menu> _menu = [];

    setState(() {
      // isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(
        'https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$idTransaction'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    print('QR CODE 2');
    print(apiResult.statusCode);
    if (apiResult.statusCode.toString() == '500') {
      _getPending(operation = "cancel", idTransaction);
      Future.delayed(Duration(seconds: 0)).then((_) {
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: OrderActivity()));
      });
    }
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString()
        .contains('Unpaid')
        .toString());
    // statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
      // Fluttertoast.showToast(
      //   msg: "Anda belum membayar!",);
      _getPending(operation = "cancel", idTransaction);
      Future.delayed(Duration(seconds: 0)).then((_) {
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: OrderActivity()));
      });
    } else {
      Fluttertoast.showToast(
        msg: "Customer telah membayar, anda tidak dapat menolak pemesanan ini!",);
      //   _getDetail(idResto).whenComplete((){
      //     _getDetailTrans(id.toString()).whenComplete((){
      //       cariKurir();
      //     });
      //   });
      //   statusPay = 'false';
      //   Navigator.pop(context);
      //   _getPending('process', id.toString());
      //   Fluttertoast.showToast(
      //     msg: "Pembayaran berhasil",);
      // }
      // _base64 = data['response']['qr_image'];
      // Uint8List bytes = Base64Codec().decode(_base64);

      // if (_base64 != '') {
      //   showModalBottomSheet(
      //       isScrollControlled: true,
      //       shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
      //       ),
      //       context: context,
      //       builder: (_){
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
      //             Padding(
      //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
      //               child: Divider(thickness: 4,),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
      //             Center(
      //               child: CustomText.textHeading2(
      //                   text: "Qris",
      //                   minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
      //                   maxLines: 1
      //               ),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
      //             Center(
      //               child: FullScreenWidget(
      //                 child: Image.memory(bytes,
      //                   width: CustomSize.sizeWidth(context) / 1.2,
      //                   height: CustomSize.sizeWidth(context) / 1.2,
      //                 ),
      //                 backgroundColor: Colors.white,
      //               ),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
      //             Center(
      //               child: Container(
      //                 alignment: Alignment.center,
      //                 width: CustomSize.sizeWidth(context) / 1.2,
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     CustomText.textTitle2(
      //                         text: 'Total harga:',
      //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
      //                         maxLines: 1
      //                     ),
      //                     CustomText.textTitle2(
      //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
      //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
      //                         maxLines: 1
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
      //             Center(
      //               child: Container(
      //                 alignment: Alignment.center,
      //                 width: CustomSize.sizeWidth(context) / 1.2,
      //                 child: CustomText.textTitle1(
      //                     text: 'Scan disini untuk melakukan pembayaran',
      //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
      //                     maxLines: 1
      //                 ),
      //               ),
      //             ),
      //             Center(
      //               child: Container(
      //                 alignment: Alignment.center,
      //                 width: CustomSize.sizeWidth(context) / 1.2,
      //                 child: CustomText.textTitle1(
      //                     text: 'ke $nameRestoTrans!',
      //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
      //                     maxLines: 3
      //                 ),
      //               ),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
      //             GestureDetector(
      //               onTap: ()async{
      //                 Fluttertoast.showToast(
      //                   msg: "Anda belum membayar!",);
      //               },
      //               child: Center(
      //                 child: Container(
      //                   width: CustomSize.sizeWidth(context) / 1.1,
      //                   height: CustomSize.sizeHeight(context) / 14,
      //                   decoration: BoxDecoration(
      //                     // color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
      //                       borderRadius: BorderRadius.circular(50)
      //                   ),
      //                   child: Center(
      //                     child: Padding(
      //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //                       child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
      //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
      //           ],
      //         );
      //       }
      //   );
      // }
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
        // isLoadChekPay = false;
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
  }

  String address = "";
  String type = "";
  int all = 0;
  int total = 0;
  int ongkir = 0;
  String harga = '0';
  List<String> restoId = [];
  String phone = '';
  String date_trans = '';
  // String qty = '';
  List<String> qty = [];
  String? id;
  List<Menu> menu = [];
  String chatroom = 'null';
  String Meja = 'null';
  String note = '';
  String chatRestoCount = '';
  bool waiting = false;
  List<Transaction> detTransaction = [];
  Future _getDetailTrans(String Id, String name, String status)async{
    // waiting = true;
    idTrans = Id;
    List<Transaction> _detTransaction = [];
    List<Menu> _menu = [];

    print('IRG-$idTrans');
    print(restoAddress);
    print(pjTokoTrans);
    print(phoneRestoTrans);
    print(latRes);
    print(longRes);
    print(delivAddress);
    print(userNamePembeli);
    print(notelp);
    print(latUser);
    print(longUser);

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans/$Id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('OIII'+apiResult.body.toString());
    var data = json.decode(apiResult.body);
    // print(data);

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

    // note = data['trx']['note'].toString().split('[')[1].split(']')[0];
    for(var v in data['trx']['item']){
        Menu p = Menu(
            id: v['id'],
            name: v['name'],
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
    //       id: v['id'],
    //       name: v['name'],
    //       desc: v['desc'],
    //       qty: v['qty'].toString(),
    //       urlImg: v['img'],
    //       type: v['type'],
    //       is_recommended: v['is_recommended'],
    //       price: Price(original: int.parse(v['price'].toString())),
    //   );
    //   _menu.add(p);
    // }

    if (data['trx']['type'].toString() == 'Pesan antar') {
      var addresses = await
      locationFromAddress(data['trx']['address'].toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latUser = placemarks[0].latitude.toString();
          longUser = placemarks[0].longitude.toString();
          print('latUser');
          print(latUser);
          print(longUser);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
      // geoCode.forwardGeocoding(
      //     address: data['trx']['address'].toString());
      // Geocoder2.getDataFromAddress(address: data['trx']['address'].toString(), googleMapApiKey: 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE');
      var first = addresses;
      setState(() {
        // latUser = first.latitude.toString();
        // longUser = first.longitude.toString();
        print('latt');
        print(latUser);
        print(longUser);
      });
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
                                  controller: _controller,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      // height: CustomSize.sizeHeight(context) / 4.4,
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
                                        // height: CustomSize.sizeHeight(context) / 4.4,
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
                                                                (menu[index].price!.discounted == menu[index].price!.original || menu[index].price!.discounted == 'null' || menu[index].price!.discounted == '' || menu[index].price!.discounted == 0)?CustomText.bodyMedium14(
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
                                                CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(1000), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
                                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((all+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
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
                                                                CustomText.bodyMedium12(text: chatRestoCount, color: (chatRestoCount != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()))
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
                                  _checkPayBCA(id!);
                                  setState(() { });
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
                                            CustomText.textHeading7(text: "Tolak", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                            CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
                              //         _getPending(operation = "cancel", id!);
                              //         setStateModal(() {});
                              //         Future.delayed(Duration(seconds: 0)).then((_) {
                              //           Navigator.pushReplacement(
                              //               context,
                              //               PageTransition(
                              //                   type: PageTransitionType.fade,
                              //                   child: OrderActivity()));
                              //         });
                              //         setState(() { });
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
                              //                   CustomText.textHeading7(text: "Tolak", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                              //                   CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     GestureDetector(
                              //       onTap: (){
                              //           if (type == 'delivery') {
                              //             _getPending(operation = "process", id!);
                              //             Future.delayed(Duration(seconds: 0)).then((_) {
                              //               Navigator.pushReplacement(
                              //                   context,
                              //                   PageTransition(
                              //                       type: PageTransitionType.fade,
                              //                       child: OrderActivity()));
                              //             });
                              //             // if (int.parse(deposit) >= (ongkir+1000)) {
                              //             //   // cariKurir()!.whenComplete((){
                              //             //     _getPending(operation = "process", id!);
                              //             //     Future.delayed(Duration(seconds: 0)).then((_) {
                              //             //       Navigator.pushReplacement(
                              //             //           context,
                              //             //           PageTransition(
                              //             //               type: PageTransitionType.fade,
                              //             //               child: OrderActivity()));
                              //             //     });
                              //             //   // });
                              //             // } else {
                              //             //   Fluttertoast.showToast(
                              //             //     msg: 'Saldo deposit anda tidak mencukupi untuk melanjutkan transaksi ini!',);
                              //             // }
                              //             // _getPending(operation = "process", id!);
                              //             // Future.delayed(Duration(seconds: 0)).then((_) {
                              //             //   Navigator.pushReplacement(
                              //             //       context,
                              //             //       PageTransition(
                              //             //           type: PageTransitionType.fade,
                              //             //           child: OrderActivity()));
                              //             // });
                              //           } else {
                              //             _getPending(operation = "process", id!).whenComplete(() {
                              //               Future.delayed(Duration(seconds: 0)).then((_) {
                              //                 Navigator.pushReplacement(
                              //                     context,
                              //                     PageTransition(
                              //                         type: PageTransitionType.fade,
                              //                         child: OrderActivity()));
                              //               });
                              //             });
                              //             // if (int.parse(deposit) >= (1000)) {
                              //             //   _getPending(operation = "process", id!).whenComplete(() {
                              //             //     Future.delayed(Duration(seconds: 0)).then((_) {
                              //             //       Navigator.pushReplacement(
                              //             //           context,
                              //             //           PageTransition(
                              //             //               type: PageTransitionType.fade,
                              //             //               child: OrderActivity()));
                              //             //     });
                              //             //   });
                              //             // } else {
                              //             //   Fluttertoast.showToast(
                              //             //     msg: 'Saldo deposit anda tidak mencukupi untuk melanjutkan transaksi ini!',);
                              //             // }
                              //           }
                              //         setStateModal(() {});
                              //         setState(() { });
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
                              //                   CustomText.textHeading7(text: "Proses", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                              //                   CustomText.textHeading7(text: "Pesanan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
                          SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                        ],
                      ),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    )
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
      notelp = data['trx']['user_phone'].toString();
      chatroom = (data['trx']['chatroom'] != null)?(data['trx']['chatroom']['id']??'null').toString():'null';
      print('chatt '+chatroom.toString());
      Meja = (data['trx']['restaurant_tables_id'] != null)?(data['trx']['restaurant_tables_id']??'null').toString():'null';
      // Meja = '1';
      ongkir = int.parse(data['trx']['ongkir'].toString());
      total = int.parse(data['trx']['total'].toString());
      all = total+ongkir;
      type = data['trx']['type'].toString();
      address = data['trx']['address'].toString();
      delivAddress = address.toString();
      phone = data['trx']['user_phone'].toString();
      date_trans = data['trx']['created_at'].toString();
      // print(price);
      // detTransaction = _detTransaction;
      menu = _menu;
    });
  }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + address;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String idTrans = '';
  String restoAddress = '';
  String pjTokoTrans = '';
  String phoneRestoTrans = "";
  String latRes = "";
  String longRes = "";
  String delivAddress = "";
  String userNamePembeli = "";
  String notelp = "";
  String latUser = "";
  String longUser = "";
  Future<String?>? cariKurir()async{
    // print(qrscan);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse('https://qurir.devastic.com/api/borzo/checkout'),
        body: {
          'address_pick_up': restoAddress,
          'name_pick_up': pjTokoTrans,
          'phone_pick_up': phoneRestoTrans,
          'latitude_pick_up': latRes,
          'longitude_pick_up': longRes,
          'address_sender': delivAddress,
          'name_sender': userNamePembeli,
          'phone_sender': notelp,
          'latitude_sender': latUser,
          'longitude_sender': longUser,
          'transaction_id': 'IRG-$idTrans'
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('Cek Harga '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // totalOngkirBorzo = data['price'];
    setState((){});

    // for(var v in data['device_id']){
    //   // User p = User.resto(
    //   //   name: v['device_id'],
    //   // );
    //   List<String> id = [];
    //   id.add(v);
    //   print('099');
    //   print(id);
    //   OneSignal.shared.postNotification(OSCreateNotification(
    //     playerIds: id,
    //     heading: "$nameUser telah memesan produk di toko Anda",
    //     content: "Cek sekarang !",
    //     androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    //   ));
    //   // await OneSignal.shared.postNotificationWithJson();
    //   // user3.add(v['device_id']);
    //   // _user.add(p);
    // }

    if(data['status_code'] == 200){
      print('IRG-$idTrans');
      print(restoAddress);
      print(pjTokoTrans);
      print(phoneRestoTrans);
      print(latRes);
      print(longRes);
      print(delivAddress);
      print(userNamePembeli);
      print(notelp);
      print(latUser);
      print(longUser);
      // totalOngkirBorzo = data['price'];
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // pref.setString('totalOngkirBorzo', totalOngkirBorzo);
      setState((){});
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('note');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
      // await pref.remove('restoIdUsr');
      // pref.remove("addressDelivTrans");
      // pref.remove("distan");
      // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
      // print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
    }
  }

  Future _open(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/open/$id'), headers: {
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
  Future _getPending(String operation, String id)async{
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


  bool scrl = false;

  late ScrollController _controller;
  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {});
    }
    if (_controller.offset <= _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        print('oy');
        scrl = true;
      });
    }
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
    pref.setString('inDetail', '2');
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

    setState(() {
      meja = _meja;
      // isLoading = false;
    });

    String id = pref.getString("idHomeResto") ?? "";
    var apiResult2 = await http
        .get(Uri.parse(Links.mainUrl + "/deposit/$id"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data2 = json.decode(apiResult2.body);
    deposit = data2['balance'].toString();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getUserDataResto()async{
    // List<Menu> _menu = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/userdata/'+checkId), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(Links.mainUrl + '/resto/userdata/'+checkId);
    var data = json.decode(apiResult.body);

    print('id e '+data.toString());
    print('id e '+checkId.toString());
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
      pjTokoTrans = data['name_pj'].toString();
      // restoAddress = '';
      // phoneRestoTrans = '';
      // latRes = '';
      // longRes = '';

      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // bankTokoTrans = data['bank'].toString();
      // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  String checkId = "";
  Future _getDetail()async{
    // waiting = true;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$checkId'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('resto data '+data.toString());

    setState(() {
      restoAddress = data['data']['address'];
      phoneRestoTrans = data['data']['phone_number'].toString();
      latRes = data['data']['lat'].toString();
      longRes = data['data']['long'].toString();
      // waiting = false;
    });
    if (latRes == 'null' || longRes == 'null') {
      var addresses = await
      locationFromAddress(restoAddress.toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latRes = placemarks[0].latitude.toString();
          longRes = placemarks[0].longitude.toString();
          print('latRes');
          print(latRes);
          print(longRes);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
      // geoCode.forwardGeocoding(
      //     address: restoAddress.toString());
      // Geocoder2.getDataFromAddress(address: restoAddress.toString(), googleMapApiKey: 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE');
      var first = addresses;
      setState(() {
        // latRes = first.latitude.toString();
        // longRes = first.longitude.toString();
        // print('latt');
        // print(latUser);
        // print(longUser);
      });
    }
  }

  @override
  void initState() {
    _getQr();
    _getTrans();
    getUser();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    // _getDetailTrans(id);
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
                              userNamePembeli = transaction[index].username.toString();
                              if (waiting == false) {
                                waiting = true;
                                _getDetail().whenComplete((){
                                  _getUserDataResto().whenComplete((){
                                    _getDetailTrans(transaction[index].id.toString(), userName, transaction[index].status!).whenComplete((){
                                      _getTrans();
                                    });
                                  });
                                });
                              }
                              id = transaction[index].id.toString();
                              _open('', id!);
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              pref.setString('idnyatrans', transaction[index].id.toString());
                              print(id);
                              setState(() {});
                              // harga = menu[index].price!.original.toString();
                              // qty = menu[index].qty.toString();
                              // print((transaction[index].id));
                              // Future.delayed(Duration(milliseconds: 1), () {
                              //   showModalBottomSheet(
                              //       isScrollControlled: true,
                              //       shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                              //       ),
                              //       context: context,
                              //       builder: (_){
                              //         return Padding(
                              //           padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                              //           child: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               SizedBox(height: CustomSize.sizeHeight(context) / 288,),
                              //               Padding(
                              //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.6),
                              //                 child: Divider(thickness: 3,),
                              //               ),
                              //               SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                              //               Container(
                              //                 width: CustomSize.sizeWidth(context),
                              //                 height: CustomSize.sizeHeight(context) / 3.8,
                              //                 decoration: BoxDecoration(
                              //                   color: Colors.white,
                              //                   borderRadius: BorderRadius.circular(20),
                              //                   boxShadow: [
                              //                     BoxShadow(
                              //                       color: Colors.grey.withOpacity(0.5),
                              //                       spreadRadius: 0,
                              //                       blurRadius: 4,
                              //                       offset: Offset(0, 3), // changes position of shadow
                              //                     ),
                              //                   ],
                              //                 ),
                              //                 child: Padding(
                              //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //                   child: Column(
                              //                     crossAxisAlignment: CrossAxisAlignment.start,
                              //                     children: [
                              //                       SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                              //                       CustomText.textTitle3(text: "Rincian Pembayaran"),
                              //                       SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                              //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //                         children: [
                              //                           CustomText.bodyLight16(text: "Harga"),
                              //                           CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total)
                              //                             // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)
                              //                           ),
                              //                         ],
                              //                       ),
                              //                       SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                              //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //                         children: [
                              //                           CustomText.bodyLight16(text: "Ongkir"),
                              //                           CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir)
                              //                             // totalOngkir
                              //                           ),
                              //                         ],
                              //                       ),
                              //                       SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                              //                       Divider(thickness: 1,),
                              //                       SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                              //                       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //                         children: [
                              //                           CustomText.textTitle3(text: "Total Pembayaran"),
                              //                           CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(all)
                              //                             // NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ],
                              //                   ),
                              //                 ),
                              //               ),
                              //               SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                              //               Container(
                              //                 width: CustomSize.sizeWidth(context),
                              //                 height: CustomSize.sizeHeight(context) / 7.2,
                              //                 decoration: BoxDecoration(
                              //                   color: Colors.white,
                              //                   borderRadius: BorderRadius.circular(20),
                              //                   boxShadow: [
                              //                     BoxShadow(
                              //                       color: Colors.grey.withOpacity(0.5),
                              //                       spreadRadius: 0,
                              //                       blurRadius: 4,
                              //                       offset: Offset(0, 3), // changes position of shadow
                              //                     ),
                              //                   ],
                              //                 ),
                              //                 child: Padding(
                              //                   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                              //                   child: Row(
                              //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //                     children: [
                              //                       Row(
                              //                         children: [
                              //                           Container(
                              //                             padding: EdgeInsets.all(5),
                              //                             child: Container(
                              //                               width: CustomSize.sizeWidth(context) / 7.6,
                              //                               height: CustomSize.sizeWidth(context) / 7.6,
                              //                               decoration: BoxDecoration(
                              //                                   color: CustomColor.primary,
                              //                                   shape: BoxShape.circle
                              //                               ),
                              //                               child: Center(
                              //                                 child: Icon(
                              //                                   // (_transCode == 1)?
                              //                                   FontAwesome.motorcycle
                              //                                   // :(_transCode == 2)?MaterialCommunityIcons.shopping:Icons.restaurant
                              //                                   , color: Colors.white, size: 21,),
                              //                               ),
                              //                             ),
                              //                           ),
                              //                           SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                              //                           Column(
                              //                             mainAxisAlignment: MainAxisAlignment.center,
                              //                             crossAxisAlignment: CrossAxisAlignment.start,
                              //                             children: [
                              //                               CustomText.textHeading7(text:
                              //                               // (_transCode == 1)?
                              //                               "Pesan antar"
                              //                                 // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                              //                                 ,),
                              //                               SizedBox(height: CustomSize.sizeHeight(context) / 138,),
                              //                               CustomText.bodyRegular15(text:
                              //                               // (_transCode == 1)?
                              //                               "Alamat Pengiriman"
                              //                                 // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                              //                                 ,),
                              //                               CustomText.textHeading7(text:
                              //                               // (_transCode == 1)?
                              //                               "Jl Jemur Gayungan 1 no 86"
                              //                                 // :(_transCode == 2)?"Ambil Langsung":"Makan Ditempat"
                              //                                 ,),
                              //                             ],
                              //                           ),
                              //                         ],
                              //                       ),
                              //                     ],
                              //                   ),
                              //                 ),
                              //               ),
                              //               SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                              //               Row(
                              //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //                 children: [
                              //                   GestureDetector(
                              //                     onTap: (){
                              //                       Navigator.pop(context);
                              //                     },
                              //                     child: Center(
                              //                       child: Container(
                              //                         width: CustomSize.sizeWidth(context) / 2.3,
                              //                         height: CustomSize.sizeHeight(context) / 14,
                              //                         decoration: BoxDecoration(
                              //                             color: CustomColor.redBtn,
                              //                             borderRadius: BorderRadius.circular(50)
                              //                         ),
                              //                         child: Center(
                              //                           child: Padding(
                              //                             padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //                             child: Column(
                              //                               mainAxisAlignment: MainAxisAlignment.center,
                              //                               crossAxisAlignment: CrossAxisAlignment.center,
                              //                               children: [
                              //                                 CustomText.textHeading7(text: "Tolak", color: Colors.white),
                              //                                 CustomText.textHeading7(text: "Pesanan", color: Colors.white),
                              //                               ],
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   GestureDetector(
                              //                     onTap: (){
                              //                       Navigator.pop(context);
                              //                     },
                              //                     child: Center(
                              //                       child: Container(
                              //                         width: CustomSize.sizeWidth(context) / 2.3,
                              //                         height: CustomSize.sizeHeight(context) / 14,
                              //                         decoration: BoxDecoration(
                              //                             color: CustomColor.accent,
                              //                             borderRadius: BorderRadius.circular(50)
                              //                         ),
                              //                         child: Center(
                              //                           child: Padding(
                              //                             padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //                             child: Column(
                              //                               mainAxisAlignment: MainAxisAlignment.center,
                              //                               crossAxisAlignment: CrossAxisAlignment.center,
                              //                               children: [
                              //                                 CustomText.textHeading7(text: "Terima", color: Colors.white),
                              //                                 CustomText.textHeading7(text: "Pesanan", color: Colors.white),
                              //                               ],
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //               SizedBox(height: CustomSize.sizeHeight(context) / 56,),
                              //             ],
                              //           ),
                              //         );
                              //       }
                              //   );
                              // });
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
                                                  text: (transaction[index].type.toString() != "Makan Ditempat")?(transaction[index].type.toString() != "Ambil Sekarang")?"Pesan Antar":"Ambil Ditempat":transaction[index].type.toString(),
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              // CustomText.bodyLight12(
                                              //     text: transaction[index].date_trans.toString().split('T')[1].split(':')[0]+':'+transaction[index].date_trans.toString().split('T')[1].split(':')[1]+', '+DateFormat('dd-MM-y').format(DateTime.parse(transaction[index].date_trans)).toString(),
                                              //     maxLines: 1,
                                              //     minSize: 10
                                              // ),
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
                                                  CustomText.bodyRegular12(text: (transaction[index].total!+1000).toString(), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
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
                                            padding: EdgeInsets.only(top: 0, left: 5),
                                            child: Icon(Icons.circle, color: Colors.transparent, size: 14,)
                                        ),
                                        (transaction[index].chat_user != '')?Container(
                                            padding: EdgeInsets.only(top: 15, right: 15),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(Icons.circle, color: (transaction[index].chat_user != '0')?CustomColor.redBtn:Colors.transparent, size: 26,),
                                                CustomText.bodyMedium12(text: (transaction[index].chat_user != '0')?transaction[index].chat_user:'', color: (transaction[index].chat_user != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()))
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
