import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  TextEditingController _loginTextEmail = TextEditingController(text: "");
  TextEditingController _loginTextPassword = TextEditingController(text: "");

  FocusNode fPassword;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "795151845860-o778hf0d6lf62tvnkpd0dc6ttrjt7hnm.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Future<void> _handleSignIn() async {
    await _googleSignIn.signOut();
    await _googleSignIn.signIn().then((value) async{
      print(value);
      // var apiResult = await http
      //     .post(Links.mainUrl + '/regis', body: {'email': value.email.toString(), 'password': value.id.toString(), 'address': "",
      //   'name': value.displayName.toString(), 'photoUrl': value.photoUrl.toString()});
      // print(apiResult.body);
      // var data = json.decode(apiResult.body);
      //
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // pref.setInt("id", data['user']['id']);
      // pref.setString("username", data['user']['username']);
      // pref.setString("name", data['user']['name']);
      // pref.setString("email", data['user']['email']);
      // pref.setString("img", data['user']['img']);
      // pref.setString("address", data['user']['address'].toString());
      // pref.setString("notelp", data['user']['notelp'].toString());
      // pref.setString("akses", data['user']['akses']);
      // pref.setString("token", data['access_token']);

    //   Navigator.pushReplacement(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.rightToLeft,
    //           child: HomeActivity()));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Container(
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
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 24,
                ),
                CustomText.textHeading2(text: "Sign in and explore !"),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 63,
                ),
                CustomText.bodyMedium16(
                    text: "Just one step before exploring",
                    maxLines: 1
                ),
                CustomText.bodyMedium16(
                    text: "the largest culinary network",
                    maxLines: 1
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 24,
                ),
                CustomText.bodyMedium16(
                    text: "   Email",
                    maxLines: 1
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) * 0.005,
                ),
                Container(
                  height: CustomSize.sizeHeight(context) / 14,
                  decoration: BoxDecoration(
                    color: Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    child: Center(
                      child: TextField(
                        controller: _loginTextEmail,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.black,
                        style: GoogleFonts.sourceSansPro(
                            textStyle:
                            TextStyle(fontSize: 16, color: Colors.black)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(0),
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
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                CustomText.bodyMedium16(
                    text: "   Password",
                    maxLines: 1
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) * 0.005,
                ),
                Container(
                  height: CustomSize.sizeHeight(context) / 14,
                  decoration: BoxDecoration(
                    color: Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            enableInteractiveSelection: false,
                            autocorrect: false,
                            focusNode: fPassword,
                            onSubmitted: (term) {
                              fPassword.unfocus();
                            },
                            obscureText: _obscureText,
                            controller: _loginTextPassword,
                            cursorColor: Colors.black,
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 14, color: Colors.black)),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(0),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggle,
                          child: Icon(
                              _obscureText
                                  ? MaterialCommunityIcons.eye
                                  : MaterialCommunityIcons.eye_off,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) * 0.005,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: CustomText.bodyMedium16(
                      text: "Forgot Password",
                      color: CustomColor.primary,
                      maxLines: 1
                  ),
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 18,
                ),
                Container(
                  height: CustomSize.sizeHeight(context) / 12,
                  width: CustomSize.sizeWidth(context) ,
                  decoration: BoxDecoration(
                      color: CustomColor.primary,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: CustomText.bodyMedium16(
                        text: "Sign in",
                        color: Colors.white,
                        maxLines: 1
                    ),
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
                        color: CustomColor.secondary,
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
                        CustomText.bodyMedium16(
                            text: "Lanjutkan dengan Google",
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
