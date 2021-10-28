import 'package:flutter/material.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  Future idPlayer() async{
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    playerId = status.subscriptionStatus.userId;

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("playerId", playerId);

    print('player id'+playerId.toString());
    setState(() {});
  }
  String? playerId;

  @override
  void initState() {
    idPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: CustomColor.primaryLight,
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
                child: CustomText.textHeading9(text: "Indonesia Resto Guide"),
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
                  idPlayer();
                  Navigator.pushReplacement(
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
