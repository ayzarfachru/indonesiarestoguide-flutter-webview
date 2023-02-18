class NguponYuk{
  int? id;
  String? code;
  String? price;
  String? status;
  String? date;
  String? expired;

  NguponYuk({required this.id, required this.price, required this.status, required this.date});

  NguponYuk.sub({
        this.id,
        this.code,
        this.price,
        this.status,
        this.date,
        this.expired,
      });
}
