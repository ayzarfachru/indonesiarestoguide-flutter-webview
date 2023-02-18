import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'ngupon_yuk_activity.dart';

class NguponYukPaid extends StatefulWidget {
  @override
  _NguponYukPaidState createState() => _NguponYukPaidState();
}

class _NguponYukPaidState extends State<NguponYukPaid> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  String img = "";

  bool isLoading = false;
  bool ksg = false;

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img')??'');
      print(img);
    });
  }

  // /page/history?resto=$id
  List number = [];
  List<NguponYuk> nguponYuk = [];
  Future _getNguponYuk()async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYuk');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for (var h in data['data']['paid']) {
      NguponYuk c = NguponYuk.sub(
          id: int.parse(h['id'].toString()),
          code: h['code'].toString(),
          price: h['value'].toString(),
          status: h['status'],
          date: DateFormat('y-MM-dd').format(DateTime.parse(h['updated_at'].toString())).toString(),
          expired: DateFormat('y-MM-dd').format(DateTime.parse(h['expired_at'].toString())).toString(),
      );
      if (number.toString() == '[]') {
        number.add(1);
      } else {
        number.add((int.parse(number.last.toString())+1));
      }
      nguponYuk.add(c);
    }

    // for(var v in data['trans']){
    //   History h = History(
    //     id: v['id'],
    //     name: v['resto_name'],
    //     time: v['time'],
    //     price: v['price'],
    //     img: v['resto_img'],
    //     type: v['type'],
    //     status: v['status'],
    //   );
    //   _history.add(h);
    // }

    setState(() {
      isLoading = false;
    });

    if (apiResult.statusCode == 200) {
      if (nguponYuk.toString() == '[]') {
        ksg = true;
      } else {
        ksg = false;
      }
    }
  }

  void Mailer(String emailShare, String harga) async {
    String myEmail = '';
    String myName = '';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      myEmail = (pref.getString('email')??'');
      myName = (pref.getString('name')??'');
      print(myEmail);
    });

    String username = 'sender.imajicipta@gmail.com';
    String password = 'ewjdxowvqqkdaxko';
    // String password = 'imajiciptasurabaya70';
    print(username);
    print(password);

    final smtpServer = gmail(username, password);

    //Create our Message
    final message = Message()
      ..from = Address(username, myEmail)
      ..recipients.add(emailShare)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Berbagi Ngupon Yuk!'
      ..text = 'Hai pengguna IRG, saya $myName membagikan kupon pembelian makanan atau minuman senilai $harga kepada kamu.\n Cek di aplikasi IRG sekarang!';
    var yourHtmlTemplate= 'Hai pengguna IRG, saya $myName membagikan kupon pembelian makanan atau minuman senilai $harga kepada kamu.\n Cek di aplikasi IRG sekarang!';
    message.html = yourHtmlTemplate;


    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print(e);
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future _bagikanNguponYuk(String idShare, String emailShare, String harga)async{
    setState(() {});

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.put(Uri.parse(Links.nguponUrl + '/kupon/$idShare'),
        body: {
          'email' : emailShare,
        },
        headers: {
          // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    print('_bagikanNguponYuk');
    print(data.toString());

    Mailer(emailShare, harga);
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: new NguponYukActivity()));
    setState(() {});
  }

  String? id;

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (homepg != '1') {
        _getNguponYuk();
      } else {
        idResto();
      }
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  TextEditingController email = TextEditingController(text: '');

  void _onRefresh() async {
    // monitor network fetch
    _getNguponYuk();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  bool isQrKupon = false;
  QrKupon(String qrKupon, String idQr, String codeQr, bool isQr, String harga) async {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
        ),
        context: context,
        builder: (_){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                child: Divider(thickness: 4,),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 106,),
              // Center(
              //   child: CustomText.textHeading2(
              //       text: "Qris",
              //       minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
              //       maxLines: 1
              //   ),
              // ),
              // SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
              Center(
                child: Container(
                  width: CustomSize.sizeWidth(context) / 1.2,
                  height: CustomSize.sizeWidth(context) / 1.2,
                  child: FullScreenWidget(
                    backgroundColor: Colors.white,
                    child: Center(
                      child: (isQr == true)?QrImage(
                        data: qrKupon,
                        version: QrVersions.auto,
                        size: 320,
                        gapless: false,
                      ):Container(color: Colors.grey),
                    ),
                  ),
                ),
                // FullScreenWidget(
                //   child: Image.memory(bytes,
                //     width: CustomSize.sizeWidth(context) / 1.2,
                //     height: CustomSize.sizeWidth(context) / 1.2,
                //   ),
                //   backgroundColor: Colors.white,
                // ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 88,),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: CustomSize.sizeWidth(context) / 1.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CustomText.textTitle2(
                      //     text: 'Total harga:',
                      //     minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                      //     maxLines: 1
                      // ),
                      // CustomText.textTitle2(
                      //     text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((amount+1000).toString())),
                      //     minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                      //     maxLines: 1
                      // ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: CustomSize.sizeWidth(context) / 1.2,
                  child: CustomText.textTitle8(
                      text: codeQr,
                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                      maxLines: 1
                  ),
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: CustomSize.sizeWidth(context) / 1.2,
                  child: CustomText.textTitle1(
                      text: (isQr == true)?'Scan disini untuk melakukan pembayaran':'Baru bisa digunakan H+1 setelah pembelian kupon!',
                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                      maxLines: 1
                  ),
                ),
              ),
              (isQr == true)?Center(
                child: Container(
                  alignment: Alignment.center,
                  width: CustomSize.sizeWidth(context) / 1.2,
                  child: CustomText.textTitle1(
                      text: 'menggunakan Ngupon Yuk',
                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                      maxLines: 3
                  ),
                ),
              ):Container(),
              SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: CustomSize.sizeWidth(context) / 1.2,
                  child: CustomText.textTitle1(
                      text: 'Peringatan! Jangan membagikan qr anda\n secara sembarangan.',
                      color: CustomColor.redBtn,
                      align: 1,
                      minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                      maxLines: 3
                  ),
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              GestureDetector(
                onTap: ()async{
                  // if (isLoadChekPay != true) {
                  //   _checkPayBCA(trx_id);
                  // }
                  // Fluttertoast.showToast(
                  //   msg: "Anda belum membayar!",);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          title: Text('Masukkan Email'),
                          content: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            controller: email,
                            decoration: InputDecoration(
                              hintText: "Masukkan email pengguna",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    // minWidth: CustomSize.sizeWidth(context),
                                    style: TextButton.styleFrom(
                                      backgroundColor: CustomColor.redBtn,
                                      padding: EdgeInsets.all(0),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                    ),
                                    child: Text('Batal', style: TextStyle(color: Colors.white)),
                                    onPressed: () async{
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    // minWidth: CustomSize.sizeWidth(context),
                                    style: TextButton.styleFrom(
                                      backgroundColor: CustomColor.accent,
                                      padding: EdgeInsets.all(0),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                    ),
                                    child: Text('Kirim', style: TextStyle(color: Colors.white)),
                                    onPressed: () async{
                                      if (email.text != '') {
                                        Navigator.pop(context);
                                        _bagikanNguponYuk(idQr, email.text, harga);
                                      }
                                      // _getNguponYukRef(kodeRef.text);
                                    },
                                  ),
                                ],
                              ),
                            ),

                          ],
                        );
                      });
                },
                child: Center(
                  child: Container(
                    width: CustomSize.sizeWidth(context) / 1.1,
                    height: CustomSize.sizeHeight(context) / 14,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText.textTitle3(text: "Bagikan Kupon", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            GestureDetector(
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                                      content: Text('Bagikan kupon anda kepada pengguna lain dengan cara memasukkan email pengguna lain yang akan menerima kupon anda.\n\nKupon anda otomatis akan berkurang setelah anda bagikan.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                      // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                      actions: <Widget>[
                                        Center(
                                          child: TextButton(
                                            // minWidth: CustomSize.sizeWidth(context),
                                            style: TextButton.styleFrom(
                                              backgroundColor: CustomColor.accent,
                                              padding: EdgeInsets.all(0),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                            child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                            onPressed: () async{
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),

                                      ],
                                    );
                                  }
                                );
                              },
                              child: FaIcon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 54,),
              // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
            ],
          );
        }
    );
  }

  idResto() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    id = pref.getString("idresto");
    print('NGAB '+id.toString());
  }

  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // countChat();
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
    Navigator.pop(context);
    return Future.value(true);
  }

  String formattedDate = DateFormat('y-MM-dd').format(DateTime.now());

  @override
  void initState() {
    getHomePg();
    getImg();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
        body: SafeArea(
          child: (ksg != true)?SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: nguponYuk.length,
                      itemBuilder: (_, index){
                        return Column(
                          children: [
                            SizedBox(
                              height: CustomSize.sizeHeight(context) / 86,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText.bodyMedium16a(
                                  textAlign: TextAlign.left,
                                  sizeNew: double.parse(
                                      ((MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()
                                          .contains('.') ==
                                          true)
                                          ? (MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()
                                          .split('.')[0]
                                          : (MediaQuery.of(context).size.width *
                                          0.03)
                                          .toString()),
                                  // text: DateFormat("d MMM yyyy - HH:mm").format(
                                  //     DateTime.parse(nguponYuk[index].date.toString())),
                                  text: number[index].toString(),
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText.bodyMedium16a(
                                              textAlign: TextAlign.left,
                                              text: nguponYuk[index].code,
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()),
                                            ),
                                            CustomText.bodyMedium16c(
                                              textAlign: TextAlign.right,
                                              text: NumberFormat.currency(
                                                  locale: 'id',
                                                  symbol: 'Rp. ',
                                                  decimalDigits: 0)
                                                  .format(int.parse(nguponYuk[index].price.toString())),
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03)
                                                      .toString()),
                                              color: (nguponYuk[index].status == "reserved")
                                                  ? CustomColor.redBtn
                                                  : CustomColor.accent,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText.bodyMedium16a(
                                              textAlign: TextAlign.left,
                                              sizeNew: double.parse(
                                                  ((MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                      true)
                                                      ? (MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()
                                                      .split('.')[0]
                                                      : (MediaQuery.of(context).size.width *
                                                      0.03)
                                                      .toString()),
                                              // text: DateFormat("d MMM yyyy - HH:mm").format(
                                              //     DateTime.parse(nguponYuk[index].date.toString())),
                                              text: 'Berlaku sampai: '+nguponYuk[index].date.toString(),
                                              color: Colors.grey,
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                String harga = NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp. ',
                                                    decimalDigits: 0)
                                                    .format(int.parse(nguponYuk[index].price.toString())).toString();
                                                if (int.parse(nguponYuk[index].date.toString().replaceAll('-', '').toString()) < int.parse(formattedDate!.replaceAll('-', '').toString())) {
                                                  QrKupon(nguponYuk[index].code.toString(), nguponYuk[index].id.toString(), nguponYuk[index].code.toString(), true, harga);
                                                } else {
                                                  QrKupon(nguponYuk[index].code.toString(), nguponYuk[index].id.toString(), nguponYuk[index].code.toString(), false, harga);
                                                }
                                                // _getQrBCA(int.parse(nguponYuk[index].id.toString()), int.parse(nguponYuk[index].price.toString()));
                                              },
                                              child: Container(
                                                // height: CustomSize.sizeHeight(context) / 24,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: CustomColor.accent)
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.03, vertical: CustomSize.sizeHeight(context) * 0.005),
                                                  child: Center(
                                                    child: CustomText.textTitle8(
                                                        text: "Lihat",
                                                        color: CustomColor.accent,
                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        );
                      }
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                ],
              ),
            ),
          ):Container(child: CustomText.bodyMedium12(text: "kosong", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())), alignment: Alignment.center, height: CustomSize.sizeHeight(context),),
        ),
        // floatingActionButton: GestureDetector(
        //   onTap: (){
        //     // Navigator.push(
        //     //     context,
        //     //     PageTransition(
        //     //         type: PageTransitionType.rightToLeft,
        //     //         child: CartActivity()));
        //   },
        //   child: Container(
        //     width: CustomSize.sizeWidth(context) / 6.6,
        //     height: CustomSize.sizeWidth(context) / 6.6,
        //     decoration: BoxDecoration(
        //         color: CustomColor.primary,
        //         shape: BoxShape.circle
        //     ),
        //     child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 30,)),
        //   ),
        // )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
