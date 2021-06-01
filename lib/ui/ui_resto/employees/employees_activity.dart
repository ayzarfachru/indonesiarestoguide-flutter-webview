import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/model/History.dart';
import 'package:indonesiarestoguide/ui/ui_resto/employees/add_employees.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:indonesiarestoguide/ui/detail/detail_history.dart';

class EmployeesActivity extends StatefulWidget {
  @override
  _EmployeesActivityState createState() => _EmployeesActivityState();
}

class _EmployeesActivityState extends State<EmployeesActivity> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  String img = "";

  bool isLoading = false;

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
      print(img);
    });
  }

  List<History> history = [];
  Future _getHistory()async{
    List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/history', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['trans']){
      History h = History(
          id: v['id'],
          name: v['resto_name'],
          time: v['time'],
          price: v['price'],
          img: v['resto_img'],
          type: v['type']
      );
      _history.add(h);
    }

    setState(() {
      history = _history;
      isLoading = false;
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    _getHistory();
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

  @override
  void initState() {
    _getHistory();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (isLoading)?Container(
            width: CustomSize.sizeWidth(context),
            height: CustomSize.sizeHeight(context),
            child: Center(child: CircularProgressIndicator())):SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            distance: 30,
            backgroundColor: Colors.white,
            color: CustomColor.primary,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 32,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: CustomSize.sizeWidth(context),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: (homepg != "1")?CustomText.textHeading3(
                        text: "Riwayat",
                        minSize: 18,
                        maxLines: 1
                    ):CustomText.textHeading3(
                        text: "Data Pegawai",
                        color: CustomColor.primary,
                        minSize: 18,
                        maxLines: 1
                    ),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (_, index){
                      return Padding(
                        padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                        child: GestureDetector(
                          // onTap: (){
                          //   Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id)));
                          // },
                          child: Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 5,
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                Container(
                                  width: CustomSize.sizeWidth(context) / 1.1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Divider(thickness: 1.5, color: CustomColor.secondary,),
                                      CustomText.bodyMedium16(
                                          text: (homepg != "1")?history[index].name:"Ahmad"
                                          // history[index].name
                                          ,
                                          minSize: 16,
                                          maxLines: 1
                                      ),
                                      CustomText.bodyLight12(
                                          text: "Jl. Bendul Merisi no.31 Surabaya",
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText.bodyMedium12(
                                              text: "8 Mar 2021",
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          // CustomText.textHeading4(
                                          //     text: "Rp. "+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(history[index].price),
                                          //     minSize: 18,
                                          //     maxLines: 1
                                          // ),
                                        ],
                                      ),
                                      CustomText.bodyMedium12(
                                          text: "+62 87828192378",
                                          maxLines: 1,
                                          minSize: 12
                                      ),
                                      Divider(thickness: 1.5, color: CustomColor.secondary,),
                                    ],
                                  ),
                                ),
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
        floatingActionButton: (homepg != '1')?Container():GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: AddEmployeesActivity()));
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 6.6,
            height: CustomSize.sizeWidth(context) / 6.6,
            decoration: BoxDecoration(
                color: CustomColor.primary,
                shape: BoxShape.circle
            ),
            child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
          ),
        )
    );
  }
}
