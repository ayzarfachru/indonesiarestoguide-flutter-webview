import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class ProfileActivity extends StatefulWidget {
  @override
  _ProfileActivityState createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  String name = "Deni";
  String initialName = "";

  @override
  void initState() {
    initialName = name.substring(0, 1).toUpperCase();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                  CustomText.textHeading4(
                      text: "Profile",
                      minSize: 18,
                      maxLines: 1
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: CustomSize.sizeWidth(context) / 6,
                            height: CustomSize.sizeWidth(context) / 6,
                            decoration: BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: CustomText.text(
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initialName,
                                  color: Colors.white
                              ),
                            ),
                          ),
                          SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          Container(
                            width: CustomSize.sizeWidth(context) / 1.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText.textHeading4(
                                    text: name,
                                    maxLines: 1,
                                    minSize: 18
                                ),
                                CustomText.bodyLight16(text: "+62834473274273", maxLines: 1, minSize: 12),
                                CustomText.bodyLight16(text: "denidc27@gmail.com", maxLines: 1, minSize: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Icon(Octicons.pencil)
                    ],
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                    child: CustomText.textHeading4(
                        text: "Akun",
                        minSize: 18,
                        maxLines: 1
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      children: [
                        Icon(FontAwesome.history),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        CustomText.bodyRegular16(
                            text: "Riwayat",
                            minSize: 16,
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      children: [
                        Icon(MaterialCommunityIcons.inbox_arrow_down),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        CustomText.bodyRegular16(
                            text: "Masukan",
                            minSize: 16,
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      children: [
                        Icon(MaterialIcons.restaurant),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        CustomText.bodyRegular16(
                            text: "Kelola Restaurant",
                            minSize: 16,
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                    child: CustomText.textHeading4(
                        text: "Info Lainnya",
                        minSize: 18,
                        maxLines: 1
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        CustomText.bodyRegular16(
                            text: "Tentang Kami",
                            minSize: 16,
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 48),
                child: Container(
                  width: CustomSize.sizeWidth(context),
                  height: CustomSize.sizeHeight(context) / 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: CustomColor.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: CustomColor.primary,),
                      SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                      CustomText.bodyRegular16(text: "Keluar", color: CustomColor.primary),
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
}
