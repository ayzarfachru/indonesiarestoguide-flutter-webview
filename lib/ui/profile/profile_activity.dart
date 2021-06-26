import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/ui/auth/login_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:indonesiarestoguide/ui/ui_resto/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indonesiarestoguide/ui/profile/edit_profile.dart';
import 'package:indonesiarestoguide/ui/about/about_activity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../history/history_activity.dart';

class ProfileActivity extends StatefulWidget {
  @override
  _ProfileActivityState createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  // String name = "Deni";
  String id = "";
  String name = "";
  String restoName = "";
  String initial = "";
  String email = "";
  String img = "";
  String notelp = "";
  String homepg = "";

  getName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = (pref.getString('name'));
      print(name);
    });
  }

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  getEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      email = (pref.getString('email'));
      print(email);
    });
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
      print(img);
    });
  }

  getNotelp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      notelp = (pref.getString('notelp'));
      print(notelp);
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  _launchURL() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'indonesiarestoguide@gmail.com',
      query: 'subject=App Feedback&body=App Version 1.1.0', //add subject and body here
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool isLoading = false;
  Future _getUserResto()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    setState(() {
      id = data['resto']['id'].toString();
      restoName = data['resto']['name'];
      // history = _history;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserResto();
    getName();
    getInitial();
    getEmail();
    getImg();
    getNotelp();
    getHomePg();
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
                            child: (img == "/".substring(0, 1))?Center(
                              child: CustomText.text(
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initial,
                                  color: Colors.white
                              ),
                            ):Container(),
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
                                (notelp != "null")?CustomText.bodyLight16(text: notelp, maxLines: 1, minSize: 12)
                                    :CustomText.bodyLight16(text: "Nomor belum diisi.", maxLines: 1, minSize: 12),
                                CustomText.bodyLight16(text: email, maxLines: 1, minSize: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () async{
                            setState(() {
                              Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditProfile()));
                            });
                          },
                          child: Icon(Octicons.pencil)
                      )
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
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: new HistoryActivity()));
                    },
                    child: Padding(
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
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: GestureDetector(
                      onTap: _launchURL,
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
                  ),
                  (homepg != "1")?Divider():Container(),
                  (homepg != "1")?(id == '')?GestureDetector(
                    onTap: () async{
                      // SharedPreferences pref = await SharedPreferences.getInstance();
                      // pref.setString("homepg", "1");
                      setState(() {
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: AddViewResto()));
                      });
                    },
                    child: Padding(
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
                  ):GestureDetector(
                    onTap: () async{
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setString("homepg", "1");
                      // pref.setString("homerestoname", restoName);
                      setState(() {
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
                      });
                    },
                    child: Padding(
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
                  ):Container(),
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
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: AboutActivity()));
                    },
                    child: Padding(
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
                  ),
                  Divider(),
                ],
              ),
              GestureDetector(
                onTap: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.clear();
                  setState(() {
                    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new LoginActivity()));
                  });
                },
                child: Padding(
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
