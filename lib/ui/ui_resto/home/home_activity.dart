import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/history/history_activity.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/ui/profile/profile_activity.dart';
import 'package:indonesiarestoguide/ui/promo/promo_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/employees/employees_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/menu/menu_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/order/order_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/reservation_resto/reservation_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/reservation_resto/reservation_pending_page.dart';
import 'package:indonesiarestoguide/ui/ui_resto/schedule_resto/schedule_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/meja/meja_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeActivityResto extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivityResto> {
  String img = "";
  String homepg = "";
  int id;

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
      print(img);
    });
  }

  getId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      id = (pref.getInt('id'));
      print(id);
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  @override
  void initState() {
    super.initState();
    getImg();
    getId();
    getHomePg();
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Press Back Again to Back');
      return Future.value(false);
    }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: CustomSize.sizeWidth(context),
              height: CustomSize.sizeHeight(context) / 2.8,
              decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.vertical( bottom: Radius.circular(60))
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () async{
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              pref.setString("homepg", "");
                              setState(() {
                                Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivity()));
                              });
                            },
                            child: Icon(FontAwesome.sign_out, color: Colors.white, size: 32,)
                        ),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                            });
                          },
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 8,
                            height: CustomSize.sizeWidth(context) / 8,
                            decoration: (img == "/".substring(0, 1))?BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                            ):BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  image: NetworkImage(Links.subUrl +
                                      "$img"),
                                  fit: BoxFit.cover
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 10),
                      child: CustomText.textHeading5(
                        text: "Selamat Datang,",
                        color: Colors.white,
                        minSize: 24,
                        maxLines: 1
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 10),
                      child: CustomText.textHeading5(
                        text: "di Restoran GSB",
                        color: Colors.white,
                          minSize: 24,
                          maxLines: 1
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Center(
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new DetailResto(id.toString())));
                          });
                        },
                        child: Container(
                          width: CustomSize.sizeWidth(context) / 1.1,
                          height: CustomSize.sizeHeight(context) / 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(0, 7), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText.textHeading4(
                                          text: "Restoranmu",
                                        minSize: 18,
                                        maxLines: 1
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText.bodyRegular14(
                                            text: "Info yang ditampilin tentang",
                                          ),
                                          CustomText.bodyRegular14(
                                              text: "restomu",
                                              maxLines: 2
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(MaterialCommunityIcons.home_account, color: CustomColor.primary, size: 49,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 90,),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: CustomSize.sizeHeight(context) / 90,),
                        CustomText.bodyMedium16(
                            text: "Kelola Restoranmu",
                            minSize: 16,
                            maxLines: 1
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MenuActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.restaurant, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Menu",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  print(homepg + "oi");
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesome.tags, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Promo",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesome.th, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Meja",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 58,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ReservationRestoActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesome5.clipboard, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Reservasi",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        CustomText.bodyMedium16(
                            text: "Lainnya tentang Restomu",
                            minSize: 16,
                            maxLines: 1
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new HistoryActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesome.history, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Riwayat",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ScheduleActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(MaterialCommunityIcons.door_closed, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Jadwal",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                    CustomText.bodyMedium14(
                                        text: "Operasional",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EmployeesActivity()));
                                });
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 3.8,
                                height: CustomSize.sizeWidth(context) / 3.8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.account_box_rounded, color: CustomColor.primary, size: 32,),
                                    CustomText.bodyMedium14(
                                        text: "Karyawan",
                                        minSize: 14,
                                        maxLines: 1
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                            SizedBox(height: CustomSize.sizeHeight(context) / 9,),
                  ],
                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
          floatingActionButton: GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: OrderActivity()));
            },
            child: Container(
              width: CustomSize.sizeWidth(context) / 6.6,
              height: CustomSize.sizeWidth(context) / 6.6,
              decoration: BoxDecoration(
                  color: CustomColor.primary,
                  shape: BoxShape.circle
              ),
              child: Center(child: Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 28,)),
            ),
          )
      ),
    );
  }
}
