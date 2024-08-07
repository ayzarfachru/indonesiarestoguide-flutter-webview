import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:indonesiarestoguide/welcome.dart';
import 'package:indonesiarestoguide/webview_activity.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.audio.request();
  await Permission.location.request();
  await Permission.manageExternalStorage.request();
  await Permission.storage.request();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await Firebase.initializeApp();
  OneSignal.initialize("${const String.fromEnvironment('onsignalid')}");
  OneSignal.Notifications.requestPermission(true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future initDynamicLinks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null) {
      pref.setString("url_dylink", data.link.queryParameters["url"].toString());
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      pref.setString(
          "url_dylink", dynamicLink.link.queryParameters["url"].toString());
    });
  }

  String id = "";
  bool isLoading = false;

  Future _toWebViewDetailResto(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url: "${const String.fromEnvironment('url')}/resto-detail/" + id,
            )));
  }

  Future _toWebViewHistoryDetail(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url: "${const String.fromEnvironment('url')}/history/" +
                  id +
                  "/resto",
            )));
  }

  Future _toWebViewAdmin(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url:
                  "${const String.fromEnvironment('url')}/profile/user/?page=/redirectToTrasaction/" +
                      id,
            )));
  }

  String codeNotif = "";

  Future _toWebView() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: codeNotif,
              url: pref.getString("url") ?? "",
            )));
  }

  bool isLogin = false;
  String res = '';

  @override
  void initState() {
    // initDynamicLinks();
    OneSignal.Notifications.addForegroundWillDisplayListener((result) {
      // Display Notification, send null to not display, send notification to display
      if (result.notification.body.toString().contains("IRG-")) {
        setState(() {
          codeNotif = result.notification.body.toString();
        });
        _toWebView();
      } else if (result.notification.body
          .toString()
          .toLowerCase()
          .contains("pembayaran transaksi")) {
        setState(() {
          codeNotif = result.notification.body.toString();
        });
        _toWebView();
      }
    });

    OneSignal.Notifications.addClickListener((result) {
      if (result.notification.body.toString().contains("IRG-")) {
        setState(() {
          codeNotif = result.notification.body.toString();
        });
        _toWebView();
      } else if (result.notification.body
          .toString()
          .toLowerCase()
          .contains("pembayaran transaksi")) {
        var aStr = result.notification.body
            .toString()
            .replaceAll(new RegExp(r'[^0-9]'), '');
        var aInt = int.parse(aStr);
        final RegExp regexp = new RegExp(r'^0+(?=.)');
        _toWebViewHistoryDetail(aInt.toString().replaceAll(regexp, ''));
      } else if (result.notification.body
          .toString()
          .toLowerCase()
          .contains("ada pesanan")) {
        if (result.notification.collapseId
                .toString()
                .toLowerCase()
                .split('home_')[1]
                .split('_')[0] ==
            'admin') {
          _toWebViewAdmin(result.notification.collapseId
              .toString()
              .toLowerCase()
              .split('home_admin_')[1]);
        }
      } else if (result.notification.body
          .toString()
          .toLowerCase()
          .contains("ada promo")) {
        if (result.notification.collapseId
                .toString()
                .toLowerCase()
                .split('home_')[1]
                .split('_')[0] ==
            'user') {
          _toWebViewDetailResto(
              result.notification.collapseId.toString().split("home_user_")[1]);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: CustomColor.primary,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            color: CustomColor.background, centerTitle: true, elevation: 0),
      ),
      home: new Welcome(),
    );
  }
}
