import 'package:kam5ia/model/Resto.dart';

import 'Menu.dart';

class TransactionResto{
  int? id;
  String? status;
  Resto? resto;
  List<Menu?>? menus;
  String? datetime;
  String? method;

  TransactionResto(
      {required this.id,
        required this.status,
        required this.resto,
        required this.menus,
        required this.datetime,
        required this.method});

  TransactionResto.withoutMenu(this.id, this.status, this.resto, this.datetime, this.method);

  TransactionResto.menuOnly(this.menus);
}