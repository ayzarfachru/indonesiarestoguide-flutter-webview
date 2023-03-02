import 'dart:convert';
import 'dart:typed_data';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:kam5ia/ui/ngupon_yuk/ngupon_yuk_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HorizontalCouponExample2 extends StatefulWidget {
  int hargaNgupon = 0;
  int id = 0;

  HorizontalCouponExample2(this.hargaNgupon, this.id, {Key? key}) : super(key: key);

  @override
  _HorizontalCouponExample2 createState() => _HorizontalCouponExample2(hargaNgupon, id);
}

class _HorizontalCouponExample2 extends State<HorizontalCouponExample2> {
  int hargaNgupon = 0;
  int id = 0;
  bool wait = false;
  _HorizontalCouponExample2(this.hargaNgupon, this.id);

  TextEditingController kodeRef = TextEditingController(text: '');

  Future _getNguponYuk()async{
    setState(() {
      wait = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");

    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy&restaurant_id=$id'), headers: {
      // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=buy&restaurant_id=$id'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print('_getNguponYuk');
    print(data.toString());

    for(var v in data['data']){
      if (v['restaurant_id'].toString() == id.toString()) {
        couponId = v['id'].toString();
        // statusNgupon = v['status'].toString();
        if (v['status'].toString() == 'available') {
          // isNgupon = true;
          hargaNgupon = int.parse(v['price'].toString());
        }
      }
    }

    wait = false;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
            content: Text('Kupon baru dapat digunakan 1 hari setelah pembelian anda!\n\nApakah anda yakin ingin membeli kupon ini?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                      child: Text('Tidak', style: TextStyle(color: Colors.white)),
                      onPressed: () async{
                        Navigator.pop(context);
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
                      child: Text('Iya', style: TextStyle(color: Colors.white)),
                      onPressed: () async{
                        Navigator.pop(context);
                        Navigator.pop(context);
                        if (wait == false) {
                        _checkoutNguponYuk();
                        Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                        } else {
                          Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

            ],
          );
        });

    setState(() {});
  }

  String couponId = '';
  Future _getNguponYukRef(String ref)async{
    setState(() {
      wait = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");

    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy&restaurant_id=$id&ref_code=${ref.replaceAll('#', '')}'), headers: {
      // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=buy&restaurant_id=$id&ref_code=${ref.replaceAll('#', '')}'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print('_getNguponYukKode');
    print(Links.nguponUrl + '/kupon?action=buy&restaurant_id=$id&ref_code=${ref.replaceAll('#', '')}');
    print(data.toString());

    if (data['data'].toString() == '[]') {
      wait = false;
      Fluttertoast.showToast(
        msg: "Kode tidak tersedia!",);
    } else {
      wait = false;
      for(var v in data['data']){
        if (v['restaurant_id'].toString() == id.toString()) {
          couponId = v['id'].toString();
          print('couponId');
          print(couponId);
          // statusNgupon = v['status'].toString();
          if (v['status'].toString() == 'available') {
            // isNgupon = true;
            hargaNgupon = int.parse(v['price'].toString());
          }
        }
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
              content: Text('Kupon baru dapat digunakan 1 hari setelah pembelian anda!\n\nApakah anda yakin ingin membeli kupon ini?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                        child: Text('Tidak', style: TextStyle(color: Colors.white)),
                        onPressed: () async{
                          Navigator.pop(context);
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
                        child: Text('Iya', style: TextStyle(color: Colors.white)),
                        onPressed: () async{
                          Navigator.pop(context);
                          Navigator.pop(context);
                          if (wait == false) {
                            _checkoutNguponYukRef(ref);
                            Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                          } else {
                            Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                          }
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

    setState(() {});
  }


  Future _checkoutNguponYuk()async{
    setState(() {
      wait = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.post(Uri.parse(Links.nguponUrl + '/kupon'),
        body: {
          'email' : email,
          'batch_id' : couponId,
          'action' : 'new',
          'restaurant' : id.toString(),
        },
        headers: {
      // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.post(Uri.parse(Links.secondNguponUrl + '/kupon'),
          body: {
            'email' : email,
            'batch_id' : couponId,
            'action' : 'new',
            'restaurant' : id.toString(),
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
          data = json.decode(apiResultSecond.body);
          print('_apiResultSecond data 2');
          // print(data);
          setState((){});
        } else {
          print('_apiResultSecond success');
        }
    print('_checkoutNguponYuk');
    print(data.toString());

    _getUnpaidNguponYuk();
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.rightToLeft,
    //         child: new NguponYukActivity()));
    setState(() {});
  }

  Future _checkoutNguponYukRef(String ref_code)async{
    setState(() {
      wait = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.post(Uri.parse(Links.nguponUrl + '/kupon'),
        body: {
          'email' : email,
          'batch_id' : couponId,
          'action' : 'new',
          'restaurant' : id.toString(),
          'ref_code' : ref_code.toString(),
        },
        headers: {
      // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.post(Uri.parse(Links.secondNguponUrl + '/kupon'),
          body: {
            'email' : email,
            'batch_id' : couponId,
            'action' : 'new',
            'restaurant' : id.toString(),
            'ref_code' : ref_code.toString(),
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print('_checkoutNguponYuk');
    print(data.toString());

    _getUnpaidNguponYuk();
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.rightToLeft,
    //         child: new NguponYukActivity()));
    setState(() {});
  }

  Future _checkUnpaidNguponYuk()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    setState(() {
      wait = true;
    });
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_checkUnpaidNguponYuk');
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=use&user=$email'), headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print(data['data']['unpaid']);

    if (data['data']['unpaid'].toString() != '[]') {
      wait = false;
      Fluttertoast.showToast(
          msg: "Kupon anda sebelumnya belum terbayar!",);
      setState(() {});
    } else {
      wait = false;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
              content: Text('Apakah anda menggunakan kode referral?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              actions: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        // minWidth: CustomSize.sizeWidth(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.all(0),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                        ),
                        child: Text('Tidak', style: TextStyle(color: Colors.white)),
                        onPressed: () async{
                          if (wait == false) {
                            _getNguponYuk();
                          } else {
                            Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                          }
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
                        child: Text('Iya', style: TextStyle(color: Colors.white)),
                        onPressed: () async{
                          if (wait == false) {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    title: Text('Kode Referral'),
                                    content: TextField(
                                      autofocus: true,
                                      keyboardType: TextInputType.text,
                                      controller: kodeRef,
                                      decoration: InputDecoration(
                                        hintText: "Masukkan Kode Referral",
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
                                                setState(() {});
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
                                                if (wait == false) {
                                                  _getNguponYukRef(kodeRef.text);
                                                } else {
                                                  Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                                                }
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  );
                                });
                          } else {
                            Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                          }
                        },
                      ),
                    ],
                  ),
                ),

              ],
            );
          });
      setState(() {});
    }
  }

  Future _getUnpaidNguponYuk()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=use&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getUnpaidNguponYuk');
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.get(Uri.parse(Links.secondNguponUrl + '/kupon?action=use&user=$email'), headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
      data = json.decode(apiResultSecond.body);
      print('_apiResultSecond data 2');
      // print(data);
      setState((){});
    } else {
      print('_apiResultSecond success');
    }
    print(data['data']['unpaid']);

    for (var h in data['data']['unpaid']) {
      Fluttertoast.showToast(
        msg: "Tunggu sebentar!",);
      _getQrBCA(int.parse(h['id'].toString()), int.parse(h['price'].toString()));

      // NguponYuk c = NguponYuk(
      //     id: int.parse(h['id'].toString()),
      //     price: h['price'].toString(),
      //     status: h['status'],
      //     date: DateFormat('H:m / d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
      // );
      // nguponYuk.add(c);
    }
  }

  late String _base64 = "";
  bool isLoadChekPay = false;
  bool loadQr = false;
  Future<void> _getQrBCA(int trx_id, int amount)async{
    // List<Menu> _menu = [];

    setState(() {
      loadQr = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String email = (pref.getString('email')??'');
    var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/bca/generate'),
        body: {'app_id': 'NGY', 'trx_id': trx_id.toString(), 'amount': (amount+1000).toString()},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    var data = json.decode(apiResult.body);
    print('QR CODE');
    print(data);
    print(data['response']['qr_image']);
    _base64 = data['response']['qr_image'];
    Uint8List bytes = Base64Codec().decode(_base64);

    if (_base64 != '') {
      wait = false;
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
                  child: FullScreenWidget(
                    child: Image.memory(bytes,
                      width: CustomSize.sizeWidth(context) / 1.2,
                      height: CustomSize.sizeWidth(context) / 1.2,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: CustomSize.sizeWidth(context) / 1.2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText.textTitle2(
                            text: 'Total harga:',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                        CustomText.textTitle2(
                            text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((amount+1000).toString())),
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: CustomSize.sizeWidth(context) / 1.2,
                    child: CustomText.textTitle1(
                        text: 'Scan disini untuk melakukan pembayaran',
                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                        maxLines: 1
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: CustomSize.sizeWidth(context) / 1.2,
                    child: CustomText.textTitle1(
                        text: 'Tambahan biaya transaksi sebesar Rp1.000',
                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                        maxLines: 3
                    ),
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                GestureDetector(
                  onTap: ()async{
                    if (isLoadChekPay != true) {
                      if (wait == false) {
                        _checkPayBCA(trx_id);
                      } else {
                        Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                      }
                      setState(() {});
                    }
                    // Fluttertoast.showToast(
                    //   msg: "Anda belum membayar!",);
                  },
                  child: Center(
                    child: Container(
                      width: CustomSize.sizeWidth(context) / 1.1,
                      height: CustomSize.sizeHeight(context) / 14,
                      decoration: BoxDecoration(
                          color: CustomColor.primaryLight,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomText.textTitle3(text: "Cek Pembayaran", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
    // for(var v in data['menu']){
    //   Menu p = Menu(
    //       id: v['id'],
    //       name: v['name'],
    //       desc: v['desc'],
    //       urlImg: v['img'],
    //       type: v['type'],
    //       is_recommended: v['is_recommended'],
    //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
    //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
    //   );
    //   _menu.add(p);
    // }
    setState(() {
      // loadQr = false;
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  String statusPay = '';
  Future<void> _checkPayBCA(int trx_id)async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=NGY&trx_id=$trx_id'),
      // var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=NGY&trx_id=$id'),
      // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
      // headers: {
      //   "Accept": "Application/json",
      //   "Authorization": "Bearer $token"
      // }
    );
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
      // _checkoutNguponYuk(trx_id);
      wait = false;
    } else {
      statusPay = 'false';

      wait = false;
      _checkoutNguponYukSecond(trx_id);
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
    }
    setState(() {
      isLoadChekPay = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  Future _checkoutNguponYukSecond(int trx_id)async{
    setState(() {});

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.post(Uri.parse(Links.nguponUrl + '/kupon'),
        body: {
          'email' : email,
          'batch_id' : trx_id.toString(),
          'action' : 'paid',
        },
        headers: {
          // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    if (apiResult.statusCode.toString() != '200') {
      var apiResultSecond = await http.post(Uri.parse(Links.secondNguponUrl + '/kupon'),
          body: {
            'email' : email,
            'batch_id' : trx_id.toString(),
            'action' : 'paid',
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
          data = json.decode(apiResultSecond.body);
          print('_apiResultSecond data 2');
          // print(data);
          setState((){});
        } else {
          print('_apiResultSecond success');
        }
    print('_checkoutNguponYukSecond');
    print(data.toString());

    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: new NguponYukActivity()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xfff1e3d3);
    const Color secondaryColor = Color(0xffd88c9a);

    return CouponCard(
      width: CustomSize.sizeWidth(context) / 1.1,
      height: CustomSize.sizeHeight(context) / 4.4,
      backgroundColor: CustomColor.secondary,
      clockwise: true,
      curvePosition: 135,
      curveRadius: 30,
      curveAxis: Axis.vertical,
      borderRadius: 10,
      firstChild: Container(
        decoration: BoxDecoration(
          color: CustomColor.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText.textTitle8(text: 'Rp'+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(hargaNgupon.toString())), minSize: double.parse(((MediaQuery.of(context).size.width*0.0575).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.0575)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.0575)).toString()), color: Colors.white),
                    // Text(
                    //   'Rp50.000',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // Text(
                    //   'RUPIAH',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white54, height: 0),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    if (wait == false) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              insetPadding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.025),
                              contentPadding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              // title: Center(child: Text('NGUPON YUK!', style: TextStyle(color: CustomColor.primary))),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FullScreenWidget(
                                    backgroundIsTransparent: true,
                                    child: Image.asset(
                                      "assets/NguponYuk.png",
                                      width: CustomSize.sizeWidth(context) / 1,
                                      // height: CustomSize.sizeWidth(context),
                                    ),
                                  ),
                                  // Text('Makan bayar Rp0, bahkan mendapatkan penghasilan!\n\nLangkah-langkah:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                                  // Text('1. Beli kupon makan senilai Rp.500.000 (10 kupon senilai Rp.50.000)\n2. Cukup bayar senilai Rp.375.000 (diskon 25%)\n3. Kupon berlaku hanya 3 bulan\n4. Setelah anda membeli, maka akan mendapatkan kode referral yang berusia selama 1 tahun\n5. Ajak 10 teman anda untuk ikut membeli dengan menggunakan kode referral anda\n6. Setelah tercapai 10 pembelian yang menggunakan kode referral anda, maka:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                                  // Padding(
                                  //   padding: EdgeInsets.only(left: 10, right: 10),
                                  //   child: Text('- Pengembalian dana awal anda sebesar Rp.375.000 (tahap ini anda sudah makan senilai Rp.500.000 dengan tanpa bayar)\n- Pemberian bonus kupon makan lagi senilai Rp.500.000 (tahap ini anda bisa mendapatkan penghasilan)', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                                  // ),
                                  // Text('7. Kupon ini hanya dapat digunakan di resto ini beserta cabangnya\n8. Kupon tidak dapat diuangkan\n9. Kupon tidak dapat memberikan pengembalian pembayaran anda dibawah nilai kupon', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                                ],
                              ),
                              // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                              actions: <Widget>[
                                Row(
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
                                        setState(() {});
                                      },
                                    ),
                                    TextButton(
                                      // minWidth: CustomSize.sizeWidth(context),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        padding: EdgeInsets.all(0),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                      ),
                                      child: Text('Lanjutkan', style: TextStyle(color: Colors.white)),
                                      onPressed: () async{
                                        Navigator.pop(context);
                                        if (wait == false) {
                                          _checkUnpaidNguponYuk();
                                        } else {
                                          Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),

                              ],
                            );
                          }
                      );
                    } else {
                      Fluttertoast.showToast(msg: 'Tunggu sebentar!');
                    }
                  },
                  child: Text(
                    'BELI KUPON\nDISINI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      secondChild: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   ' ',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 13,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black54,
            //   ),
            // ),
            SizedBox(height: 4),
            Text(
              'NGUPON YUK',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: CustomColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            GestureDetector(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        insetPadding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.025),
                        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        // title: Center(child: Text('NGUPON YUK!', style: TextStyle(color: CustomColor.primary))),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FullScreenWidget(
                              backgroundIsTransparent: true,
                              child: Image.asset(
                                "assets/NguponYuk.png",
                                width: CustomSize.sizeWidth(context) / 1,
                                // height: CustomSize.sizeWidth(context),
                              ),
                            ),
                            // Text('Makan bayar Rp0, bahkan mendapatkan penghasilan!\n\nLangkah-langkah:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.start),
                            // Text('1. Beli kupon makan senilai Rp.500.000 (10 kupon senilai Rp.50.000)\n2. Cukup bayar senilai Rp.375.000 (diskon 25%)\n3. Kupon berlaku hanya 3 bulan\n4. Setelah anda membeli, maka akan mendapatkan kode referral yang berusia selama 1 tahun\n5. Ajak 10 teman anda untuk ikut membeli dengan menggunakan kode referral anda\n6. Setelah tercapai 10 pembelian yang menggunakan kode referral anda, maka:', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 10, right: 10),
                            //   child: Text('- Pengembalian dana awal anda sebesar Rp.375.000 (tahap ini anda sudah makan senilai Rp.500.000 dengan tanpa bayar)\n- Pemberian bonus kupon makan lagi senilai Rp.500.000 (tahap ini anda bisa mendapatkan penghasilan)', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                            // ),
                            // Text('7. Kupon ini hanya dapat digunakan di resto ini beserta cabangnya\n8. Kupon tidak dapat diuangkan\n9. Kupon tidak dapat memberikan pengembalian pembayaran anda dibawah nilai kupon', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                          ],
                        ),
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
                setState(() {});
              },
              child: Container(
                width: CustomSize.sizeWidth(context) / 6.5,
                height: CustomSize.sizeHeight(context) / 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CustomColor.primary)
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                  child: Center(
                    child: CustomText.textTitle8(
                        text: "Pelajari",
                        color: CustomColor.primary,
                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Text(
              'Kupon berlaku selama 1 tahun',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}