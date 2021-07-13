import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/ui/auth/login_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/irgLogo.png",
                width: CustomSize.sizeWidth(context) / 1.4,
                height: CustomSize.sizeWidth(context) / 1.4,
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 24,
              ),
              Container(
                alignment: Alignment.center,
                width: CustomSize.sizeWidth(context) / 1.1,
                child: CustomText.textHeading2(text: "Indonesia Resto Guide"),
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 48,
              ),
              CustomText.bodyMedium16(
                  text: "Get your favourite food from your",
                  maxLines: 1
              ),
              CustomText.bodyMedium16(
                  text: "favourite restaurant the fastest way",
                  maxLines: 1
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 18,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: LoginActivity()));
                },
                child: Container(
                  height: CustomSize.sizeHeight(context) / 12,
                  width: CustomSize.sizeWidth(context) / 1.4,
                  decoration: BoxDecoration(
                    color: CustomColor.primary,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: CustomText.bodyMedium16(
                        text: "Get Started",
                        color: Colors.white,
                        maxLines: 1
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
