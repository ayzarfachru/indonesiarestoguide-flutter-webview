import 'package:kam5ia/model/Resto.dart';

import 'Price.dart';

class Menu{
  int id = 0;
  String restoId = '';
  String name = '';
  String restoName = '';
  String desc = '';
  String qty = '';
  Price? price = null;
  Price? delivery_price = null;
  String urlImg = '';
  String type = '';
  String is_recommended = '';
  String is_available = '';
  double? distance;

  Menu({required this.id, required this.restoId, required this.name, required this.restoName, required this.desc, required this.qty, required this.price, required this.delivery_price, required this.urlImg, required this.type, required this.is_recommended, required this.is_available, required this.distance});
  Menu.qty(this.qty);
}

// import 'package:kam5ia/model/Resto.dart';
//
// import 'Price.dart';

class Menu2{
  int id;
  String restoId;
  String name;
  String restoName;
  String desc;
  String qty;
  Price? price;
  Price? delivery_price;
  String urlImg;
  String type;
  String is_recommended;
  String is_available;
  double? distance;
  Resto usaha;

  Menu2({required this.id, required this.restoId, required this.name, required this.restoName, required this.desc, required this.qty, required this.price, required this.delivery_price, required this.urlImg, required this.type, required this.is_recommended, required this.is_available, required this.distance, required this.usaha});
}

class Menu3{
  int id = 0;
  String restoId = '';
  String name = '';
  String restoName = '';
  String desc = '';
  String qty = '';
  Price? price = null;
  Price? delivery_price = null;
  String urlImg = '';
  String type = '';
  String ex_date = '';
  String is_recommended = '';
  String is_available = '';
  double? distance;

  Menu3({required this.id, required this.restoId, required this.name, required this.restoName, required this.desc, required this.qty, required this.price, required this.delivery_price, required this.urlImg, required this.type, required this.is_recommended, required this.is_available, required this.distance, required this.ex_date});
}