import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class DetailResto extends StatefulWidget {
  @override
  _DetailRestoState createState() => _DetailRestoState();
}

class _DetailRestoState extends State<DetailResto> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Stack(
            children: [
              Container(
                height: CustomSize.sizeHeight(context) / 3.2,
                width: CustomSize.sizeWidth(context),
                decoration: BoxDecoration(
                  color: Colors.amber
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CustomSize.sizeHeight(context) / 3.8,),
                  Container(
                      width: CustomSize.sizeWidth(context),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 1.4,
                                child: CustomText.textHeading2(
                                    text: "Resto Biasa",
                                  maxLines: 2,
                                  minSize: 20
                                ),
                              ),
                              Icon(MaterialCommunityIcons.bookmark,
                                color: CustomColor.secondary, size: 40,)
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 52),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 2.2,
                                decoration: BoxDecoration(
                                  color: CustomColor.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: CustomSize.sizeWidth(context) / 48,
                                    vertical: CustomSize.sizeHeight(context) / 48
                                  ),
                                  child: Column(
                                    children: [
                                      CustomText.bodyMedium16(text: "Kisaran Harga", minSize: 16),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyRegular16(text: "IDR 15k - 25k", minSize: 16, color: CustomColor.primary),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: CustomSize.sizeWidth(context) / 2.2,
                                decoration: BoxDecoration(
                                  color: CustomColor.secondary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: CustomSize.sizeWidth(context) / 48,
                                      vertical: CustomSize.sizeHeight(context) / 48
                                  ),
                                  child: Column(
                                    children: [
                                      CustomText.bodyMedium16(text: "Alamat", minSize: 16),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyRegular16(text: "Jl  Kehatimu", minSize: 16, color: CustomColor.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 14),
                          child: CustomText.bodyRegular14(
                              text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                              minSize: 14,
                            maxLines: 100
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 24,),
                        Container(
                          height: CustomSize.sizeWidth(context) / 2.4,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                              itemBuilder: (_, index){
                                return Padding(
                                  padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) * 0.03),
                                  child: Container(
                                    width: CustomSize.sizeWidth(context) / 2.4,
                                    height: CustomSize.sizeWidth(context) / 2.4,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 8),
                          child: CustomText.bodyMedium16(
                              text: "Penawaran yang Tersedia",
                            color: CustomColor.primary,
                            maxLines: 1
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Ionicons.ios_wallet, color: CustomColor.primary,),
                              SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                              Container(
                                width: CustomSize.sizeWidth(context) / 1.5,
                                child: CustomText.bodyLight14(
                                    text: "Diskon 25%, untuk pembelian nasi padang",
                                  minSize: 14,
                                  maxLines: 2
                                ),
                              ),
                              SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                              Icon(Icons.chevron_right_sharp, size: 32,),
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 8),
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 4,
                            height: CustomSize.sizeHeight(context) / 18,
                            decoration: BoxDecoration(
                              color: CustomColor.accentLight,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(child: CustomText.bodyRegular14(text: "See more", color: CustomColor.accent)),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                              CustomText.textHeading4(text: "Rekomendasi Menu", color: CustomColor.primary),
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        ListView.builder(
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: CustomSize.sizeWidth(context) / 32,
                                  left: CustomSize.sizeWidth(context) / 32,
                                  right: CustomSize.sizeWidth(context) / 32,
                                ),
                                child: GestureDetector(
                                  onTap: (){
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                      ),
                                        context: context,
                                        builder: (_){
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                                child: Divider(thickness: 4,),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                              Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  height: CustomSize.sizeWidth(context) / 1.2,
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText.textHeading5(
                                                        text: "Burger Enak",
                                                        minSize: 18,
                                                        maxLines: 1
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyRegular16(
                                                        text: "Lorem ipsum dolor sit amet, con sectetur adipiscing elit",
                                                        maxLines: 100,
                                                        minSize: 16
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                                    CustomText.bodyMedium16(
                                                        text: "IDR 15.000",
                                                        maxLines: 1,
                                                        minSize: 16
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                              Center(
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 1.1,
                                                  height: CustomSize.sizeHeight(context) / 14,
                                                  decoration: BoxDecoration(
                                                      color: CustomColor.primary,
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  child: Center(child: CustomText.bodyRegular16(text: "Add to cart", color: Colors.white)),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            ],
                                          );
                                        }
                                    );
                                  },
                                  child: Container(
                                    width: CustomSize.sizeWidth(context),
                                    height: CustomSize.sizeHeight(context) / 3.8,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 1.65,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText.textHeading4(
                                                            text: "Burger Enak",
                                                          minSize: 18,
                                                          maxLines: 1
                                                        ),
                                                        CustomText.bodyRegular16(
                                                            text: "Lorem ipsum dolor sit amet, con sectetur adipiscing elit",
                                                            maxLines: 2,
                                                            minSize: 16
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText.bodyMedium16(
                                                            text: "15.000",
                                                            maxLines: 1,
                                                            minSize: 16
                                                        ),
                                                        SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                                                        Icon(Icons.favorite, color: CustomColor.secondary, size: 36,)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 3.4,
                                                    height: CustomSize.sizeWidth(context) / 3.4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.amberAccent,
                                                      borderRadius: BorderRadius.circular(20)
                                                    ),
                                                  ),
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 4.6,
                                                    height: CustomSize.sizeHeight(context) / 18,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.accentLight,
                                                        borderRadius: BorderRadius.circular(20)
                                                    ),
                                                    child: Center(child: CustomText.bodyRegular16(text: "Add", color: CustomColor.accent)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                              CustomText.textHeading4(text: "Semua Menu", color: CustomColor.primary),
                            ],
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        ListView.builder(
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(
                                top: CustomSize.sizeWidth(context) / 32,
                                left: CustomSize.sizeWidth(context) / 32,
                                right: CustomSize.sizeWidth(context) / 32,
                              ),
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 3.8,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: CustomSize.sizeWidth(context) / 1.65,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText.textHeading4(
                                                        text: "Burger Enak",
                                                        minSize: 18,
                                                        maxLines: 1
                                                    ),
                                                    CustomText.bodyRegular16(
                                                        text: "Lorem ipsum dolor sit amet, con sectetur adipiscing elit",
                                                        maxLines: 2,
                                                        minSize: 16
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText.bodyMedium16(
                                                        text: "15.000",
                                                        maxLines: 1,
                                                        minSize: 16
                                                    ),
                                                    SizedBox(height: CustomSize.sizeHeight(context) / 63,),
                                                    Icon(Icons.favorite, color: CustomColor.secondary, size: 36,)
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 3.4,
                                                height: CustomSize.sizeWidth(context) / 3.4,
                                                decoration: BoxDecoration(
                                                    color: Colors.amberAccent,
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                              ),
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 4.6,
                                                height: CustomSize.sizeHeight(context) / 18,
                                                decoration: BoxDecoration(
                                                    color: CustomColor.accentLight,
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Center(child: CustomText.bodyRegular16(text: "Add", color: CustomColor.accent)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider()
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 8,
                              height: CustomSize.sizeWidth(context) / 8,
                              decoration: BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                              ),
                              child: Center(child: Icon(CupertinoIcons.cart_fill, color: Colors.white,)),
                            ),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                        Center(
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                              color: CustomColor.primary,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(child: CustomText.bodyRegular16(text: "Reservasi Sekarang", color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 32),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: CustomSize.sizeWidth(context) / 7,
                    height: CustomSize.sizeWidth(context) / 7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 7,
                          offset: Offset(0, 7), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(child: Icon(Icons.chevron_left, size: 38,)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
