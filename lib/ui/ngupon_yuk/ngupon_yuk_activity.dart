import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
import 'ngupon_yuk_used.dart';

class NguponYukActivity extends StatefulWidget {
  @override
  _NguponYukActivityState createState() => _NguponYukActivityState();
}

class _NguponYukActivityState extends State<NguponYukActivity> {
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
            length: 3,
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
                              child: Text("Belum dibayar", style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Belum dipakai", style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Sudah dipakai", style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              body: TabBarView(
                children: [
                  NguponYukUnpaid(),
                  NguponYukPaid(),
                  NguponYukUsed(),
                  // OrderPending(),
                  // OrderProcess(),
                  // OrderReady(),
                ],
              ),
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
