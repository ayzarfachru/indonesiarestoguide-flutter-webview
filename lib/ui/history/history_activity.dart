import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kam5ia/model/History.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kam5ia/ui/detail/detail_history.dart';

class HistoryActivity extends StatefulWidget {
  @override
  _HistoryActivityState createState() => _HistoryActivityState();
}

class _HistoryActivityState extends State<HistoryActivity> {
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

  List<History> history = [];
  // /page/history?resto=$id
  Future _getHistory()async{
    List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/page/history'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('History User');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['trans']){
      History h = History(
        id: v['id'],
        name: v['resto_name'],
        time: v['time'],
        price: v['price'],
        img: v['resto_img'],
        type: v['type'],
        status: v['status'],
      );
      _history.add(h);
    }

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

    if (data['trans'] != null) {
      for(var v in data['trans']){
        History h = History(
          id: v['id'],
          name: v['resto_name'],
          time: v['time'],
          price: v['price'],
          img: v['resto_img'],
          type: v['type'],
          status: v['status'],
        );
        _user.add(h);
      }
    }

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
        _getHistory();
      } else {
        idResto();
      }
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

  idResto() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    id = pref.getString("idresto");
    print('NGAB '+id.toString());
    _getHistoryResto();
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
      child: Scaffold(
        backgroundColor: CustomColor.secondary,
        body: SafeArea(
          child: (isLoading)?Container(
              width: CustomSize.sizeWidth(context),
              height: CustomSize.sizeHeight(context),
              child: Center(child: CircularProgressIndicator(
                color: CustomColor.primaryLight,
              ))):SmartRefresher(
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
              child: (ksg != true)?Column(
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
                      child: (homepg != "1")?Row(
                        children: [
                          GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 88,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: CustomText.textHeading4(
                                text: "Riwayat",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                maxLines: 1
                            ),
                          ),
                        ],
                      ):Row(
                        children: [
                          GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 88,
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: CustomText.textHeading4(
                                text: "Riwayat Penjualan",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                maxLines: 1
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (homepg != "1")?history.length:user.length,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          child: GestureDetector(
                            onTap: (){
                              (homepg != "1")?Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id))):
                              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(user[index].id)));
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              height: CustomSize.sizeHeight(context) / 4,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 38),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.8,
                                      height: CustomSize.sizeWidth(context) / 2.8,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: (homepg != "1")?NetworkImage(Links.subUrl + history[index].img):(user[index].img != null)?NetworkImage(Links.subUrl + user[index].img):AssetImage('assets/default.png') as ImageProvider,
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                    ),
                                    SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomText.bodyMedium16(
                                              text: (homepg != "1")?history[index].name:user[index].name
                                              // history[index].name
                                              ,
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                              maxLines: 1
                                          ),
                                          CustomText.bodyLight12(
                                              text: (homepg != "1")?history[index].time:user[index].time,
                                              maxLines: 1,
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                          ),
                                          CustomText.bodyMedium12(
                                              text: (homepg != "1")?history[index].type:user[index].type,
                                              maxLines: 1,
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                          ),
                                          CustomText.bodyLight12(
                                              text: (homepg != "1")?(history[index].status == 'done')?"Selesai":'Dibatalkan':(user[index].status == 'done')?"Selesai":'Dibatalkan',
                                              maxLines: 1,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                              color: (homepg != "1")?(history[index].status == 'done')?CustomColor.accent:CustomColor.redBtn:(user[index].status == 'done')?CustomColor.accent:CustomColor.redBtn
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText.textHeading4(
                                                  text: (homepg != "1")?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((history[index].price+1000)):
                                                  NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((user[index].price+1000)),
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                  maxLines: 1
                                              ),
                                              (homepg != "1")?
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 4.2,
                                                height: CustomSize.sizeHeight(context) / 24,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: CustomColor.accent)
                                                ),
                                                child: Center(child: CustomText.bodyRegular14(text: "Pesan Lagi", color: CustomColor.accent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),),
                                              ):Container(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                ],
              ):Stack(
                children: [
                  Column(
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
                          child: (homepg != "1")?Row(
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                              ),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 88,
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: CustomText.textHeading4(
                                    text: "Riwayat",
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1
                                ),
                              ),
                            ],
                          ):CustomText.textHeading3(
                              text: "Riwayat Pembelian",
                              color: CustomColor.primary,
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                              maxLines: 1
                          ),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: (homepg != "1")?history.length:user.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              child: GestureDetector(
                                onTap: (){
                                  (homepg != "1")?Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id))):
                                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(user[index].id)));
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 4,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 38),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 2.8,
                                          height: CustomSize.sizeWidth(context) / 2.8,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: (homepg != "1")?NetworkImage(Links.subUrl + history[index].img):NetworkImage(Links.subUrl + user[index].img),
                                                  fit: BoxFit.cover
                                              ),
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                        ),
                                        SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomText.bodyMedium16(
                                                  text: (homepg != "1")?history[index].name:user[index].name
                                                  // history[index].name
                                                  ,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                  maxLines: 1
                                              ),
                                              CustomText.bodyLight12(
                                                  text: (homepg != "1")?history[index].time:user[index].time,
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              CustomText.bodyMedium12(
                                                  text: (homepg != "1")?history[index].type:user[index].type,
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              CustomText.bodyLight12(
                                                  text: (homepg != "1")?(history[index].status == 'done')?"Selesai":'Dibatalkan':(user[index].status == 'done')?"Selesai":'Dibatalkan',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                  color: (homepg != "1")?(history[index].status == 'done')?CustomColor.accent:CustomColor.redBtn:(user[index].status == 'done')?CustomColor.accent:CustomColor.redBtn
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.textHeading4(
                                                      text: (homepg != "1")?NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(history[index].price):
                                                      NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(user[index].price),
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                      maxLines: 1
                                                  ),
                                                  (homepg != "1")?
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 4.2,
                                                    height: CustomSize.sizeHeight(context) / 24,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: CustomColor.accent)
                                                    ),
                                                    child: Center(child: CustomText.bodyRegular14(text: "Pesan Lagi", color: CustomColor.accent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
                                                  ):Container(),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                    ],
                  ),
                  Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
                ],
              ),
            ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
