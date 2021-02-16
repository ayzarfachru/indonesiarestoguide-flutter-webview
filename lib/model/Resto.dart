import 'Menu.dart';
import 'Promo.dart';

class Resto{
  int id;
  String name;
  String address;
  String desc;
  String priceRange;
  bool isFavourite;
  double distance;
  List<String> images;
  List<Menu> menus;
  List<Menu> all;
  List<Promo> promos;

  Resto(this.id, this.name, this.isFavourite, this.distance);

  Resto.all(
      this.id,
      this.name,
      this.address,
      this.desc,
      this.priceRange,
      this.isFavourite,
      this.distance,
      this.images,
      this.menus,
      this.all,
      this.promos
      );
}