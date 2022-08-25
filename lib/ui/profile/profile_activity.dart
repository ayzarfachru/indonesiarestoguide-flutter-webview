import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
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
      name = (pref.getString('name')??'');
      print(name);
    });
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "887058389150-nesf8jr9jdk5n2dtt1t30to2el1v3bbi.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      // 'https://www.googleapis.com/auth/user.birthday.read',
      // 'https://www.googleapis.com/auth/user.gender.read',
      // 'https://www.googleapis.com/auth/user.phonenumbers.read'
    ],
  );

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name')!.substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  getEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      email = (pref.getString('email')??'');
      print(email);
    });
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img')??'');
      print(img);
    });
  }

  getNotelp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      notelp = (pref.getString('notelp')??'');
      print(notelp+' telp');
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
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
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto'), headers: {
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
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/auth/logout'), headers: {
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
      name = (pref.getString('name')??'');
      print(name);
      email = (pref.getString('email')??'');
      print(email);
      img = (pref.getString('img')??'');
      print(img);
      notelp = (pref.getString('notelp')??"");
      print(notelp);
      // gender = (pref.getString('gender'));
      // print(gender);
      // tgl = (pref.getString('tgl'));
      // print(tgl);
    });
  }

  String owner = 'false';
  List<User> user = [];
  Future _getOwnerResto()async{
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    List<User> _user = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('owner');
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
      if (data['resto'].toString() == "[]") {
        _getUserResto();
      } else {
        owner = 'true';
        for(var v in data['resto']){
          User p = User.resto(
            id: int.parse(v['restaurant_id']),
            name: v['restaurant']['name'],
            email: v['restaurant']['address'],
            notelp: '',
            img: v['restaurant']['img'],
          );
          _user.add(p);
        }
      }
    } else {
      _getUserResto();
    }

    setState(() {
      user = _user;
    });
  }

  showAlertDialog(String id) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary),),
      onPressed:  () {
        _delMenu(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Resto"),
      content: Text("Apakah anda yakin ingin melepas akun owner anda dari resto ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _delMenu(String id)async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner/delete/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (apiResult.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: ProfileActivity()));
    }

    setState(() {
      isLoading = false;
    });
  }

  Future _getCheckResto()async{
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    int idRes = pref.getInt("ownerId") ?? 0;
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner/activate/'+idRes.toString()), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    print(idRes);
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
      // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // // history = _history;
      // openAndClose = (data['status'].toString() == "closed")?'1':'0';
      // isLoading = false;
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
      }
      // else if (data['resto']['id'] == null || id == 'null' || id == '') {
      //   kosong = '1';
      // }
      else {
        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      }
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "");
    pref.setString("idresto", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  Future<bool> onWillPop2() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
//     Navigator.pop(context);
    return Future.value(true);
  }

  Future _getOwnerOut()async{
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    int idRes = pref.getInt("ownerId") ?? 0;
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner/deactivate'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    print('iki loh rekk');
    print(idRes);
    var data = json.decode(apiResult.body);

    // SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('ownerId');
    pref.remove('owner');
    pref.setString("homepg", "");

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
      // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // // history = _history;
      // openAndClose = (data['status'].toString() == "closed")?'1':'0';
      // isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "success") {
        logOut();
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
        // kosong = '1';
      }
      // else if (data['resto']['id'] == null || id == 'null' || id == '') {
      //   kosong = '1';
      // }
      else {
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      }
    }
  }

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getOwnerResto();
    // _getUserResto();
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
    return WillPopScope(
      onWillPop: (homepg != "1")?onWillPop:onWillPop2,
      child: MediaQuery(
        child: Scaffold(
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
                      Row(
                        children: [
                          GestureDetector(
                              onTap: ()async{
                                if (homepg != "1") {
                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                  pref.setString("homepg", "");
                                  pref.setString("idresto", "");
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 88,
                          ),
                          GestureDetector(
                            onTap: () async{
                              if (homepg != "1") {
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                pref.setString("homepg", "");
                                pref.setString("idresto", "");
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              children: [
                                CustomText.textHeading4(
                                    text: "Profile",
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1
                                ),
                                (owner == 'true')?CustomText.textHeading4(
                                    text: " Owner",
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    maxLines: 1,
                                    color: CustomColor.accent
                                ):Container(),
                              ],
                            ),
                          ),
                        ],
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
                                      size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
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
                                    child: (img == "" || img == 'null')?Image.network(Links.subUrl + "$img", fit: BoxFit.fitWidth):Container(decoration: BoxDecoration(
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
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                    (notelp.toString() != "null" && notelp.toString() != '')?CustomText.bodyLight16(text: notelp, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))
                                        :CustomText.bodyLight16(text: "Nomor belum diisi.", maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    CustomText.bodyLight16(text: email, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                      ):
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                        child: CustomText.textHeading4(
                            text: "Info Lainnya",
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
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
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
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
                            launch('mailto:info@indonesiarestoguide.id');
                          },
                          child: Row(
                            children: [
                              Icon(MaterialCommunityIcons.inbox_arrow_down),
                              SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                              CustomText.bodyRegular16(
                                  text: "Masukan",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
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
                            (owner != 'true')?(kosong == '1')?Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: AddViewResto())):Fluttertoast.showToast(msg: "Tunggu sebentar."):
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    title: Text('Bisnismu', style: TextStyle(color: CustomColor.primary)),
                                    content: Container(
                                      height: CustomSize.sizeHeight(context) / 2.2,
                                      width: CustomSize.sizeWidth(context) / 1.1,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          controller: _scrollController,
                                          physics: BouncingScrollPhysics(),
                                          itemCount: user.length,
                                          itemBuilder: (_, index){
                                            return Padding(
                                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                                              child: GestureDetector(
                                                onTap: () async{
                                                  // Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id)));
                                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                                  pref.setInt("ownerId", user[index].id!);
                                                  pref.setString("owner", 'true') ?? '';
                                                  pref.setString("nameOwner", name);
                                                  pref.setString("emailOwner", email);
                                                  pref.setString("homepg", "1");
                                                  _getCheckResto();
                                                },
                                                child: Container(
                                                  // width: CustomSize.sizeWidth(context),
                                                  // height: CustomSize.sizeHeight(context) / 7.5,
                                                  color: Colors.white,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: CustomSize.sizeWidth(context) / 9,
                                                            height: CustomSize.sizeWidth(context) / 9,
                                                            decoration: (user[index].img == "/".substring(0, 1))?BoxDecoration(
                                                                color: CustomColor.primaryLight,
                                                                shape: BoxShape.circle
                                                            ):BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              image: new DecorationImage(
                                                                  image: (user[index].img != null)?NetworkImage(Links.subUrl +
                                                                      user[index].img!):AssetImage('assets/default.png') as ImageProvider,
                                                                  fit: BoxFit.cover
                                                              ),
                                                            ),
                                                            child: (user[index].img == "/".substring(0, 1))?Center(
                                                              child: CustomText.text(
                                                                  size: double.parse(((MediaQuery.of(context).size.width*0.093).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.093)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.093)).toString()),
                                                                  weight: FontWeight.w800,
                                                                  // text: initial,
                                                                  color: Colors.white
                                                              ),
                                                            ):Container(),
                                                          ),
                                                          SizedBox(width: CustomSize.sizeWidth(context) / 28,),
                                                          Container(
                                                            width: CustomSize.sizeWidth(context) / 2.5,
                                                            // width: CustomSize.sizeWidth(context) / 1.6,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                CustomText.textHeading4(
                                                                    text: user[index].name,
                                                                    maxLines: 2,
                                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                                ),
                                                                CustomText.textTitle1(
                                                                    text: user[index].email,
                                                                    maxLines: 12,
                                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                                ),
                                                                // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                                // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      GestureDetector(
                                                          onTap: (){
                                                            showAlertDialog(user[index].id.toString());
                                                          },
                                                          child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                                      ),
                                                      // Padding(
                                                      //   padding: const EdgeInsets.only(right: 8.0),
                                                      //   child: GestureDetector(
                                                      //       onTap: () async{
                                                      //         setState(() {
                                                      //           showAlertDialog(user[index].id.toString());
                                                      //         });
                                                      //       },
                                                      //       child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                                      //   ),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                      ),
                                    ),
                                    // actions: <Widget>[
                                    //   Center(
                                    //     child: Row(
                                    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    //       children: [
                                    //         FlatButton(
                                    //           // minWidth: CustomSize.sizeWidth(context),
                                    //           color: CustomColor.redBtn,
                                    //           textColor: Colors.white,
                                    //           shape: RoundedRectangleBorder(
                                    //               borderRadius: BorderRadius.all(Radius.circular(10))
                                    //           ),
                                    //           child: Text('Batal'),
                                    //           onPressed: () async{
                                    //             setState(() {
                                    //               // codeDialog = valueText;
                                    //               Navigator.pop(context);
                                    //             });
                                    //           },
                                    //         ),
                                    //         FlatButton(
                                    //           color: CustomColor.primaryLight,
                                    //           textColor: Colors.white,
                                    //           shape: RoundedRectangleBorder(
                                    //               borderRadius: BorderRadius.all(Radius.circular(10))
                                    //           ),
                                    //           child: Text('Iya'),
                                    //           onPressed: () async{
                                    //             Navigator.pop(context);
                                    //             String qrcode = '';
                                    //             // addResto2();
                                    //           },
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    //
                                    // ],
                                  );
                                });
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
                                  text: (owner != 'true')?"Kelola Restomu":'Lihat Bisnis',
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
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
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
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
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
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
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
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
                      if (owner == 'true' && homepg == "1") {
                        _googleSignIn.signOut();
                        _getOwnerOut();
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.clear();
                        setState(() {
                          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new LoginActivity()));
                        });
                      } else {
                        _googleSignIn.signOut();
                        logOut();
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.clear();
                        setState(() {
                          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new LoginActivity()));
                        });
                      }
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
                            CustomText.bodyRegular16(text: "Keluar", color: CustomColor.primary, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
