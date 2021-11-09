import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/order/order_pending.dart';
import 'package:kam5ia/ui/ui_resto/order/order_process.dart';
import 'package:kam5ia/ui/ui_resto/order/order_ready.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';

class OrderActivity extends StatefulWidget {
  @override
  _OrderActivityState createState() => _OrderActivityState();
}

class _OrderActivityState extends State<OrderActivity> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  DateTime? currentBackPressTime;
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
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: HomeActivityResto()));
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: MediaQuery(
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(MediaQuery.of(context).size.height/7.5),
                  child: AppBar(
                    title: Column(
                      children: [
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 42,
                        ),
                        CustomText.textHeading3(
                            text: "Daftar Pesanan",
                            color: CustomColor.primary,
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
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
                                child: Text("Pending", style: TextStyle(fontSize: 15)),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Process", style: TextStyle(fontSize: 15)),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Ready", style: TextStyle(fontSize: 15)),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              body: TabBarView(
                children: [
                  OrderPending(),
                  OrderProcess(),
                  OrderReady(),
                ],
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
          ),
        ),
      ),
    );
  }
}
