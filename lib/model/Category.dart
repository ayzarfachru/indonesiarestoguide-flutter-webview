class Category{
  int? id;
  String? nama;
  String? img;
  String? created;
  String? isNguponYuk;

  Category({required this.id, required this.nama, required this.img, required this.created});

  Category.sub({
    this.id,
    this.nama
  });

  Category.nguponYuk({
        this.id,
        this.nama,
        this.img,
        this.created,
        required this.isNguponYuk
      });
}
