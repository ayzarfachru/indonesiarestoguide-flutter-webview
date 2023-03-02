import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kam5ia/model/History.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ngupon_yuk/ngupon_yuk_unpaid.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kam5ia/ui/detail/detail_history.dart';

import 'ngupon_yuk_paid.dart';
import 'ngupon_yuk_referral_user.dart';

class NguponYukRefActivity extends StatefulWidget {
  @override
  _NguponYukRefActivityState createState() => _NguponYukRefActivityState();
}

class _NguponYukRefActivityState extends State<NguponYukRefActivity> {
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
  Future _getNguponYuk()async{
    List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=use&user=$email'), headers: {
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

    if (data['data'].toString().contains('code') == true) {
      refCode = data['data']['ref_code'].toString();
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
      history = _history;
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (history.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
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
        _getNguponYuk();
      } else {
        idResto();
      }
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    _getNguponYuk();
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
            child: ProfileActivity()));
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
    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: MediaQuery(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DefaultTabController(
            length: 1,
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
                                  Navigator.pushReplacement(context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: ProfileActivity()));
                                },
                                child: CustomText.textHeading4(
                                    text: "Ngupon Yuk",
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ),
                          (refCode != '')?GestureDetector(
                            onTap: (){
                              // Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                CustomText.textHeading4(
                                    text: "Referral",
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1
                                ),
                                SizedBox(
                                  width: CustomSize.sizeWidth(context) / 88,
                                ),
                                CustomText.textHeading4(
                                    text: refCode,
                                    color: CustomColor.primaryLight,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1
                                ),
                                SizedBox(
                                  width: CustomSize.sizeWidth(context) * 0.001,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                            title: Center(child: Text('Info', style: TextStyle(color: Colors.blue))),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Setelah tercapai 10 pembelian yang menggunakan kode referral anda, maka:\n', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 10, right: 10),
                                                  child: Text('- Anda mendapatkan pengganti pembelian kupon anda di awal\n- Mendapatkan kupon makan lagi senilai Rp. 500.000, di resto yang anda bebas pilih', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                                                ),
                                              ],
                                            ),
                                            // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                            actions: <Widget>[
                                              Center(
                                                child: TextButton(
                                                  // minWidth: CustomSize.sizeWidth(context),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: CustomColor.accent,
                                                    padding: EdgeInsets.all(0),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                  ),
                                                  child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                                  onPressed: () async{
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),

                                            ],
                                          );
                                        }
                                    );
                                  },
                                  child: FaIcon(
                                    Icons.info_outline,
                                    color: Colors.grey,
                                    size: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
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
                              child: Text("Pengguna referral anda", style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              body: TabBarView(
                children: [
                  NguponYukRefUser(),
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
      ),
    );
  }
}
