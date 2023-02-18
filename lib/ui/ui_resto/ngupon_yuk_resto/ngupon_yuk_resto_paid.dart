import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/ui/ui_resto/ngupon_yuk_resto/ngupon_yuk_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class NguponYukRestoPaid extends StatefulWidget {
  @override
  _NguponYukRestoPaidState createState() => _NguponYukRestoPaidState();
}

class _NguponYukRestoPaidState extends State<NguponYukRestoPaid> {
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
    print('_getNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    nguponYuk = [];

    for (var h in data['data']['paid']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['code'].toString(),
          price: h['value'].toString(),
          status: h['status'],
          date: DateFormat('d-M-y').format(DateTime.parse(h['expired_at'].toString())).toString()
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

  Future _bagikanNguponYuk(String idShare, String emailShare)async{
    setState(() {});

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.put(Uri.parse(Links.nguponUrl + '/kupon/$idShare'),
        body: {
          'email' : emailShare,
        },
        headers: {
          // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    print('_bagikanNguponYuk');
    print(data.toString());

    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: new NguponYukRestoActivity()));
    setState(() {});
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

  TextEditingController email = TextEditingController(text: '');

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

  List number = [];
  Future _getNguponYukPaid()async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    id = pref.getString("idresto");
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/coupon/resto?restaurant=$id&action=used'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYukPaid');
    print(Links.nguponUrl + '/kupon?action=use&restaurant_id=$id');
    var data = json.decode(apiResult.body);
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
          date: DateFormat('d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      );
      // (
      //     id: int.parse(h['id'].toString()),
      //     price: h['value'].toString(),
      //     status: h['status'],
      //     date: DateFormat('H:m / d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      // );
      if (number.toString() == '[]') {
        number.add(1);
      } else {
        number.add((int.parse(number.last.toString())+1));
      }
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

  TextEditingController _loginTextName = TextEditingController(text: "");

  @override
  void initState() {
    _getNguponYukPaid();
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
                                              text: nguponYuk[index].code,
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
                                                  .format(int.parse(nguponYuk[index].price.toString())),
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
                                              text: 'Tanggal: '+nguponYuk[index].date.toString(),
                                              color: Colors.grey,
                                            ),
                                            // GestureDetector(
                                            //   onTap: (){
                                            //     QrKupon(nguponYuk[index].code.toString(), nguponYuk[index].id.toString(), nguponYuk[index].code.toString());
                                            //     // _getQrBCA(int.parse(nguponYuk[index].id.toString()), int.parse(nguponYuk[index].price.toString()));
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
                                            //             text: "Lihat",
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
