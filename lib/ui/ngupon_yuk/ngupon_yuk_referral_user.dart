import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/utils/email_sender.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'ngupon_yuk_activity.dart';

class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class NguponYukRefUser extends StatefulWidget {
  @override
  _NguponYukRefUserState createState() => _NguponYukRefUserState();
}

class _NguponYukRefUserState extends State<NguponYukRefUser> {
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
  List number = [];
  List<NguponYuk> nguponYuk = [];
  List<NguponYuk> nguponYukDone = [];
  Future _getNguponYuk()async{

    setState(() {
      isLoading = true;
      nguponYuk = [];
      nguponYukDone = [];
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/coupon/ref?user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYuk ref');
    print(Links.nguponUrl + '/coupon/ref?user=$email');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for (var h in data['data']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['user']['email'].toString(),
          price: h['total'].toString(),
          status: h['status'],
          date: DateFormat('d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      );
      if (number.toString() == '[]') {
        number.add(1);
      } else {
        number.add((int.parse(number.last.toString())+1));
      }
      nguponYuk.add(c);
    }

    for (var h in data['data']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['user']['email'].toString(),
          price: h['total'].toString(),
          status: h['status'],
          date: DateFormat('d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      );
      if (h['status'].toString() == 'paid') {
        nguponYukDone.add(c);
      }
    }

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
        _getNguponYuk();
      } else {
        idResto();
      }
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  TextEditingController email = TextEditingController(text: '');

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
        body: SafeArea(
          child: SmartRefresher(
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
            child: ScrollConfiguration(
              behavior: CustomScroll(),
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
                                                  color:
                                                  (nguponYuk[index].status.toString() != 'paid')?
                                                  CustomColor.redBtn:
                                                  CustomColor.accent,
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
                                                Container(
                                                  // height: CustomSize.sizeHeight(context) / 24,
                                                  // decoration: BoxDecoration(
                                                  //     borderRadius: BorderRadius.circular(20),
                                                  //     border: Border.all(color: CustomColor.accent)
                                                  // ),
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.03, vertical: CustomSize.sizeHeight(context) * 0.005),
                                                    child: Center(
                                                      child: CustomText.textTitle8(
                                                          text: nguponYuk[index].status.toString().toUpperCase(),
                                                          color: (nguponYuk[index].status.toString() == 'paid')?CustomColor.accent:CustomColor.redBtn,
                                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                      (nguponYuk.length == 10)?SizedBox(height: CustomSize.sizeHeight(context) / 10,):SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                    ],
                  ),
                ),
              ):Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (nguponYukDone.length >= 10)?GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: EmailSender()));
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                color: CustomColor.accent,
                borderRadius: BorderRadius.circular(50)
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomText.textTitle2(text: "Klik disini untuk klaim", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
              ),
            ),
          ),
        ):Container()
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
