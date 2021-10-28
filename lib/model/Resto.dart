import 'Menu.dart';
import 'Promo.dart';

class Resto{
  int id;
  String? name;
  String? address;
  String? desc;
  String? day;
  String? hours;
  String? isOpen;
  String? status;
  String? priceRange;
  bool? isFavourite;
  double? distance;
  String? img;
  List<String?>? images;
  List<Menu?>? menus;
  List<Menu?>? all;
  List<Promo?>? promos;

  Resto(this.id, this.name, this.isFavourite, this.distance);

  Resto.all(
      {required this.id,
        this.name,
        this.address,
        this.desc,
        this.day,
        this.hours,
        this.isOpen,
        this.status,
        this.priceRange,
        this.isFavourite,
        this.distance,
        this.img,
        this.images,
        this.menus,
        this.all,
        this.promos});
}