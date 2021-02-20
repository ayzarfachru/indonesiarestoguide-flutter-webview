import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:indonesiarestoguide/ui/profile/profile_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  ScrollController _scrollController = ScrollController();
  List<String> images = ["t", "f"];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context) / 3,
                child: Stack(
                  children: [
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.8,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          height: CustomSize.sizeHeight(context) / 3.8,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: images.map((e) {
                          return Container(
                            color: (e != "t")?Colors.black:Colors.amber,
                          );
                        }).toList(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 7,
                              offset: Offset(0, 7), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                            Container(
                              width: CustomSize.sizeWidth(context) / 6.5,
                              height: CustomSize.sizeWidth(context) / 6.5,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Pesananmu",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.4,
                                height: CustomSize.sizeHeight(context) / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 4.8,
                                        height: CustomSize.sizeHeight(context) / 6.8,
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                      SizedBox(width: CustomSize.sizeWidth(context) / 36,),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 63),
                                        child: Container(
                                          width: CustomSize.sizeWidth(context) / 2.4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText.bodyMedium14(text: "Rumah Makan Selera Bunda", minSize: 14, maxLines: 2),
                                                  CustomText.bodyLight12(text: "01 Jan 2021, 10:00", minSize: 12),
                                                  CustomText.bodyMedium12(text: "Pesan Antar", minSize: 12),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText.bodyLight12(text: "Diproses", minSize: 12, color: Colors.amberAccent),
                                                  CustomText.bodyMedium14(text: "35.000", minSize: 14),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Resto Dekat Sini",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 2.3,
                                height: CustomSize.sizeHeight(context) / 3.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.3,
                                      height: CustomSize.sizeHeight(context) / 5.8,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyRegular14(text: "1.8 Km"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyMedium16(text: "Resto Biasa"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Lagi Diskon",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.3,
                                height: CustomSize.sizeHeight(context) / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 3,
                                      height: CustomSize.sizeHeight(context) / 5,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.6,
                                        height: CustomSize.sizeHeight(context) / 5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText.bodyLight12(text: "0.9 Km", minSize: 12),
                                                CustomText.bodyMedium14(text: "Burger Enak Banget", minSize: 14, maxLines: 2),
                                                CustomText.bodyMedium12(text: "Resto Biasa", minSize: 12),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                CustomText.bodyRegular12(text: "IDR 15.000", minSize: 12,
                                                    decoration: TextDecoration.lineThrough),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                CustomText.bodyRegular12(text: "IDR 12.000", minSize: 12),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Pesan Lagi",
                          maxLines: 1
                      ),
                    ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 2.3,
                                height: CustomSize.sizeHeight(context) / 3.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 4,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.3,
                                      height: CustomSize.sizeHeight(context) / 5.8,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyRegular14(text: "1.8 Km"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                      child: CustomText.bodyMedium16(text: "Resto Biasa"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 8,)
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
        child: Container(
          width: CustomSize.sizeWidth(context) / 1.12,
          height: CustomSize.sizeHeight(context) / 12,
          decoration: BoxDecoration(
            color: CustomColor.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(MaterialCommunityIcons.percent, size: 32, color: Colors.white,),
              Icon(MaterialCommunityIcons.bookmark, size: 32, color: Colors.white,),
              Icon(MaterialCommunityIcons.shopping, size: 32, color: Colors.white,),
              GestureDetector(
                  onTap: () async{
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    pref.clear();
                  },
                  child: Icon(FontAwesome.search, size: 32, color: Colors.white,)),
              GestureDetector(
                onTap: (){
                  setState(() {
                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                  });
                },
                child: Icon(Ionicons.md_person, size: 32, color: Colors.white,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
