class User{
  int? id;
  String? name;
  String? img;
  String? notelp;
  String? email;
  String? gender;
  String? tgl;
  String? token;

  User(
      {required this.name,
      required this.img,
      required this.notelp,
      required this.email,
      required this.gender,
      required this.tgl,
      required this.token});

  User.resto(
      {this.id,
      this.name,
      this.img,
      this.notelp,
      this.email,
      this.gender,
      this.tgl,
      this.token});

  User.name(this.name);
}