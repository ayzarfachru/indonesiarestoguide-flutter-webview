import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:kam5ia/webview_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;

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
        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate()
              .catchError((e) => showSnack(e.toString()));
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

    print('dylink1 welcome');
    print(data?.link);
    checkToken().whenComplete(() {
      if (data != null) {
        if (data.link.hasQuery) {
          if (data.link.toString().contains('resto-detail')) {
            if (data.link.toString().contains("/?qr")) {
              handleTableLink(data.link.toString()).whenComplete(() {
                CustomNavigator.navigatorPushReplacement(
                    context,
                    new WebViewActivity(
                      codeNotif: codeNotif,
                      url: (data.link.queryParameters["url"]
                          .toString()
                          .contains('resto-detail/'))
                          ? data.link.queryParameters["url"].toString()
                          : data.link.queryParameters["url"]
                          .toString()
                          .replaceAll('resto-detail', 'resto-detail/'),
                    ));
              });
            } else {
              CustomNavigator.navigatorPushReplacement(
                  context,
                  new WebViewActivity(
                    codeNotif: codeNotif,
                    url: (data.link.queryParameters["url"]
                        .toString()
                        .contains('resto-detail/'))
                        ? data.link.queryParameters["url"].toString()
                        : data.link.queryParameters["url"]
                        .toString()
                        .replaceAll('resto-detail', 'resto-detail/'),
                  ));
            }
          } else {
            CustomNavigator.navigatorPushReplacement(
                context,
                new WebViewActivity(
                  codeNotif: codeNotif,
                  url: "",
                ));
          }
        } else {
          CustomNavigator.navigatorPushReplacement(
              context,
              new WebViewActivity(
                codeNotif: codeNotif,
                url: "",
              ));
        }
      } else {
        CustomNavigator.navigatorPushReplacement(
            context,
            new WebViewActivity(
              codeNotif: codeNotif,
              url: "",
            ));
      }
    });
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future handleTableLink(String urlLink) async {
    var parameters = DynamicLinkParameters(
      uriPrefix: 'https://irgresto.page.link',
      link: Uri.parse(urlLink),
      androidParameters: AndroidParameters(
        packageName: "com.devus.indonesiarestoguide",
        fallbackUrl: Uri.parse("https://jiitu.co.id"),
      ),
      iosParameters: IOSParameters(
        bundleId: "com.devus.indonesiarestoguide",
        appStoreId: "1498909115",
      ),
    );
    var shortLink = await dynamicLinks.buildShortLink(parameters);
    var shortUrl = shortLink.shortUrl;

    print('table');
    print(urlLink);
    print(shortUrl);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("table", shortUrl.toString());
  }

  String codeNotif = '';
  // bool notifOrder = false;
  Future checkToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    if(token != "" && token != "null"){
      var apiResult = await http
          .get(Uri.parse('https://jiitu.co.id/api/irg/v2/transaction/user-check'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      print(apiResult.body);
      if (apiResult.body.toString().contains('Unauthenticated') == false) {
        if(json.decode(apiResult.body)['transaction'] != false){
          var data = json.decode(apiResult.body)['transaction']['id'];
          print(data);

          setState(() {
            codeNotif = "IRG-" + data.toString().padLeft(5, '0') + " sudah siap diambil";
            // notifOrder = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    idPlayer();
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('"OneSignal: notification opened: '+result.notification.collapseId.toString());
      var res = result.notification.collapseId.toString();
      // print(result.notification.payload.collapseId);
      print('res onesignal');
      print(res);
      if (res.contains('home_user')) {
        if (res.split('home_')[1].split('_')[0] == 'user'){
          CustomNavigator.navigatorPushReplacement(
              context,
              new WebViewActivity(
                codeNotif: codeNotif,
                url: ('https://m.indonesiarestoguide.id/resto-detail/'+res.split('home_user_')[1]),
              ));
        }
      } else if (res.contains('home_admin')) {
        if (res.split('home_')[1].split('_')[0] == 'admin'){
          CustomNavigator.navigatorPushReplacement(
              context,
              new WebViewActivity(
                codeNotif: codeNotif,
                url: ('https://m.indonesiarestoguide.id/profile/user/?page=/redirectToTrasaction/'+res.split('home_admin_')[1]),
              ));
        }
      }
    });
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
