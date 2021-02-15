import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class SearchActivity extends StatefulWidget {
  @override
  _SearchActivityState createState() => _SearchActivityState();
}

class _SearchActivityState extends State<SearchActivity> {
  TextEditingController _loginTextName = TextEditingController(text: "");
  ScrollController _scrollController = ScrollController();

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                Container(
                  width: CustomSize.sizeWidth(context),
                  height: CustomSize.sizeHeight(context) / 12,
                  decoration: BoxDecoration(
                    color: CustomColor.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesome.search, size: 28, color: Colors.grey,),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        Expanded(
                          child: TextField(
                            controller: _loginTextName,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v){

                            },
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintText: "Apa yang kamu cari hari ini",
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                        text: "Paling banyak Dicari"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 18,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: 4,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                                child: Container(
                                  height: CustomSize.sizeHeight(context) / 19,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: CustomColor.accent)
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                    child: Center(
                                      child: CustomText.bodyRegular14(
                                        text: "Soto Daging",
                                        color: CustomColor.accent
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Jelajahi"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 7,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                                child: Column(
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 6,
                                      height: CustomSize.sizeWidth(context) / 6,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        color: CustomColor.secondary
                                      ),
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                    CustomText.textHeading4(
                                        text: "Appetizer"
                                    ),
                                  ],
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Rekomendasi"
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              height: CustomSize.sizeWidth(context) / 2.6,
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
                              child: Row(
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 2.6,
                                    height: CustomSize.sizeWidth(context) / 2.6,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  SizedBox(
                                    width: CustomSize.sizeWidth(context) / 32,
                                  ),
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 2.1,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText.bodyLight12(
                                            text: "0.9 km",
                                            maxLines: 1,
                                            minSize: 12
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        CustomText.textHeading4(
                                            text: "Burger Enak",
                                            minSize: 18,
                                            maxLines: 1
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        CustomText.bodyMedium12(
                                            text: "Resto Biasa",
                                            maxLines: 1,
                                            minSize: 12
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
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
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
