import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kam5ia/ui/profile/edit_profile.dart';
import 'package:kam5ia/ui/about/about_activity.dart';
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
      print(notelp+' telp');
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
      path: 'kamsia.owner@gmail.com',
      // query: 'subject=App Feedback&body=App Version 1.1.0', //add subject and body here
      query: 'subject=Saran/Masukan untuk Kamsia', //add subject and body here
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool isLoading = false;
  String kosong = '';
  String openAndClose = "0";
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
      id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // history = _history;
      openAndClose = (data['status'].toString() == "closed")?'1':'0';
      isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "User tidak punya resto") {
        kosong = '1';
      } else if (data['resto']['id'] == null || id == 'null' || id == '') {
        kosong = '1';
      }
    }
  }

  Future logOut()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/auth/logout', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oyyy '+apiResult.body.toString());
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

    // setState(() {
    //   // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
    //   // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
    //   // // history = _history;
    //   // openAndClose = (data['status'].toString() == "closed")?'1':'0';
    //   // isLoading = false;
    // });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      print('pb');
    }
  }

  File? image;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = (pref.getString('name'));
      print(name);
      email = (pref.getString('email'));
      print(email);
      img = (pref.getString('img'));
      print(img);
      notelp = (pref.getString('notelp'));
      print(notelp);
      // gender = (pref.getString('gender'));
      // print(gender);
      // tgl = (pref.getString('tgl'));
      // print(tgl);
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserResto();
    getName();
    getInitial();
    getPref();
    // getEmail();
    // getImg();
    // getNotelp();
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
                          (img == "" || img == null)?Container(
                            width: CustomSize.sizeWidth(context) / 6,
                            height: CustomSize.sizeWidth(context) / 6,
                            decoration: (image==null)?(img == "" || img == null)?BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                            ):BoxDecoration(
                              shape: BoxShape.circle,
                              image: ("$img".substring(0, 8) == '/storage')?DecorationImage(
                                  image: NetworkImage(Links.subUrl +
                                      "$img"),
                                  fit: BoxFit.cover
                              ):DecorationImage(
                                  image: Image.memory(Base64Decoder().convert(img)).image,
                                  fit: BoxFit.cover
                              ),
                            ): BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  image: new FileImage(image!),
                                  fit: BoxFit.cover
                              ),
                            ),
                            child: (img == "" || img == null)?Center(
                              child: CustomText.text(
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initial,
                                  color: Colors.white
                              ),
                            ):Container(),
                          ):FullScreenWidget(
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 6,
                              height: CustomSize.sizeWidth(context) / 6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: (img == "" || img == null)?Image.network(Links.subUrl + "$img", fit: BoxFit.fitWidth):Container(decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: ("$img".substring(0, 8) == '/storage')?DecorationImage(
                                      image: NetworkImage(Links.subUrl +
                                          "$img"),
                                      fit: BoxFit.cover
                                  ):DecorationImage(
                                      image: Image.memory(Base64Decoder().convert(img)).image,
                                      fit: BoxFit.cover
                                  ),
                                ),),
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
                                (notelp.toString() != "null" && notelp.toString() != '')?CustomText.bodyLight16(text: notelp, maxLines: 1, minSize: 12)
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
                  (homepg != "1")?Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                    child: CustomText.textHeading4(
                        text: "Akun",
                        minSize: 18,
                        maxLines: 1
                    ),
                  ):
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                    child: CustomText.textHeading4(
                        text: "Info Lainnya",
                        minSize: 18,
                        maxLines: 1
                    ),
                  ),
                  Divider(),
                  (homepg != "1")?GestureDetector(
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
                  ):Container(),
                  (homepg != "1")?Divider():Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 48,
                        vertical: CustomSize.sizeHeight(context) / 86
                    ),
                    child: GestureDetector(
                      onTap: (){
                        // _launchURL();
                        launch('mailto:info@irg.com');
                      },
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
                        (kosong == '1')?Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: AddViewResto())):Fluttertoast.showToast(msg: "Tunggu sebentar.");
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: CustomSize.sizeWidth(context) / 48,
                          vertical: CustomSize.sizeHeight(context) / 86
                      ),
                      child: Row(
                        children: [
                          Icon(MaterialIcons.store),
                          SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          CustomText.bodyRegular16(
                              text: "Kelola Restomu",
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
                          Icon(MaterialIcons.store),
                          SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          CustomText.bodyRegular16(
                              text: "Kelola Restomu",
                              minSize: 16,
                              maxLines: 1
                          ),
                        ],
                      ),
                    ),
                  ):Container(),
                  (homepg != "1")?Divider():Container(),
                  (homepg != "1")?SizedBox(height: CustomSize.sizeHeight(context) / 32,):Container(),
                  (homepg != "1")?Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                    child: CustomText.textHeading4(
                        text: "Info Lainnya",
                        minSize: 18,
                        maxLines: 1
                    ),
                  ):Container(),
                  (homepg != "1")?Divider():Container(),
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
                  logOut();
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
