import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:indonesiarestoguide/webview_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';

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
    if (OneSignal.Notifications.permission == false) {
      OneSignal.Notifications.requestPermission(true);
    }
    Future.delayed(Duration(milliseconds: 1500), () async {
      OneSignal.User.pushSubscription.optIn();
      playerId = await OneSignal.User.pushSubscription.id;

      setState(() {});

      if (playerId == null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          CustomNavigator.navigatorPushReplacementWelcome(
              context, new Welcome());
        });
      } else {
        _checkForSession().then((status) {
          if (status) {
            initDynamicLinks();
          }
        });
      }
    });
  }

  AppUpdateInfo? _updateInfo;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate()
              .catchError((e) => showSnack(e.toString()));
        } else {
          _checkForSession().then((status) {
            if (status) {
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

  Future initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    checkToken().whenComplete(() async {
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
        if (!_initialURILinkHandled) {
          _initialURILinkHandled = true;
          try {
            // 3
            final initialURI = await getInitialUri();
            // 4
            if (initialURI != null) {
              if (!mounted) {
                return;
              }
              if (initialURI.toString().contains('url')) {
                if (initialURI.toString().contains('qr')) {
                  urlFI = (initialURI.queryParameters['url']
                          .toString()
                          .contains('resto-detail/'))
                      ? initialURI.queryParameters['url'].toString()
                      : initialURI.queryParameters['url'].toString();
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  pref.setString(
                      "table",
                      initialURI.queryParameters['url']
                          .toString()
                          .split('qr=')[1]);
                } else {
                  urlFI = (initialURI.queryParameters['url']
                          .toString()
                          .contains('resto-detail/'))
                      ? initialURI.queryParameters['url'].toString()
                      : initialURI.queryParameters['url'].toString();
                }
              } else {
                if (initialURI.toString().contains('qr')) {
                  urlFI =
                      initialURI.toString().replaceAll('mirg://', 'https://');
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  pref.setString(
                      "table", initialURI.toString().split('qr=')[1]);
                } else {
                  urlFI =
                      initialURI.toString().replaceAll('mirg://', 'https://');
                }
              }
              setState(() {});
            } else {
              // app link with api
              SharedPreferences pref = await SharedPreferences.getInstance();
              String is_first_install =
                  (pref.getString("is_first_install") ?? "true");
              if (is_first_install.toString() == 'null') {
                is_first_install = 'true';
              }
              if (isLoadingFI != true) {
                isLoadingFI = true;
                setState(() {});
                if (is_first_install != 'false') {
                  var apiResult = await http.get(
                      Uri.parse("${const String.fromEnvironment('jiitulinks')}"),
                      headers: {
                        "Accept": "Application/json",
                      });
                  if (apiResult.statusCode == 200) {
                    isLoadingFI = false;
                    if (json
                        .decode(apiResult.body)
                        .toString()
                        .contains('url')) {
                      urlFI = json.decode(apiResult.body)['url'];
                      if (json
                          .decode(apiResult.body)
                          .toString()
                          .contains('qr')) {
                        tableFI = json
                            .decode(apiResult.body)['url']
                            .toString()
                            .split('qr=')[1];
                        pref.setString(
                            "table",
                            json
                                .decode(apiResult.body)['url']
                                .toString()
                                .split('qr=')[1]);
                      }
                    }
                    pref.setString("is_first_install", "false");
                    CustomNavigator.navigatorPush(
                        context,
                        new WebViewActivity(
                          codeNotif: codeNotif,
                          url: (urlFI.toString().contains('resto-detail/'))
                              ? urlFI.toString()
                              : urlFI
                                  .toString()
                                  .replaceAll('resto-detail', 'resto-detail/'),
                        ));
                    setState(() {});
                  } else {
                    pref.setString("is_first_install", "false");
                    isLoadingFI = false;
                    CustomNavigator.navigatorPush(
                        context,
                        new WebViewActivity(
                          codeNotif: codeNotif,
                          url: (urlFI.toString().contains('resto-detail/'))
                              ? urlFI.toString()
                              : urlFI
                                  .toString()
                                  .replaceAll('resto-detail', 'resto-detail/'),
                        ));
                    setState(() {});
                  }
                } else {
                  isLoadingFI = false;
                  CustomNavigator.navigatorPush(
                      context,
                      new WebViewActivity(
                        codeNotif: codeNotif,
                        url: (urlFI.toString().contains('resto-detail/'))
                            ? urlFI.toString()
                            : urlFI
                                .toString()
                                .replaceAll('resto-detail', 'resto-detail/'),
                      ));
                }
              }
            }
          } on PlatformException {
            debugPrint("Failed to receive initial uri");
          }
        }

        CustomNavigator.navigatorPush(
            context,
            new WebViewActivity(
              codeNotif: codeNotif,
              url: (urlFI.toString().contains('resto-detail/'))
                  ? urlFI.toString()
                  : urlFI
                      .toString()
                      .replaceAll('resto-detail', 'resto-detail/'),
            ));
      }
    });
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future handleTableLink(String urlLink) async {
    var parameters = DynamicLinkParameters(
      uriPrefix: "${const String.fromEnvironment('pagelink')}",
      link: Uri.parse(urlLink),
      androidParameters: AndroidParameters(
        packageName: "com.devus.indonesiarestoguide",
        fallbackUrl: Uri.parse("${const String.fromEnvironment('jiitu')}"),
      ),
      iosParameters: IOSParameters(
        bundleId: "com.devus.indonesiarestoguide",
        appStoreId: "1498909115",
      ),
    );
    var shortLink = await dynamicLinks.buildShortLink(parameters);
    var shortUrl = shortLink.shortUrl;

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("table", shortUrl.toString());
  }

  String codeNotif = '';

  Future checkToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    if (token != "" && token != "null") {
      var apiResult = await http.get(
          Uri.parse("${const String.fromEnvironment('jiitucheck')}"),
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      if (apiResult.body.toString().contains('Unauthenticated') == false) {
        if (json.decode(apiResult.body)['transaction'] != false) {
          var data = json.decode(apiResult.body)['transaction']['id'];
          setState(() {
            codeNotif = "IRG-" +
                data.toString().padLeft(5, '0') +
                " sudah siap diambil";
          });
        }
      }
    }
  }

  bool isLoadingFI = false;
  String urlFI = '';
  String tableFI = '';
  bool _initialURILinkHandled = false;

  Future firstInstall() async {
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;
      try {
        final initialURI = await getInitialUri();
        if (initialURI != null) {
          if (!mounted) {
            return;
          }
          if (initialURI.toString().contains('url')) {
            if (initialURI.toString().contains('qr')) {
              urlFI = (initialURI.queryParameters['url']
                      .toString()
                      .contains('resto-detail/'))
                  ? initialURI.queryParameters['url'].toString()
                  : initialURI.queryParameters['url'].toString();
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString("table",
                  initialURI.queryParameters['url'].toString().split('qr=')[1]);
            } else {
              urlFI = (initialURI.queryParameters['url']
                      .toString()
                      .contains('resto-detail/'))
                  ? initialURI.queryParameters['url'].toString()
                  : initialURI.queryParameters['url'].toString();
            }
          } else {
            if (initialURI.toString().contains('qr')) {
              urlFI = initialURI.toString().replaceAll('mirg://', 'https://');
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString("table", initialURI.toString().split('qr=')[1]);
            } else {
              urlFI = initialURI.toString().replaceAll('mirg://', 'https://');
            }
          }
          setState(() {});
        } else {
          // app link with api
          SharedPreferences pref = await SharedPreferences.getInstance();
          String is_first_install =
              (pref.getString("is_first_install") ?? "true");
          if (isLoadingFI != true) {
            isLoadingFI = true;
            setState(() {});
            if (is_first_install != 'false') {
              var apiResult = await http.get(
                  Uri.parse("${const String.fromEnvironment('jiitulinks')}"),
                  headers: {
                    "Accept": "Application/json",
                  });
              if (apiResult.statusCode == 200) {
                isLoadingFI = false;
                if (json.decode(apiResult.body).toString().contains('url')) {
                  urlFI = json.decode(apiResult.body)['url'];
                  if (json.decode(apiResult.body).toString().contains('qr')) {
                    tableFI = json
                        .decode(apiResult.body)['url']
                        .toString()
                        .split('qr=')[1];
                    pref.setString(
                        "table",
                        json
                            .decode(apiResult.body)['url']
                            .toString()
                            .split('qr=')[1]);
                  }
                }
                pref.setString("is_first_install", "false");
                setState(() {});
              } else {
                pref.setString("is_first_install", "false");
                isLoadingFI = false;
                setState(() {});
              }
            } else {
              isLoadingFI = false;
            }
          }
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        debugPrint("Failed to receive initial uri");
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    idPlayer();
    OneSignal.Notifications.addClickListener((result) {
      var res = result.notification.collapseId.toString();
      if (res.contains('home_user')) {
        if (res.split('home_')[1].split('_')[0] == 'user') {
          CustomNavigator.navigatorPushReplacement(
              context,
              new WebViewActivity(
                codeNotif: codeNotif,
                url: ('${const String.fromEnvironment('url')}/resto-detail/' +
                    res.split('home_user_')[1]),
              ));
        }
      } else if (res.contains('home_admin')) {
        if (res.split('home_')[1].split('_')[0] == 'admin') {
          CustomNavigator.navigatorPushReplacement(
              context,
              new WebViewActivity(
                codeNotif: codeNotif,
                url:
                    ('${const String.fromEnvironment('url')}/profile/user/?page=/redirectToTrasaction/' +
                        res.split('home_admin_')[1]),
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
