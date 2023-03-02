import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:full_screen_image/full_screen_image.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/ui/ui_resto/ngupon_yuk_resto/ngupon_yuk_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NguponYukRestoUnpaid extends StatefulWidget {
  @override
  _NguponYukRestoUnpaidState createState() => _NguponYukRestoUnpaidState();
}

class _NguponYukRestoUnpaidState extends State<NguponYukRestoUnpaid> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  String img = "";

  bool isLoading = false;
  bool ksg = false;

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img')??'');
      print(img);
    });
  }

  // /page/history?resto=$id
  List<NguponYuk> nguponYuk = [];
  Future _getNguponYuk(String searchEmail)async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$searchEmail'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYukSearch');
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=use&user=$searchEmail'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print(data['data']['paid']);

    nguponYuk = [];

    for (var h in data['data']['paid']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['code'].toString(),
          price: h['value'].toString(),
          status: h['status'],
          // date: DateFormat('H:m / d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
          date: DateFormat('d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      );
      nguponYuk.add(c);
    }

    // for(var v in data['trans']){
    //   History h = History(
    //     id: v['id'],
    //     name: v['resto_name'],
    //     time: v['time'],
    //     price: v['price'],
    //     img: v['resto_img'],
    //     type: v['type'],
    //     status: v['status'],
    //   );
    //   _history.add(h);
    // }

    setState(() {
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (nguponYuk.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

  List number = [];
  String formattedDate = DateFormat('y-MM-dd').format(DateTime.now());
  Future _getNguponYukUnpaid()async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    id = pref.getString("idresto");
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/coupon/resto?restaurant=$id&action=paid'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYukUnpaid');
    print(Links.nguponUrl + '/kupon?action=use&restaurant_id=$id');
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/coupon/resto?restaurant=$id&action=paid'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print(data);
    // print(data['data']['unpaid']);

    nguponYuk = [];

    for (var h in data['data']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['code'].toString(),
          price: h['value'].toString(),
          status: h['status'],
          // date: DateFormat('H:m / d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
          date: DateFormat('y-MM-dd').format(DateTime.parse(h['updated_at'].toString())).toString()
      );
      if (int.parse((DateFormat('y-MM-dd').format(DateTime.parse(h['updated_at'].toString())).toString()).replaceAll('-', '')) < int.parse(formattedDate!.replaceAll('-', '').toString())) {
        if (number.toString() == '[]') {
          number.add(1);
        } else {
          number.add((int.parse(number.last.toString())+1));
        }
        nguponYuk.add(c);
      }
    }

    // for(var v in data['trans']){
    //   History h = History(
    //     id: v['id'],
    //     name: v['resto_name'],
    //     time: v['time'],
    //     price: v['price'],
    //     img: v['resto_img'],
    //     type: v['type'],
    //     status: v['status'],
    //   );
    //   _history.add(h);
    // }

    setState(() {
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (nguponYuk.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

  String? id;

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (homepg != '1') {
        // _getNguponYuk();
      } else {
        // idResto();
        // _getNguponYuk();
      }
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    // _getNguponYuk();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  idResto() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    id = pref.getString("idresto");
    print('NGAB '+id.toString());
  }

  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // countChat();
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
    Navigator.pop(context);
    return Future.value(true);
  }

  late String _base64 = "";
  bool isLoadChekPay = false;
  bool loadQr = false;

  String statusPay = '';
  Future<void> _checkPayBCA(int trx_id)async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=NGY&trx_id=$trx_id'),
      // var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=NGY&trx_id=$id'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
      // _checkoutNguponYuk(trx_id);
    } else {
      statusPay = 'false';

      _checkoutNguponYuk(trx_id);
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
    }
    setState(() {
      isLoadChekPay = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  Future _checkoutNguponYuk(int trx_id)async{
    setState(() {});

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.post(Uri.parse(Links.nguponUrl + '/kupon'),
        body: {
          'email' : email,
          'batch_id' : trx_id.toString(),
          'action' : 'paid'
        },
        headers: {
          // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.post(Uri.parse(Links.secondNguponUrl + '/kupon'),
          body: {
            'email' : email,
            'batch_id' : trx_id.toString(),
            'action' : 'paid'
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
          data = json.decode(apiResultSecond.body);
          print('_apiResultSecond data 2');
          // print(data);
          setState((){});
        } else {
          print('_apiResultSecond success');
        }
    print('_checkoutNguponYuk');
    print(data.toString());

    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: new NguponYukRestoActivity()));
    setState(() {});
  }


  TextEditingController _loginTextName = TextEditingController(text: "");

  @override
  void initState() {
    _getNguponYukUnpaid();
    getHomePg();
    getImg();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  // SizedBox(height: CustomSize.sizeHeight(context) / 72,),
                  // Container(
                  //   width: CustomSize.sizeWidth(context),
                  //   height: CustomSize.sizeHeight(context) / 16,
                  //   decoration: BoxDecoration(
                  //     color: CustomColor.secondary,
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Icon(FontAwesome.search, size: 24, color: Colors.grey,),
                  //         SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                  //         Expanded(
                  //           child: TextField(
                  //             controller: _loginTextName,
                  //             keyboardType: TextInputType.emailAddress,
                  //             cursorColor: Colors.black,
                  //             textInputAction: TextInputAction.search,
                  //             onSubmitted: (v){
                  //               _getNguponYuk(_loginTextName.text);
                  //               // _search(_loginTextName.text, '');
                  //               setState(() {});
                  //             },
                  //             onChanged: (v){
                  //               print(v.length);
                  //               if(v.length == 0){
                  //                 setState(() {});
                  //               }
                  //             },
                  //             style: GoogleFonts.poppins(
                  //                 textStyle:
                  //                 TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), color: Colors.black, fontWeight: FontWeight.w600)),
                  //             decoration: InputDecoration(
                  //               isDense: true,
                  //               // contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                  //               hintText: "Cari berdasarkan email",
                  //               hintStyle: GoogleFonts.poppins(
                  //                   textStyle:
                  //                   TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), color: Colors.grey)),
                  //               helperStyle: GoogleFonts.poppins(
                  //                   textStyle: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))),
                  //               enabledBorder: InputBorder.none,
                  //               focusedBorder: InputBorder.none,
                  //             ),
                  //           ),
                  //         ),
                  //         // Row(
                  //         //   children: [
                  //         //     (provinsi != '' || fasilitas != '' || tipe != '')?GestureDetector(
                  //         //       onTap: (){
                  //         //         // showAlertDialog();
                  //         //         provinsi = '';
                  //         //         kota1 = '';
                  //         //         kota = [];
                  //         //         facilityList2 = '';
                  //         //         fasilitas = '';
                  //         //         tipe = '';
                  //         //         FocusScope.of(context).unfocus();
                  //         //         setState(() {});
                  //         //       },
                  //         //         child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                  //         //     ):Container(),
                  //         //     SizedBox(width: CustomSize.sizeWidth(context) / 82,),
                  //         //     // GestureDetector(
                  //         //     //   onTap: (){
                  //         //     //     showAlertDialog();
                  //         //     //     FocusScope.of(context).unfocus();
                  //         //     //   },
                  //         //     //     child: Icon(FontAwesome.filter, size: 24, color: (provinsi != '' || fasilitas != '' || tipe != '')?Colors.blue:Colors.grey,)
                  //         //     // ),
                  //         //   ],
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 72,),
                  ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: nguponYuk.length,
                      itemBuilder: (_, index){
                        return Column(
                          children: [
                            SizedBox(
                              height: CustomSize.sizeHeight(context) / 86,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText.bodyMedium16a(
                                  textAlign: TextAlign.left,
                                  sizeNew: double.parse(
                                      ((MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()
                                          .contains('.') ==
                                          true)
                                          ? (MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()
                                          .split('.')[0]
                                          : (MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()),
                                  // text: DateFormat("d MMM yyyy - HH:mm").format(
                                  //     DateTime.parse(nguponYuk[index].date.toString())),
                                  text: number[index].toString(),
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText.bodyMedium16a(
                                              textAlign: TextAlign.left,
                                              text: (nguponYuk[index].status == "reserved")
                                                  ? "💸 Belum dibayar"
                                                  : "💸 Telah dibayar",
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()),
                                            ),
                                            CustomText.bodyMedium16c(
                                              textAlign: TextAlign.right,
                                              text: NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp. ',
                                                  decimalDigits: 0)
                                                  .format((int.parse(nguponYuk[index].price.toString()))),
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()),
                                              color: (nguponYuk[index].status == "reserved")
                                                  ? CustomColor.redBtn
                                                  : CustomColor.accent,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText.bodyMedium16a(
                                              textAlign: TextAlign.left,
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()),
                                              // text: DateFormat("d MMM yyyy - HH:mm").format(
                                              //     DateTime.parse(nguponYuk[index].date.toString())),
                                              text: nguponYuk[index].date.toString(),
                                              color: Colors.grey,
                                            ),
                                            // GestureDetector(
                                            //   onTap: (){
                                            //     _getQrBCA(int.parse(nguponYuk[index].id.toString()), int.parse(nguponYuk[index].price.toString()));
                                            //   },
                                            //   child: Container(
                                            //     // height: CustomSize.sizeHeight(context) / 24,
                                            //     decoration: BoxDecoration(
                                            //         borderRadius: BorderRadius.circular(20),
                                            //         border: Border.all(color: CustomColor.accent)
                                            //     ),
                                            //     child: Padding(
                                            //       padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.03, vertical: CustomSize.sizeHeight(context) * 0.005),
                                            //       child: Center(
                                            //         child: CustomText.textTitle8(
                                            //             text: "Bayar",
                                            //             color: CustomColor.accent,
                                            //             sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        );
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                ],
              ),
            ),
          ):SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: CustomSize.sizeHeight(context) / 72,),
                  // Container(
                  //   width: CustomSize.sizeWidth(context),
                  //   height: CustomSize.sizeHeight(context) / 16,
                  //   decoration: BoxDecoration(
                  //     color: CustomColor.secondary,
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Icon(FontAwesome.search, size: 24, color: Colors.grey,),
                  //         SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                  //         Expanded(
                  //           child: TextField(
                  //             controller: _loginTextName,
                  //             keyboardType: TextInputType.emailAddress,
                  //             cursorColor: Colors.black,
                  //             textInputAction: TextInputAction.search,
                  //             onSubmitted: (v){
                  //               _getNguponYuk(_loginTextName.text);
                  //               // _search(_loginTextName.text, '');
                  //               setState(() {});
                  //             },
                  //             onChanged: (v){
                  //               print(v.length);
                  //               if(v.length == 0){
                  //                 setState(() {});
                  //               }
                  //             },
                  //             style: GoogleFonts.poppins(
                  //                 textStyle:
                  //                 TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), color: Colors.black, fontWeight: FontWeight.w600)),
                  //             decoration: InputDecoration(
                  //               isDense: true,
                  //               // contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                  //               hintText: "Cari berdasarkan email",
                  //               hintStyle: GoogleFonts.poppins(
                  //                   textStyle:
                  //                   TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), color: Colors.grey)),
                  //               helperStyle: GoogleFonts.poppins(
                  //                   textStyle: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))),
                  //               enabledBorder: InputBorder.none,
                  //               focusedBorder: InputBorder.none,
                  //             ),
                  //           ),
                  //         ),
                  //         // Row(
                  //         //   children: [
                  //         //     (provinsi != '' || fasilitas != '' || tipe != '')?GestureDetector(
                  //         //       onTap: (){
                  //         //         // showAlertDialog();
                  //         //         provinsi = '';
                  //         //         kota1 = '';
                  //         //         kota = [];
                  //         //         facilityList2 = '';
                  //         //         fasilitas = '';
                  //         //         tipe = '';
                  //         //         FocusScope.of(context).unfocus();
                  //         //         setState(() {});
                  //         //       },
                  //         //         child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                  //         //     ):Container(),
                  //         //     SizedBox(width: CustomSize.sizeWidth(context) / 82,),
                  //         //     // GestureDetector(
                  //         //     //   onTap: (){
                  //         //     //     showAlertDialog();
                  //         //     //     FocusScope.of(context).unfocus();
                  //         //     //   },
                  //         //     //     child: Icon(FontAwesome.filter, size: 24, color: (provinsi != '' || fasilitas != '' || tipe != '')?Colors.blue:Colors.grey,)
                  //         //     // ),
                  //         //   ],
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 72,),
                  Container(child: CustomText.bodyMedium12(text: "Tidak ditemukan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center),
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
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
