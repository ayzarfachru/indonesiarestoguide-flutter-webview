import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kam5ia/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kam5ia/welcome.dart';
import 'package:kam5ia/webview_activity.dart';

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
  // await FlutterDownloader.initialize(debug: true);

  // GestureBinding.instance?.resamplingEnabled = true;
  // var resto = Api.getResto(4) as Resto;
  // OneSignal.shared.setAppId(
  //   "4fe55f91-4eb4-4b48-a92c-d7a1c31b114b",
  //   // iOSSettings: null
  // );
  OneSignal.initialize("4fe55f91-4eb4-4b48-a92c-d7a1c31b114b");
  // OneSignal.shared.addTrigger("prompt_ios", "true");
  // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  OneSignal.Notifications.requestPermission(true);
  // await OneSignal.shared
  //     .promptUserForPushNotificationPermission(fallbackToSettings: Platform.isIOS).then((value) => runApp(MyApp()));

  // runApp(MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     routes: <String, WidgetBuilder>{
  //       '/': (BuildContext context) => MyApp(),
  //       '/open': (BuildContext context) => DetailResto(4.toString()),
  //     }
  // ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<bool> _checkForSession() async {
    await Future.delayed(Duration.zero, () {});
    return true;
  }

  Future<int> getSwitch() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("id") ?? 0;
  }

  void _navigateHome() {
    getSwitch().then((onValue) {
      if (onValue == 0) {
        setState(() {
          isLogin = false;
        });
      } else {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  String deepLink2 = '';

  // initDynamicLinks() async {
  //   print('DynamicLinks onLink');
  //   // await Future.delayed(Duration(seconds: 3));
  //   var data = await FirebaseDynamicLinks.instance.getInitialLink();
  //   var deepLink = data.link;
  //   final queryParams = deepLink.queryParameters;
  //   if (queryParams.length > 0) {
  //     var userName = queryParams['userId'];
  //   }
  //   FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink)
  //   async {
  //     var deepLink = dynamicLink.link;
  //     deepLink2 = dynamicLink.toString();
  //     print(deepLink);
  //     debugPrint('DynamicLinks onLink $deepLink');
  //   }, onError: (e) async {
  //     debugPrint('DynamicLinks onError $e');
  //   });
  // }

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

  // Future<Widget> getRoute(deepLink) async {
  //   if (deepLink.toString().isEmpty) {
  //     return HomeActivity();
  //   } else {
  //     // if (deepLink.path == "/open") {
  //     //   final id = deepLink.queryParameters["id"];
  //     //   if (id != null) {
  //     //     if (id.toString().contains('-') == true) {
  //     //       SharedPreferences pref = await SharedPreferences.getInstance();
  //     //       // pref.getString('restoIdUsr')??'';
  //     //       print('TOL');
  //     //       return DetailResto(id.toString().split('-')[0]);
  //     //     } else {
  //     //       print('PUK');
  //     //       return DetailResto(id);
  //     //     }
  //     //   }
  //     // }
  //   }
  //   return HomeActivity();
  // }

  String owner = 'false';

  Future _getOwnerResto() async {
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    // List<User> _user = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/owner'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    // setState(() {
    //   // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
    //   // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
    //   // // history = _history;
    //   // openAndClose = (data['status'].toString() == "closed")?'1':'0';
    //   // isLoading = false;
    // });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['resto'].toString() == "[]") {
        _getUserResto();
      } else {
        owner = 'true';
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("ownerId", int.parse(res.split('_')[1]));
        pref.setString("owner", 'true');
        pref.setString("nameOwner", pref.getString('name') ?? '');
        pref.setString("emailOwner", pref.getString('email') ?? '');
        pref.setString("homepg", "1");
        _getCheckResto();
        // for(var v in data['resto']){
        //   User p = User.resto(
        //     id: int.parse(v['restaurant_id']),
        //     name: v['restaurant']['name'],
        //     email: v['restaurant']['address'],
        //     notelp: '',
        //     img: v['restaurant']['img'],
        //   );
        //   _user.add(p);
        // }
      }
    } else {
      _getUserResto();
    }

    setState(() {
      // user = _user;
    });
  }

  Future _getCheckResto() async {
    // List<History> _history = [];

    // setState(() {
    //   isLoading = true;
    // });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    int idRes = pref.getInt("ownerId") ?? 0;
    var apiResult = await http.get(
        Uri.parse(Links.mainUrl + '/owner/activate/' + idRes.toString()),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    setState(() {
      // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
      // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
      // // history = _history;
      // openAndClose = (data['status'].toString() == "closed")?'1':'0';
      // isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "User tidak punya resto") {
        kosong = '1';
      }
      // else if (data['resto']['id'] == null || id == 'null' || id == '') {
      //   kosong = '1';
      // }
      else {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("homepg", "1");
        // pref.setString("homerestoname", restoName);
        setState(() {
          // navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
          //     builder: (context) => new HomeActivityResto()));
        });
      }
    }
  }

  String id = "";
  bool isLoading = false;
  String restoName = "";
  String openAndClose = "0";
  String kosong = '';

  Future _getUserResto() async {
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    setState(() {
      id = (data['msg'].toString() == "User tidak punya resto")
          ? ''
          : data['resto']['id'].toString();
      restoName = (data['msg'].toString() == "User tidak punya resto")
          ? ''
          : data['resto']['name'];
      // history = _history;
      openAndClose = (data['status'].toString() == "closed") ? '1' : '0';
      isLoading = false;
    });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      if (data['msg'].toString() == "User tidak punya resto") {
        kosong = '1';
      } else if (data['resto']['id'] == null || id == 'null' || id == '') {
        kosong = '1';
      } else {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("homepg", "1");
        // pref.setString("homerestoname", restoName);
        setState(() {
          // navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
          //     builder: (context) => new HomeActivityResto()));
        });
      }
    }
  }

  Future _toWebViewDetailResto(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url: "https://m.indonesiarestoguide.id/resto-detail/" + id,
            )));
  }

  Future _toDetailRes() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // pref.setString("homepg", "");
    // navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
    //     builder: (context) => new DetailResto(res.split('_')[1])));
  }

  Future _toWebViewHistoryDetail(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url: "https://m.indonesiarestoguide.id/history/" + id + "/resto",
            )));
  }

  Future _toWebViewAdmin(String id) async {
    navigatorKey.currentState?.pushReplacement(new MaterialPageRoute(
        builder: (context) => new WebViewActivity(
              codeNotif: "",
              url:
                  "https://m.indonesiarestoguide.id/profile/user/?page=/redirectToTrasaction/" +
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

  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance!.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     print('ASYU');
  //     _checkForSession().then((status) {
  //       if (status) {
  //         _navigateHome();
  //       }
  //     });
  //   }
  //   if (state == AppLifecycleState.inactive) {
  //     print('ASYU');
  //     _checkForSession().then((status) {
  //       if (status) {
  //         _navigateHome();
  //       }
  //     });
  //   }
  //   if (state == AppLifecycleState.paused) {
  //     print('ASYU');
  //     _checkForSession().then((status) {
  //       if (status) {
  //         _navigateHome();
  //       }
  //     });
  //   }
  //   if (state == AppLifecycleState.detached) {
  //     print('ASYU');
  //     _checkForSession().then((status) {
  //       if (status) {
  //         _navigateHome();
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // routes: <String, WidgetBuilder>{
      //   '/open': (BuildContext context) => DetailResto(4.toString()),
      // },
      theme: ThemeData(
        primaryColor: CustomColor.primary,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            color: CustomColor.background, centerTitle: true, elevation: 0),
      ),
      // home: (isLogin)?new SplashScreen():new WelcomeScreen(),
      home: new Welcome(),
    );
  }
}
