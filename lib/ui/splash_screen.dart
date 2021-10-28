import 'package:flutter/material.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String homepg = "";
  Future<String> getSwitch() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("akses") ?? "";
  }

  Future<bool> _checkForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});

    return true;
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  @override
  void initState() {
    super.initState();
    getHomePg();
    _checkForSession().then((status) {
      if (status) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => (homepg != "1")?HomeActivity():HomeActivityResto()));
      }
    });
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
            ],
          ),
        ),
      ),
    );
  }
}
