import 'Menu.dart';

class Promo{
  int? id;
  int? menus_id;
  String? word;
  String? expired_at;
  int? discountedPrice;
  int? potongan;
  int? ongkir;
  Menu? menu;

  Promo({required this.id, required this.word, required this.discountedPrice, required this.menu});

  Promo.withoutName(this.id, this.discountedPrice, this.menu);

  Promo.resto({required this.id, this.menus_id, this.word, this.expired_at, this.discountedPrice, this.potongan, this.ongkir, this.menu});
}

class Promo2{
  int? id;
  int? menus_id;
  String? word;
  String? expired_at;
  int? discountedPrice;
  int? potongan;
  int? ongkir;
  Menu3? menu;

  Promo2({required this.id, required this.word, required this.discountedPrice, required this.menu});

  Promo2.withoutName(this.id, this.discountedPrice, this.menu);

  Promo2.resto({required this.id, this.menus_id, this.word, this.expired_at, this.discountedPrice, this.potongan, this.ongkir, this.menu});
}