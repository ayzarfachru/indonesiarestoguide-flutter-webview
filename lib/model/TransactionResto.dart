import 'package:indonesiarestoguide/model/Resto.dart';

import 'Menu.dart';

class TransactionResto{
  int id;
  String status;
  Resto resto;
  List<Menu> menus;
  String datetime;
  String method;

  TransactionResto(
      {this.id,
        this.status,
        this.resto,
        this.menus,
        this.datetime,
        this.method});

  TransactionResto.withoutMenu(this.id, this.status, this.resto, this.datetime, this.method);

  TransactionResto.menuOnly(this.menus);
}