import 'package:indonesiarestoguide/model/Resto.dart';
import 'package:indonesiarestoguide/model/User.dart';

import 'Menu.dart';

class Transaction{
  int id;
  String status;
  String username;
  String nameResto;
  String address;
  int ongkir;
  int total;
  String chatroom;
  List<Menu> menus;
  String type;
  String table;
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
        this.chatroom,
        this.menus,
        this.type,
        this.img,
        this.date,
        this.datetime,
        this.method});

  Transaction.withoutMenu(this.id, this.status, this.nameResto, this.datetime, this.method);

  Transaction.resto(
      {this.id, this.status, this.username, this.total, this.chatroom, this.type, this.img});

  Transaction.reservation(
      {this.id, this.status, this.username, this.datetime, this.table, this.total, this.img});

  Transaction.restoDetail(
      {this.type, this.address, this.ongkir, this.total});

  Transaction.menuOnly(this.menus);
}