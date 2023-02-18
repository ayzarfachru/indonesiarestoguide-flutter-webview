import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:full_screen_image/full_screen_image.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/model/NguponYuk.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ngupon_yuk_activity.dart';

class NguponYukUsed extends StatefulWidget {
  @override
  _NguponYukUsedState createState() => _NguponYukUsedState();
}

class _NguponYukUsedState extends State<NguponYukUsed> {
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
    var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=used&user=$email'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('_getNguponYuk');
    var data = json.decode(apiResult.body);
    print(data);

    if (data['data'].toString() != '[]') {
      for (var h in data['data']) {
        NguponYuk c = NguponYuk(
            id: int.parse(h['id'].toString()),
            price: h['value'].toString(),
            status: h['status'],
            date: DateFormat('H:m / d-M-y').format(DateTime.parse(h['updated_at'].toString())).toString()
        );
        if (number.toString() == '[]') {
          number.add(1);
        } else {
          number.add((int.parse(number.last.toString())+1));
        }
        nguponYuk.add(c);
      }
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

  late String _base64 = "";
  bool isLoadChekPay = false;
  bool loadQr = false;
  Future<void> _getQrBCA(int trx_id, int amount)async{
    // List<Menu> _menu = [];

    setState(() {
      loadQr = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
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
                      _checkPayBCA(trx_id);
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
      loadQr = false;
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
    if (data['response']['detail_info'].toString().contains('Unpaid') != true) {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
      // _checkoutNguponYuk(trx_id);
    } else {
      statusPay = 'false';

      _checkoutNguponYuk(trx_id);
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

  Future _checkoutNguponYuk(int trx_id)async{
    setState(() {});

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    pref.setString("homepg", "");
    String email = (pref.getString('email')??'');

    var apiResult = await http.post(Uri.parse(Links.nguponUrl + '/kupon'),
        body: {
          'email' : email,
          'batch_id' : trx_id.toString(),
          'action' : 'paid'
        },
        headers: {
          // var apiResult = await http.get(Uri.parse(Links.nguponUrl + '/kupon?action=buy'), headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    print('_checkoutNguponYuk');
    print('email'+':'+email+', '+'batch_id'+':'+trx_id.toString()+', '+'action'+':'+'paid');
    print(data.toString());

    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: new NguponYukActivity()));
    setState(() {});
  }

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
                                              text: "✓ Telah digunakan",
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
                                                  .format((int.parse(nguponYuk[index].price.toString()))),
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
                                              color: CustomColor.primary,
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
                                              text: nguponYuk[index].date.toString(),
                                              color: Colors.grey,
                                            ),
                                            Container(
                                              // height: CustomSize.sizeHeight(context) / 24,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: CustomColor.primary)
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) * 0.03, vertical: CustomSize.sizeHeight(context) * 0.005),
                                                child: Center(
                                                  child: CustomText.textTitle8(
                                                      text: "Terpakai",
                                                      color: CustomColor.primary,
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
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
