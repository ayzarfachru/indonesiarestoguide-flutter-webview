import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/ui/auth/login_activity.dart';
import 'package:indonesiarestoguide/ui/bookmark/bookmark_activity.dart';
import 'package:indonesiarestoguide/ui/cart/cart_activity.dart';
import 'package:indonesiarestoguide/ui/detail/detail_resto.dart';
import 'package:indonesiarestoguide/ui/history/history_activity.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/ui/profile/edit_profile.dart';
import 'package:indonesiarestoguide/ui/profile/profile_activity.dart';
import 'package:indonesiarestoguide/ui/promo/promo_activity.dart';
import 'package:indonesiarestoguide/ui/search/search_activity.dart';
import 'package:indonesiarestoguide/ui/splash_screen.dart';
import 'package:indonesiarestoguide/ui/welcome_screen.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Resto.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // GestureBinding.instance?.resamplingEnabled = true;
  // var resto = Api.getResto(4) as Resto;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  bool isLogin = false;
  @override
  void initState() {
    super.initState();
    _checkForSession().then((status) {
      if (status) {
        _navigateHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
