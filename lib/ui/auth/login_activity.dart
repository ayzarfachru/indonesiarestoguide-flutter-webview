import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

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
                Container(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
