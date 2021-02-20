import 'Price.dart';

class Menu{
  int id;
  String name;
  String restoName;
  String desc;
  Price price;
  String urlImg;
  double distance;

  Menu({this.id, this.name, this.restoName, this.desc, this.price, this.urlImg, this.distance});
}