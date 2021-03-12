import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/model/User.dart';

import 'Menu.dart';

class Transaction{
  int id;
  String status;
  String username;
  Resto nameResto;
  String address;
  int ongkir;
  int total;
  List<Menu> menus;
  String type;
  String img;
  String date;
  String datetime;
  String method;

  Transaction(
        {this.id,
        this.status,
        this.username,
        this.nameResto,
        this.address,
        this.ongkir,
        this.total,
        this.menus,
        this.type,
        this.img,
        this.date,
        this.datetime,
        this.method});

  Transaction.withoutMenu(this.id, this.status, this.nameResto, this.datetime, this.method);

  Transaction.resto(
      {this.id, this.status, this.username, this.total, this.type});

  Transaction.restoDetail(
      {this.type, this.address, this.ongkir, this.total});

  Transaction.menuOnly(this.menus);
}