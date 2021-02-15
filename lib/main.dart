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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance?.resamplingEnabled = true;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        appBarTheme: AppBarTheme(
            color: CustomColor.background,
            centerTitle: true,
            elevation: 0
        ),
      ),
      home: new CartActivity(),
    );
  }
}
