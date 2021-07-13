class MenuJson{
  int id;
  String name;
  String restoName;
  String restoId;
  String desc;
  String price;
  String discount;
  String urlImg;
  double distance;

  MenuJson({this.id, this.name, this.restoName, this.restoId, this.desc, this.price, this.discount, this.urlImg, this.distance});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['restoName'] = this.restoName;
    data['desc'] = this.desc;
    data['price'] = this.price;
    data['discount'] = this.discount;
    data['urlImg'] = this.urlImg;
    data['distance'] = this.distance;

    return data;
  }
}