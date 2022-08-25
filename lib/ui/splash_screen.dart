import 'package:flutter/material.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

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


  AppUpdateInfo? _updateInfo;
  bool _flexibleUpdateAvailable = false;

  Future<void> checkForUpdate() async {

    InAppUpdate.checkForUpdate().then((info) {

      setState(() {

        _updateInfo = info;

        if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate().catchError((e) => showSnack(e.toString()));
        } else {
          _checkForSession().then((status) {
            if (status) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => (homepg != "1")?HomeActivity():HomeActivityResto()));
            }
          });
        }

      });

    }).catchError((e) {

      showSnack(e.toString());

    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void showSnack(String text) {

    if (_scaffoldKey.currentContext != null) {

      ScaffoldMessenger.of(_scaffoldKey.currentContext!)

          .showSnackBar(SnackBar(content: Text(text)));

    }

  }


  Future<bool> _checkForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});

    return true;
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    getHomePg();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
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
                  child: CustomText.textHeading9(text: "Indonesia Resto Guide", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.075).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.075).toString())),
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 48,
                ),
                CustomText.bodyMedium16(
                    text: "Your Guidance to find the perfect",
                    maxLines: 1,
                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                ),
                CustomText.bodyMedium16(
                    text: "Restaurant in Indonesia",
                    maxLines: 1,
                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                ),
              ],
            ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
