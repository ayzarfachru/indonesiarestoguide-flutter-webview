import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/imgBanner.dart';
import 'package:kam5ia/ui/auth/login_activity.dart';
import 'package:kam5ia/ui/bonus/es_activity.dart';
import 'package:kam5ia/ui/bonus/nasgor_activity.dart';
import 'package:kam5ia/ui/bookmark/bookmark_activity.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/detail/detail_transaction.dart';
import 'package:kam5ia/ui/detail/detail_transaction_reser.dart';
import 'package:kam5ia/ui/detail/food_stall_activity.dart';
import 'package:kam5ia/ui/detail/food_truck_activity.dart';
import 'package:kam5ia/ui/detail/kaki_lima_list_activity.dart';
import 'package:kam5ia/ui/detail/other_activity.dart';
import 'package:kam5ia/ui/detail/pesananmu_activity.dart';
import 'package:kam5ia/ui/detail/toko_oleh2_activity.dart';
import 'package:kam5ia/ui/detail/toko_roti_activity.dart';
import 'package:kam5ia/ui/history/history_activity.dart';
import 'package:kam5ia/ui/history/history_order_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/search/search_activity.dart';
import 'package:kam5ia/ui/top_home/lagi_diskon_activity.dart';
import 'package:kam5ia/ui/top_home/terdekat_activity.dart';
import 'package:kam5ia/ui/top_home/terlaris_activity.dart';
import 'package:kam5ia/ui/top_home/termurah_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../utils/utils.dart';

class Location {
  /// Initializes the plugin and starts listening for potential platform events.
  factory Location() => instance;

  Location._();

  static final Location instance = Location._();

  /// Change settings of the location request.
  ///
  /// The [accuracy] argument is controlling the precision of the
  /// [LocationData]. The [interval] and [distanceFilter] are controlling how
  /// often a new location is sent through [onLocationChanged].
  ///
  /// [interval] and [distanceFilter] are not used on web.
  Future<bool> changeSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    return LocationPlatform.instance.changeSettings(
      accuracy: accuracy,
      interval: interval,
      distanceFilter: distanceFilter,
    );
  }

  /// Gets the current location of the user.
  ///
  /// Throws an error if the app has no permission to access location.
  /// Returns a [LocationData] object.
  Future<LocationData> getLocation() async {
    return LocationPlatform.instance.getLocation();
  }

  /// Checks if the app has permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> hasPermission() {
    return LocationPlatform.instance.hasPermission();
  }

  /// Requests permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> requestPermission() {
    return LocationPlatform.instance.requestPermission();
  }

  /// Checks if the location service is enabled.
  Future<bool> serviceEnabled() {
    return LocationPlatform.instance.serviceEnabled();
  }

  /// Request the activation of the location service.
  Future<bool> requestService() {
    return LocationPlatform.instance.requestService();
  }

  /// Returns a stream of [LocationData] objects.
  /// The frequency and accuracy of this stream can be changed with
  /// [changeSettings]
  ///
  /// Throws an error if the app has no permission to access location.
  Stream<LocationData> get onLocationChanged {
    return LocationPlatform.instance.onLocationChanged;
  }
}

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> with WidgetsBindingObserver{
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();
  ScrollController _controller = ScrollController();
  List<imgBanner> images = [];
  List<String> images2 = ['assets/banner1.png','assets/banner2.png','assets/banner3.png'];
  bool isLoading = false;
  bool isLoading2 = false;
  bool isSearch = false;
  String inCart = "";
  String name = "";
  String chat_user = "";

  int totalCuisine = 0;

  List<MenuJson> menuJson = [];
  List<String> restoId = [];
  List<String> startCuisine = [];
  List<String> qty = [];
  List<Resto> resto = [];
  List<Resto> kakilima = [];
  List<Resto> foodstall = [];
  List<Resto> foodtruck = [];
  List<Resto> other = [];
  List<Resto> tokoroti = [];
  List<Resto> tokooleh = [];
  List<Resto> again = [];
  List<Menu> promo = [];
  List<Transaction> transaction = [];
  String note = '';
  Future _getDataHome(String lat, String long)async{
    List<Resto> _resto = [];
    List<Resto> _randomRes = [];
    List<Resto> _randomRes1 = [];
    List<Resto> _randomRes2 = [];
    List<Resto> _randomRes3 = [];
    List<Resto> _randomRes4 = [];
    List<Resto> _randomRes5 = [];
    List<Resto> _randomRes6 = [];
    List<Resto> _randomRes7 = [];
    List<Resto> _kakilima = [];
    List<Resto> _foodstall = [];
    List<Resto> _foodtruck = [];
    List<Resto> _other = [];
    List<Resto> _tokoroti = [];
    List<Resto> _tokooleh = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];
    List<Transaction> _transaction = [];
    List<imgBanner> _images = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print('all data'+apiResult.body.toString());
    var data = json.decode(apiResult.body);
    // print('all data'+data['tipename'].toString().split(',').length.toString());
    // print('all data'+data['tipe'][0].toString());
    print('all data'+data['tipename'].toString());
    print('all data'+data['tipename'].toString().split(',').length.toString());
    print('all data'+lat.toString());
    print('all data'+long.toString());
    // print(data['resto']);

    // print('ini banner '+data['banner'].toString());
    // for(var v in data['banner']){
    //   imgBanner t = imgBanner(
    //       id: int.parse(v['resto_id'].toString()),
    //       urlImg: v['img']
    //   );
    //   _images.add(t);
    // }

    if (data.toString().contains('trans')) {
      for(var v in data['trans']){
        Transaction t = Transaction.all2(
            id: v['id'],
            idResto: v['restaurants_id'].toString(),
            date: v['date'],
            img: v['img'],
            nameResto: v['resto_name'],
            status: v['status'],
            total: int.parse((v['total']??0).toString()) + int.parse((v['ongkir']??0).toString()),
            type: v['type_text'],
            note: v['note'].toString(),
            chat_user: v['chat_resto'].toString(),
            // address: v['address'].toString(),
        );
        if (v['type_text'].startsWith('Reservasi') == true && v['status'] == '') {

        } else {
          _transaction.add(t);
        }
      }
    }

    // print('ini resto '+data['resto'].toString());

    // for(var v in data['resto']){
    //   Resto r = Resto.all(
    //       id: v['id'],
    //       name: v['name'],
    //       distance: double.parse(v['distance'].toString()),
    //       img: v['img']
    //   );
    //   _resto.add(r);
    // }

    // if (data['tipe'].toString() != '[]') {
    //   if (data['tipe']['KakiLima'] != null) {
    //     for(var v in data['tipe']['KakiLima']){
    //       Resto r = Resto.all(
    //           id: v['id'],
    //           name: v['name'],
    //           distance: double.parse(v['distance'].toString()),
    //           img: v['img'],
    //           isOpen: v['isOpen'].toString()
    //       );
    //       _kakilima.add(r);
    //     }
    //   }
    //   if (data['tipe']['FoodStall'] != null) {
    //     for(var v in data['tipe']['FoodStall']){
    //       Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString(),
    //       );
    //       _foodstall.add(r);
    //     }
    //   }
    //   if (data['tipe']['FoodTruck'] != null) {
    //     for(var v in data['tipe']['FoodTruck']){
    //       Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString(),
    //       );
    //       _foodtruck.add(r);
    //     }
    //   }
    //   if (data['tipe']['TokoRoti'] != null) {
    //     for(var v in data['tipe']['TokoRoti']){
    //       Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString(),
    //       );
    //       _tokoroti.add(r);
    //     }
    //   }
    //   if (data['tipe']['TokoOlehOleh'] != null) {
    //     for(var v in data['tipe']['TokoOlehOleh']){
    //       Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString(),
    //       );
    //       _tokooleh.add(r);
    //     }
    //   }
    //   if (data['tipe']['Other'] != null) {
    //     for(var v in data['tipe']['Other']){
    //       Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString(),
    //       );
    //       _other.add(r);
    //     }
    //   }
    // }


    // print('ini again '+data['again'].toString());
    if (data.toString().contains('again')) {
      for(var v in data['again']){
        Resto r = Resto.all(
            id: v['id'],
            name: v['name'],
            distance: double.parse(v['distance'].toString()),
            img: v['img'],
            isOpen: v['isOpen'].toString()
        );
        _again.add(r);
      }
    }

    // for(var v in data['tipe']){
    //   Resto r = Resto.all(
    //       id: v['id'],
    //       name: v['name'],
    //       distance: double.parse(v['distance'].toString()),
    //       img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
    //       isOpen: v['isOpen'].toString()
    //   );
    //   _randomRes.add(r);
    // }

    // print('all data'+_randomRes.toString().contains('[').toString());

    if (data.toString().contains('tipe')) {
      if (data['tipename'].toString().split(',').length >= 1) {
        for(var v in data['tipe'][0]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes1.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 2) {
        for(var v in data['tipe'][1]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes2.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 3) {
        for(var v in data['tipe'][2]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes3.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 4) {
        for(var v in data['tipe'][3]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes4.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 5) {
        for(var v in data['tipe'][4]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes5.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 6) {
        for(var v in data['tipe'][5]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes6.add(r);
        }
      }
      if (data['tipename'].toString().split(',').length >= 7) {
        for(var v in data['tipe'][6]){
          Resto r = Resto.all(
              id: v['id'],
              name: v['name'],
              distance: double.parse(v['distance'].toString()),
              img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
              status: v['status'].toString(),
              isOpen: v['isOpen'].toString()
          );
          _randomRes7.add(r);
        }
      }
    }


    for(var v in data['promo']){
      Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          desc: v['desc']??'',
          urlImg: v['img'],
          is_available: '',
          price: Price.discounted(int.parse(v['price'].toString()), int.parse(v['discounted_price'].toString())),
          distance: double.parse(v['resto_distance'].toString()), is_recommended: '', qty: '', delivery_price: null, type: ''
      );
      _promo.add(m);
    }
    setState(() {
      images = _images;
      transaction = _transaction;
      randomRes1 = _randomRes1;
      randomRes2 = _randomRes2;
      randomRes3 = _randomRes3;
      randomRes4 = _randomRes4;
      randomRes5 = _randomRes5;
      randomRes6 = _randomRes6;
      randomRes7 = _randomRes7;
      tipe = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
      tipe2 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[1].toString():'';
      tipe3 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[2].toString():'';
      tipe4 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[3].toString():'';
      tipe5 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[4].toString():'';
      tipe6 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[5].toString():'';
      tipe7 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[6].toString():'';
      startCuisine.add(tipe);
      startCuisine.add(tipe2);
      startCuisine.add(tipe3);
      startCuisine.add(tipe4);
      startCuisine.add(tipe5);
      startCuisine.add(tipe6);
      startCuisine.add(tipe7);
      print('Start'+startCuisine.toString());
      totalCuisine = data['tipename'].toString().split(',').length;
      print('Start'+totalCuisine.toString());
      resto = _resto;
      kakilima = _kakilima;
      foodstall = _foodstall;
      foodtruck = _foodtruck;
      tokoroti = _tokoroti;
      tokooleh = _tokooleh;
      other = _other;
      again = _again;
      promo = _promo;
      isLoading = false;
    });
  }

  String page = '1';

  Future _page(String lat, String long)async{
    setState(() {
      isLoading2 = true;
    });

    List<Resto> _resto = [];
    List<Resto> _randomRes = [];
    List<Resto> _randomRes1 = [];
    List<Resto> _randomRes2 = [];
    List<Resto> _randomRes3 = [];
    List<Resto> _randomRes4 = [];
    List<Resto> _randomRes5 = [];
    List<Resto> _randomRes6 = [];
    List<Resto> _randomRes7 = [];
    List<Resto> _kakilima = [];
    List<Resto> _foodstall = [];
    List<Resto> _foodtruck = [];
    List<Resto> _other = [];
    List<Resto> _tokoroti = [];
    List<Resto> _tokooleh = [];
    List<Resto> _again = [];
    List<Menu> _promo = [];
    List<Transaction> _transaction = [];
    List<imgBanner> _images = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/home?lat=$lat&long=$long&page=$page', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print('all data'+apiResult.body.toString());
    var data = json.decode(apiResult.body);
    // print('all data'+data['tipename'].toString().split(',').length.toString());
    // print('all data'+data['tipe'][0].toString());
    // print('all data'+data['again'].toString());
    print('Puki');
    print('all data2'+page.toString());
    // print('all data2'+data.toString());
    print('all data2'+data['tipe'].toString());
    print('all data2'+data['tipename'].toString());
    // print('all data2'+data['tipe'][0].toString());
    // print(data['resto']);

    // print('ini banner '+data['banner'].toString());
    // for(var v in data['banner']){
    //   imgBanner t = imgBanner(
    //       id: int.parse(v['resto_id'].toString()),
    //       urlImg: v['img']
    //   );
    //   _images.add(t);
    // }

    // if (data.toString().contains('trans')) {
    //   for(var v in data['trans']){
    //     Transaction t = Transaction.all2(
    //       id: v['id'],
    //       idResto: v['restaurants_id'].toString(),
    //       date: v['date'],
    //       img: v['img'],
    //       nameResto: v['resto_name'],
    //       status: v['status'],
    //       total: int.parse((v['total']??0).toString()) + int.parse((v['ongkir']??0).toString()),
    //       type: v['type_text'],
    //       note: v['note'].toString(),
    //       chat_user: v['chat_resto'].toString(),
    //       // address: v['address'].toString(),
    //     );
    //     if (v['type_text'].startsWith('Reservasi') == true && v['status'] == '') {
    //
    //     } else {
    //       _transaction.add(t);
    //     }
    //   }
    // }
    //
    // // print('ini resto '+data['resto'].toString());
    //
    // // for(var v in data['resto']){
    // //   Resto r = Resto.all(
    // //       id: v['id'],
    // //       name: v['name'],
    // //       distance: double.parse(v['distance'].toString()),
    // //       img: v['img']
    // //   );
    // //   _resto.add(r);
    // // }
    //
    // // if (data['tipe'].toString() != '[]') {
    // //   if (data['tipe']['KakiLima'] != null) {
    // //     for(var v in data['tipe']['KakiLima']){
    // //       Resto r = Resto.all(
    // //           id: v['id'],
    // //           name: v['name'],
    // //           distance: double.parse(v['distance'].toString()),
    // //           img: v['img'],
    // //           isOpen: v['isOpen'].toString()
    // //       );
    // //       _kakilima.add(r);
    // //     }
    // //   }
    // //   if (data['tipe']['FoodStall'] != null) {
    // //     for(var v in data['tipe']['FoodStall']){
    // //       Resto r = Resto.all(
    // //         id: v['id'],
    // //         name: v['name'],
    // //         distance: double.parse(v['distance'].toString()),
    // //         img: v['img'],
    // //         isOpen: v['isOpen'].toString(),
    // //       );
    // //       _foodstall.add(r);
    // //     }
    // //   }
    // //   if (data['tipe']['FoodTruck'] != null) {
    // //     for(var v in data['tipe']['FoodTruck']){
    // //       Resto r = Resto.all(
    // //         id: v['id'],
    // //         name: v['name'],
    // //         distance: double.parse(v['distance'].toString()),
    // //         img: v['img'],
    // //         isOpen: v['isOpen'].toString(),
    // //       );
    // //       _foodtruck.add(r);
    // //     }
    // //   }
    // //   if (data['tipe']['TokoRoti'] != null) {
    // //     for(var v in data['tipe']['TokoRoti']){
    // //       Resto r = Resto.all(
    // //         id: v['id'],
    // //         name: v['name'],
    // //         distance: double.parse(v['distance'].toString()),
    // //         img: v['img'],
    // //         isOpen: v['isOpen'].toString(),
    // //       );
    // //       _tokoroti.add(r);
    // //     }
    // //   }
    // //   if (data['tipe']['TokoOlehOleh'] != null) {
    // //     for(var v in data['tipe']['TokoOlehOleh']){
    // //       Resto r = Resto.all(
    // //         id: v['id'],
    // //         name: v['name'],
    // //         distance: double.parse(v['distance'].toString()),
    // //         img: v['img'],
    // //         isOpen: v['isOpen'].toString(),
    // //       );
    // //       _tokooleh.add(r);
    // //     }
    // //   }
    // //   if (data['tipe']['Other'] != null) {
    // //     for(var v in data['tipe']['Other']){
    // //       Resto r = Resto.all(
    // //         id: v['id'],
    // //         name: v['name'],
    // //         distance: double.parse(v['distance'].toString()),
    // //         img: v['img'],
    // //         isOpen: v['isOpen'].toString(),
    // //       );
    // //       _other.add(r);
    // //     }
    // //   }
    // // }
    //
    //
    // // print('ini again '+data['again'].toString());
    // if (data.toString().contains('again')) {
    //   for(var v in data['again']){
    //     Resto r = Resto.all(
    //         id: v['id'],
    //         name: v['name'],
    //         distance: double.parse(v['distance'].toString()),
    //         img: v['img'],
    //         isOpen: v['isOpen'].toString()
    //     );
    //     _again.add(r);
    //   }
    // }

    // for(var v in data['tipe']){
    //   Resto r = Resto.all(
    //       id: v['id'],
    //       name: v['name'],
    //       distance: double.parse(v['distance'].toString()),
    //       img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
    //       isOpen: v['isOpen'].toString()
    //   );
    //   _randomRes.add(r);
    // }

    print('all data'+_randomRes.toString().contains('[').toString());

    if (data['tipe'].toString() != '[]') {
      if (data.toString().contains('tipe')) {
        if (data['tipename'].toString().split(',').length >= 1) {
          for(var v in data['tipe'][0]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes1.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 2) {
          for(var v in data['tipe'][1]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes2.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 3) {
          for(var v in data['tipe'][2]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes3.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 4) {
          for(var v in data['tipe'][3]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes4.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 5) {
          for(var v in data['tipe'][4]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes5.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 6) {
          for(var v in data['tipe'][5]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes6.add(r);
          }
        }
        if (data['tipename'].toString().split(',').length >= 7) {
          for(var v in data['tipe'][6]){
            Resto r = Resto.all(
                id: v['id'],
                name: v['name'],
                distance: double.parse(v['distance'].toString()),
                img: ((v['img'].toString() != '[]')?v['img'][0]['img']:'').toString(),
                status: v['status'].toString(),
                isOpen: v['isOpen'].toString()
            );
            _randomRes7.add(r);
          }
        }
      }


      setState(() {
        print('CUOK');
        if (randomRes8.toString() == '[]' && randomRes9.toString() == '[]' && randomRes10.toString() == '[]' && randomRes11.toString() == '[]' && randomRes12.toString() == '[]' && randomRes13.toString() == '[]' && randomRes14.toString() == '[]') {
          tipe8 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
          if (tipe != tipe8) {
            randomRes8 = _randomRes1;
            randomRes9 = _randomRes2;
            randomRes10 = _randomRes3;
            randomRes11 = _randomRes4;
            randomRes12 = _randomRes5;
            randomRes13 = _randomRes6;
            randomRes14 = _randomRes7;
            tipe8 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
            tipe9 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[1].toString():'';
            tipe10 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[2].toString():'';
            tipe11 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[3].toString():'';
            tipe12 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[4].toString():'';
            tipe13 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[5].toString():'';
            tipe14 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[6].toString():'';
            startCuisine.add(tipe8);
            startCuisine.add(tipe9);
            startCuisine.add(tipe10);
            startCuisine.add(tipe11);
            startCuisine.add(tipe12);
            startCuisine.add(tipe13);
            startCuisine.add(tipe14);
            page = '2';
            print('CUOK');
            isLoading2 = false;
          } else {
            print('CUOK2');
            tipe8 = '';
            isLoading2 = false;
          }
          print('CUOK3');
        } else if (randomRes15.toString() == '[]' && randomRes16.toString() == '[]' && randomRes17.toString() == '[]' && randomRes18.toString() == '[]' && randomRes19.toString() == '[]' && randomRes20.toString() == '[]' && randomRes21.toString() == '[]') {
          tipe15 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
          if (tipe != tipe15) {
            randomRes15 = _randomRes1;
            randomRes16 = _randomRes2;
            randomRes17 = _randomRes3;
            randomRes18 = _randomRes4;
            randomRes19 = _randomRes5;
            randomRes20 = _randomRes6;
            randomRes21 = _randomRes7;
            tipe15 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
            tipe16 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[1].toString():'';
            tipe17 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[2].toString():'';
            tipe18 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[3].toString():'';
            tipe19 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[4].toString():'';
            tipe20 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[5].toString():'';
            tipe21 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[6].toString():'';
            startCuisine.add(tipe15);
            startCuisine.add(tipe16);
            startCuisine.add(tipe17);
            startCuisine.add(tipe18);
            startCuisine.add(tipe19);
            startCuisine.add(tipe20);
            startCuisine.add(tipe21);
            page = '3';
            isLoading2 = false;
          } else {
            tipe15 = '';
            isLoading2 = false;
          }
        } else if (randomRes22.toString() == '[]' && randomRes23.toString() == '[]' && randomRes24.toString() == '[]' && randomRes25.toString() == '[]' && randomRes26.toString() == '[]' && randomRes27.toString() == '[]' && randomRes28.toString() == '[]') {
          tipe22 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
          if (tipe != tipe22) {
            randomRes22 = _randomRes1;
            randomRes23 = _randomRes2;
            randomRes24 = _randomRes3;
            randomRes25 = _randomRes4;
            randomRes26 = _randomRes5;
            randomRes27 = _randomRes6;
            randomRes28 = _randomRes7;
            tipe22 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6 || data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[0].toString():data['tipename'].toString().split('[')[1].split(']')[0].toString();
            tipe23 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[1].toString():'';
            tipe24 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[2].toString():'';
            tipe25 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[3].toString():'';
            tipe26 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[4].toString():'';
            tipe27 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[5].toString():'';
            tipe28 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 7)?data['tipename'].toString().split('[')[1].split(']')[0].split(', ')[6].toString():'';
            startCuisine.add(tipe22);
            startCuisine.add(tipe23);
            startCuisine.add(tipe24);
            startCuisine.add(tipe25);
            startCuisine.add(tipe26);
            startCuisine.add(tipe27);
            startCuisine.add(tipe28);
            page = 'null';
            isLoading2 = false;
          } else {
            tipe22 = '';
            isLoading2 = false;
          }
        }
        print('Start2'+startCuisine.toString());
        // randomRes9 = _randomRes2;
        // randomRes10 = _randomRes3;
        // randomRes4 = _randomRes4;
        // randomRes5 = _randomRes5;
        // randomRes6 = _randomRes6;
        // randomRes7 = _randomRes7;
        // tipe9 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 2)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[1].toString():'';
        // tipe10 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 3)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[2].toString():'';
        // tipe4 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 4)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[3].toString():'';
        // tipe5 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 5)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[4].toString():'';
        // tipe6 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length >= 6)?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[5].toString():'';
        // tipe7 = (data['tipename'].toString().split('[')[1].split(']')[0].split(',').length.toString() == '7')?data['tipename'].toString().split('[')[1].split(']')[0].split(',')[6].toString():'';
        // resto = _resto;
        // kakilima = _kakilima;
        // foodstall = _foodstall;
        // foodtruck = _foodtruck;
        // tokoroti = _tokoroti;
        // tokooleh = _tokooleh;
        // other = _other;
        // again = _again;
        // promo = _promo;
      });
    } else {
      setState((){
      isLoading2 = false;
      page = 'null';
      Fluttertoast.showToast(msg: "Kategori habis");
      });
    }

  }

  //resto

  // List<History> history = [];
  Future _getUserResto()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
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
      // history = _history;
      isLoading = false;
    });
  }

  double latitude = 0;
  double longitude = 0;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  RefreshController _refreshControllerBottom =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: new HomeActivity()));
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    _getData();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onRefreshBottom() async {
    // monitor network fetch
    if (totalCuisine > startCuisine.toString().split(',').length) {
      if (totalCuisine > 7) {
        if (randomRes8.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes9.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes10.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes11.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes12.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes13.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes14.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes15.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes16.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes17.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes18.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes19.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        } else if (randomRes20.toString() == '[]') {
          _page(lat,long);
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the bottom.");
        }
      }
    } else {
      isLoading2 = false;
      setState(() {});
    }
    _getData();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshControllerBottom.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  void _onLoadingBottom() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshControllerBottom.loadComplete();
  }

  Future _getData()async{
    menuJson = [];
    restoId = [];
    qty = [];
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    pref2.setString("homepg", "");
    inCart = pref2.getString('inCart')??"";
    if(pref2.getString('inCart') == '1'){
      name = pref2.getString('menuJson')??"";
      print("Ini pref2 " +name+" SP");
      restoId.addAll(pref2.getStringList('restoId')??[]);
      print(restoId);
      qty.addAll(pref2.getStringList('qty')??[]);
      print(qty);
    }
    setState(() {});
  }



  String lat = '';
  String long = '';
  List<Menu> menuNG = [];
  List<Resto> restoSrch = [];
  String ng = '';
  // List<Resto> resto = [];
  Future _search(String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=nasi goreng&type=$type&lat=$lat&long=$long&limit=10',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    ng = data['menu'].toString();
    for(var x in data['menu']){
      Menu z = Menu(
        id: x['id'],
        name: x['name'],
        restoId: x['resto_id'].toString(),
        restoName: x['resto_name'],
        urlImg: x['img'],
        is_available: '',
        price: Price.discounted(x['price'], x['discounted_price']),
        distance: double.parse(x['resto_distance'].toString()), is_recommended: '', qty: '', desc: '', type: '', delivery_price: null,
      );
      _menu.add(z);
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    setState(() {
      menuNG = _menu;
      restoSrch = _resto;
    });
  }


  List<Menu> menuEs = [];
  List<Resto> restoSrch2 = [];
  String es = '';
  // List<Resto> resto = [];
  Future _search2(String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/page/search?q=es&type=$type&lat=$lat&long=$long&limit=10',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    es = data['menu'].toString();
    if (data['menu'] != null) {
      for(var x in data['menu']){
        Menu z = Menu(
          id: x['id'],
          name: x['name'],
          restoId: x['resto_id'].toString(),
          restoName: x['resto_name'],
          urlImg: x['img'],
          is_available: '',
          price: Price.discounted(x['price'], x['discounted_price']),
          distance: double.parse(x['resto_distance'].toString()), desc: '', qty: '', is_recommended: '', type: '', delivery_price: null,
        );
        _menu.add(z);
      }
    } else {
      _menu = [];
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    setState(() {
      menuEs = _menu;
      restoSrch2 = _resto;
    });
  }


  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar', fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()));
      return Future.value(false);
    }
//    SystemNavigator.pop();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }


  Future logOut()async{
    // List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/auth/logout', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oyyy '+apiResult.body.toString());
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
      print('pb');
    }
  }

  List<String> cuisineList = [];
  List<String> cuisineList2 = [];
  List<String> cuisineList3 = [];
  List<String> cuisineList4 = [];
  List<String> cuisineList5 = [];
  List<String> cuisineList6 = [];
  List<String> cuisineList7 = [];
  List<String> cuisineList8 = [];
  List<String> cuisineList9 = [];
  List<String> cuisineList10 = [];
  Future<void> getCuisine() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Links.mainUrl +'/util/data?q=cuisine',
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print(jsonData);

    for(var v in jsonData['data']){
      cuisineList.add(v['name']);
      cuisineList2.add(v['name']);
      cuisineList3.add(v['name']);
      cuisineList4.add(v['name']);
      cuisineList5.add(v['name']);
      cuisineList6.add(v['name']);
      cuisineList7.add(v['name']);
      cuisineList8.add(v['name']);
      cuisineList9.add(v['name']);
      cuisineList10.add(v['name']);
    }
    setState(() {});
  }

  List<Menu> menu = [];
  List<Resto> resto1 = [];
  String tipe = '';
  String tipe2 = '';
  String tipe3 = '';
  String tipe4 = '';
  String tipe5 = '';
  String tipe6 = '';
  String tipe7 = '';
  String tipe8 = '';
  String tipe9 = '';
  String tipe10 = '';
  String tipe11 = '';
  String tipe12 = '';
  String tipe13 = '';
  String tipe14 = '';
  String tipe15 = '';
  String tipe16 = '';
  String tipe17 = '';
  String tipe18 = '';
  String tipe19 = '';
  String tipe20 = '';
  String tipe21 = '';
  String tipe22 = '';
  String tipe23 = '';
  String tipe24 = '';
  String tipe25 = '';
  String tipe26 = '';
  String tipe27 = '';
  String tipe28 = '';
  String kota1 = '';
  String facilityList2 = '';
  String dataRes1 = '';
  List<Resto> randomRes1 = [];
  List<Resto> randomRes2 = [];
  List<Resto> randomRes3 = [];
  List<Resto> randomRes4 = [];
  List<Resto> randomRes5 = [];
  List<Resto> randomRes6 = [];
  List<Resto> randomRes7 = [];
  List<Resto> randomRes8 = [];
  List<Resto> randomRes9 = [];
  List<Resto> randomRes10 = [];
  List<Resto> randomRes11 = [];
  List<Resto> randomRes12 = [];
  List<Resto> randomRes13 = [];
  List<Resto> randomRes14 = [];
  List<Resto> randomRes15 = [];
  List<Resto> randomRes16 = [];
  List<Resto> randomRes17 = [];
  List<Resto> randomRes18 = [];
  List<Resto> randomRes19 = [];
  List<Resto> randomRes20 = [];
  List<Resto> randomRes21 = [];
  List<Resto> randomRes22 = [];
  List<Resto> randomRes23 = [];
  List<Resto> randomRes24 = [];
  List<Resto> randomRes25 = [];
  List<Resto> randomRes26 = [];
  List<Resto> randomRes27 = [];
  List<Resto> randomRes28 = [];
  Future _search3(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('III '+data['resto'].toString());

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          urlImg: v['img'],
          is_available: '',
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }
    
    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }
    
    setState(() {
      menu = _menu;
      randomRes1 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search4(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe2&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes2 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search5(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe3&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes3 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search6(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe4&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes4 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search7(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe5&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes5 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search8(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe6&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes6 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search9(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe7&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes7 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search10(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe8&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes8 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search11(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe9&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes9 = _resto;
      print('PPP2 '+data.toString());
    });
  }
  Future _search12(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe10&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          is_available: '',
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img']
      );
      _resto.add(r);
    }

    // if (apiResult.statusCode == 200) {
    //   if (resto.toString() == '[]') {
    //     random1();
    //     setState(() { });
    //   }
    // }

    setState(() {
      menu = _menu;
      randomRes10 = _resto;
      print('PPP2 '+data.toString());
    });
  }

  Future random1()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("homepg", "");
    cuisineList.shuffle();
    print('PPP '+cuisineList.toString());
    tipe = cuisineList[index];
    if (index < 15) {
      _search3(_loginTextName.text, '').whenComplete((){
        if (randomRes1.toString() == '[]') {
          random1();
        } else {
          index = index + 1;
          tipe2 = cuisineList2[index];
          random2();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random2()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe2 == tipe) {
      cuisineList2.shuffle();
      tipe2 = cuisineList2[index];
      random2();
    } else {
      print('HEHE');
      _search4(_loginTextName.text, '').whenComplete((){
        if (index <= 3) {
          if (randomRes2.toString() == '[]') {
            if (tipe2 == tipe) {
              cuisineList2.shuffle();
              tipe2 = cuisineList2[index];
              random2();
            } else {
              index = index + 1;
              tipe2 = cuisineList2[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random2();
            }
          } else {
            index = index + 1;
            tipe3 = cuisineList3[index];
            random3();
          }
        } else {
          index = index + 1;
          tipe3 = cuisineList3[index];
          random3();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random3()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe3 == tipe || tipe3 == tipe2) {
      cuisineList3.shuffle();
      tipe3 = cuisineList3[index];
      random3();
    } else {
      print('HEHE');
      _search5(_loginTextName.text, '').whenComplete((){
        if (index < 4) {
          if (randomRes3.toString() == '[]') {
            if (tipe3 == tipe || tipe3 == tipe2) {
              cuisineList3.shuffle();
              tipe3 = cuisineList3[index];
              random3();
            } else {
              index = index + 1;
              tipe3 = cuisineList3[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random3();
            }
          } else {
            index = index + 1;
            tipe4 = cuisineList4[index];
            random4();
          }
        } else {
          index = index + 1;
          tipe4 = cuisineList4[index];
          random4();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random4()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe4 == tipe || tipe4 == tipe2 || tipe4 == tipe3) {
      cuisineList4.shuffle();
      tipe4 = cuisineList4[index];
      random4();
    } else {
      print('HEHE');
      _search6(_loginTextName.text, '').whenComplete((){
        if (index < 6) {
          if (randomRes4.toString() == '[]') {
            if (tipe4 == tipe || tipe4 == tipe2 || tipe4 == tipe3) {
              cuisineList4.shuffle();
              tipe4 = cuisineList4[index];
              random4();
            } else {
              index = index + 1;
              tipe4 = cuisineList4[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random4();
            }
          } else {
            index = index + 1;
            tipe5 = cuisineList5[index];
            random5();
          }
        } else {
          index = index + 1;
          tipe5 = cuisineList5[index];
          random5();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random5()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe5 == tipe || tipe5 == tipe2 || tipe5 == tipe3 || tipe5 == tipe4) {
      cuisineList5.shuffle();
      tipe5 = cuisineList5[index];
      random5();
    } else {
      print('HEHE');
      _search7(_loginTextName.text, '').whenComplete((){
        if (index < 7) {
          if (randomRes5.toString() == '[]') {
            if (tipe5 == tipe || tipe5 == tipe2 || tipe5 == tipe3 || tipe5 == tipe4) {
              cuisineList5.shuffle();
              tipe5 = cuisineList5[index];
              random5();
            } else {
              index = index + 1;
              tipe5 = cuisineList5[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random5();
            }
          } else {
            index = index + 1;
            tipe6 = cuisineList6[index];
            random6();
          }
        } else {
          index = index + 1;
          tipe6 = cuisineList6[index];
          random6();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random6()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe6 == tipe || tipe6 == tipe2 || tipe6 == tipe3 || tipe6 == tipe4 || tipe6 == tipe5) {
      cuisineList6.shuffle();
      tipe6 = cuisineList6[index];
      random6();
    } else {
      print('HEHE');
      _search8(_loginTextName.text, '').whenComplete((){
        if (index < 9) {
          if (randomRes6.toString() == '[]') {
            if (tipe6 == tipe || tipe6 == tipe2 || tipe6 == tipe3 || tipe6 == tipe4 || tipe6 == tipe5) {
              cuisineList6.shuffle();
              tipe6 = cuisineList6[index];
              random6();
            } else {
              index = index + 1;
              tipe6 = cuisineList6[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random6();
            }
          } else {
            index = index + 1;
            tipe7 = cuisineList7[index];
            random7();
          }
        } else {
          index = index + 1;
          tipe7 = cuisineList7[index];
          random7();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random7()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe7 == tipe || tipe7 == tipe2 || tipe7 == tipe3 || tipe7 == tipe4 || tipe7 == tipe5 || tipe7 == tipe6) {
      cuisineList7.shuffle();
      tipe7 = cuisineList7[index];
      random7();
    } else {
      print('HEHE');
      _search9(_loginTextName.text, '').whenComplete((){
        if (index < 10) {
          if (randomRes7.toString() == '[]') {
            if (tipe7 == tipe || tipe7 == tipe2 || tipe7 == tipe3 || tipe7 == tipe4 || tipe7 == tipe5 || tipe7 == tipe6) {
              cuisineList7.shuffle();
              tipe7 = cuisineList7[index];
              random7();
            } else {
              index = index + 1;
              tipe7 = cuisineList7[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random7();
            }
          } else {
            index = index + 1;
            tipe8 = cuisineList8[index];
            random8();
          }
        } else {
          index = index + 1;
          tipe8 = cuisineList8[index];
          random8();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random8()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe8 == tipe || tipe8 == tipe2 || tipe8 == tipe3 || tipe8 == tipe4 || tipe8 == tipe5 || tipe8 == tipe6 || tipe8 == tipe7) {
      cuisineList8.shuffle();
      tipe8 = cuisineList8[index];
      random8();
    } else {
      print('HEHE');
      _search10(_loginTextName.text, '').whenComplete((){
        if (index < 12) {
          if (randomRes8.toString() == '[]') {
            if (tipe8 == tipe || tipe8 == tipe2 || tipe8 == tipe3 || tipe8 == tipe4 || tipe8 == tipe5 || tipe8 == tipe6 || tipe8 == tipe7) {
              cuisineList8.shuffle();
              tipe8 = cuisineList8[index];
              random8();
            } else {
              index = index + 1;
              tipe8 = cuisineList8[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random8();
            }
          } else {
            index = index + 1;
            tipe9 = cuisineList9[index];
            random9();
          }
        } else {
          index = index + 1;
          tipe9 = cuisineList9[index];
          random9();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random9()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe9 == tipe || tipe9 == tipe2 || tipe9 == tipe3 || tipe9 == tipe4 || tipe9 == tipe5 || tipe9 == tipe6 || tipe9 == tipe7 || tipe9 == tipe8) {
      cuisineList9.shuffle();
      tipe9 = cuisineList9[index];
      random9();
    } else {
      print('HEHE');
      _search11(_loginTextName.text, '').whenComplete((){
        if (index < 13) {
          if (randomRes9.toString() == '[]') {
            if (tipe9 == tipe || tipe9 == tipe2 || tipe9 == tipe3 || tipe9 == tipe4 || tipe9 == tipe5 || tipe9 == tipe6 || tipe9 == tipe7 || tipe9 == tipe8) {
              cuisineList9.shuffle();
              tipe9 = cuisineList9[index];
              random9();
            } else {
              index = index + 1;
              tipe9 = cuisineList9[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random9();
            }
          } else {
            index = index + 1;
            tipe10 = cuisineList10[index];
            random10();
          }
        } else {
          index = index + 1;
          tipe10 = cuisineList10[index];
          random10();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }
  Future random10()async{
    // cuisineList2.shuffle();
    print('PPP '+index.toString());
    // tipe2 = cuisineList2[index+1];
    if (tipe10 == tipe || tipe10 == tipe2 || tipe10 == tipe3 || tipe10 == tipe4 || tipe10 == tipe5 || tipe10 == tipe6 || tipe10 == tipe7 || tipe10 == tipe8 || tipe10 == tipe9) {
      cuisineList10.shuffle();
      tipe10 = cuisineList10[index];
      random10();
    } else {
      print('HEHE');
      _search12(_loginTextName.text, '').whenComplete((){
        if (index < 15) {
          if (randomRes10.toString() == '[]') {
            if (tipe10 == tipe || tipe10 == tipe2 || tipe10 == tipe3 || tipe10 == tipe4 || tipe10 == tipe5 || tipe10 == tipe6 || tipe10 == tipe7 || tipe10 == tipe8 || tipe10 == tipe9) {
              cuisineList10.shuffle();
              tipe10 = cuisineList10[index];
              random10();
            } else {
              index = index + 1;
              tipe10 = cuisineList10[index];
              // cuisineList2.shuffle();
              // tipe2 = cuisineList2[index];
              random10();
            }
          } else {
            // index = index + 9;
            // tipe10 = cuisineList10[index];
            // random10();
          }
        } else {
          // index = index + 9;
          // tipe10 = cuisineList10[index];
          // random10();
        }
      });
    }
    setState(() {
      // print('PPP3 '+data.toString());
    });
  }

  int index = 0;
  TextEditingController _loginTextName = TextEditingController(text: "");

  String deepLink2 = '';
  Future<Widget> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null){
      return getRoute(data.link);
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          print('pppp');
          print(dynamicLink.link);
          return getRoute(dynamicLink.link);
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      return e.message;
    });
    return HomeActivity();
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  Widget getRoute(deepLink){
    if (deepLink.toString().isEmpty) {
      print('kosong');
      return HomeActivity();
    }
    print(deepLink.path);
    if (deepLink.path == "/open/") {
      final id = deepLink.queryParameters["id"];
      print('id = '+id.toString());
      // if (id != null) {
      //   return DetailResto(id.toString());
      // }
      toDet(id.toString());
    }
    return HomeActivity();
  }

  Future toDet(id) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: DetailResto(id)));
  }


  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    // initDynamicLinks().then((status) {
    //   print('OI1 '+deepLink2);
    //   print('PPPP');
    // });
    index = 0;
    tipe = '';
    tipe2 = '';
    tipe3 = '';
    tipe4 = '';
    tipe5 = '';
    tipe6 = '';
    tipe7 = '';
    tipe8 = '';
    tipe9 = '';
    tipe10 = '';
    _getUserResto();
    initDynamicLinks();
    // getCuisine().whenComplete((){
    //   random1();
    // });
    Location.instance.requestPermission().then((value) {
      print(value);
    });
    Location.instance.getLocation().then((value) {
      setState(() {
        _getDataHome(value.latitude.toString(), value.longitude.toString());
        latitude = value.latitude;
        longitude = value.longitude;
        lat = latitude.toString();
        long = longitude.toString();
      });
    }).whenComplete(() {
      // _getDataHome(lat.toString(), long.toString());
    });
    // _search('');
    // _search2('');
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels != 0 && isLoading2 == true && page != 'null') {
          print(startCuisine.toString().split(',').length.toString());
          print(totalCuisine.toString());
          _page(lat,long);
          // if (page != 'null') {
          //   _page(lat,long);
          //   setState(() {});
          // }  else {
          //   isLoading2 = false;
          //   setState(() {});
          // }
          // if (totalCuisine >= startCuisine.toString().split(',').length) {
          //   if (totalCuisine >= 7) {
          //     if (randomRes8.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes9.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes10.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes11.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes12.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes13.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes14.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes15.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes16.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes17.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes18.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes19.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     } else if (randomRes20.toString() == '[]') {
          //       _page(lat,long);
          //       setState(() {});
          //       print(isLoading2.toString());
          //       print(_controller.position.pixels.toString());
          //       print("You're at the bottom.");
          //     }
          //   }
          // } else {
          //   isLoading2 = false;
          //   setState(() {});
          // }
        } else {
          isLoading2 = false;
          setState(() {});
          print(isLoading2.toString());
          print(_controller.position.pixels.toString());
          print("You're at the top.");
        }
      }
    });
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  int queryData = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    print(pref.getString("token"));
    if (pref.getString("token").toString() == 'null') {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: LoginActivity()));
    } else {
      if (state == AppLifecycleState.resumed) {
        queryData = int.parse((MediaQuery.of(context).size.width.toString().contains('.')==true)?MediaQuery.of(context).size.width.toString().split('.')[0]:MediaQuery.of(context).size.width.toString());
        // SharedPreferences pref = await SharedPreferences.getInstance();
        // pref.setString('widthDevice', queryData);
        initDynamicLinks();
        print((MediaQuery.of(context).size.width*0.035)+1);
        print((MediaQuery.of(context).size.width*0.035));
        print(queryData);
        print('ASYU');
      }
      if (state == AppLifecycleState.inactive) {
        print('ASYU2');
      }
      if (state == AppLifecycleState.paused) {
        print('ASYU3');
      }
      if (state == AppLifecycleState.detached) {
        print('ASYU4');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        // key: navigatorKey,
        body: Center(
          child: SafeArea(
            child: (isLoading)?SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primary,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: SingleChildScrollView(
                child: Container(
                    width: CustomSize.sizeWidth(context),
                    height: CustomSize.sizeHeight(context),
                    child: Center(child: CircularProgressIndicator(
                      color: CustomColor.primary,
                    ))),
              ),
            ):SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primary,
              ),
              footer: CustomFooter(builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if(mode==LoadStatus.idle){
                  body =  MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else if(mode==LoadStatus.loading){
                  body = Text("");
                  isLoading2 = true;
                }
                else if(mode == LoadStatus.failed){
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else if(mode == LoadStatus.canLoading){
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                else{
                  body = MediaQuery(child: Text(""), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),);
                }
                return Container(
                  height: CustomSize.sizeHeight(context) / 48,
                  alignment: Alignment.topCenter,
                  child: Center(child: body),
                );
              },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView(
                controller: _controller,
                physics: BouncingScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 3.55,
                        child: Stack(
                          children: [
                            Container(
                              width: CustomSize.sizeWidth(context),
                              height: CustomSize.sizeHeight(context) / 3.8,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  enableInfiniteScroll: false,
                                  autoPlay: false,
                                  height: CustomSize.sizeHeight(context) / 3.8,
                                  scrollDirection: Axis.horizontal,
                                ),
                                items: images2.map((e) {
                                  return GestureDetector(
                                    // onTap: (){
                                    //   Navigator.push(
                                    //       context,
                                    //       PageTransition(
                                    //           type: PageTransitionType.rightToLeft,
                                    //           child: new DetailResto(e.id.toString())));
                                    //   print(e.id.toString());
                                    // },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              // image: NetworkImage(Links.subUrl + e.urlImg),
                                              image: AssetImage(e),
                                              fit: BoxFit.cover
                                          )
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: Container(
                              alignment: Alignment.center,
                              width: CustomSize.sizeWidth(context) / 1.1,
                              height: CustomSize.sizeHeight(context) / 7,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(0, 0), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          PageTransition(type: PageTransitionType.rightToLeft,
                                              // child: new SearchActivity(promo, latitude.toString(), longitude.toString(), 'Opening Course')));
                                              child: new TermurahActivity()));
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 6.5,
                                          height: CustomSize.sizeWidth(context) / 6.5,
                                          decoration: BoxDecoration(
                                              color: CustomColor.primary,
                                              shape: BoxShape.circle
                                          ),
                                          child: Icon(FontAwesomeIcons.iceCream, color: Colors.white,),
                                        ),
                                        SizedBox(
                                          height: CustomSize.sizeHeight(context) * 0.004,
                                        ),
                                        MediaQuery(
                                          child: CustomText.textHeading6(
                                              text: 'Terbaru',
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),
                                              // minSize: double.parse(((MediaQuery.of(context).size.width*0.035)+1).toString()),
                                              maxLines: 1
                                          ),
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          PageTransition(type: PageTransitionType.rightToLeft,
                                              child: new TerlarisActivity()));
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 6.5,
                                          height: CustomSize.sizeWidth(context) / 6.5,
                                          decoration: BoxDecoration(
                                              color: CustomColor.primary,
                                              shape: BoxShape.circle
                                          ),
                                          child: Icon(FontAwesomeIcons.cookieBite, color: Colors.white,),
                                        ),
                                        SizedBox(
                                          height: CustomSize.sizeHeight(context) * 0.004,
                                        ),
                                        MediaQuery(
                                          child: CustomText.textHeading6(
                                              text: 'Terlaris',
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),
                                              // minSize: double.parse(((MediaQuery.of(context).size.width*0.035)+1).toString()),
                                              maxLines: 1
                                          ),
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          PageTransition(type: PageTransitionType.rightToLeft,
                                              child: new TerdekatActivity()));
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 6.5,
                                          height: CustomSize.sizeWidth(context) / 6.5,
                                          decoration: BoxDecoration(
                                              color: CustomColor.primary,
                                              shape: BoxShape.circle
                                          ),
                                          child: Icon(Icons.location_on, color: Colors.white,),
                                        ),
                                        SizedBox(
                                          height: CustomSize.sizeHeight(context) * 0.004,
                                        ),
                                        MediaQuery(
                                          child: CustomText.textHeading6(
                                              text: 'Terdekat',
                                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),
                                              // minSize: double.parse(((MediaQuery.of(context).size.width*0.035)+1).toString()),
                                              maxLines: 1
                                          ),
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context,
                                          PageTransition(type: PageTransitionType.rightToLeft,
                                              child: new LagiDiskonActivity()));
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 6.5,
                                          height: CustomSize.sizeWidth(context) / 6.5,
                                          decoration: BoxDecoration(
                                              color: CustomColor.primary,
                                              shape: BoxShape.circle
                                          ),
                                          child: Icon(FontAwesomeIcons.percent, color: Colors.white,),
                                        ),
                                        SizedBox(
                                          height: CustomSize.sizeHeight(context) * 0.004,
                                        ),
                                        MediaQuery(
                                          child: CustomText.textHeading6(
                                            text: 'Lagi Diskon',
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                            // minSize: double.parse(((MediaQuery.of(context).size.width*0.035)+1).toString()),
                                            maxLines: 1,
                                          ),
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),

                          (transaction.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: "Pesananmu",
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    // SharedPreferences pref = await SharedPreferences.getInstance();
                                    // pref.setString('statusPesanan', );
                                    var i = await Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new HistoryOrderActivity()));
                                    if(i == null){
                                      _getData();
                                    }
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (transaction.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 5,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (transaction.length < 10)?transaction.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: ()async{
                                        if(transaction[index].type!.startsWith('Reservasi') != true){
                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                          pref.setString("chatUserCount", transaction[index].chat_user);
                                          pref.setString("idnyatrans", transaction[index].id.toString());
                                          pref.setString("idnyatransRes", transaction[index].idResto.toString());
                                          pref.setString("restoNameTrans99", transaction[index].nameResto);
                                          pref.setString("alamateResto99", transaction[index].address);
                                          pref.setString('rev', '0');
                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.rightToLeft,
                                                  child: new DetailTransaction(transaction[index].id!, transaction[index].status!, transaction[index].note!, transaction[index].idResto!)));
                                        } else if (transaction[index].type!.startsWith('Reservasi') == true && transaction[index].status == 'pending') {
                                          SharedPreferences pref = await SharedPreferences.getInstance();
                                          pref.setString('rev', '1');
                                          pref.setString("chatUserCount", transaction[index].chat_user);
                                          pref.setString("idnyatrans", transaction[index].id.toString());
                                          pref.setString("idnyatransRes", transaction[index].idResto.toString());
                                          pref.setString("restoNameTrans99", transaction[index].nameResto);
                                          pref.setString("alamateResto99", transaction[index].address);
                                          pref.setString("jmlhMeja", transaction[index].type.toString().replaceAll('Reservasi untuk ', '').replaceAll(' orang', ''));
                                          pref.setString("tglReser", transaction[index].date.toString().split(',')[0]);
                                          pref.setString("jamReser", transaction[index].date.toString().split(', ')[1]);
                                          pref.setString("hargaReser", (int.parse(transaction[index].total.toString())/int.parse(transaction[index].type.toString().replaceAll('Reservasi untuk ', '').replaceAll(' orang', '').toString())).toString());
                                          pref.setString("totalReser", transaction[index].total.toString());
                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.rightToLeft,
                                                  child: new DetailTransactionReser(transaction[index].id!, transaction[index].status!, transaction[index].note!, transaction[index].idResto!)));
                                        }
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 1.2,
                                        height: CustomSize.sizeHeight(context) / 5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 3.4,
                                                height: CustomSize.sizeHeight(context) / 6.8,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    image: DecorationImage(
                                                        image: NetworkImage(Links.subUrl + transaction[index].img!),
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 36,),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 63),
                                                child: Container(
                                                  width: CustomSize.sizeWidth(context) / 2.2,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                  width: (transaction[index].chat_user != '0' && transaction[index].chat_user != 'null')?CustomSize.sizeWidth(context) / 2.6:CustomSize.sizeWidth(context) / 2.2,
                                                                  child: MediaQuery(child: CustomText.bodyMedium14(text: transaction[index].nameResto.toString(), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), maxLines: 1),
                                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),)),
                                                              (transaction[index].chat_user != '0' && transaction[index].chat_user != 'null')?Stack(
                                                                alignment: Alignment.center,
                                                                children: [
                                                                  Icon(Icons.circle, color: (transaction[index].chat_user != '0')?CustomColor.redBtn:Colors.transparent, size: 24,),
                                                                  MediaQuery(child: CustomText.bodyMedium14(text: transaction[index].chat_user, color: (transaction[index].chat_user != '0')?Colors.white:Colors.transparent, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),)
                                                                ],
                                                              ):Container()
                                                            ],
                                                          ),
                                                          MediaQuery(child: CustomText.bodyLight12(text: transaction[index].date, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                                          (transaction[index].type!.startsWith('Reservasi'))
                                                              ?MediaQuery(child: CustomText.bodyMedium10(text: transaction[index].type.toString().replaceAll('untuk ', '').replaceAll('orang', 'meja'), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.025).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.025)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.025)).toString())),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),)
                                                              :MediaQuery(child: CustomText.bodyMedium12(text: transaction[index].type, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          MediaQuery(
                                                            child: CustomText.bodyLight12(text: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status != 'ready')?'Selesai':'Selesai':(transaction[index].type.toString().contains('Reservasi'))?'Telah disetujui':'Diproses':'Menunggu':'Dibatalkan', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                                            // CustomText.bodyLight12(text: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status != 'ready')?Colors.amberAccent:Colors.amberAccent:Colors.green:Colors.blue:CustomColor.redBtn, minSize: 12,
                                                                color: (transaction[index].status != 'cancel')?(transaction[index].status != 'pending')?(transaction[index].status != 'process')?(transaction[index].status != 'ready')?CustomColor.primary:CustomColor.primary:Colors.green:Colors.blue:CustomColor.redBtn),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                                          ),
                                                          MediaQuery(child: CustomText.bodyMedium14(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format((transaction[index].type!.startsWith('Reservasi'))?(transaction[index].total!+1000):(transaction[index].total!+1000)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (transaction.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          // (kakilima.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Kaki Lima",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new KakiLimaListActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (kakilima.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (kakilima.length <= 10)?kakilima.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86,),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(kakilima[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (kakilima[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (kakilima[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + kakilima[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (kakilima[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + kakilima[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                       color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: kakilima[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: kakilima[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (kakilima.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                          //
                          // (foodstall.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Food Stall",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new FoodStallActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (foodstall.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (foodstall.length <= 10)?foodstall.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(foodstall[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (foodstall[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (foodstall[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + foodstall[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (foodstall[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + foodstall[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                       color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: foodstall[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: foodstall[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (foodstall.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                          //
                          // (foodtruck.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Food Truck",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new FoodTruckActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (foodtruck.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (foodtruck.length <= 10)?foodtruck.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(foodtruck[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (foodtruck[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (foodtruck[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + foodtruck[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (foodtruck[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + foodtruck[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                       color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: foodtruck[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: foodtruck[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (foodtruck.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                          //
                          // (tokoroti.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Toko Roti/Kue",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new TokoRotiActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (tokoroti.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (tokoroti.length <= 10)?tokoroti.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(tokoroti[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (tokoroti[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (tokoroti[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + tokoroti[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (tokoroti[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + tokoroti[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                       color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: tokoroti[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: tokoroti[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (tokoroti.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                          //
                          // (tokooleh.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Toko Oleh-Oleh",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new TokoOleh2Activity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (tokooleh.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (tokooleh.length <= 10)?tokooleh.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(tokooleh[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (tokooleh[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (tokooleh[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + tokooleh[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (tokooleh[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + tokooleh[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                       color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: tokooleh[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: tokooleh[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (tokooleh.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                          //
                          // (other.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Other",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new OtherActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (other.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (other.length <= 10)?other.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: DetailResto(other[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (other[index].isOpen == 'false')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: (other[index].img != null)?BoxDecoration(
                          //                             image: DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + other[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ):BoxDecoration(
                          //                               color: CustomColor.primary
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: (other[index].img != null)?BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + other[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ):BoxDecoration(
                          //                         color: CustomColor.primary
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyRegular14(text: other[index].distance.toString() + " km"),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: CustomText.bodyMedium16(text: other[index].name),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (other.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          // (promo.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Lagi Diskon",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new PromoActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (promo.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 5,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       // itemCount: promo.length,
                          //       itemCount: (promo.length < 10)?promo.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: new DetailResto(promo[index].restoId.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 1.3,
                          //               height: CustomSize.sizeHeight(context) / 5,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Row(
                          //                 children: [
                          //                   Container(
                          //                     width: CustomSize.sizeWidth(context) / 3,
                          //                     height: CustomSize.sizeHeight(context) / 5,
                          //                     decoration: BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + promo[index].urlImg),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                   ),
                          //                   SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          //                   Padding(
                          //                     padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                          //                     child: Container(
                          //                       width: CustomSize.sizeWidth(context) / 2.6,
                          //                       height: CustomSize.sizeHeight(context) / 5,
                          //                       child: Column(
                          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                         crossAxisAlignment: CrossAxisAlignment.start,
                          //                         children: [
                          //                           Column(
                          //                             crossAxisAlignment: CrossAxisAlignment.start,
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: promo[index].distance.toString() + " Km", minSize: 12),
                          //                               CustomText.textTitle6(text: promo[index].name, minSize: 14, maxLines: 2),
                          //                               CustomText.bodyMedium12(text: promo[index].restoName, minSize: 12),
                          //                             ],
                          //                           ),
                          //                           Row(
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.original), minSize: 12,
                          //                                   decoration: TextDecoration.lineThrough),
                          //                               SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          //                               CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.discounted), minSize: 12),
                          //                             ],
                          //                           )
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (promo.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          // (es != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Wah segar nih . . .",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new EsActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (es != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 5,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       // itemCount: promo.length,
                          //       itemCount: (menuEs.length < 10)?menuEs.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: new DetailResto(menuEs[index].restoId.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 1.3,
                          //               height: CustomSize.sizeHeight(context) / 5,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Row(
                          //                 children: [
                          //                   Container(
                          //                     width: CustomSize.sizeWidth(context) / 3,
                          //                     height: CustomSize.sizeHeight(context) / 5,
                          //                     decoration: BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + menuEs[index].urlImg),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                   ),
                          //                   SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          //                   Padding(
                          //                     padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                          //                     child: Container(
                          //                       width: CustomSize.sizeWidth(context) / 2.6,
                          //                       height: CustomSize.sizeHeight(context) / 5,
                          //                       child: Column(
                          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                         crossAxisAlignment: CrossAxisAlignment.start,
                          //                         children: [
                          //                           Column(
                          //                             crossAxisAlignment: CrossAxisAlignment.start,
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: menuEs[index].distance.toString() + " Km", minSize: 12),
                          //                               CustomText.textTitle6(text: menuEs[index].name, minSize: 14, maxLines: 2),
                          //                               CustomText.bodyMedium12(text: menuEs[index].restoName, minSize: 12),
                          //                             ],
                          //                           ),
                          //                           Row(
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuEs[index].price!.original), minSize: 12,
                          //                                   decoration: (menuEs[index].price!.discounted != null && menuEs[index].price!.discounted.toString() != '0')?TextDecoration.lineThrough:TextDecoration.none),
                          //                               SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          //                               (menuEs[index].price!.discounted != null && menuEs[index].price!.discounted.toString() != '0')
                          //                                   ?CustomText.bodyRegular12(
                          //                                   text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuEs[index].price!.discounted), minSize: 12):SizedBox(),
                          //                             ],
                          //                           )
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (es != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          // (ng != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomText.textTitle2(
                          //           text: "Ngidam nasi goreng ya?",
                          //           maxLines: 1
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           var i = await Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new NasgorActivity()));
                          //           if(i == null){
                          //             _getData();
                          //           }
                          //         },
                          //         child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (ng != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 5,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       // itemCount: promo.length,
                          //       itemCount: (menuNG.length < 10)?menuNG.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: new DetailResto(menuNG[index].restoId.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 1.3,
                          //               height: CustomSize.sizeHeight(context) / 5,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Row(
                          //                 children: [
                          //                   Container(
                          //                     width: CustomSize.sizeWidth(context) / 3,
                          //                     height: CustomSize.sizeHeight(context) / 5,
                          //                     decoration: BoxDecoration(
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + menuNG[index].urlImg),
                          //                           fit: BoxFit.cover
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                   ),
                          //                   SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          //                   Padding(
                          //                     padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                          //                     child: Container(
                          //                       width: CustomSize.sizeWidth(context) / 2.6,
                          //                       height: CustomSize.sizeHeight(context) / 5,
                          //                       child: Column(
                          //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                         crossAxisAlignment: CrossAxisAlignment.start,
                          //                         children: [
                          //                           Column(
                          //                             crossAxisAlignment: CrossAxisAlignment.start,
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: menuNG[index].distance.toString() + " Km", minSize: 12),
                          //                               CustomText.textTitle6(text: menuNG[index].name, minSize: 14, maxLines: 2),
                          //                               CustomText.bodyMedium12(text: menuNG[index].restoName, minSize: 12),
                          //                             ],
                          //                           ),
                          //                           Row(
                          //                             children: [
                          //                               CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuNG[index].price!.original), minSize: 12,
                          //                                   decoration: (menuNG[index].price!.discounted != null && menuNG[index].price!.discounted.toString() != '0')?TextDecoration.lineThrough:TextDecoration.none),
                          //                               SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          //                               (menuNG[index].price!.discounted != null && menuNG[index].price!.discounted.toString() != '0')
                          //                                   ?CustomText.bodyRegular12(
                          //                                   text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menuNG[index].price!.discounted), minSize: 12):SizedBox(),
                          //                             ],
                          //                           )
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (ng != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes1.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes1.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes1.length < 10)?randomRes1.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes1[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes1[index].status.toString() == 'active')?(randomRes1[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes1[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes1[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes1[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes1[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes1[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes1[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes1[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes1[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes1[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes1[index].distance.toString() + " Km", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes1[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes1.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes2.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe2,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe2);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes2.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes2.length < 10)?randomRes2.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes2[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes2[index].status.toString() == 'active')?(randomRes2[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes2[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes2[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes2[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes2[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes2[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes2[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes2[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes2[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes2[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes2[index].distance.toString() + " Km", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes2[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes2.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes3.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe3,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe3);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes3.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes3.length < 10)?randomRes3.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes3[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes3[index].status.toString() == 'active')?(randomRes3[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes3[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes3[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes3[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes3[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes3[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes3[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes3[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes3[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes3[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes3[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes3[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes3.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes4.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe4,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe4);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes4.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes4.length < 10)?randomRes4.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes4[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes4[index].status.toString() == 'active')?(randomRes4[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes4[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes4[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes4[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes4[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes4[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes4[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes4[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes4[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes4[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes4[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes4[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes4.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes5.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe5,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe5);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes5.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes5.length < 10)?randomRes5.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes5[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes5[index].status.toString() == 'active')?(randomRes5[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes5[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes5[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes5[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes5[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes5[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes5[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes5[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes5[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes5[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes5[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes5[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes5.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes6.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe6,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe6);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes6.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes6.length < 10)?randomRes6.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes6[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes6[index].status.toString() == 'active')?(randomRes6[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes6[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes6[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes6[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes6[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes6[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes6[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes6[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes6[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes6[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes6[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes6[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes6.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes7.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe7,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe7);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes7.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes7.length < 10)?randomRes7.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes7[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes7[index].status.toString() == 'active')?(randomRes7[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes7[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes7[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes7[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes7[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes7[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes7.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes8.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe8,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe8);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes8.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes8.length < 10)?randomRes8.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes8[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes8[index].status.toString() == 'active')?(randomRes8[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes8[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes8[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes8[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes8[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes8[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes8[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes8[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes8[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes8[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes8[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes8[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes8.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes9.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe9,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe9);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes9.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes9.length < 10)?randomRes9.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes9[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes9[index].status.toString() == 'active')?(randomRes9[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes9[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes9[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes9[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes9[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes9[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes9[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes9[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes9[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes9[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes9[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes9[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes9.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes10.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe10,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe10);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes10.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes10.length < 10)?randomRes10.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes10[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes10[index].status.toString() == 'active')?(randomRes10[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes10[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes10[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes10[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes10[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes10[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes10[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes10[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes10[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes10[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes10[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes10[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes10.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes11.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe11,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe11);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes11.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes11.length < 10)?randomRes11.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes11[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes11[index].status.toString() == 'active')?(randomRes11[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes11[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes11[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes11[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes11[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes11[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes11[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes11[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes11[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes11[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes11[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes11[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes11.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes12.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe12,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe12);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes12.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes12.length < 10)?randomRes12.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes12[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes12[index].status.toString() == 'active')?(randomRes12[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes12[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes12[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes12[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes12[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes12[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes12[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes12[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes12[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes12[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes12[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes12[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes12.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes13.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe13,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe13);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes13.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes13.length < 10)?randomRes13.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes13[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes13[index].status.toString() == 'active')?(randomRes13[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes13[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes13[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes13[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes13[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes13[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes13[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes13[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes13[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes13[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes13[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes13[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes13.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes14.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe14,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe14);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes14.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes14.length < 10)?randomRes14.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes14[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes14[index].status.toString() == 'active')?(randomRes14[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes14[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes14[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes14[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes14[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes14[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes14[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes14[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes14[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes14[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes14[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes14[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes14.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes15.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe15,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe15);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes15.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes15.length < 10)?randomRes15.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes15[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes15[index].status.toString() == 'active')?(randomRes15[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes15[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes15[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes15[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes15[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes15[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes15[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes15[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes15[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes15[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes15[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes15[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes15.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes16.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe16,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe16);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes16.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes16.length < 10)?randomRes16.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes16[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes16[index].status.toString() == 'active')?(randomRes16[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes16[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes16[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes16[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes16[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes16[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes16[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes16[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes16[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes16[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes16[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes16[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes16.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes17.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe17,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe17);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes17.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes17.length < 10)?randomRes17.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes17[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes17[index].status.toString() == 'active')?(randomRes17[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes17[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes17[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes17[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes17[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes17[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes17[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes17[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes17[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes17[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes17[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes17[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes17.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes18.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe18,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe18);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes18.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes18.length < 10)?randomRes18.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes18[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes18[index].status.toString() == 'active')?(randomRes18[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes18[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes18[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes18[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes18[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes18[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes18[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes18[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes18[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes18[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes18[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes18[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes18.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes19.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe19,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe19);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes19.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes19.length < 10)?randomRes19.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes19[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes19[index].status.toString() == 'active')?(randomRes19[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes19[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes19[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes19[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes19[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes19[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes19[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes19[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes19[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes19[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes19[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes19[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes19.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes20.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: tipe20,
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe20);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes20.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes20.length < 10)?randomRes20.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes20[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes20[index].status.toString() == 'active')?(randomRes20[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes20[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes20[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes20[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes20[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes20[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes20[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes20[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes20[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes20[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes20[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes20[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes20.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes21.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe21,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe21);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes21.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes21.length < 10)?randomRes21.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes21[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes21[index].status.toString() == 'active')?(randomRes21[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes21[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes21[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes21[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes21[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes21[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes21[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes21[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes21[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes21[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes21[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes21[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes21.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes22.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe22,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe22);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes22.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes22.length < 10)?randomRes22.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes22[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes22[index].status.toString() == 'active')?(randomRes22[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes22[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes22[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes22[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes22[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes22[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes22[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes22[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes22[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes22[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes22[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes22[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes22.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes23.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe23,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe23);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes23.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes23.length < 10)?randomRes23.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes23[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes23[index].status.toString() == 'active')?(randomRes23[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes23[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes23[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes23[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes23[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes23[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes23[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes23[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes23[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes23[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes23[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes23[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes23.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes24.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe24,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe24);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes24.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes24.length < 10)?randomRes24.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes24[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes24[index].status.toString() == 'active')?(randomRes24[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes24[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes24[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes24[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes24[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes24[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes24[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes24[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes24[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes24[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes24[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes24[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes24.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes25.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe25,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe25);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes25.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes25.length < 10)?randomRes25.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes25[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes25[index].status.toString() == 'active')?(randomRes25[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes25[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes25[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes25[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes25[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes25[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes25[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes25[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes25[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes25[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes25[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes25[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes25.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes26.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe26,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe26);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes26.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes26.length < 10)?randomRes26.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes26[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes26[index].status.toString() == 'active')?(randomRes26[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes26[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes26[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes26[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes26[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes26[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes26[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes26[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes26[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes26[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes26[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes26[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes26.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes27.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe27,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe27);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes27.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes27.length < 10)?randomRes27.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes27[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes27[index].status.toString() == 'active')?(randomRes27[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes27[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes27[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes27[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes27[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes27[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes27[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes27[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes27[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes27[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes27[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes27[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes27.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (randomRes28.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                    text: tipe28,
                                    maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: ()async{
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setString("pgtipe", tipe28);
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new FoodTruckActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                      text: "Lebih banyak",
                                      color: CustomColor.primary,
                                      maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (randomRes28.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (randomRes28.length < 10)?randomRes28.length:10,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(randomRes28[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            (randomRes28[index].status.toString() == 'active')?(randomRes28[index].isOpen.toString() == 'true')?Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (randomRes28[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (randomRes28[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + randomRes28[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes28[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes28[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes28[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ):Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey,
                                                    BlendMode.saturation,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: (randomRes28[index].img != '')?Colors.transparent:CustomColor.primary,
                                                      image: (randomRes28[index].img != '')?DecorationImage(
                                                          image: NetworkImage(Links.subUrl + randomRes28[index].img!),
                                                          fit: BoxFit.cover
                                                      ):DecorationImage(
                                                          image: AssetImage("assets/irgLogo.png"),
                                                          fit: BoxFit.contain
                                                      ),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes28[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes28[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                          (randomRes28.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          // (randomRes7.toString() != '[]')?Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       MediaQuery(
                          //         child: CustomText.textTitle2(
                          //           text: tipe7,
                          //           maxLines: 1,
                          //           sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                          //         ),
                          //         data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          //       ),
                          //       GestureDetector(
                          //         onTap: ()async{
                          //           SharedPreferences pref = await SharedPreferences.getInstance();
                          //           pref.setString("pgtipe", tipe7);
                          //           Navigator.push(
                          //               context,
                          //               PageTransition(
                          //                   type: PageTransitionType.rightToLeft,
                          //                   child: new FoodTruckActivity()));
                          //         },
                          //         child: MediaQuery(
                          //           child: CustomText.bodyMedium12(
                          //             text: "Lebih banyak",
                          //             color: CustomColor.primary,
                          //             maxLines: 1,
                          //             sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                          //           ),
                          //           data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ):Container(),
                          // (randomRes7.toString() != '[]')?Container(
                          //   width: CustomSize.sizeWidth(context),
                          //   height: CustomSize.sizeHeight(context) / 3.6,
                          //   child: ListView.builder(
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: (randomRes7.length < 10)?randomRes7.length:10,
                          //       itemBuilder: (_, index){
                          //         return Padding(
                          //           padding: EdgeInsets.only(
                          //               left: CustomSize.sizeWidth(context) / 20,
                          //               top: CustomSize.sizeHeight(context) / 86,
                          //               bottom: CustomSize.sizeHeight(context) / 86),
                          //           child: GestureDetector(
                          //             onTap: (){
                          //               // print(again[index].id.toString()+ 'ini id Pesan lagi');
                          //               Navigator.push(
                          //                   context,
                          //                   PageTransition(
                          //                       type: PageTransitionType.rightToLeft,
                          //                       child: new DetailResto(randomRes7[index].id.toString())));
                          //             },
                          //             child: Container(
                          //               width: CustomSize.sizeWidth(context) / 2.3,
                          //               height: CustomSize.sizeHeight(context) / 3.6,
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(20),
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color: Colors.grey.withOpacity(0.5),
                          //                     spreadRadius: 0,
                          //                     blurRadius: 4,
                          //                     offset: Offset(0, 3), // changes position of shadow
                          //                   ),
                          //                 ],
                          //               ),
                          //               child: Column(
                          //                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                 children: [
                          //                   (randomRes7[index].status.toString() == 'active')?(randomRes7[index].isOpen.toString() == 'true')?Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     decoration: BoxDecoration(
                          //                       color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                          //                       image: (randomRes7[index].img != '')?DecorationImage(
                          //                           image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                          //                           fit: BoxFit.cover
                          //                       ):DecorationImage(
                          //                           image: AssetImage("assets/irgLogo.png"),
                          //                           fit: BoxFit.contain
                          //                       ),
                          //                       borderRadius: BorderRadius.circular(20),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: BoxDecoration(
                          //                             color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                          //                             image: (randomRes7[index].img != '')?DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ):DecorationImage(
                          //                                 image: AssetImage("assets/irgLogo.png"),
                          //                                 fit: BoxFit.contain
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ):Container(
                          //                     width: CustomSize.sizeWidth(context) / 2.3,
                          //                     height: CustomSize.sizeHeight(context) / 5.8,
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(20),
                          //                       child: ColorFiltered(
                          //                         colorFilter: ColorFilter.mode(
                          //                           Colors.grey,
                          //                           BlendMode.saturation,
                          //                         ),
                          //                         child: Container(
                          //                           decoration: BoxDecoration(
                          //                             color: (randomRes7[index].img != '')?Colors.transparent:CustomColor.primary,
                          //                             image: (randomRes7[index].img != '')?DecorationImage(
                          //                                 image: NetworkImage(Links.subUrl + randomRes7[index].img!),
                          //                                 fit: BoxFit.cover
                          //                             ):DecorationImage(
                          //                                 image: AssetImage("assets/irgLogo.png"),
                          //                                 fit: BoxFit.contain
                          //                             ),
                          //                             borderRadius: BorderRadius.circular(20),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                   SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: MediaQuery(child: CustomText.bodyRegular14(text: randomRes7[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                          //                       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                          //                   ),
                          //                   Padding(
                          //                     padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                          //                     child: MediaQuery(child: CustomText.bodyMedium16(text: randomRes7[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                          //                       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // ):Container(),
                          // (randomRes7.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),

                          (isLoading2 == true)?Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: CustomSize.sizeWidth(context) / 1.1,
                              height: CustomSize.sizeHeight(context) / 14,
                              // decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(30),
                              //     color: CustomColor.accent
                              // ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
                                ),
                              ),
                            ),
                          ):Container(),

                          (again.toString() != '[]')?Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery(
                                  child: CustomText.textTitle2(
                                      text: "Pesan Lagi",
                                      maxLines: 1,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.rightToLeft,
                                            child: new PesananmuActivity()));
                                  },
                                  child: MediaQuery(
                                    child: CustomText.bodyMedium12(
                                        text: "Lebih banyak",
                                        color: CustomColor.primary,
                                        maxLines: 1,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()),
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ):Container(),
                          (again.toString() != '[]')?Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 3.6,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: again.length,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: CustomSize.sizeWidth(context) / 20,
                                        top: CustomSize.sizeHeight(context) / 86,
                                        bottom: CustomSize.sizeHeight(context) / 86),
                                    child: GestureDetector(
                                      onTap: (){
                                        // print(again[index].id.toString()+ 'ini id Pesan lagi');
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.rightToLeft,
                                                child: new DetailResto(again[index].id.toString())));
                                      },
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 3.6,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: CustomSize.sizeWidth(context) / 2.3,
                                              height: CustomSize.sizeHeight(context) / 5.8,
                                              decoration: BoxDecoration(
                                                color: (again[index].img != '')?Colors.transparent:CustomColor.primary,
                                                image: (again[index].img != '')?DecorationImage(
                                                    image: NetworkImage(Links.subUrl + again[index].img!),
                                                    fit: BoxFit.cover
                                                ):DecorationImage(
                                                    image: AssetImage("assets/irgLogo.png"),
                                                    fit: BoxFit.contain
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                            // (again[index].isOpen.toString() == 'true')?Container(
                                            //   width: CustomSize.sizeWidth(context) / 2.3,
                                            //   height: CustomSize.sizeHeight(context) / 5.8,
                                            //   decoration: BoxDecoration(
                                            //     color: (again[index].img != '')?Colors.transparent:CustomColor.primary,
                                            //     image: (again[index].img != '')?DecorationImage(
                                            //         image: NetworkImage(Links.subUrl + again[index].img!),
                                            //         fit: BoxFit.cover
                                            //     ):DecorationImage(
                                            //         image: AssetImage("assets/irgLogo.png"),
                                            //         fit: BoxFit.contain
                                            //     ),
                                            //     borderRadius: BorderRadius.circular(20),
                                            //   ),
                                            // ):Container(
                                            //   width: CustomSize.sizeWidth(context) / 2.3,
                                            //   height: CustomSize.sizeHeight(context) / 5.8,
                                            //   child: ClipRRect(
                                            //     borderRadius: BorderRadius.circular(20),
                                            //     child: ColorFiltered(
                                            //       colorFilter: ColorFilter.mode(
                                            //         Colors.grey,
                                            //         BlendMode.saturation,
                                            //       ),
                                            //       child: Container(
                                            //         decoration: BoxDecoration(
                                            //           color: (again[index].img != '')?Colors.transparent:CustomColor.primary,
                                            //           image: (again[index].img != '')?DecorationImage(
                                            //               image: NetworkImage(Links.subUrl + again[index].img!),
                                            //               fit: BoxFit.cover
                                            //           ):DecorationImage(
                                            //               image: AssetImage("assets/irgLogo.png"),
                                            //               fit: BoxFit.contain
                                            //           ),
                                            //           borderRadius: BorderRadius.circular(20),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyRegular14(text: again[index].distance.toString() + " Km",sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString()),),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                              child: MediaQuery(child: CustomText.bodyMedium16(text: again[index].name, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ):Container(),
                        ],
                      ),
                      (again.toString() != '[]')?SizedBox(height: CustomSize.sizeHeight(context) / 14,):SizedBox(height: CustomSize.sizeHeight(context) / 10,)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.12,
            height: CustomSize.sizeHeight(context) / 12,
            decoration: BoxDecoration(
              color: CustomColor.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    onTap: ()async{
                      var i = await Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: new HomeActivity()));
                      if(i == null){
                        _getData();
                      }
                    },
                    child: Icon(MaterialCommunityIcons.home, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: BookmarkActivity()));
                    },
                    child: Icon(MaterialCommunityIcons.bookmark, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: ()async{
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      String _cart = pref.getString('inCart')??'';
                      print(pref.getString('inCart'));
                      if(_cart != ''){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: CartActivity()));
                        // .then((_) {
                        //   // This block runs when you have returned back to the 1st Page from 2nd.
                        //   setState(() {
                        //     Navigator.pushReplacement(context, PageTransition(
                        //         type: PageTransitionType.fade,
                        //         child: HomeActivity()));
                        //   });
                        // });
                      }else{
                        Fluttertoast.showToast(
                          msg: "Tidak ada pesanan di keranjang anda", fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()));
                      }
                    },
                    child: Icon(CupertinoIcons.cart_fill, size: 32, color: Colors.white,)),
                GestureDetector(
                    onTap: ()async{
                      var i = await Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new SearchActivity(promo, latitude.toString(), longitude.toString(), '')));
                      if(i == null){
                        _getData();
                      }
                    },
                    child: Icon(FontAwesome.search, size: 32, color: Colors.white,)),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new ProfileActivity()));
                    });
                  },
                  onLongPress: ()async{
                    logOut();
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    pref.clear();
                    setState(() {
                      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new LoginActivity()));
                    });
                  },
                  child: Icon(Ionicons.md_person, size: 32, color: Colors.white,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
