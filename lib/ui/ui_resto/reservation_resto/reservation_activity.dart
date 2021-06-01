import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/ui/ui_resto/order/order_pending.dart';
import 'package:indonesiarestoguide/ui/ui_resto/order/order_process.dart';
import 'package:indonesiarestoguide/ui/ui_resto/order/order_ready.dart';
import 'package:indonesiarestoguide/ui/ui_resto/reservation_resto/reservation_done_page.dart';
import 'package:indonesiarestoguide/ui/ui_resto/reservation_resto/reservation_pending_page.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';

class ReservationRestoActivity extends StatefulWidget {
  @override
  _ReservationRestoActivityState createState() => _ReservationRestoActivityState();
}

class _ReservationRestoActivityState extends State<ReservationRestoActivity> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
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
                      text: "Reservasi",
                      color: CustomColor.primary,
                      minSize: 18,
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
                    border: Border(bottom: BorderSide(width: 3, color: CustomColor.primary),),
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
                          child: Text("Done", style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          body: TabBarView(
            children: [
              ReservationPending(),
              ReservationDone(),
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
      ),
    );
  }
}
