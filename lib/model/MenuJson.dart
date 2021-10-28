class MenuJson{
  int id;
  String name;
  String restoName;
  String restoId;
  String desc;
  String price;
  String pricePlus;
  String? discount;
  String urlImg;
  double? distance;

  MenuJson({required this.id, required this.name, required this.restoName, required this.restoId, required this.desc, required this.price, required this.pricePlus, required this.discount, required this.urlImg, required this.distance});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['restoName'] = this.restoName;
    data['desc'] = this.desc;
    data['price'] = this.price;
    data['pricePlus'] = this.pricePlus;
    data['discount'] = this.discount;
    data['urlImg'] = this.urlImg;
    data['distance'] = this.distance;

    return data;
  }
}