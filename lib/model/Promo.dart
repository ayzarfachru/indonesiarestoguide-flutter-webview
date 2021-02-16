import 'Menu.dart';

class Promo{
  int id;
  String word;
  int discountedPrice;
  Menu menu;

  Promo(this.id, this.word, this.discountedPrice, this.menu);

  Promo.withoutName(this.id, this.discountedPrice, this.menu);
}