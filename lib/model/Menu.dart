import 'Price.dart';

class Menu{
  int id;
  String name;
  String restoId;
  String restoName;
  String desc;
  String qty;
  Price price;
  String urlImg;
  double distance;

  Menu({this.id, this.name, this.restoId, this.restoName, this.desc, this.qty, this.price, this.urlImg, this.distance});
}