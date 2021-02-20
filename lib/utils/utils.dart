import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/model/Promo.dart';
import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Links{
  static String mainUrl = "http://192.168.100.10:8000/api/v2";
  static String subUrl = "http://192.168.100.10:8000";
}

class CustomText{
  static Widget text(
      {String text,
      double size,
      double minSize,
      int maxLines,
      FontWeight weight,
      Color color}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: size,
              fontWeight:
              weight, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textHeading1({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 32,
              fontWeight:
              FontWeight.w700, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textHeading2({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 32,
              fontWeight:
              FontWeight.w600, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textHeading3({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textHeading4({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w600, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textHeading5({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.w600, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle1({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w400, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle2({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle3({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle5({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle6({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget textTitle7({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 13,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyMedium16({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyMedium14({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyMedium12({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w500, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyRegular16({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w400, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyRegular14({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w400, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyRegular12({String text, Color color,
    double minSize, int maxLines, TextDecoration decoration}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w400, color: color??Colors.black,
              decoration: decoration??TextDecoration.none)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyLight16({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyLight14({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyLight12({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }

  static Widget bodyLight10({String text, Color color,
    double minSize, int maxLines,}){
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontSize: 10,
              fontWeight:
              FontWeight.w300, color: color??Colors.black)),
      minFontSize: minSize??0,
      maxLines: maxLines??1,
    );
  }
}

class CustomColor{
  static Color primary = Color(0xffAF1E22);
  static Color primaryLight = Color(0xffAF1E22).withOpacity(.2);
  static Color secondary = Color(0xffF5F5F5);

  static Color accent = Color(0xff26CD67);
  static Color accentLight = Color(0xff26CD67).withOpacity(0.2);

  static Color background = Color(0xffF2F6FD);

  static Color textTitle = Color(0xff040507);
  static Color textBody = Color(0xffA5A5A5);
  static Color textBodyWhite = Color(0xffFFFFFF);

  static Color dividerDark = Color(0xffCBD0DF);
  static Color dividerLight = Color(0xffF4F6FA);

  static List<Color> gradient1 = [Color(0xff2BC5F1), Color(0xff7FE2FE)];
  static List<Color> gradient2 = [Color(0xffFDFDFD), Color(0xffD6E7F3)];
  static List<Color> gradient3 = [Color(0xffFF92B0), Color(0xffD274DE)];
  static List<Color> gradient4 = [Color(0xff6EDBFA), Color(0xffBDF0FF)];
}

class CustomNavigator{
  static navigatorPush(BuildContext context, Widget direction) {
    return Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 100),
            child: direction));
  }
  static navigatorPushReplacement(BuildContext context, Widget direction) {
    return Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 100),
            child: direction));
  }
}

class CustomSize{
  static sizeHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static sizeWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
}

class Api{
  static Future<Resto> getResto(id) async {
    var request = await http.get(Links.mainUrl+"/api/v2/resto/detail/$id", headers: {"Accept": "Application/json"});
    var response = json.decode(request.body)['data'];
    var recom = <Menu>[];
    var menus = <Menu>[];
    var images = <String>[];
    var promos = <Promo>[];
    for(var rMenu in response['recom']){
      var price = Price(rMenu['price'], rMenu.containsKey('discounted') ? rMenu['dicounted'] : 0, rMenu['delivery_price']);
      var menu = Menu(rMenu['id'], rMenu['name'], rMenu['desc'], price, rMenu['img']);
      recom.add(menu);
    }
    for(var rMenu in response['menu']){
      for(var dMenu in rMenu['menu']){
        var price = Price(dMenu['price'], dMenu.containsKey('discounted') ? dMenu['dicounted'] : 0, dMenu['delivery_price']);
        var menu = Menu(dMenu['id'], dMenu['name'], dMenu['desc'], price, dMenu['img']);
        menus.add(menu);
      }
    }
    for(var url in response['img']){
      images.add(url);
    }
    for(var p in response['promo']){
      var price = Price(p['menu_price'], p['menu_discounted'], p['menu_price']);
      var menu = Menu(p['menu_id'], p['menu_name'], p['menu_desc'], price, p['menu_img']);
      var promo = Promo(p['menu_id'], p['word'], price.discounted, menu);
      promos.add(promo);
    }
    return Resto.all(
        id,
        response['name'],
        response['address'],
        response['desc'],
        response['range'],
        false,
        0,
        images,
        recom,
        menus,
        promos
    );
  }
}