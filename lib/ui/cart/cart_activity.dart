import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class CartActivity extends StatefulWidget {
  @override
  _CartActivityState createState() => _CartActivityState();
}

class _CartActivityState extends State<CartActivity> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                    CustomText.bodyLight12(text: "Alamat Pengiriman"),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    CustomText.textHeading4(
                        text: "Jl. Griya Bhayangkara Masangan Kulon C-2/15",
                      minSize: 16,
                      maxLines: 10
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.008,),
                    Container(
                      width: CustomSize.sizeWidth(context) / 3,
                      height: CustomSize.sizeHeight(context) / 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 0.5)
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Octicons.pencil, size: 14,),
                            SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                            CustomText.bodyMedium12(text: "Ganti Alamat")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Divider(thickness: 6, color: CustomColor.secondary,),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 8,
                          height: CustomSize.sizeWidth(context) / 8,
                          decoration: BoxDecoration(
                            color: CustomColor.primary,
                            shape: BoxShape.circle
                          ),
                          child: Center(
                            child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                          ),
                        ),
                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        CustomText.textHeading4(text: "Pesan Antar",),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                      child: Container(
                        height: CustomSize.sizeHeight(context) / 24,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CustomColor.accent)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Center(
                            child: CustomText.bodyRegular14(
                                text: "Ganti",
                                color: CustomColor.accent
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Divider(thickness: 6, color: CustomColor.secondary,),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: 2,
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
                                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                            CustomText.bodyMedium16(
                                                text: "15.000",
                                                maxLines: 1,
                                                minSize: 16
                                            ),
                                          ],
                                        ),
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
                                      Row(
                                        children: [
                                          Container(
                                            width: CustomSize.sizeWidth(context) / 12,
                                            height: CustomSize.sizeWidth(context) / 12,
                                            decoration: BoxDecoration(
                                              color: CustomColor.accentLight,
                                              shape: BoxShape.circle
                                            ),
                                            child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
                                          ),
                                          SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                          CustomText.bodyRegular16(text: "1"),
                                          SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                          Container(
                                            width: CustomSize.sizeWidth(context) / 12,
                                            height: CustomSize.sizeWidth(context) / 12,
                                            decoration: BoxDecoration(
                                                color: CustomColor.accentLight,
                                                shape: BoxShape.circle
                                            ),
                                            child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
                                          ),
                                        ],
                                      )
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
                  }
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: CustomSize.sizeWidth(context) / 32,
                  vertical: CustomSize.sizeHeight(context) / 86
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.textHeading4(text: "Ada lagi pesanannya ?"),
                        CustomText.bodyRegular16(text: "Masih bisa tambah lagi loo")
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                      child: Container(
                        height: CustomSize.sizeHeight(context) / 24,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CustomColor.accent)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                          child: Center(
                            child: CustomText.bodyRegular14(
                                text: "Tambah",
                                color: CustomColor.accent
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: CustomSize.sizeWidth(context),
                decoration: BoxDecoration(
                  color: CustomColor.secondary
                ),
                child: Column(
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 20,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 2.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
