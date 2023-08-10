import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kam5ia/ui/auth/regist_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/welcome_screen.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  TextEditingController _loginTextEmail = TextEditingController(text: "");
  TextEditingController _loginTextPassword = TextEditingController(text: "");

  FocusNode? fPassword;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool isLoading = false;
  String message = '';

  Future logOut()async{
    // List<History> _history = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/auth/logout'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oyyy '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // for(var v in data['trans']){
    //   History h = History(
    //       id: v['id'],
    //       name: v['resto_name'],
    //       time: v['time'],
    //       price: v['price'],
    //       img: v['resto_img'],
    //       type: v['type']
    //   );
    //   _history.add(h);
    // }

    // setState(() {
    //   // id = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['id'].toString();
    //   // restoName = (data['msg'].toString() == "User tidak punya resto")?'':data['resto']['name'];
    //   // // history = _history;
    //   // openAndClose = (data['status'].toString() == "closed")?'1':'0';
    //   // isLoading = false;
    // });

    // if(openAndClose == '0'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '1');
    // }else if(openAndClose == '1'){
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   pref.setString("openclose", '0');
    // }

    if (apiResult.statusCode == 200) {
      print('pb');
    }
  }

  Future _login(String email, String password) async {
    await idPlayer();
    if(email != "" && password != ""){
      setState(() {
        isLoading = true;
      });
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/auth/login'), body: {'email': email, 'password': password, 'device_id': playerId});
      print('apiResult.body login');
      print(apiResult.body);
      var data = json.decode(apiResult.body);
      if (data['status_code'].toString() == "200") {

        if (data['user']['email_verified_at'].toString() == 'null') {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("token", data['access_token'].toString());
          logOut();
          message = 'Verifikasi akun anda terlebih dahulu pada pesan yang dikirim melalui email anda!';
          setState((){});
          setState(() {
            isLoading = false;
          });
        } else {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setInt("id", int.parse(data['user']['id'].toString()));
          pref.setString("name", data['user']['name'].toString());
          pref.setString("email", data['user']['email'].toString());
          pref.setString("img", (data['user']['img'].toString() != 'null')?data['user']['img'].toString():'');
          pref.setString("gender", data['user']['gender'].toString());
          pref.setString("tgl", data['user']['ttl'].toString());
          pref.setString("notelp", data['user']['phone_number'].toString());
          pref.setString("token", data['access_token'].toString());
          // pref.setString("timeLog", DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

          print('Time '+DateTime.now().toString());
          print('Time '+DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Login berhasil!');
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  title: Center(child: Text('Terms Conditions', style: TextStyle(color: CustomColor.redBtn, fontSize: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString())))),
                  content: Container(
                    height: CustomSize.sizeHeight(context) / 2,
                    width: CustomSize.sizeWidth(context) / 1.5,
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Text('Pendahuluan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('PT Imaji Cipta (mempunyai produk yang disebut “Indonesia Resto Guide”) ialah suatu perseroan terbatas yang salah satu jenis usahanya berkecimpung pada bidang portal penjualan di bidang kuliner. Indonesia Resto Guide. PT Imaji Cipta dalam hal ini menyediakan Platform penjualan elektronik (e-commerce) di mana Pengguna dapat melakukan transaksi jual-beli, menggunakan berbagai fitur serta layanan yang tersedia. Setiap pihak yang berada pada wilayah Negara Kesatuan Republik Indonesia bisa mengakses Platform Indonesia Resto Guide untuk membuka lapangan penjualan di bidang kuliner, menggunakan layanan, atau hanya sekedar mengakses / mengunjungi. \n\nSyarat & ketentuan yang telah ditetapkan untuk mengatur pemakaian jasa yang ditawarkan oleh PT. Imaji Cipta terkait penggunaan perangkat lunak Indonesia Resto Guide. Pengguna disarankan membaca dengan seksama karena dapat berdampak pada hak dan kewajiban Pengguna di bawah aturan. dengan mendaftar akun Indonesia Resto Guide dan /atau memakai Platform Indonesia Resto Guide, maka Pengguna dianggap sudah membaca, mengerti, tahu serta menyetujui seluruh isi pada aturan Penggunaan. Jika pengguna tidak menyetujui salah satu, pesebagian, atau semua isi syarat & ketentuan, maka pengguna tidak diperkenankan memakai layanan Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Definisi', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Dalam Aturan Penggunaan istilah-istilah di bawah ini mempunyai arti sebagai berikut:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	PT. Imaji Cipta (Indonesia Resto Guide) adalah suatu perseroan terbatas yang menjalankan kegiatan usaha jasa aplikasi Indonesia Resto Guide, yakni aplikasi pencarian lapak dan Kuliner yang dijual oleh penjual terdaftar. Yang selanjutnya disebut Indonesia Resto Guide. \n\n2.)	Akun adalah data tentang Pengguna, minimum terdiri dari nama, password, nomor telepon, dan email yang wajib diisi oleh Pengguna Terdaftar. \n\n3.)	Platform Indonesia Resto Guide adalah situs resmi indonesiarestoguide.com dan seluruh website resmi beserta aplikasi resmi Indonesia Resto Guide (berbasis Android dan iOS) yang dapat diakses melalui perangkat komputer dan/atau perangkat seluler Pengguna. \n\n4.)	Pembeli adalah Pengguna terdaftar yang melakukan permintaan atas Makanan atau minuman yang dijual oleh Penjual di Aplikasi Indonesia Resto Guide. \n\n5.)	Penjual adalah Pengguna terdaftar yang melakukan kegiatan buka toko dan/atau melakukan penawaran atas suatu Makanan dan minuman kepada para Pengguna dan /atau Pembeli. \n\n6.)	Layanan adalah secara kolektif: (i) Platform Indonesia Resto Guide; (ii) Konten, fitur, layanan, dan fungsi apa pun yang tersedia di atau melalui Platform oleh atau atas nama Indonesia Resto Guide, termasuk Layanan Partner; dan pemberitahuan email, tombol, widget, dan iklan.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Pengguna, Penjual, Akun, Password & Keamanan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	Pengguna wajib berusia minimal 18 tahun (kecuali ditentukan lain oleh peraturan perundang-undangan yang berlaku di Indonesia). Pengguna yang belum genap berusia 18 tahun wajib memperoleh persetujuan dari orang tua atau wali untuk menggunakan dan /atau mengakses layanan di Platform Indonesia Resto Guide dan bertanggung jawab atas segala biaya yang timbul terkait penggunaan layanan di Platform Indonesia Resto Guide. \n\n2.)	Pengguna harus memahami bahwa 1 (satu) nomor telepon hanya dapat digunakan untuk mendaftar 1 (satu) akun Pengguna Indonesia Resto Guide, kecuali bagi Pengguna yang telah memiliki beberapa akun dengan 1 (satu) nomor telepon sebelumnya \n\n3.)	Pengguna yang telah mendaftar berhak bertindak sebagai: Pembeli dan Penjual. \n\n4.)	Penjual diwajibkan membayar biaya pembukaan toko. Penjual berhak melakukan pengaturan terhadap barang yang akan diperdagangkan di lapak pribadi Penjual. \n\n5.)	Indonesia Resto Guide memiliki hak untuk melakukan tindakan yang perlu atas setiap dugaan pelanggaran Syarat & ketentuan sesuai dengan hukum yang berlaku, yakni tindakan berupa penghapusan Barang, penutupan toko, suspensi akun, sampai penghapusan akun pengguna. \n\n6.)	Pengguna menyetujui untuk tidak menggunakan dan/atau mengakses sistem Indonesia Resto Guide secara langsung atau tidak langsung, baik keseluruhan atau sebagian dengan virus, perangkat lunak, atau teknologi lainnya yang dapat mengakibatkan melemahkan, merusak, mengganggu dan menghambat, membatasi, mengambil alih fungsionalitas serta integritas dari sistem perangkat lunak atau perangkat keras, jaringan, dan/atau data pada Aplikasi Indonesia Resto Guide. \n\n7.)	Pengguna wajib mengetahui bahwa detail informasi berupa data diri nama, alamat usaha, nomor telepon akun milik Pengguna akan diterima oleh pihak Penjual dalam kemudahan bertransaksi dan berfungsi sebagai database penjual sendiri \n\n8.)	Penjual harus mengetahui bahwa detail informasi milik Pengguna adalah rahasia, dan karenanya Penjual tidak akan mengungkapkan detail informasi akun Pengguna kepada Pihak Ketiga mana pun kecuali untuk kegiatan jual beli dalam aplikasi Indonesia Resto Guide. \n\n9.)	Penjual setuju untuk menanggung setiap risiko terkait pengungkapan informasi Akun Pengguna kepada Pihak Ketiga mana pun dan bertanggung jawab penuh atas setiap konsekuensi yang berkaitan dengan hal tersebut. \n\n10.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk melanggar peraturan yang ditetapkan oleh hukum di Indonesia maupun di negara lainnya. \n\n11.)	Pengguna dilarang mendistribusikan virus atau teknologi lainnya yang dapat membahayakan aplikasi Indonesia Resto Guide, kepentingan dan/atau properti dari Pengguna lain, maupun instansi Pemerintahan. \n\n12.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk tujuan komersial dan melakukan transfer/menjual akun Pengguna ke Pengguna lain atau ke pihak lain dengan tujuan apapun. \n\n13.)	Pengguna wajib menghargai hak-hak Pengguna lainnya dengan tidak memberikan informasi pribadi ke pihak lain tanpa izin pihak yang bersangkutan. \n\n14.)	Pengguna wajib membaca, memahami serta mengikuti semua ketentuan yang diatur dalam Aturan Penggunaan ini.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Ketentuan Lain', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	Apabila pengguna mempergunakan fitur/layanan yang tersedia dalam Website/Aplikasi Indonesia Resto Guide, maka Pengguna dengan ini menyatakan telah memahami dan menyetujui segala syarat dan ketentuan yang diatur khusus sehubungan dengan fitur/layanan yang digunakan. \n\n2.)	Segala hal yang belum dan/atau tidak diatur dalam syarat dan ketentuan khusus dalam fitur tersebut maka akan sepenuhnya merujuk pada syarat dan ketentuan Indonesia Resto Guide secara umum. \n\n3.)	Dengan menyetujui Syarat dan Ketentuan, maka Pengguna telah dianggap paham dan mengikuti Kebijakan Privasi Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Pembaruan & Perubahan Aturan Penggunaan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Indonesia Resto Guide memiliki hak untuk melakukan pembaruan dan/atau perubahan Aturan Penggunaan dari waktu ke waktu jika diperlukan demi keamanan dan kenyamanan Pengguna di Platform Indonesia Resto Guide. Pengguna harus setuju untuk membaca secara saksama dan memeriksa Aturan Penggunaan ini dari waktu ke waktu untuk mengetahui pembaruan dan/atau perubahan apapun. Dengan tetap mengakses dan menggunakan layanan Indonesia Resto Guide, maka pengguna dianggap menyetujui perubahan-perubahan dalam Syarat & Ketentuan kami.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start, ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // FlatButton(
                          //   // minWidth: CustomSize.sizeWidth(context),
                          //   color: CustomColor.redBtn,
                          //   textColor: Colors.white,
                          //   shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.all(Radius.circular(10))
                          //   ),
                          //   child: Text('Batal'),
                          //   onPressed: () async{
                          //     setState(() {
                          //       // codeDialog = valueText;
                          //       Navigator.pop(context);
                          //     });
                          //   },
                          // ),
                          TextButton(
                            // minWidth: CustomSize.sizeWidth(context),
                            style: TextButton.styleFrom(
                              backgroundColor: CustomColor.primaryLight,
                              padding: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                            ),
                            child: Text('Setuju', style: TextStyle(color: Colors.white)),
                            onPressed: () async{
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: HomeActivity()));
                              terms = true;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              });
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Email atau password anda salah!',);
        setState(() {
          isLoading = false;
        });
      }
    }else{
      Fluttertoast.showToast(
        msg: "Datamu kurang lengkap nih",);
    }
  }


  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "839490096186-4ulavkeso7qrl384n3tmd55qmh4iot2o.apps.googleusercontent.com",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      // 'https://www.googleapis.com/auth/user.birthday.read',
      // 'https://www.googleapis.com/auth/user.gender.read',
      // 'https://www.googleapis.com/auth/user.phonenumbers.read'
    ],
  );

  Future<void> _handleSignIn() async {
    await idPlayer();
    // await _googleSignIn.signOut();
    await _googleSignIn.signIn().then((value) async{
      print(playerId.toString()+' ply');
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/auth/login/google'),
          body: {'email': value?.email, 'name': value?.displayName, 'photoUrl': value?.photoUrl, 'device_id': playerId});
      print('print auth');
      print(apiResult.body);
      var data = json.decode(apiResult.body);
      if (data['status_code'].toString() == "200") {

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("id", int.parse(data['user']['id'].toString()));
        pref.setString("name", data['user']['name'].toString());
        pref.setString("email", data['user']['email'].toString());
        pref.setString("img", (data['user']['img'].toString() != 'null')?data['user']['img'].toString():'');
        pref.setString("gender", data['user']['gender'].toString());
        pref.setString("tgl", data['user']['ttl'].toString());
        pref.setString("notelp", data['user']['phone_number'].toString());
        pref.setString("token", data['access_token'].toString());
        // pref.setString("timeLog", DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        print('Time '+DateTime.now().toString());
        print('Time '+DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', ''));

        print(data['user']['id'].toString()+' telp');

        if (mounted == false) {
          Fluttertoast.showToast(
              msg: 'Tekan sekali lagi untuk login!');
          // Future.delayed(Duration(seconds: 5), () async {
          //   print('ini ' + mounted.toString());
          //   _handleSignIn();
          // });
        } else {
          Fluttertoast.showToast(
              msg: 'Login berhasil!');
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  title: Center(child: Text('Terms Conditions', style: TextStyle(color: CustomColor.redBtn, fontSize: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString())))),
                  content: Container(
                    height: CustomSize.sizeHeight(context) / 2,
                    width: CustomSize.sizeWidth(context) / 1.5,
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Text('Pendahuluan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('PT Imaji Cipta (mempunyai produk yang disebut “Indonesia Resto Guide”) ialah suatu perseroan terbatas yang salah satu jenis usahanya berkecimpung pada bidang portal penjualan di bidang kuliner. Indonesia Resto Guide. PT Imaji Cipta dalam hal ini menyediakan Platform penjualan elektronik (e-commerce) di mana Pengguna dapat melakukan transaksi jual-beli, menggunakan berbagai fitur serta layanan yang tersedia. Setiap pihak yang berada pada wilayah Negara Kesatuan Republik Indonesia bisa mengakses Platform Indonesia Resto Guide untuk membuka lapangan penjualan di bidang kuliner, menggunakan layanan, atau hanya sekedar mengakses / mengunjungi. \n\nSyarat & ketentuan yang telah ditetapkan untuk mengatur pemakaian jasa yang ditawarkan oleh PT. Imaji Cipta terkait penggunaan perangkat lunak Indonesia Resto Guide. Pengguna disarankan membaca dengan seksama karena dapat berdampak pada hak dan kewajiban Pengguna di bawah aturan. dengan mendaftar akun Indonesia Resto Guide dan /atau memakai Platform Indonesia Resto Guide, maka Pengguna dianggap sudah membaca, mengerti, tahu serta menyetujui seluruh isi pada aturan Penggunaan. Jika pengguna tidak menyetujui salah satu, pesebagian, atau semua isi syarat & ketentuan, maka pengguna tidak diperkenankan memakai layanan Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Definisi', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Dalam Aturan Penggunaan istilah-istilah di bawah ini mempunyai arti sebagai berikut:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	PT. Imaji Cipta (Indonesia Resto Guide) adalah suatu perseroan terbatas yang menjalankan kegiatan usaha jasa aplikasi Indonesia Resto Guide, yakni aplikasi pencarian lapak dan Kuliner yang dijual oleh penjual terdaftar. Yang selanjutnya disebut Indonesia Resto Guide. \n\n2.)	Akun adalah data tentang Pengguna, minimum terdiri dari nama, password, nomor telepon, dan email yang wajib diisi oleh Pengguna Terdaftar. \n\n3.)	Platform Indonesia Resto Guide adalah situs resmi indonesiarestoguide.com dan seluruh website resmi beserta aplikasi resmi Indonesia Resto Guide (berbasis Android dan iOS) yang dapat diakses melalui perangkat komputer dan/atau perangkat seluler Pengguna. \n\n4.)	Pembeli adalah Pengguna terdaftar yang melakukan permintaan atas Makanan atau minuman yang dijual oleh Penjual di Aplikasi Indonesia Resto Guide. \n\n5.)	Penjual adalah Pengguna terdaftar yang melakukan kegiatan buka toko dan/atau melakukan penawaran atas suatu Makanan dan minuman kepada para Pengguna dan /atau Pembeli. \n\n6.)	Layanan adalah secara kolektif: (i) Platform Indonesia Resto Guide; (ii) Konten, fitur, layanan, dan fungsi apa pun yang tersedia di atau melalui Platform oleh atau atas nama Indonesia Resto Guide, termasuk Layanan Partner; dan pemberitahuan email, tombol, widget, dan iklan.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Pengguna, Penjual, Akun, Password & Keamanan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	Pengguna wajib berusia minimal 18 tahun (kecuali ditentukan lain oleh peraturan perundang-undangan yang berlaku di Indonesia). Pengguna yang belum genap berusia 18 tahun wajib memperoleh persetujuan dari orang tua atau wali untuk menggunakan dan /atau mengakses layanan di Platform Indonesia Resto Guide dan bertanggung jawab atas segala biaya yang timbul terkait penggunaan layanan di Platform Indonesia Resto Guide. \n\n2.)	Pengguna harus memahami bahwa 1 (satu) nomor telepon hanya dapat digunakan untuk mendaftar 1 (satu) akun Pengguna Indonesia Resto Guide, kecuali bagi Pengguna yang telah memiliki beberapa akun dengan 1 (satu) nomor telepon sebelumnya \n\n3.)	Pengguna yang telah mendaftar berhak bertindak sebagai: Pembeli dan Penjual. \n\n4.)	Penjual diwajibkan membayar biaya pembukaan toko. Penjual berhak melakukan pengaturan terhadap barang yang akan diperdagangkan di lapak pribadi Penjual. \n\n5.)	Indonesia Resto Guide memiliki hak untuk melakukan tindakan yang perlu atas setiap dugaan pelanggaran Syarat & ketentuan sesuai dengan hukum yang berlaku, yakni tindakan berupa penghapusan Barang, penutupan toko, suspensi akun, sampai penghapusan akun pengguna. \n\n6.)	Pengguna menyetujui untuk tidak menggunakan dan/atau mengakses sistem Indonesia Resto Guide secara langsung atau tidak langsung, baik keseluruhan atau sebagian dengan virus, perangkat lunak, atau teknologi lainnya yang dapat mengakibatkan melemahkan, merusak, mengganggu dan menghambat, membatasi, mengambil alih fungsionalitas serta integritas dari sistem perangkat lunak atau perangkat keras, jaringan, dan/atau data pada Aplikasi Indonesia Resto Guide. \n\n7.)	Pengguna wajib mengetahui bahwa detail informasi berupa data diri nama, alamat usaha, nomor telepon akun milik Pengguna akan diterima oleh pihak Penjual dalam kemudahan bertransaksi dan berfungsi sebagai database penjual sendiri \n\n8.)	Penjual harus mengetahui bahwa detail informasi milik Pengguna adalah rahasia, dan karenanya Penjual tidak akan mengungkapkan detail informasi akun Pengguna kepada Pihak Ketiga mana pun kecuali untuk kegiatan jual beli dalam aplikasi Indonesia Resto Guide. \n\n9.)	Penjual setuju untuk menanggung setiap risiko terkait pengungkapan informasi Akun Pengguna kepada Pihak Ketiga mana pun dan bertanggung jawab penuh atas setiap konsekuensi yang berkaitan dengan hal tersebut. \n\n10.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk melanggar peraturan yang ditetapkan oleh hukum di Indonesia maupun di negara lainnya. \n\n11.)	Pengguna dilarang mendistribusikan virus atau teknologi lainnya yang dapat membahayakan aplikasi Indonesia Resto Guide, kepentingan dan/atau properti dari Pengguna lain, maupun instansi Pemerintahan. \n\n12.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk tujuan komersial dan melakukan transfer/menjual akun Pengguna ke Pengguna lain atau ke pihak lain dengan tujuan apapun. \n\n13.)	Pengguna wajib menghargai hak-hak Pengguna lainnya dengan tidak memberikan informasi pribadi ke pihak lain tanpa izin pihak yang bersangkutan. \n\n14.)	Pengguna wajib membaca, memahami serta mengikuti semua ketentuan yang diatur dalam Aturan Penggunaan ini.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Ketentuan Lain', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('1.)	Apabila pengguna mempergunakan fitur/layanan yang tersedia dalam Website/Aplikasi Indonesia Resto Guide, maka Pengguna dengan ini menyatakan telah memahami dan menyetujui segala syarat dan ketentuan yang diatur khusus sehubungan dengan fitur/layanan yang digunakan. \n\n2.)	Segala hal yang belum dan/atau tidak diatur dalam syarat dan ketentuan khusus dalam fitur tersebut maka akan sepenuhnya merujuk pada syarat dan ketentuan Indonesia Resto Guide secara umum. \n\n3.)	Dengan menyetujui Syarat dan Ketentuan, maka Pengguna telah dianggap paham dan mengikuti Kebijakan Privasi Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Pembaruan & Perubahan Aturan Penggunaan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                        Text('Indonesia Resto Guide memiliki hak untuk melakukan pembaruan dan/atau perubahan Aturan Penggunaan dari waktu ke waktu jika diperlukan demi keamanan dan kenyamanan Pengguna di Platform Indonesia Resto Guide. Pengguna harus setuju untuk membaca secara saksama dan memeriksa Aturan Penggunaan ini dari waktu ke waktu untuk mengetahui pembaruan dan/atau perubahan apapun. Dengan tetap mengakses dan menggunakan layanan Indonesia Resto Guide, maka pengguna dianggap menyetujui perubahan-perubahan dalam Syarat & Ketentuan kami.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start, ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // FlatButton(
                          //   // minWidth: CustomSize.sizeWidth(context),
                          //   color: CustomColor.redBtn,
                          //   textColor: Colors.white,
                          //   shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.all(Radius.circular(10))
                          //   ),
                          //   child: Text('Batal'),
                          //   onPressed: () async{
                          //     setState(() {
                          //       // codeDialog = valueText;
                          //       Navigator.pop(context);
                          //     });
                          //   },
                          // ),
                          TextButton(
                            // minWidth: CustomSize.sizeWidth(context),
                            style: TextButton.styleFrom(
                              backgroundColor: CustomColor.primaryLight,
                              padding: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                            ),
                            child: Text('Setuju', style: TextStyle(color: Colors.white)),
                            onPressed: () async{
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: HomeActivity()));
                              terms = true;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),

                  ],
                );
              });
        }
      }else{
        Fluttertoast.showToast(
          msg: data['message'],);
      }
    });
  }

  Future idPlayer() async{
    var status = await OneSignal.shared.getDeviceState();
    playerId = status?.userId;

    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("playerId", playerId!);

    print('player id'+playerId.toString());
    setState(() {});
  }
  String? playerId;

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
//     DateTime now = DateTime.now();
//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
//       return Future.value(false);
//     }
// //    SystemNavigator.pop();
//     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    exit(0);
    return Future.value(true);
  }

  bool terms = false;

  @override
  void initState() {
    // idPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        // backgroundColor: CustomColor.primaryLight,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ScrollConfiguration(
                  behavior: CustomScroll(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onDoubleTap: (){
                              // _login('admin@admin.com', 'adminadmin');
                            },
                            child: Container(
                                alignment: Alignment.center,
                                child: MediaQuery(child: CustomText.auth(text: "Sign in and explore!", minSize: double.parse(((MediaQuery.of(context).size.width*0.085).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.085).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.085).toString())),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),)
                            ),
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 70,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: MediaQuery(
                              child: CustomText.bodyMedium16(
                                  text: "Just one step before exploring",
                                  maxLines: 1,
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                              ),
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: MediaQuery(
                              child: CustomText.bodyMedium16(
                                  text: "the largest culinary network",
                                  maxLines: 1,
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                              ),
                              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                            ),
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 24,
                          ),
                          CustomText.bodyMedium16(
                              text: "   Email",
                              maxLines: 1
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          Container(
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                              color: Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                              child: Center(
                                child: TextField(
                                  controller: _loginTextEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  cursorColor: Colors.black,
                                  style: GoogleFonts.sourceSansPro(
                                      textStyle:
                                      TextStyle(fontSize: 16, color: Colors.black)),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    hintStyle: GoogleFonts.poppins(
                                        textStyle:
                                        TextStyle(fontSize: 14, color: Colors.grey)),
                                    helperStyle: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 14)),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyMedium16(
                              text: "   Password",
                              maxLines: 1
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          Container(
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                              color: Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      enableInteractiveSelection: false,
                                      autocorrect: false,
                                      focusNode: fPassword,
                                      obscureText: _obscureText,
                                      controller: _loginTextPassword,
                                      cursorColor: Colors.black,
                                      style: GoogleFonts.poppins(
                                          textStyle:
                                          TextStyle(fontSize: 14, color: Colors.black)),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(0),
                                        hintStyle: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: 16, color: Colors.grey)),
                                        helperStyle: GoogleFonts.poppins(
                                            textStyle: TextStyle(fontSize: 14)),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _toggle,
                                    child: Icon(
                                        _obscureText
                                            ? MaterialCommunityIcons.eye
                                            : MaterialCommunityIcons.eye_off,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Row(
                          //   mainAxisSize: MainAxisSize.max,
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     Checkbox(
                          //       value: terms,
                          //       onChanged: (bool? value) {
                          //         setState(() {
                          //           terms = value!;
                          //         });
                          //       },
                          //     ),
                          //     GestureDetector(
                          //       onTap: (){
                          //         showDialog(
                          //             context: context,
                          //             builder: (context) {
                          //               return AlertDialog(
                          //                 contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                          //                 shape: RoundedRectangleBorder(
                          //                     borderRadius: BorderRadius.all(Radius.circular(10))
                          //                 ),
                          //                 title: Center(child: Text('Terms Conditions', style: TextStyle(color: CustomColor.redBtn, fontSize: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString())))),
                          //                 content: Container(
                          //                   height: CustomSize.sizeHeight(context) / 2,
                          //                   width: CustomSize.sizeWidth(context) / 1.5,
                          //                   child: ListView(
                          //                     physics: AlwaysScrollableScrollPhysics(),
                          //                     padding: EdgeInsets.zero,
                          //                     shrinkWrap: true,
                          //                     children: [
                          //                       Text('Pendahuluan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('PT Imaji Cipta (mempunyai produk yang disebut “Indonesia Resto Guide”) ialah suatu perseroan terbatas yang salah satu jenis usahanya berkecimpung pada bidang portal penjualan di bidang kuliner. Indonesia Resto Guide. PT Imaji Cipta dalam hal ini menyediakan Platform penjualan elektronik (e-commerce) di mana Pengguna dapat melakukan transaksi jual-beli, menggunakan berbagai fitur serta layanan yang tersedia. Setiap pihak yang berada pada wilayah Negara Kesatuan Republik Indonesia bisa mengakses Platform Indonesia Resto Guide untuk membuka lapangan penjualan di bidang kuliner, menggunakan layanan, atau hanya sekedar mengakses / mengunjungi. \n\nSyarat & ketentuan yang telah ditetapkan untuk mengatur pemakaian jasa yang ditawarkan oleh PT. Imaji Cipta terkait penggunaan perangkat lunak Indonesia Resto Guide. Pengguna disarankan membaca dengan seksama karena dapat berdampak pada hak dan kewajiban Pengguna di bawah aturan. dengan mendaftar akun Indonesia Resto Guide dan /atau memakai Platform Indonesia Resto Guide, maka Pengguna dianggap sudah membaca, mengerti, tahu serta menyetujui seluruh isi pada aturan Penggunaan. Jika pengguna tidak menyetujui salah satu, pesebagian, atau semua isi syarat & ketentuan, maka pengguna tidak diperkenankan memakai layanan Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Definisi', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Dalam Aturan Penggunaan istilah-istilah di bawah ini mempunyai arti sebagai berikut:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('1.)	PT. Imaji Cipta (Indonesia Resto Guide) adalah suatu perseroan terbatas yang menjalankan kegiatan usaha jasa aplikasi Indonesia Resto Guide, yakni aplikasi pencarian lapak dan Kuliner yang dijual oleh penjual terdaftar. Yang selanjutnya disebut Indonesia Resto Guide. \n\n2.)	Akun adalah data tentang Pengguna, minimum terdiri dari nama, password, nomor telepon, dan email yang wajib diisi oleh Pengguna Terdaftar. \n\n3.)	Platform Indonesia Resto Guide adalah situs resmi indonesiarestoguide.com dan seluruh website resmi beserta aplikasi resmi Indonesia Resto Guide (berbasis Android dan iOS) yang dapat diakses melalui perangkat komputer dan/atau perangkat seluler Pengguna. \n\n4.)	Pembeli adalah Pengguna terdaftar yang melakukan permintaan atas Makanan atau minuman yang dijual oleh Penjual di Aplikasi Indonesia Resto Guide. \n\n5.)	Penjual adalah Pengguna terdaftar yang melakukan kegiatan buka toko dan/atau melakukan penawaran atas suatu Makanan dan minuman kepada para Pengguna dan /atau Pembeli. \n\n6.)	Layanan adalah secara kolektif: (i) Platform Indonesia Resto Guide; (ii) Konten, fitur, layanan, dan fungsi apa pun yang tersedia di atau melalui Platform oleh atau atas nama Indonesia Resto Guide, termasuk Layanan Partner; dan pemberitahuan email, tombol, widget, dan iklan.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Pengguna, Penjual, Akun, Password & Keamanan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('1.)	Pengguna wajib berusia minimal 18 tahun (kecuali ditentukan lain oleh peraturan perundang-undangan yang berlaku di Indonesia). Pengguna yang belum genap berusia 18 tahun wajib memperoleh persetujuan dari orang tua atau wali untuk menggunakan dan /atau mengakses layanan di Platform Indonesia Resto Guide dan bertanggung jawab atas segala biaya yang timbul terkait penggunaan layanan di Platform Indonesia Resto Guide. \n\n2.)	Pengguna harus memahami bahwa 1 (satu) nomor telepon hanya dapat digunakan untuk mendaftar 1 (satu) akun Pengguna Indonesia Resto Guide, kecuali bagi Pengguna yang telah memiliki beberapa akun dengan 1 (satu) nomor telepon sebelumnya \n\n3.)	Pengguna yang telah mendaftar berhak bertindak sebagai: Pembeli dan Penjual. \n\n4.)	Penjual diwajibkan membayar biaya pembukaan toko. Penjual berhak melakukan pengaturan terhadap barang yang akan diperdagangkan di lapak pribadi Penjual. \n\n5.)	Indonesia Resto Guide memiliki hak untuk melakukan tindakan yang perlu atas setiap dugaan pelanggaran Syarat & ketentuan sesuai dengan hukum yang berlaku, yakni tindakan berupa penghapusan Barang, penutupan toko, suspensi akun, sampai penghapusan akun pengguna. \n\n6.)	Pengguna menyetujui untuk tidak menggunakan dan/atau mengakses sistem Indonesia Resto Guide secara langsung atau tidak langsung, baik keseluruhan atau sebagian dengan virus, perangkat lunak, atau teknologi lainnya yang dapat mengakibatkan melemahkan, merusak, mengganggu dan menghambat, membatasi, mengambil alih fungsionalitas serta integritas dari sistem perangkat lunak atau perangkat keras, jaringan, dan/atau data pada Aplikasi Indonesia Resto Guide. \n\n7.)	Pengguna wajib mengetahui bahwa detail informasi berupa data diri nama, alamat usaha, nomor telepon akun milik Pengguna akan diterima oleh pihak Penjual dalam kemudahan bertransaksi dan berfungsi sebagai database penjual sendiri \n\n8.)	Penjual harus mengetahui bahwa detail informasi milik Pengguna adalah rahasia, dan karenanya Penjual tidak akan mengungkapkan detail informasi akun Pengguna kepada Pihak Ketiga mana pun kecuali untuk kegiatan jual beli dalam aplikasi Indonesia Resto Guide. \n\n9.)	Penjual setuju untuk menanggung setiap risiko terkait pengungkapan informasi Akun Pengguna kepada Pihak Ketiga mana pun dan bertanggung jawab penuh atas setiap konsekuensi yang berkaitan dengan hal tersebut. \n\n10.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk melanggar peraturan yang ditetapkan oleh hukum di Indonesia maupun di negara lainnya. \n\n11.)	Pengguna dilarang mendistribusikan virus atau teknologi lainnya yang dapat membahayakan aplikasi Indonesia Resto Guide, kepentingan dan/atau properti dari Pengguna lain, maupun instansi Pemerintahan. \n\n12.)	Pengguna dilarang menggunakan Platform Indonesia Resto Guide untuk tujuan komersial dan melakukan transfer/menjual akun Pengguna ke Pengguna lain atau ke pihak lain dengan tujuan apapun. \n\n13.)	Pengguna wajib menghargai hak-hak Pengguna lainnya dengan tidak memberikan informasi pribadi ke pihak lain tanpa izin pihak yang bersangkutan. \n\n14.)	Pengguna wajib membaca, memahami serta mengikuti semua ketentuan yang diatur dalam Aturan Penggunaan ini.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Ketentuan Lain', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('1.)	Apabila pengguna mempergunakan fitur/layanan yang tersedia dalam Website/Aplikasi Indonesia Resto Guide, maka Pengguna dengan ini menyatakan telah memahami dan menyetujui segala syarat dan ketentuan yang diatur khusus sehubungan dengan fitur/layanan yang digunakan. \n\n2.)	Segala hal yang belum dan/atau tidak diatur dalam syarat dan ketentuan khusus dalam fitur tersebut maka akan sepenuhnya merujuk pada syarat dan ketentuan Indonesia Resto Guide secara umum. \n\n3.)	Dengan menyetujui Syarat dan Ketentuan, maka Pengguna telah dianggap paham dan mengikuti Kebijakan Privasi Indonesia Resto Guide.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.justify, ),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Pembaruan & Perubahan Aturan Penggunaan', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                          //                       Text('Indonesia Resto Guide memiliki hak untuk melakukan pembaruan dan/atau perubahan Aturan Penggunaan dari waktu ke waktu jika diperlukan demi keamanan dan kenyamanan Pengguna di Platform Indonesia Resto Guide. Pengguna harus setuju untuk membaca secara saksama dan memeriksa Aturan Penggunaan ini dari waktu ke waktu untuk mengetahui pembaruan dan/atau perubahan apapun. Dengan tetap mengakses dan menggunakan layanan Indonesia Resto Guide, maka pengguna dianggap menyetujui perubahan-perubahan dalam Syarat & Ketentuan kami.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start, ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //                 actions: <Widget>[
                          //                   Center(
                          //                     child: Row(
                          //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //                       children: [
                          //                         // FlatButton(
                          //                         //   // minWidth: CustomSize.sizeWidth(context),
                          //                         //   color: CustomColor.redBtn,
                          //                         //   textColor: Colors.white,
                          //                         //   shape: RoundedRectangleBorder(
                          //                         //       borderRadius: BorderRadius.all(Radius.circular(10))
                          //                         //   ),
                          //                         //   child: Text('Batal'),
                          //                         //   onPressed: () async{
                          //                         //     setState(() {
                          //                         //       // codeDialog = valueText;
                          //                         //       Navigator.pop(context);
                          //                         //     });
                          //                         //   },
                          //                         // ),
                          //                         FlatButton(
                          //                           color: CustomColor.primaryLight,
                          //                           textColor: Colors.white,
                          //                           shape: RoundedRectangleBorder(
                          //                               borderRadius: BorderRadius.all(Radius.circular(10))
                          //                           ),
                          //                           child: Text('Setuju'),
                          //                           onPressed: () async{
                          //                             Navigator.pop(context);
                          //                             terms = true;
                          //                             setState(() {});
                          //                           },
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   ),
                          //
                          //                 ],
                          //               );
                          //             });
                          //       },
                          //       child: CustomText.bodyMedium16(
                          //           text: "Terms Conditions",
                          //           maxLines: 1,
                          //           minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                          //           color: Colors.black,
                          //           decoration: TextDecoration.underline
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) * 0.005,
                          // ),
                          // Align(
                          //   alignment: Alignment.bottomRight,
                          //   child: CustomText.bodyMedium16(
                          //       text: "Forgot Password",
                          //       color: CustomColor.primary,
                          //       maxLines: 1
                          //   ),
                          // ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 24,
                          ),
                          (isLoading != true)?GestureDetector(
                            onTap: (){
                              if (_loginTextEmail.text == '' || _loginTextPassword.text == '') {
                                Fluttertoast.showToast(msg: "Please fill in your email and password");
                              } else {
                                // if (terms == false) {
                                //   Fluttertoast.showToast(msg: "Baca lalu setujui Terms Conditions untuk melanjutkan.");
                                // } else {
                                //   idPlayer().whenComplete(() {
                                //     terms = true;
                                //     setState(() {});
                                //     _login(_loginTextEmail.text, _loginTextPassword.text);
                                //   });
                                // }
                                FocusScope.of(context).requestFocus(new FocusNode());
                                setState((){});
                                _login(_loginTextEmail.text, _loginTextPassword.text);
                              }
                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 12,
                              width: CustomSize.sizeWidth(context) ,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Center(
                                child: MediaQuery(
                                  child: CustomText.bodyMedium16(
                                      text: "Log in",
                                      maxLines: 1,
                                      color: Colors.white,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                              ),
                            ),
                          ):Container(
                            height: CustomSize.sizeHeight(context) / 12,
                            width: CustomSize.sizeWidth(context) ,
                            decoration: BoxDecoration(
                                color: CustomColor.primary,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                color: CustomColor.primaryLight,
                              ),
                            ),
                          ),

                          // Container(
                          //   alignment: Alignment.center,
                          //   child: Image.asset(
                          //     "assets/irgLogo.png",
                          //     width: CustomSize.sizeWidth(context) / 1.4,
                          //     height: CustomSize.sizeWidth(context) / 1.4,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) / 54,
                          // ),
                          // Center(
                          //   child: Container(
                          //     alignment: Alignment.topCenter,
                          //     width: CustomSize.sizeWidth(context) / 1.1,
                          //     child: MediaQuery(child: CustomText.textHeading8(text: "Indonesia Resto Guide", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.07).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.07).toString())),
                          //       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),),
                          //   ),
                          // ),

                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          Divider(),
                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) * 0.005,
                          // ),
                          GestureDetector(
                            onTap: (){
                              // if (terms == false) {
                              //   Fluttertoast.showToast(msg: "Baca lalu setujui Terms Conditions untuk melanjutkan.");
                              // } else {
                              //   idPlayer().whenComplete(() {
                              //     terms = true;
                              //     setState(() {});
                              //     _handleSignIn();
                              //   });
                              // }
                              FocusScope.of(context).requestFocus(new FocusNode());
                              setState((){});
                              _handleSignIn();
                            },
                            child: Container(
                              height: CustomSize.sizeHeight(context) / 12,
                              width: CustomSize.sizeWidth(context) ,
                              decoration: BoxDecoration(
                                  color: CustomColor.primary,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icon_google.png",
                                    width: CustomSize.sizeWidth(context) / 14,
                                    height: CustomSize.sizeWidth(context) / 14,
                                  ),
                                  MediaQuery(
                                    child: CustomText.bodyMedium16(
                                        text: " Sign in with Google",
                                        maxLines: 1,
                                        color: Colors.white,
                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                    ),
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                          (message != '')?Center(child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                            child: CustomText.bodyMedium16(text: (message != 'email existed')?message:'email telah digunakan', maxLines: 10, color: CustomColor.redBtn),
                          )):Container(),
                          SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MediaQuery(
                                child: CustomText.bodyRegular15(
                                    text: "Don't have an account?",
                                    maxLines: 1,
                                    color: Colors.black,
                                    sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                ),
                                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: RegistActivity()));
                                },
                                child: MediaQuery(
                                  child: CustomText.bodyRegular15(
                                      text: " Sign up",
                                      maxLines: 1,
                                      color: CustomColor.primary,
                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
                                  ),
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 86,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRightWithFade,
                                child: WelcomeScreen()));
                      },
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 7,
                        height: CustomSize.sizeWidth(context) / 7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 7,
                              offset: Offset(0, 7), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(child: Icon(Icons.chevron_left, size: 38,)),
                      ),
                    ),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
