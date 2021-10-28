import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/bookmark/bookmark_activity.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/history/history_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/profile/edit_profile.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/search/search_activity.dart';
import 'package:kam5ia/ui/splash_screen.dart';
import 'package:kam5ia/ui/welcome_screen.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'model/Resto.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
  OneSignal.shared.init(
      "a3dc8acb-9bd7-4ee4-9506-7f1252048e69",
      iOSSettings: null
  );
  OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

  // runApp(MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     routes: <String, WidgetBuilder>{
  //       '/': (BuildContext context) => MyApp(),
  //       '/open': (BuildContext context) => DetailResto(4.toString()),
  //     }
  // ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
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
          initDynamicLinks();
          print('IKI LOH COK');
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

  Future<Widget> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null){
      return getRoute(data.link);
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          print('pppp');
          return getRoute(dynamicLink!.link);
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      return e.message;
    });
    return HomeActivity();
  }

  Widget getRoute(deepLink){
    if (deepLink.toString().isEmpty) {
      return HomeActivity();
    }
    if (deepLink.path == "/open") {
      final id = deepLink.queryParameters["id"];
      if (id!= null) {
        return DetailResto(id);
      }
    }
    return HomeActivity();
  }


  bool isLogin = false;
  @override
  void initState() {
    // initDynamicLinks().then((status) {
    //   print('OI1 '+deepLink2);
    // });
    WidgetsBinding.instance!.addObserver(this);
    _checkForSession().then((status) {
      if (status) {
        _navigateHome();
      }
    });
    print('OI2 '+deepLink2);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('ASYU');
      _checkForSession().then((status) {
        if (status) {
          _navigateHome();
        }
      });
    }
    if (state == AppLifecycleState.inactive) {
      print('ASYU');
      _checkForSession().then((status) {
        if (status) {
          _navigateHome();
        }
      });
    }
    if (state == AppLifecycleState.paused) {
      print('ASYU');
      _checkForSession().then((status) {
        if (status) {
          _navigateHome();
        }
      });
    }
    if (state == AppLifecycleState.detached) {
      print('ASYU');
      _checkForSession().then((status) {
        if (status) {
          _navigateHome();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
          // routes: <String, WidgetBuilder>{
          //   '/open': (BuildContext context) => DetailResto(4.toString()),
          // },
      theme: ThemeData(
        primaryColor: CustomColor.primary,
        primaryColorBrightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        accentColor: CustomColor.primary,
        accentColorBrightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
            color: CustomColor.background,
            centerTitle: true,
            elevation: 0
        ),
      ),
      home: (isLogin)?new SplashScreen():new WelcomeScreen(),
    );
  }
}
