import 'package:indonesiarestoguide/model/Resto.dart';

import 'Menu.dart';

class Transaction{
  int id;
  String status;
  Resto resto;
  List<Menu> menus;
  String datetime;
  String method;

  Transaction(
      {this.id,
      this.status,
      this.resto,
      this.menus,
      this.datetime,
      this.method});

  Transaction.withoutMenu(this.id, this.status, this.resto, this.datetime, this.method);

  Transaction.menuOnly(this.menus);
}