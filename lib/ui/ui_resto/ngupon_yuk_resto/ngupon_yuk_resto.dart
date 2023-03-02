import 'dart:convert';

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kam5ia/model/History.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/ngupon_yuk_resto/ngupon_yuk_resto_paid.dart';
import 'package:kam5ia/ui/ui_resto/ngupon_yuk_resto/ngupon_yuk_resto_unpaid.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';


class NguponYukRestoActivity extends StatefulWidget {
  @override
  _NguponYukRestoActivityState createState() => _NguponYukRestoActivityState();
}

class _NguponYukRestoActivityState extends State<NguponYukRestoActivity> {
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

  String refCode = "";
  List<History> history = [];
  // /page/history?resto=$id
  Future _useNguponYuk(String qrcode)async{

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    print('_useNguponYuk');
    print(qrcode.toString());
    // var apiResult = await http.delete(Uri.parse(Links.nguponUrl + '/kupon/$qrcode'), headers: {
    //   "Accept": "Application/json",
    //   "Authorization": "Bearer $token"
    // });
    // print('_useNguponYuk');
    // print(apiResult.body);
    // var data = json.decode(apiResult.body);

    // if (data['data'].toString().contains('code') == true) {
    //   refCode = data['data']['ref_code'].toString();
    // }
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

    // setState(() {
    //   history = _history;
    //   isLoading = false;
    // });

    // if (apiResult.statusCode == 200) {
    //   if (history.toString() == '[]') {
    //     ksg = true;
    //   } else {
    //     ksg = false;
    //   }
    // }
  }

  String? id;
  List<History> user = [];
  // /page/history?resto=$id
  Future _getHistoryResto()async{
    List<History> _user = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/history?resto=$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);

    // if (data['trans'] != null) {
    //   for(var v in data['trans']){
    //     History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type'],
    //       status: v['status'],
    //     );
    //     _user.add(h);
    //   }
    // }

    setState(() {
      user = _user;
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (user.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

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
    _getHistoryResto();
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
    Navigator.pushReplacement(context,
        PageTransition(
            type: PageTransitionType.fade,
            child: HomeActivityResto()));
    return Future.value(true);
  }


  @override
  void initState() {
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: CustomColor.secondary,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/7.5),
              child: AppBar(
                title: Column(
                  children: [
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 42,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: (){
                                  onWillPop();
                                },
                                child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
                            ),
                            SizedBox(
                              width: CustomSize.sizeWidth(context) / 88,
                            ),
                            GestureDetector(
                              onTap: (){
                                onWillPop();
                              },
                              child: CustomText.textHeading4(
                                  text: "Ngupon Yuk",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  maxLines: 1
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: ()async{
                            // Navigator.pop(context);
                            var result = await Navigator.push(context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: QRViewExample()));

                            if (result != '') {
                              Navigator.pushReplacement(context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: NguponYukRestoActivity()));
                            }
                            // String qrcode = '';
                            // try {
                            //   qrcode = (await BarcodeScanner.scan().whenComplete((){
                            //     _useNguponYuk(qrcode);
                            //     // makeTransaction(qrcode);
                            //     print('SCAN');
                            //     print(qrcode);
                            //     setState(() {});
                            //   })).toString() ;
                            //   setState(() {});
                            //   // makeTransaction(qrcode);
                            // } on PlatformException catch (error) {
                            //   if (error.code == BarcodeScanner.cameraAccessDenied) {
                            //     print('Izin kamera tidak diizinkan oleh si pengguna');
                            //   } else {
                            //     print('Error: $error');
                            //   }
                            // }
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                elevation: 1.5,
                bottom: TabBar(
                    labelColor: CustomColor.primary,
                    unselectedLabelColor: CustomColor.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 3, color: CustomColor.primaryLight),),
                    ),
                    tabs: [
                      Tab(
                        child: Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Kupon tersedia", style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Kupon terpakai", style: TextStyle(fontSize: 15)),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            body: TabBarView(
              children: [
                NguponYukRestoUnpaid(),
                NguponYukRestoPaid(),
                // OrderPending(),
                // OrderProcess(),
                // OrderReady(),
              ],
            ),
            // SafeArea(
            //   child: (isLoading)?Container(
            //       width: CustomSize.sizeWidth(context),
            //       height: CustomSize.sizeHeight(context),
            //       child: Center(child: CircularProgressIndicator(
            //         color: CustomColor.primaryLight,
            //       ))):SmartRefresher(
            //     enablePullDown: true,
            //     enablePullUp: false,
            //     header: WaterDropMaterialHeader(
            //       distance: 30,
            //       backgroundColor: Colors.white,
            //       color: CustomColor.primary,
            //     ),
            //     controller: _refreshController,
            //     onRefresh: _onRefresh,
            //     onLoading: _onLoading,
            //     child: SingleChildScrollView(
            //       controller: _scrollController,
            //       child: (ksg != true)?Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           SizedBox(
            //             height: CustomSize.sizeHeight(context) / 32,
            //             child: Container(
            //               color: Colors.white,
            //             ),
            //           ),
            //           Container(
            //             width: CustomSize.sizeWidth(context),
            //             color: Colors.white,
            //             child: Padding(
            //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
            //               child: (homepg != "1")?Row(
            //                 children: [
            //                   GestureDetector(
            //                       onTap: (){
            //                         Navigator.pop(context);
            //                       },
            //                       child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
            //                   ),
            //                   SizedBox(
            //                     width: CustomSize.sizeWidth(context) / 88,
            //                   ),
            //                   GestureDetector(
            //                     onTap: (){
            //                       Navigator.pop(context);
            //                     },
            //                     child: CustomText.textHeading4(
            //                         text: "Ngupon Yuk",
            //                         sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
            //                         maxLines: 1
            //                     ),
            //                   ),
            //                 ],
            //               ):Row(
            //                 children: [
            //                   GestureDetector(
            //                       onTap: (){
            //                         Navigator.pop(context);
            //                       },
            //                       child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
            //                   ),
            //                   SizedBox(
            //                     width: CustomSize.sizeWidth(context) / 88,
            //                   ),
            //                   GestureDetector(
            //                     onTap: (){
            //                       Navigator.pop(context);
            //                     },
            //                     child: CustomText.textHeading4(
            //                         text: "Ngupon Yuk",
            //                         sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
            //                         maxLines: 1
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           ListView.builder(
            //               shrinkWrap: true,
            //               controller: _scrollController,
            //               physics: NeverScrollableScrollPhysics(),
            //               itemCount: (homepg != "1")?history.length:user.length,
            //               itemBuilder: (_, index){
            //                 return Padding(
            //                   padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
            //                   child: GestureDetector(
            //                     onTap: (){
            //                       (homepg != "1")?Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id))):
            //                       Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(user[index].id)));
            //                     },
            //                     child: Container(
            //                       width: CustomSize.sizeWidth(context),
            //                       height: CustomSize.sizeHeight(context) / 4,
            //                       color: Colors.white,
            //                       child: Padding(
            //                         padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 38),
            //                         child: Row(
            //                           crossAxisAlignment: CrossAxisAlignment.center,
            //                           children: [
            //                             Container(
            //                               width: CustomSize.sizeWidth(context) / 2.8,
            //                               height: CustomSize.sizeWidth(context) / 2.8,
            //                               decoration: BoxDecoration(
            //                                   image: DecorationImage(
            //                                       image: (homepg != "1")?NetworkImage(Links.subUrl + history[index].img):(user[index].img != null)?NetworkImage(Links.subUrl + user[index].img):AssetImage('assets/default.png') as ImageProvider,
            //                                       fit: BoxFit.cover
            //                                   ),
            //                                   borderRadius: BorderRadius.circular(20)
            //                               ),
            //                             ),
            //                             SizedBox(width: CustomSize.sizeWidth(context) / 24,),
            //                             Container(
            //                               width: CustomSize.sizeWidth(context) / 2,
            //                               child: Column(
            //                                 crossAxisAlignment: CrossAxisAlignment.start,
            //                                 mainAxisAlignment: MainAxisAlignment.center,
            //                                 children: [
            //                                   CustomText.bodyMedium16(
            //                                       text: (homepg != "1")?history[index].name:user[index].name
            //                                       // history[index].name
            //                                       ,
            //                                       sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
            //                                       maxLines: 1
            //                                   ),
            //                                   CustomText.bodyLight12(
            //                                       text: (homepg != "1")?history[index].time:user[index].time,
            //                                       maxLines: 1,
            //                                       sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
            //                                   ),
            //                                   CustomText.bodyMedium12(
            //                                       text: (homepg != "1")?history[index].type:user[index].type,
            //                                       maxLines: 1,
            //                                       sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
            //                                   ),
            //                                   CustomText.bodyLight12(
            //                                       text: (homepg != "1")?(history[index].status == 'done')?"Selesai":'Dibatalkan':(user[index].status == 'done')?"Selesai":'Dibatalkan',
            //                                       maxLines: 1,
            //                                       minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
            //                                       color: (homepg != "1")?(history[index].status == 'done')?CustomColor.accent:CustomColor.redBtn:(user[index].status == 'done')?CustomColor.accent:CustomColor.redBtn
            //                                   ),
            //                                   Row(
            //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                                     children: [
            //                                       CustomText.textHeading4(
            //                                           text: (homepg != "1")?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((history[index].price+1000)):
            //                                           NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((user[index].price+1000)),
            //                                           sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
            //                                           maxLines: 1
            //                                       ),
            //                                       (homepg != "1")?
            //                                       Container(
            //                                         width: CustomSize.sizeWidth(context) / 4.2,
            //                                         height: CustomSize.sizeHeight(context) / 24,
            //                                         decoration: BoxDecoration(
            //                                             borderRadius: BorderRadius.circular(20),
            //                                             border: Border.all(color: CustomColor.accent)
            //                                         ),
            //                                         child: Center(child: CustomText.bodyRegular14(text: "Pesan Lagi", color: CustomColor.accent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),),
            //                                       ):Container(),
            //                                     ],
            //                                   )
            //                                 ],
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 );
            //               }
            //           ),
            //           SizedBox(height: CustomSize.sizeHeight(context) / 48,)
            //         ],
            //       ):Stack(
            //         children: [
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               SizedBox(
            //                 height: CustomSize.sizeHeight(context) / 32,
            //                 child: Container(
            //                   color: Colors.white,
            //                 ),
            //               ),
            //               Container(
            //                 width: CustomSize.sizeWidth(context),
            //                 color: Colors.white,
            //                 child: Padding(
            //                   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
            //                   child: (homepg != "1")?Row(
            //                     children: [
            //                       GestureDetector(
            //                           onTap: (){
            //                             Navigator.pop(context);
            //                           },
            //                           child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
            //                       ),
            //                       SizedBox(
            //                         width: CustomSize.sizeWidth(context) / 88,
            //                       ),
            //                       GestureDetector(
            //                         onTap: (){
            //                           Navigator.pop(context);
            //                         },
            //                         child: CustomText.textHeading4(
            //                             text: "Ngupon Yuk",
            //                             sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
            //                             maxLines: 1
            //                         ),
            //                       ),
            //                     ],
            //                   ):CustomText.textHeading3(
            //                       text: "Ngupon Yuk",
            //                       color: CustomColor.primary,
            //                       sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
            //                       maxLines: 1
            //                   ),
            //                 ),
            //               ),
            //               ListView.builder(
            //                   shrinkWrap: true,
            //                   controller: _scrollController,
            //                   physics: NeverScrollableScrollPhysics(),
            //                   itemCount: (homepg != "1")?history.length:user.length,
            //                   itemBuilder: (_, index){
            //                     return Padding(
            //                       padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
            //                       child: GestureDetector(
            //                         onTap: (){
            //                           (homepg != "1")?Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id))):
            //                           Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(user[index].id)));
            //                         },
            //                         child: Container(
            //                           width: CustomSize.sizeWidth(context),
            //                           height: CustomSize.sizeHeight(context) / 4,
            //                           color: Colors.white,
            //                           child: Padding(
            //                             padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 38),
            //                             child: Row(
            //                               crossAxisAlignment: CrossAxisAlignment.center,
            //                               children: [
            //                                 Container(
            //                                   width: CustomSize.sizeWidth(context) / 2.8,
            //                                   height: CustomSize.sizeWidth(context) / 2.8,
            //                                   decoration: BoxDecoration(
            //                                       image: DecorationImage(
            //                                           image: (homepg != "1")?NetworkImage(Links.subUrl + history[index].img):NetworkImage(Links.subUrl + user[index].img),
            //                                           fit: BoxFit.cover
            //                                       ),
            //                                       borderRadius: BorderRadius.circular(20)
            //                                   ),
            //                                 ),
            //                                 SizedBox(width: CustomSize.sizeWidth(context) / 24,),
            //                                 Container(
            //                                   width: CustomSize.sizeWidth(context) / 2,
            //                                   child: Column(
            //                                     crossAxisAlignment: CrossAxisAlignment.start,
            //                                     mainAxisAlignment: MainAxisAlignment.center,
            //                                     children: [
            //                                       CustomText.bodyMedium16(
            //                                           text: (homepg != "1")?history[index].name:user[index].name
            //                                           // history[index].name
            //                                           ,
            //                                           sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
            //                                           maxLines: 1
            //                                       ),
            //                                       CustomText.bodyLight12(
            //                                           text: (homepg != "1")?history[index].time:user[index].time,
            //                                           maxLines: 1,
            //                                           sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
            //                                       ),
            //                                       CustomText.bodyMedium12(
            //                                           text: (homepg != "1")?history[index].type:user[index].type,
            //                                           maxLines: 1,
            //                                           sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
            //                                       ),
            //                                       CustomText.bodyLight12(
            //                                           text: (homepg != "1")?(history[index].status == 'done')?"Selesai":'Dibatalkan':(user[index].status == 'done')?"Selesai":'Dibatalkan',
            //                                           maxLines: 1,
            //                                           minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
            //                                           color: (homepg != "1")?(history[index].status == 'done')?CustomColor.accent:CustomColor.redBtn:(user[index].status == 'done')?CustomColor.accent:CustomColor.redBtn
            //                                       ),
            //                                       Row(
            //                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                                         children: [
            //                                           CustomText.textHeading4(
            //                                               text: (homepg != "1")?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(history[index].price):
            //                                               NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(user[index].price),
            //                                               sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
            //                                               maxLines: 1
            //                                           ),
            //                                           (homepg != "1")?
            //                                           Container(
            //                                             width: CustomSize.sizeWidth(context) / 4.2,
            //                                             height: CustomSize.sizeHeight(context) / 24,
            //                                             decoration: BoxDecoration(
            //                                                 borderRadius: BorderRadius.circular(20),
            //                                                 border: Border.all(color: CustomColor.accent)
            //                                             ),
            //                                             child: Center(child: CustomText.bodyRegular14(text: "Pesan Lagi", color: CustomColor.accent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
            //                                           ):Container(),
            //                                         ],
            //                                       )
            //                                     ],
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                         ),
            //                       ),
            //                     );
            //                   }
            //               ),
            //               SizedBox(height: CustomSize.sizeHeight(context) / 48,)
            //             ],
            //           ),
            //           Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}



class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.

  Future _useNguponYuk(String qrcode)async{

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    print('qrcode');
    print(qrcode.toString());
    var apiResult = await http.delete(Uri.parse(Links.nguponUrl + '/kupon/${qrcode.replaceAll('#', '')}'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_useNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.delete(Uri.parse(Links.secondNguponUrl + '/kupon/${qrcode.replaceAll('#', '')}'), headers: {
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

    // if (data['data'].toString().contains('code') == true) {
    //   refCode = data['data']['ref_code'].toString();
    // }
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
      // history = _history;
      // isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      Navigator.pop(context, 'v');
      // if (history.toString() == '[]') {
      //   ksg = true;
      // } else {
      //   ksg = false;
      // }
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (result != null)
                    Row(
                      children: [
                        CustomText.textHeading4(
                            text: 'Kode: ',
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                            maxLines: 1
                        ),
                        CustomText.textHeading4(
                            text: '${result!.code}',
                            color: CustomColor.primaryLight,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                            maxLines: 1
                        ),
                      ],
                    ) else CustomText.textHeading4(
                      text: 'Scan qr terlebih dahulu!',
                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                      maxLines: 1
                  )
                    // Text('Kupon: ${result!.code}')
                  // else
                    // const Text('Scan a code'),
                  ,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                            return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: (snapshot.data.toString() == 'false')?CustomColor.redBtn:CustomColor.accent, // background
                                  // onPrimary: Colors.yellow, // foreground
                                ),
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                                child: FutureBuilder(
                                  future: controller?.getFlashStatus(),
                                  builder: (context, snapshot) {
                                    return CustomText.textHeading4(
                                        text: 'Flash: '+((snapshot.data.toString()! == 'false')?'off':'on'),
                                        color: Colors.white,
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                        maxLines: 1
                                    );
                                    // Text('Flash: '+((snapshot.data.toString()! == 'false')?'off':'on'));
                                  },
                                ));
                          }
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                            return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: (describeEnum(snapshot.data!).toString() == 'back')?CustomColor.accent:Colors.blueAccent, // background
                                  // onPrimary: Colors.yellow, // foreground
                                ),
                                onPressed: () async {
                                  await controller?.flipCamera();
                                  setState(() {});
                                },
                                child: FutureBuilder(
                                  future: controller?.getCameraInfo(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      return CustomText.textHeading4(
                                          text: (describeEnum(snapshot.data!).toString() == 'back')?'Kamera belakang':'Kamera depan',
                                          color: Colors.white,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                          maxLines: 1
                                      );
                                      // Text(
                                      //     (describeEnum(snapshot.data!).toString() == 'back')?'Kamera belakang':'Kamera depan');
                                    } else {
                                      return const Text('tunggu...');
                                    }
                                  },
                                ));
                          }
                        ),
                      )
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: <Widget>[
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.pauseCamera();
                  //         },
                  //         child: const Text('pause',
                  //             style: TextStyle(fontSize: 20)),
                  //       ),
                  //     ),
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.resumeCamera();
                  //         },
                  //         child: const Text('resume',
                  //             style: TextStyle(fontSize: 20)),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        print('result');
        print(result!.code);
        _useNguponYuk(result!.code.toString());
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}