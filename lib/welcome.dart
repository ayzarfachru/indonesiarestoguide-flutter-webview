import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
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

  // Future idPlayer() async {
  //   await OneSignal.shared.getDeviceState().then((status) async {
  //     print(playerId);
  //     setState(() {
  //       playerId = status?.userId;
  //     });
  //
  //     print(playerId);
  //     if (playerId == null) {
  //       CustomNavigator.navigatorPushReplacementWelcome(context, new Welcome());
  //     } else {
  //       await initDynamicLinks().whenComplete(() async {
  //         SharedPreferences pref = await SharedPreferences.getInstance();
  //         String urlDyLink = pref.getString("url_dylink") ?? "";
  //         pref.setString("url_dylink", "");
  //         _checkForSession().then((status) {
  //           if (status) {
  //             CustomNavigator.navigatorPushReplacement(
  //                 context,
  //                 new WebViewActivity(
  //                   codeNotif: "",
  //                   url: urlDyLink,
  //                 ));
  //           }
  //         });
  //       });
  //     }
  //   });
  // }

  Future idPlayer() async {
    await OneSignal.shared.getDeviceState().then((status) {
      print(playerId);
      setState(() {
        playerId = status?.userId;
      });

      print(playerId);
      if (playerId == null) {
        CustomNavigator.navigatorPushReplacementWelcome(context, new Welcome());
      } else {
        _checkForSession().then((status) {
          print('_checkForSession 1');
          print(status);
          if (status) {
            initDynamicLinks();
          }
        });
      }
    });
  }

  AppUpdateInfo? _updateInfo;
  Future<void> checkForUpdate() async {

    print('UpdateAvailability.updateAvailable');
    print(UpdateAvailability.updateAvailable);
    print(_updateInfo?.updateAvailability);

    InAppUpdate.checkForUpdate().then((info) {

      setState(() {

        _updateInfo = info;

        print('UpdateAvailability.updateAvailable');
        print(info);
        print(UpdateAvailability.updateAvailable);
        print('_updateInfo?.updateAvailability 1');
        print(_updateInfo?.updateAvailability);
        print('UpdateAvailability.updateAvailable 1');
        print(UpdateAvailability.updateAvailable);
        print(_updateInfo?.availableVersionCode);
        print(UpdateAvailability.updateNotAvailable);
        print('UpdateAvailability.updateAvailable');
        if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate().catchError((e) => showSnack(e.toString()));
        } else {
          _checkForSession().then((status) {
            print('_checkForSession');
            print(status);
            if (status) {
              print('check');
              initDynamicLinks();
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

  // Future initDynamicLinks() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   final PendingDynamicLinkData? data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //
  //   print('dylink1');
  //   if (data != null) {
  //     print(data.link);
  //     pref.setString("url_dylink", data.link.queryParameters["url"].toString());
  //   }
  //   FirebaseDynamicLinks.instance.onLink
  //       .listen((PendingDynamicLinkData dynamicLink) async {
  //     print('dylink2');
  //     print(dynamicLink.link.queryParameters["url"]);
  //     pref.setString(
  //         "url_dylink", dynamicLink.link.queryParameters["url"].toString());
  //   });
  // }

  Future initDynamicLinks() async {
    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();

    print('dylink1');
    print(data?.link);
    if (data != null) {
      if (data.link.toString().contains('resto-detail')) {
        CustomNavigator.navigatorPushReplacement(
            context,
            new WebViewActivity(
              codeNotif: "",
              url: data.link.toString().split('open/?url=')[1].toString(),
            ));
      }
    } else {
      CustomNavigator.navigatorPushReplacement(
          context,
          new WebViewActivity(
            codeNotif: "",
            url: "",
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    idPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
