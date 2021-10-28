class Price{
  int? original;
  int? discounted;
  int? delivery;
  int? takeaway;
  int? disctakeaway;
  String? oriString;
  String? deliString;

  Price({required this.original, required this.discounted, required this.delivery});

  Price.original(this.original);

  Price.discounted(this.original, this.discounted);

  Price.delivery(this.original, this.delivery);

  Price.menu(this.original, this.delivery, this.discounted, this.takeaway, this.disctakeaway);

  Price.promo(this.oriString, this.deliString);
}