import 'Menu.dart';

class Promo{
  int id;
  int menus_id;
  String word;
  String expired_at;
  int discountedPrice;
  int potongan;
  int ongkir;
  Menu menu;

  Promo({this.id, this.word, this.discountedPrice, this.menu});

  Promo.withoutName(this.id, this.discountedPrice, this.menu);

  Promo.resto({this.id, this.menus_id, this.word, this.expired_at, this.discountedPrice, this.potongan, this.ongkir, this.menu});
}