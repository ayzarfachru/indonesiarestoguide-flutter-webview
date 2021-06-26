class User{
  int id;
  String name;
  String img;
  String notelp;
  String email;
  String gender;
  String tgl;
  String token;

  User(
      {this.name,
      this.img,
      this.notelp,
      this.email,
      this.gender,
      this.tgl,
      this.token});

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