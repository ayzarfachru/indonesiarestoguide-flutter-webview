import 'package:flutter/material.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:kam5ia/webview_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class Welcome extends StatefulWidget {
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String? playerId;

  Future<bool> _checkForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});

    return true;
  }

  Future idPlayer() async {
    await OneSignal.shared.getDeviceState().then((status) async {
      print(playerId);
      setState(() {
        playerId = status?.userId;
      });

      print(playerId);
      if (playerId == null) {
        CustomNavigator.navigatorPushReplacementWelcome(context, new Welcome());
      } else {
        await initDynamicLinks().whenComplete(() async {
          SharedPreferences pref = await SharedPreferences.getInstance();
          String urlDyLink = pref.getString("url_dylink") ?? "";
          pref.setString("url_dylink", "");
          _checkForSession().then((status) {
            if (status) {
              CustomNavigator.navigatorPushReplacement(
                  context,
                  new WebViewActivity(
                    codeNotif: "",
                    url: urlDyLink,
                  ));
            }
          });
        });
      }
    });
  }

  Future initDynamicLinks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    print('dylink1');
    if (data != null) {
      print(data.link);
      pref.setString("url_dylink", data.link.queryParameters["url"].toString());
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      print('dylink2');
      print(dynamicLink.link.queryParameters["url"]);
      pref.setString(
          "url_dylink", dynamicLink.link.queryParameters["url"].toString());
    });
  }

  @override
  void initState() {
    super.initState();
    idPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primaryLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: CustomSize.sizeWidth(context) / 86),
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
            ],
          ),
        ),
      ),
    );
  }
}
