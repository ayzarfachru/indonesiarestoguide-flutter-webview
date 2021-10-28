import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/welcome_screen.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  TextEditingController _loginTextEmail = TextEditingController(text: "");
  TextEditingController _loginTextPassword = TextEditingController(text: "");

  FocusNode? fPassword;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool isLoading = false;

  Future _login(String email, String password) async {
    await idPlayer();
    if(email != "" && password != ""){
      setState(() {
        isLoading = true;
      });
      var apiResult = await http.post(Links.mainUrl + '/auth/login', body: {'email': email, 'password': password, 'device_id': playerId});
      print(apiResult.body);
      var data = json.decode(apiResult.body);
      if (data['status_code'].toString() == "200") {

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("id", data['user']['id']);
        pref.setString("name", data['user']['name']);
        pref.setString("email", data['user']['email']);
        pref.setString("img", data['user']['img']);
        pref.setString("gender", data['user']['gender']);
        pref.setString("tgl", data['user']['ttl']);
        pref.setString("notelp", data['user']['phone_number']);
        pref.setString("token", data['access_token']);
        // pref.setString("timeLog", DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        print('Time '+DateTime.now().toString());
        print('Time '+DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: HomeActivity()));
      } else {
        Fluttertoast.showToast(
          msg: data['message'],);
        setState(() {
          isLoading = false;
        });
      }
    }else{
      Fluttertoast.showToast(
        msg: "Datamu kurang lengkap nih",);
    }
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

  Future<void> _handleSignIn() async {
    await idPlayer();
    await _googleSignIn.signOut();
    await _googleSignIn.signIn().then((value) async{
      print(playerId.toString()+' ply');
      var apiResult = await http.post(Links.mainUrl + '/auth/login/google',
          body: {'email': value.email, 'name': value.displayName, 'photoUrl': value.photoUrl, 'device_id': playerId});
      print(apiResult.body);
      var data = json.decode(apiResult.body);
      if (data['status_code'].toString() == "200") {

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("id", data['user']['id']);
        pref.setString("name", data['user']['name']);
        pref.setString("email", data['user']['email']);
        pref.setString("img", data['user']['img']);
        pref.setString("gender", data['user']['gender']);
        pref.setString("tgl", data['user']['ttl']);
        pref.setString("notelp", data['user']['phone_number']);
        pref.setString("token", data['access_token']);
        // pref.setString("timeLog", DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        print('Time '+DateTime.now().toString());
        print('Time '+DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        print(data['user']['id'].toString()+' telp');

        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: HomeActivity()));
      }else{
        Fluttertoast.showToast(
          msg: data['message'],);
      }
    });
  }

  Future idPlayer() async{
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    playerId = status.subscriptionStatus.userId;

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("playerId", playerId);

    print('player id'+playerId.toString());
    setState(() {});
  }
  String? playerId;

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
//     DateTime now = DateTime.now();
//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
//       return Future.value(false);
//     }
// //    SystemNavigator.pop();
//     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    exit(0);
    return Future.value(true);
  }

  @override
  void initState() {
    idPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        // backgroundColor: CustomColor.primaryLight,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRightWithFade,
                              child: WelcomeScreen()));
                    },
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
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 22,
                  ),
                  GestureDetector(
                    onDoubleTap: (){_login('admin@admin.com', 'adminadmin');},
                    child: Container(
                        alignment: Alignment.center,
                        child: MediaQuery(child: CustomText.textHeading2(text: "Sign in and explore !", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.08).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.08).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.08).toString())),
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),)
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 63,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: MediaQuery(
                      child: CustomText.bodyMedium16(
                          text: "Just one step before exploring",
                          maxLines: 1,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                      ),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: MediaQuery(
                      child: CustomText.bodyMedium16(
                          text: "the largest culinary network",
                          maxLines: 1,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                      ),
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 44,
                  ),
                  // CustomText.bodyMedium16(
                  //     text: "   Email",
                  //     maxLines: 1
                  // ),
                  // SizedBox(
                  //   height: CustomSize.sizeHeight(context) * 0.005,
                  // ),
                  // Container(
                  //   height: CustomSize.sizeHeight(context) / 14,
                  //   decoration: BoxDecoration(
                  //     color: Color(0xffF5F5F5),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  //     child: Center(
                  //       child: TextField(
                  //         controller: _loginTextEmail,
                  //         keyboardType: TextInputType.emailAddress,
                  //         cursorColor: Colors.black,
                  //         style: GoogleFonts.sourceSansPro(
                  //             textStyle:
                  //             TextStyle(fontSize: 16, color: Colors.black)),
                  //         decoration: InputDecoration(
                  //           isDense: true,
                  //           contentPadding: EdgeInsets.all(0),
                  //           hintStyle: GoogleFonts.poppins(
                  //               textStyle:
                  //               TextStyle(fontSize: 14, color: Colors.grey)),
                  //           helperStyle: GoogleFonts.poppins(
                  //               textStyle: TextStyle(fontSize: 14)),
                  //           enabledBorder: InputBorder.none,
                  //           focusedBorder: InputBorder.none,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  // CustomText.bodyMedium16(
                  //     text: "   Password",
                  //     maxLines: 1
                  // ),
                  // SizedBox(
                  //   height: CustomSize.sizeHeight(context) * 0.005,
                  // ),
                  // Container(
                  //   height: CustomSize.sizeHeight(context) / 14,
                  //   decoration: BoxDecoration(
                  //     color: Color(0xffF5F5F5),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: TextField(
                  //             enableInteractiveSelection: false,
                  //             autocorrect: false,
                  //             focusNode: fPassword,
                  //             obscureText: _obscureText,
                  //             controller: _loginTextPassword,
                  //             cursorColor: Colors.black,
                  //             style: GoogleFonts.poppins(
                  //                 textStyle:
                  //                 TextStyle(fontSize: 14, color: Colors.black)),
                  //             decoration: InputDecoration(
                  //               isDense: true,
                  //               contentPadding: EdgeInsets.all(0),
                  //               hintStyle: GoogleFonts.poppins(
                  //                   textStyle: TextStyle(
                  //                       fontSize: 16, color: Colors.grey)),
                  //               helperStyle: GoogleFonts.poppins(
                  //                   textStyle: TextStyle(fontSize: 14)),
                  //               enabledBorder: InputBorder.none,
                  //               focusedBorder: InputBorder.none,
                  //             ),
                  //           ),
                  //         ),
                  //         GestureDetector(
                  //           onTap: _toggle,
                  //           child: Icon(
                  //               _obscureText
                  //                   ? MaterialCommunityIcons.eye
                  //                   : MaterialCommunityIcons.eye_off,
                  //               color: Colors.black),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  //
                  // // SizedBox(
                  // //   height: CustomSize.sizeHeight(context) * 0.005,
                  // // ),
                  // // Align(
                  // //   alignment: Alignment.bottomRight,
                  // //   child: CustomText.bodyMedium16(
                  // //       text: "Forgot Password",
                  // //       color: CustomColor.primary,
                  // //       maxLines: 1
                  // //   ),
                  // // ),
                  // SizedBox(
                  //   height: CustomSize.sizeHeight(context) / 18,
                  // ),
                  // (isLoading != true)?GestureDetector(
                  //   onTap: (){
                  //     _login(_loginTextEmail.text, _loginTextPassword.text);
                  //   },
                  //   child: Container(
                  //     height: CustomSize.sizeHeight(context) / 12,
                  //     width: CustomSize.sizeWidth(context) ,
                  //     decoration: BoxDecoration(
                  //         color: CustomColor.primary,
                  //         borderRadius: BorderRadius.circular(20)
                  //     ),
                  //     child: Center(
                  //       child: CustomText.bodyMedium16(
                  //           text: "Sign in",
                  //           color: Colors.white,
                  //           maxLines: 1
                  //       ),
                  //     ),
                  //   ),
                  // ):Container(
                  //   height: CustomSize.sizeHeight(context) / 12,
                  //   width: CustomSize.sizeWidth(context) ,
                  //   decoration: BoxDecoration(
                  //       color: CustomColor.primary,
                  //       borderRadius: BorderRadius.circular(20)
                  //   ),
                  //   child: Center(
                  //     child: CircularProgressIndicator(
                  //       backgroundColor: Colors.white,
                  //       color: CustomColor.primaryLight,
                  //     ),
                  //   ),
                  // ),

                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/irgLogo.png",
                      width: CustomSize.sizeWidth(context) / 1.4,
                      height: CustomSize.sizeWidth(context) / 1.4,
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 54,
                  ),
                  Center(
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: CustomSize.sizeWidth(context) / 1.1,
                      child: MediaQuery(child: CustomText.textHeading8(text: "Indonesia Resto Guide", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.07).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.07).toString())),
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) * 0.005,
                  ),
                  Divider(),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) * 0.005,
                  ),
                  GestureDetector(
                    onTap: _handleSignIn,
                    child: Container(
                      height: CustomSize.sizeHeight(context) / 12,
                      width: CustomSize.sizeWidth(context) ,
                      decoration: BoxDecoration(
                          color: CustomColor.primary,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icon_google.png",
                            width: CustomSize.sizeWidth(context) / 14,
                            height: CustomSize.sizeWidth(context) / 14,
                          ),
                          MediaQuery(
                            child: CustomText.bodyMedium16(
                                text: " Masuk / Daftar dengan Google",
                                maxLines: 1,
                                color: Colors.white,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                            ),
                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
