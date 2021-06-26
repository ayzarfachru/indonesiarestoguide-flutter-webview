import 'Price.dart';

class Menu{
  int id;
  String restoId;
  String name;
  String restoName;
  String desc;
  String qty;
  Price price;
  Price delivery_price;
  String urlImg;
  String type;
  String is_recommended;
  double distance;

  Menu({this.id, this.restoId, this.name, this.restoName, this.desc, this.qty, this.price, this.delivery_price, this.urlImg, this.type, this.is_recommended, this.distance});
}