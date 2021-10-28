import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/model/User.dart';

import 'Menu.dart';

class Transaction{
  int? id;
  String? status;
  String? username;
  String? idResto;
  String? nameResto;
  String? address;
  int? ongkir;
  int? total;
  String? chatroom;
  List<Menu?>? menus;
  String? type;
  String? table;
  String? img;
  String? date;
  String? datetime;
  String? method;
  String? note;
  String chat_user = '';
  String is_opened = '';

  Transaction(
        {required this.id,
        required this.status,
        required this.username,
        required this.nameResto,
        required this.address,
        required this.ongkir,
        required this.total,
        required this.chatroom,
        required this.menus,
        required this.type,
        required this.img,
        required this.date,
        required this.datetime,
        required this.method});

  Transaction.all({this.id, this.date, this.img, this.idResto, this.nameResto, this.status, this.total, this.type, this.note});

  Transaction.all2({this.id, this.date, this.img, this.idResto, this.nameResto, this.status, this.total, this.ongkir, this.type, this.note, required this.chat_user});

  Transaction.withoutMenu(this.id, this.status, this.nameResto, this.datetime, this.method);

  Transaction.resto(
      {required this.id, required this.status, required this.username, required this.total, required this.chatroom, required this.type, required this.img});

  Transaction.resto2(
      {required this.id, required this.status, required this.username, required this.total, required this.chatroom, required this.type, required this.img, required this.chat_user});

  Transaction.resto3(
      {required this.id, required this.status, required this.username, required this.total, required this.chatroom, required this.type, required this.img, required this.chat_user, required this.is_opened});

  Transaction.home(
      {required this.chat_user, required this.is_opened});

  Transaction.reservation(
      {required this.id, this.status, this.username, this.datetime, this.table, this.total, this.img, required this.chatroom, required this.chat_user, required this.is_opened});

  Transaction.restoDetail(
      {this.type, this.address, this.ongkir, this.total});

  Transaction.menuOnly(this.menus);
}