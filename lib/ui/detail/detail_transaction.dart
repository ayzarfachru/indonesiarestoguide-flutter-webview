import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/ui/cart/cart_activity.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/utils/chat_activity.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTransaction extends StatefulWidget {
  int id;
  String status;
  String note = '';
  String idResto = '';

  DetailTransaction(this.id, this.status, this.note, this.idResto);

  @override
  _DetailTransactionState createState() => _DetailTransactionState(id, status, note, idResto);
}

class _DetailTransactionState extends State<DetailTransaction> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  int id;
  String status;
  String note = '';
  String idResto = '';

  _DetailTransactionState(this.id, this.status, this.note, this.idResto);

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  String type = '';
  String address = '';
  int ongkir = 0;
  int harga = 0;
  int total = 0;
  int totalAll = 0;
  String chatroom = 'null';
  String phone = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Menu> menu = [];
  String menuKurir = '';
  List<String> menu2 = [];
  List<MenuJson> menu3 = [];
  List<String> menu4 = [];
  List<String> menu5 = [];
  String nameRestoTrans = '';
  String restoAddress = '';
  String tungguProses = '';
  Future<void> getData()async{
    List<Menu> _menu = [];
    List<String> _menu2 = [];
    List<MenuJson> _menu3 = [];
    List<String> _menu4 = [];
    List<String> _menu5 = [];

    setState(() {
      if (statusTrans == '') {
        statusTrans = 'pending';
        print('statusTrans');
        print(statusTrans);
      } else if (statusTrans == 'null'){
        print('statusTrans');
        print(statusTrans);
        statusTrans = 'pending';
      }
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    pref.setString('inDetail', '1');

    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/$id'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    print(id);
    print('TRANS?');
    var data = json.decode(apiResult.body);

    for(var v in data['menu']){
      Menu m = Menu(
          id: v['menus_id'],
          qty: v['qty'].toString(),
          price: Price(original: v['price'], discounted: null, delivery: null),
          name: v['name'],
          urlImg: v['image'],
          is_available: '',
          desc: v['desc'], is_recommended: '', restoName: '', type: '', distance: null, restoId: '', delivery_price: null
      );
      if (menuKurir == '') {
        menuKurir = v['name']+': '+v['qty'].toString();
      } else {
        menuKurir = menuKurir+', '+v['name']+': '+v['qty'].toString();
      }
      _menu.add(m);
    }
    for(var v in data['menu']){
      MenuJson j = MenuJson(
        id: v['menus_id'],
        restoId: pref.getString('idnyatransRes')!,
        name: v['name'],
        desc: v['desc'],
        price: v['price'].toString(),
        discount: v['discount'],
        pricePlus: v['pricePlus'],
        urlImg: v['image'], restoName: '', distance: null,
      );
      _menu3.add(j);
    }
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu2.add(v['qty'].toString());
    }
    // _menu3.add(jsonEncode(data['menu']));
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu4.add(v['menus_id'].toString());
      print('ini '+v['menus_id'].toString());
    }
    for(var v in data['menu']){
      // Menu m = Menu.qty(
      //     ['qty'].toString(),
      // );
      _menu5.add(v['name'].toString()+": kam5ia_null}");
    }
    setState(() {
      menu = _menu;
      menu2 = _menu2;
      menu3 = _menu3;
      menu4 = _menu4;
      menu5 = _menu5;
      type = data['trans']['type'];
      // if (type != 'delivery') {
      //   if (data['trans']['total'].toString() == '0') {
      //     _platformfee = 0;
      //   }
      // }

      // else if (type == 'delivery' && statusTrans == 'pending') {
      //   tungguProses = 'true';
      // }
      latUser = data['trans']['lat']??'';
      longUser = data['trans']['long']??'';
      print('LATLONG');
      print(latUser);
      print(longUser);
      address = data['trans']['address']??'';
      ongkir = data['trans']['ongkir'];
      total = data['trans']['total'];
      if (type != 'delivery') {
        if (data['trans']['total'].toString() == '0') {
          _platformfee = 0;
          totalAll = 0;
          isLoadChekPayFirst = false;
          _getDetail(idResto);
          print('&&');
          print(statusTrans);
          if (statusTrans == 'pending' || statusTrans == '') {
            print('&& succ');
            _getPending('process', id.toString());
            statusTrans = 'process';
            pref.setString('statusTrans', 'process');
            setState((){});
          }
        } else {
          totalAll = data['trans']['total']+data['trans']['ongkir'];
          _checkPayFirst();
        }
      } else {
        totalAll = data['trans']['total']+data['trans']['ongkir'];
        _checkPayFirst();
      }
      harga = data['trans']['total'] - data['trans']['ongkir'];
      chatroom = data['chatroom'].toString();
      phone = data['phone_number'].toString();
      print('NO TELP');
      print(phone);
      // phone = data['phone_number'].toString();
      // isLoading = false;
    });
    print(chatroom);
  }

  String emailTokoTrans = '';
  String ownerTokoTrans = '';
  String pjTokoTrans = '';
  String nameNorekTokoTrans = '';
  String bankTokoTrans = '';
  String nameRekening = '';
  String nameBank = '';
  String norekTokoTrans = '';
  String addressRes = '';
  Future<void> _getUserDataResto()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/userdata/'+idResto), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    print('id e '+apiResult.body.toString());
    print('id e '+idResto.toString());
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
      emailTokoTrans = data['email'].toString();
      ownerTokoTrans = data['name_owner'].toString();
      pjTokoTrans = data['name_pj'].toString();
      // bankTokoTrans = data['bank'].toString();
      // nameNorekTokoTrans = data['namaNorek'].toString();
      nameRekening = data['nama_norek'].toString();
      nameBank = data['bank_norek'].toString();
      norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      _getDetail(idResto);
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  String NameDriver = 'Belum mencari';
  String PhoneDriver = '-';
  String PhotoDriver = '';
  String StatusDriver = 'Tunggu sebentar';
  Future<void> _getDriver()async{
    // List<Menu> _menu = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://qurir.devastic.com/api/borzo?transaction_id=IRG-$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print(data);

    print('driver '+apiResult.body.toString());
    print('driver ID '+id.toString());
    print('driver '+idResto.toString());
    if (apiResult.body.toString() != '"not found"') {
      if (data['status'].toString() == 'parcel_picked_up' || data['status'].toString() == 'completed' || data['status'].toString() == 'done') {
        NameDriver = (apiResult.body.toString() != '"not found"')?data['courier']['name'].toString():'Tidak Ditemukan';
        PhoneDriver = (apiResult.body.toString() != '"not found"')?data['courier']['phone'].toString():'0';
        PhotoDriver = (apiResult.body.toString() != '"not found"')?data['courier']['photo'].toString():'';
        // StatusDriver = (apiResult.body.toString() != '"not found"')?(data['status'].toString() != 'active')?'Sudah sampai':data['status'].toString():'Tidak Ditemukan';
        StatusDriver = (apiResult.body.toString() != '"not found"')?data['status'].toString():'Tidak Ditemukan';
        if (statusTrans == 'process') {
          pref.setString("statusTrans", 'ready');
          _getPending('ready', id.toString());
        }
        setState((){});
      } else {
        if (data['courier'].toString().contains('name') == false) {
          StatusDriver = (apiResult.body.toString() != '"not found"')?data['status'].toString():'Tidak Ditemukan';
          PhoneDriver = 'Tunggu';
        } else {
          print('pending123');
          NameDriver = (apiResult.body.toString() != '"not found"')?data['courier']['name'].toString():'Tidak Ditemukan';
          PhoneDriver = (apiResult.body.toString() != '"not found"')?data['courier']['phone'].toString():'Tidak Ditemukan';
          PhotoDriver = (apiResult.body.toString() != '"not found"')?data['courier']['photo'].toString():'';
          // StatusDriver = (apiResult.body.toString() != '"not found"')?(data['status'].toString() != 'active')?'Sudah sampai':data['status'].toString():'Tidak Ditemukan';
          StatusDriver = (apiResult.body.toString() != '"not found"')?(data['status'].toString() == 'sent')?'parcel_picked_up':(data['status'].toString() == 'done')?'completed':data['status'].toString():'Tidak Ditemukan';
        }
      }
    } else {
      if (statusTrans != 'pending') {
        _getDetail(idResto).whenComplete((){
          _getDetailTrans(id.toString()).whenComplete((){
            cariKurir();
          });
        });
        NameDriver = 'Tidak Ditemukan';
        PhoneDriver = 'Tidak Ditemukan';
        PhotoDriver = '';
        StatusDriver = 'Tidak Ditemukan';
      }
    }
    print('NameDriver');
    print(NameDriver);
    if (NameDriver != 'Tidak Ditemukan' && NameDriver != 'Tunggu' && NameDriver != '"not found"') {
      // _getProcess(operation = "ready", id.toString());
      print('SISI');
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

  String operation ='';
  Future _getProcess(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    // for(var v in data['trx']['process']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      // _getDataHome(latitude.toString(), longitude.toString());
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }

  String phoneRestoTrans = "";
  String delivAddress = "";
  int _platformfee = 1000;
  String userNamePembeli = "";
  String notelp = "";
  String latUser = "";
  String longUser = "";
  String idTrans = '';
  Future _getDetailTrans(String Id)async{
    List<Transaction> _detTransaction = [];
    List<Menu> _menu = [];
    idTrans = Id;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    userNamePembeli = (pref.getString('name')??'');
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/trans/$Id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('TYPE');
    print(data);

    // for(var v in data['trans']){
    //   Transaction r = Transaction.restoDetail(
    //       type: v['type'],
    //       address: v['status'],
    //       ongkir: v['ongkir'],
    //       total: v['total'],
    //   );
    //   _detTransaction.add(r);
    // }


    if (data['trx']['type'].toString() == 'delivery' && latUser == '' && longUser == '') {
      var addresses = await
      locationFromAddress(data['trx']['address'].toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latUser = placemarks[0].latitude.toString();
          longUser = placemarks[0].longitude.toString();
          print('latUser');
          print(latUser);
          print(longUser);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
      // geoCode.forwardGeocoding(
      //     address: data['trx']['address'].toString());
      // Geocoder2.getDataFromAddress(address: data['trx']['address'].toString(), googleMapApiKey: 'AIzaSyDZH54AvqWFepAGB7wh2VQPAhASjFzI-lE');
      var first = addresses;
      setState(() {
        // latUser = first.latitude.toString();
        // longUser = first.longitude.toString();
        print('latt');
        print(latUser);
        print(longUser);
      });
    }

    setState(() {
      print('ploow');
      print(data['trx']);
      // waiting = false;
      notelp = data['trx']['user_phone'].toString();
      // chatroom = (data['trx']['chatroom'] != null)?data['trx']['chatroom']['id'].toString():'';
      // ongkir = int.parse(data['trx']['ongkir']);
      // total = int.parse(data['trx']['total']);
      // all = total+ongkir;
      // type = data['trx']['type'].toString();
      delivAddress = data['trx']['address'].toString();
      // address = data['trx']['address'].toString();
      // phone = data['trx']['user_phone'].toString();
      // notelp = data['trx']['user_phone'].toString();
      // print(price);
      print('CUOK');
      print('IRG-$idTrans');
      print(restoAddress);
      print(pjTokoTrans);
      print(phoneRestoTrans);
      print(latRes);
      print(longRes);
      print(delivAddress);
      print(userNamePembeli);
      print(notelp);
      print(latUser);
      print(longUser);
      // detTransaction = _detTransaction;
      // menu = _menu;
    });
  }

  Future<String?>? cariKurir()async{
    // print(qrscan);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse('https://qurir.devastic.com/api/borzo/checkout'),
        body: {
          'resto_name': (note != '' && note != '[]' && note.contains('keterangan') == true)?
          (note.contains(', {keterangan') == true)?
          'IRG'+' - '+'Pengambilan di '+nameRestoTrans.toString()+', '+'pesanan: '+'('+menuKurir+')'+'. Jika ada masalah terkait merchant, hubungi kami sebagai penyelenggara aplikasi di 082166070555'+'~~~keterangan alamat pengiriman: '+note.split(', {keterangan: ')[1].replaceAll('[', '').replaceAll(']', '').replaceAll('{', '').replaceAll('}, ', '\n').replaceAll('}', ''):
          'IRG'+' - '+'Pengambilan di '+nameRestoTrans.toString()+', '+'pesanan: '+'('+menuKurir+')'+'. Jika ada masalah terkait merchant, hubungi kami sebagai penyelenggara aplikasi di 082166070555'+'~~~keterangan alamat pengiriman: '+note.split('{keterangan: ')[1].replaceAll('[', '').replaceAll(']', '').replaceAll('{', '').replaceAll('}, ', '\n').replaceAll('}', '')
            :'IRG'+' - '+'Pengambilan di '+nameRestoTrans.toString()+', '+'pesanan: '+'('+menuKurir+')'+'. Jika ada masalah terkait merchant, hubungi kami sebagai penyelenggara aplikasi di 082166070555',
          'address_pick_up': restoAddress,
          'name_pick_up': pjTokoTrans,
          'phone_pick_up': phoneRestoTrans,
          'latitude_pick_up': latRes,
          'longitude_pick_up': longRes,
          'address_sender': delivAddress,
          'name_sender': userNamePembeli,
          'phone_sender': notelp,
          'latitude_sender': latUser,
          'longitude_sender': longUser,
          'transaction_id': 'IRG-$idTrans'
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('Cek Harga '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    print('BORZO');
    print(data);
    // totalOngkirBorzo = data['price'];
    setState((){});

    print('IRG-$idTrans');
    print(restoAddress);
    print(pjTokoTrans);
    print(phoneRestoTrans);
    print(latRes);
    print(longRes);
    print(delivAddress);
    print(userNamePembeli);
    print(notelp);
    print(latUser);
    print(longUser);

    // for(var v in data['device_id']){
    //   // User p = User.resto(
    //   //   name: v['device_id'],
    //   // );
    //   List<String> id = [];
    //   id.add(v);
    //   print('099');
    //   print(id);
    //   OneSignal.shared.postNotification(OSCreateNotification(
    //     playerIds: id,
    //     heading: "$nameUser telah memesan produk di toko Anda",
    //     content: "Cek sekarang !",
    //     androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    //   ));
    //   // await OneSignal.shared.postNotificationWithJson();
    //   // user3.add(v['device_id']);
    //   // _user.add(p);
    // }

    if(data['status_code'] == 200){
      print('IRG-$idTrans');
      print(restoAddress);
      print(pjTokoTrans);
      print(phoneRestoTrans);
      print(latRes);
      print(longRes);
      print(delivAddress);
      print(userNamePembeli);
      print(notelp);
      print(latUser);
      print(longUser);
      // totalOngkirBorzo = data['price'];
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // pref.setString('totalOngkirBorzo', totalOngkirBorzo);
      setState((){});
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('note');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
      // await pref.remove('restoIdUsr');
      // pref.remove("addressDelivTrans");
      // pref.remove("distan");
      // notif(jsonEncode(data['device_id'].toString().split('[')[1].split(']')[0]));
      // print('ini device nya '+json.encode(data['device_id'].toString().split('[')[1].split(']')[0]));
    }
  }

  late String _base64 = "";

  bool loadQr = false;
  Future<void> _getQrBCA()async{
    // List<Menu> _menu = [];

    setState(() {
      loadQr = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/bca/generate'),
        body: {'app_id': 'IRG', 'trx_id': id.toString(), 'name_resto': nameRestoTrans.toString(), 'amount': (totalAll+1000).toString()},
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
                            text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
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
                        text: 'ke $nameRestoTrans!',
                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                        maxLines: 3
                    ),
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                GestureDetector(
                  onTap: ()async{
                    if (isLoadChekPay != true) {
                      _checkPayBCA();
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
  bool isLoadChekPay = false;
  bool kurir = false;
  Future<void> _checkPayBCA()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
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
    } else {
      statusPay = 'false';
      if (type == 'delivery') {
        _getDetail(idResto).whenComplete((){
          _getDetailTrans(id.toString()).whenComplete((){
            cariKurir();
            pref.setString("statusTrans", 'process');
            _getPending('process', id.toString());
          });
        });
      } else {
        if (statusTrans == 'pending') {
          pref.setString("statusTrans", 'process');
          _getPending('process', id.toString());
        }
      }
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
    }
    // _base64 = data['response']['qr_image'];
    // Uint8List bytes = Base64Codec().decode(_base64);

    // if (_base64 != '') {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
    //       ),
    //       context: context,
    //       builder: (_){
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
    //               child: Divider(thickness: 4,),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: CustomText.textHeading2(
    //                   text: "Qris",
    //                   minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
    //                   maxLines: 1
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
    //             Center(
    //               child: FullScreenWidget(
    //                 child: Image.memory(bytes,
    //                   width: CustomSize.sizeWidth(context) / 1.2,
    //                   height: CustomSize.sizeWidth(context) / 1.2,
    //                 ),
    //                 backgroundColor: Colors.white,
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     CustomText.textTitle2(
    //                         text: 'Total harga:',
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                     CustomText.textTitle2(
    //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'Scan disini untuk melakukan pembayaran',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 1
    //                 ),
    //               ),
    //             ),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'ke $nameRestoTrans!',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 3
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
    //             GestureDetector(
    //               onTap: ()async{
    //                 Fluttertoast.showToast(
    //                   msg: "Anda belum membayar!",);
    //               },
    //               child: Center(
    //                 child: Container(
    //                   width: CustomSize.sizeWidth(context) / 1.1,
    //                   height: CustomSize.sizeHeight(context) / 14,
    //                   decoration: BoxDecoration(
    //                     // color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
    //                       borderRadius: BorderRadius.circular(50)
    //                   ),
    //                   child: Center(
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                       child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
    //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //           ],
    //         );
    //       }
    //   );
    // }
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
      isLoadChekPay = false;
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

  Future _getPending(String operation, String id)async{
    List<Transaction> _transaction = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/trans/op/$operation/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    _getUserDataResto();
    getUser();
    getData();
    _getData();
    _getData2();
    setState(() {});

    // for(var v in data['trx']['process']){
    //   Transaction r = Transaction.resto(
    //       id: v['id'],
    //       status: v['status'],
    //       username: v['username'],
    //       total: int.parse(v['total']),
    //       type: v['type']
    //   );
    //   _transaction.add(r);
    // }

    setState(() {
      // transaction = _transaction;
      print(operation+'   '+id);
    });
  }

  bool isLoadChekPayFirst = true;
  Future<void> _checkPayFirst()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPayFirst = true;
    });
    // Fluttertoast.showToast(
    //   msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
        // body: {'app_id': 'IRG', 'trx_id': id.toString(), 'amount': (totalAll+1000).toString()},
        // headers: {
        //   "Accept": "Application/json",
        //   "Authorization": "Bearer $token"
        // }
    );
    print(apiResult.statusCode);
    if (apiResult.statusCode == 500) {
      isLoadChekPayFirst = false;
      // if (type == 'dinein') {
      //   statusPay = pref.getString("statusPay") ?? "true";
      // } else {
      //   statusPay = 'true';
      // }
      statusPay = 'true';
      setState((){});
    }
    var data = json.decode(apiResult.body);
    print('QR CODE 2');
    print(data);
    print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    if (data['response']['detail_info'].toString().contains('Unpaid') != true) {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
    } else {
      statusPay = 'false';
      if (type == 'delivery') {
        if (statusTrans == 'process') {
          _getDriver().whenComplete((){
            _getDetail(idResto);
          });
          print('process');
        } else if (statusTrans == 'ready') {
          _getDriver().whenComplete((){
            _getDetail(idResto);
          });
        } else if (statusTrans == 'pending') {
          tungguProses = 'true';
          print('pending');
        } else if (statusTrans == 'cancel') {
          print('cancel');
        } else {
          print('p');
        }
      } else {
        if (statusTrans == 'pending') {
          pref.setString("statusTrans", 'process');
          _getPending('process', id.toString());
        }
      }
      // _getDetail(idResto).whenComplete((){
      //   _getDetailTrans(id.toString()).whenComplete((){
      //     cariKurir();
      //   });
      // });
      // Navigator.pop(context);
      // _getPending('process', id.toString());
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
    }
    // _base64 = data['response']['qr_image'];
    // Uint8List bytes = Base64Codec().decode(_base64);

    // if (_base64 != '') {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
    //       ),
    //       context: context,
    //       builder: (_){
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
    //               child: Divider(thickness: 4,),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: CustomText.textHeading2(
    //                   text: "Qris",
    //                   minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
    //                   maxLines: 1
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
    //             Center(
    //               child: FullScreenWidget(
    //                 child: Image.memory(bytes,
    //                   width: CustomSize.sizeWidth(context) / 1.2,
    //                   height: CustomSize.sizeWidth(context) / 1.2,
    //                 ),
    //                 backgroundColor: Colors.white,
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     CustomText.textTitle2(
    //                         text: 'Total harga:',
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                     CustomText.textTitle2(
    //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'Scan disini untuk melakukan pembayaran',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 1
    //                 ),
    //               ),
    //             ),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'ke $nameRestoTrans!',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 3
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
    //             GestureDetector(
    //               onTap: ()async{
    //                 Fluttertoast.showToast(
    //                   msg: "Anda belum membayar!",);
    //               },
    //               child: Center(
    //                 child: Container(
    //                   width: CustomSize.sizeWidth(context) / 1.1,
    //                   height: CustomSize.sizeHeight(context) / 14,
    //                   decoration: BoxDecoration(
    //                     // color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
    //                       borderRadius: BorderRadius.circular(50)
    //                   ),
    //                   child: Center(
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                       child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
    //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //           ],
    //         );
    //       }
    //   );
    // }
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
      isLoadChekPayFirst = false;
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

  // _launchURL() async {
  //   var url = 'https://www.google.co.id/maps/place/' + restoAddress;
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  // Future<void> _getUserDataResto()async{
  //   // List<Menu> _menu = [];
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String token = pref.getString("token") ?? "";
  //   var apiResult = await http.get(Links.mainUrl + '/resto/userdata/$checkId', headers: {
  //     "Accept": "Application/json",
  //     "Authorization": "Bearer $token"
  //   });
  //   print(apiResult.body);
  //   var data = json.decode(apiResult.body);
  //
  //   // for(var v in data['menu']){
  //   //   Menu p = Menu(
  //   //       id: v['id'],
  //   //       name: v['name'],
  //   //       desc: v['desc'],
  //   //       urlImg: v['img'],
  //   //       type: v['type'],
  //   //       is_recommended: v['is_recommended'],
  //   //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
  //   //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
  //   //   );
  //   //   _menu.add(p);
  //   // }
  //   setState(() {
  //     emailTokoTrans = data['email'].toString();
  //     ownerTokoTrans = data['name_owner'].toString();
  //     pjTokoTrans = data['name_pj'].toString();
  //     // bankTokoTrans = data['bank'].toString();
  //     // nameNorekTokoTrans = data['namaNorek'].toString();
  //     norekTokoTrans = data['norek'].toString();
  //     // isLoading = false;
  //   });
  // }

  String userName = '';
  String timeLog = '';
  String chatUserCount = '';
  String statusTrans = 'pending';
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name')??'');
      timeLog = (pref.getString('timeLog')??'');
      chatUserCount = (pref.getString('chatUserCount')??'');
      statusTrans = (pref.getString('statusTrans')??'pending');
    });
  }

  DateTime? currentBackPressTime;
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
    return Future.value(true);
  }

  String inCart = "";
  Future _getData()async{
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    inCart = pref2.getString('inCart')??"";
    // if(checkId == idnyaResto && inCart == '1'){
    //   name = pref2.getString('menuJson')??"";
    //   print("Ini pref2 " +name+" SP");
    //   restoId.addAll(pref2.getStringList('restoId')??[]);
    //   print(restoId);
    //   qty.addAll(pref2.getStringList('qty')??[]);
    //   print('qty '+qty.toString());
    //   noted.addAll(pref2.getStringList('note')??[]);
    //   print('notednya '+noted.toString());
    // } else if (checkId != idnyaResto && inCart == '1') {
    //   print(restoId.toString()+'ididi');
    //   print(qty);
    // } else {
    //   pref2.remove('inCart');
    //   // pref2.setString("menuJson", "[]");
    //   pref2.remove("restoIdUsr");
    //   pref2.remove("restoId");
    //   pref2.remove("qty");
    //   print('cukimay');
    // }
    setState(() {});
  }

  Future _getData2()async{
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // cart = pref.getString('inCart');
    // checkId = pref.getString('restoIdUsr')??'';
    // json2 = pref.getString("menuJson");
    // print('cokk '+json2);
    setState(() {});
  }

  String can_delivery = "";
  String can_takeaway = "";
  String idnyaResto = "";
  String isOpen = "";
  List<String> noted = [];
  String nameResto = "";
  String latRes = "";
  String longRes = "";
  Future _getDetail(String id)async{
    setState(() {
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('ini loh sob '+data['data'].toString());

    SharedPreferences pref2 = await SharedPreferences.getInstance();
    pref2.setString('latResto', data['data']['lat'].toString());
    pref2.setString('longResto', data['data']['long'].toString());
    pref2.setString('can_deliveryUser', data['data']['can_delivery'].toString());
    pref2.setString('can_take_awayUser', data['data']['can_take_away'].toString());

    latRes = data['data']['lat'].toString();
    longRes = data['data']['long'].toString();

    if (data['data']['lat'].toString() == 'null' || data['data']['long'].toString() == 'null') {
      var addresses = await
      locationFromAddress(data['data']['address'].toString(),
          localeIdentifier: 'id_ID')
          .then((placemarks) async {
        setState(() {
          latRes = placemarks[0].latitude.toString();
          longRes = placemarks[0].longitude.toString();
          print('latResLOLO');
          print(latRes);
          print(longRes);
          // address = placemarks[0].street +
          //     ', ' +
          //     placemarks[0].subLocality! +
          //     ', ' +
          //     placemarks[0].locality! +
          //     ', ' +
          //     placemarks[0].subAdministrativeArea! +
          //     ', ' +
          //     placemarks[0].administrativeArea! +
          //     ' ' +
          //     placemarks[0].postalCode! +
          //     ', ' +
          //     placemarks[0].country!;
        });
      });
    }
    setState(() {
      idnyaResto = data['data']['id'].toString();
      nameRestoTrans = data['data']['name'];
      restoAddress = data['data']['address'];
      phoneRestoTrans = data['data']['phone_number'];
      can_delivery = data['data']['can_delivery'].toString();
      can_takeaway = data['data']['can_take_away'].toString();
      isLoading = false;
      // print('iniphone '+phone.toString());
      // // can_delivery = data['data']['can_delivery'].toString();
      // // can_takeaway = data['data']['can_take_away'].toString();
      // isOpen = data['data']['isOpen'].toString();
    });
  }

  _launchURL() async {
    var url = 'https://www.google.co.id/maps/place/' + restoAddress;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  toCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    inCart = '1';
    String idRes = '';

    idRes = pref.getString("idnyatransRes")??'';
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99")??'');
    pref.setString("alamateResto", restoAddress);
    pref.setString("restoPhoneTrans", phone);
    pref.setString("restoIdUsr", idRes);
    // menuJson = [];
    // print('kudune '+pref.getString("alamateResto99"));
    // json2 = pref.getString("menuJson");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    // setStateModal(() {});
    setState(() {});
  }

  void chat(String urlChat) async {
    var uri = Uri.parse(urlChat);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  toCart2() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    inCart = '1';
    String idRes = '';

    idRes = pref.getString("idnyatransRes")??'';
    // String json1 = jsonEncode(menuJson.map((m) => m.toJson()).toList());
    pref.setString('inCart', '1');
    pref.setString("menuJson", jsonEncode(menu3.map((m) => m.toJson()).toList()));
    pref.setString("restoIdUsr", idnyaResto);
    pref.setStringList("restoId", menu4);
    pref.setStringList("qty", menu2);
    print('qtynya '+menu4.toString());
    pref.setStringList("note", menu5);
    pref.setString("restoNameTrans", pref.getString("restoNameTrans99")??'');
    pref.setString("alamateResto", restoAddress);
    pref.setString("restoPhoneTrans", phone);
    pref.setString("restoIdUsr", idRes);
    // menuJson = [];
    // print('kudune '+pref.getString("alamateResto99"));
    // json2 = pref.getString("menuJson");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    Future.delayed(Duration(seconds: 1)).whenComplete((){
      Navigator.push(context, PageTransition(
          type: PageTransitionType.rightToLeft,
          child: CartActivity()));
    });
    // setStateModal(() {});
    setState(() {});
  }

  delCart() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // print('ini json '+json2.toString()+ cart.toString());
    pref.setString("menuJson", "");
    pref.setString("restoId", "");
    pref.setString("qty", "");
    pref.setString("note", "");
    pref.remove('address');
    pref.remove('inCart');
    pref.remove('restoIdUsr');
    pref.remove("addressDelivTrans");
    pref.remove("distan");
    _getData2();
    _getData();
    // noteProduct = '';
    // getNote();

    // setStateModal(() {});
    setState(() {});
  }

  String paymentDinein = '';

  @override
  void initState() {
    // _getUserDataResto();
    _getUserDataResto();
    getUser();
    getData();
    _getData();
    _getData2();
    // _getDetail(id);
    super.initState();
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    _getUserDataResto();
    getUser();
    getData();
    _getData();
    _getData2();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPop(),
      child: MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: (isLoadChekPayFirst == true)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primaryLight,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
                  child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));
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
                                        offset: Offset(0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Icon(Icons.chevron_left, size: 38,)))
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 48,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context) / 1.5,
                            child: CustomText.textHeading3(
                                text: "Detail Transaction",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                    Divider(thickness: 6, color: CustomColor.secondary,),
                    (type == 'delivery' || type == 'takeaway')?Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                          // Divider(thickness: 6, color: CustomColor.secondary,),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                          Padding(
                            padding: EdgeInsets.only(
                              left: CustomSize.sizeWidth(context) / 32,
                              right: CustomSize.sizeWidth(context) / 32,
                            ),
                            child: CustomText.textHeading4(text: (type == 'delivery')?"Alamat Pengiriman":"Alamat Pengambilan", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                          Padding(
                            padding: EdgeInsets.only(
                              left: CustomSize.sizeWidth(context) / 18,
                              right: CustomSize.sizeWidth(context) / 18,
                            ),
                            child: CustomText.textHeading6(
                                text: address,
                                minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                maxLines: 10
                            ),
                          ),
                        ],
                      ),
                    ):SizedBox(),
                    // SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                    // Divider(thickness: 6, color: CustomColor.secondary,),
                    Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                      ),
                      child: CustomText.textHeading4(text: "Tipe Pembelian", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,),
                    Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 18,
                        right: CustomSize.sizeWidth(context) / 18,
                      ),
                      child: CustomText.textHeading6(text: (type == 'delivery')?"Pesan Antar":(type == 'takeaway')?"Ambil Langsung":"Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                    Divider(thickness: 6, color: CustomColor.secondary,),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: menu.length,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.only(
                              top: CustomSize.sizeWidth(context) / 68,
                              left: CustomSize.sizeWidth(context) / 32,
                              right: CustomSize.sizeWidth(context) / 32,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 1.65,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CustomText.textHeading4(
                                                  text: menu[index].name,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                  maxLines: 1
                                              ),
                                              CustomText.bodyRegular12(
                                                  text: menu[index].desc,
                                                  maxLines: 2,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                              Row(
                                                children: [
                                                  CustomText.bodyMedium14(
                                                      text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original) ,
                                                      maxLines: 1,
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.0025),
                                              CustomText.bodyMedium14(
                                                  text: menu[index].qty.toString()+' Item',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 3.4,
                                          height: CustomSize.sizeWidth(context) / 3.4,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                                  fit: BoxFit.cover
                                              ),
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Divider()
                              ],
                            ),
                          );
                        }
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.0075),
                    (note != '' && note != '[]')?Divider(thickness: 6, color: CustomColor.secondary,):Container(),
                    (note != '' && note != '[]')?Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                      ),
                      child: CustomText.textHeading4(text: "Catatan mu", minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                    ):Container(),
                    (note != '' && note != '[]')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0048,):Container(),
                    (note != '' && note != '[]')?Padding(
                      padding: EdgeInsets.only(
                        left: CustomSize.sizeWidth(context) / 18,
                        right: CustomSize.sizeWidth(context) / 18,
                      ),
                      child: CustomText.textHeading6(text: note.replaceAll('[', '').replaceAll(']', '').replaceAll('{', '').replaceAll('}, ', '\n').replaceAll('}', ''), maxLines: 99, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                    ):Container(),
                    (note != '' && note != '[]')?SizedBox(height: CustomSize.sizeHeight(context) * 0.0075):Container(),
                    // Divider(thickness: 6, color: CustomColor.secondary,),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: CustomSize.sizeWidth(context) / 32,
                    //       vertical: CustomSize.sizeHeight(context) / 55
                    //   ),
                    //   child: Container(
                    //     width: CustomSize.sizeWidth(context),
                    //     decoration: BoxDecoration(
                    //         color: Colors.white
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         CustomText.textHeading7(text: "Data Usaha", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                    //         SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                    //         Container(
                    //           padding: EdgeInsets.only(
                    //             left: CustomSize.sizeWidth(context) / 25,
                    //             right: CustomSize.sizeWidth(context) / 25,
                    //           ),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               (nameRestoTrans != '' && nameRestoTrans != 'null')?
                    //               CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (restoAddress != '' && restoAddress != 'null')?
                    //               Row(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         _launchURL();
                    //                       },
                    //                       child: Container(
                    //                           width: CustomSize.sizeWidth(context) / 1.8,
                    //                           child: CustomText.bodyRegular17(text: restoAddress, maxLines: 14, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                    //                       )
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (emailTokoTrans != '' && emailTokoTrans != 'null')?
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         launch('mailto:$emailTokoTrans');
                    //                       },
                    //                       child: Container(
                    //                           width: CustomSize.sizeWidth(context) / 1.8,
                    //                           child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                    //                       )
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (phone != '' && phone != 'null')?
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         launch('tel:$phone');
                    //                       },
                    //                       child: CustomText.bodyRegular17(text: phone, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString()))
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               // (ownerTokoTrans != '' && ownerTokoTrans != 'null')?
                    //               // CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               // Row(
                    //               //   children: [
                    //               //     CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //               //     CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //               //   ],
                    //               // ),
                    //               // SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //               //
                    //               // (pjTokoTrans != '' && pjTokoTrans != 'null')?
                    //               // CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               // Row(
                    //               //   children: [
                    //               //     CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //               //     CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //               //   ],
                    //               // ),
                    //               // SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (nameRekening != '' && nameRekening != 'null')?
                    //               CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameRekening, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (nameBank != '' && nameBank != 'null')?
                    //               CustomText.bodyRegular17(text: "Rekening Bank: "+nameBank, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (norekTokoTrans != '' && norekTokoTrans != 'null')?
                    //               CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn, minSize: double.parse(((MediaQuery.of(context).size.width*0.037).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.037)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.037)).toString())),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    (type == 'delivery')?Divider(thickness: 6, color: CustomColor.secondary,):Container(),
                    (type == 'delivery')?Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: CustomSize.sizeWidth(context) / 32,
                          vertical: CustomSize.sizeHeight(context) / 55
                      ),
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        decoration: BoxDecoration(
                            color: Colors.white
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText.textHeading7(text: "Data Kurir", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                            SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                            Container(
                              padding: EdgeInsets.only(
                                left: CustomSize.sizeWidth(context) / 25,
                                right: CustomSize.sizeWidth(context) / 25,
                              ),
                              child: Row(
                                children: [
                                  (tungguProses != 'true' && statusTrans != 'cancel' && StatusDriver != 'pending' && StatusDriver != 'Tidak Ditemukan')?ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: FullScreenWidget(
                                      child: Container(
                                        width: CustomSize.sizeWidth(context) / 6,
                                        height: CustomSize.sizeWidth(context) / 6,
                                        child: Image.network(
                                          PhotoDriver,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            // Appropriate logging or analytics, e.g.
                                            // myAnalytics.recordError(
                                            //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                            //   exception,
                                            //   stackTrace,
                                            // );
                                            return Image.network(
                                              PhotoDriver,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                // Appropriate logging or analytics, e.g.
                                                // myAnalytics.recordError(
                                                //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                                //   exception,
                                                //   stackTrace,
                                                // );
                                                return Image.network(
                                                  PhotoDriver,
                                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                    // Appropriate logging or analytics, e.g.
                                                    // myAnalytics.recordError(
                                                    //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                                    //   exception,
                                                    //   stackTrace,
                                                    // );
                                                    return Image.asset('assets/default.png');
                                                  },
                                                  loadingBuilder: (BuildContext context, Widget child,
                                                      ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        color: CustomColor.primary,
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  fit: BoxFit.cover,
                                                  width: CustomSize.sizeWidth(context) / 6,
                                                  height: CustomSize.sizeWidth(context) / 6,
                                                );
                                              },
                                              fit: BoxFit.cover,
                                              width: CustomSize.sizeWidth(context) / 6,
                                              height: CustomSize.sizeWidth(context) / 6,
                                            );
                                          },
                                          fit: BoxFit.cover,
                                          width: CustomSize.sizeWidth(context) / 6,
                                          height: CustomSize.sizeWidth(context) / 6,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                  ):Container(
                                    width: CustomSize.sizeWidth(context) / 6,
                                    height: CustomSize.sizeWidth(context) / 6,
                                    child: Image.asset('assets/default.png'),
                                  ),
                                  //     :Container(
                                  //   width: CustomSize.sizeWidth(context) / 6,
                                  //   height: CustomSize.sizeWidth(context) / 6,
                                  //   decoration: (user[index].img == "/".substring(0, 1))?BoxDecoration(
                                  //       color: CustomColor.primaryLight,
                                  //       shape: BoxShape.circle
                                  //   )
                                  // ),
                                  // FullScreenWidget(
                                  //   child: Container(
                                  //     width: CustomSize.sizeWidth(context) / 6,
                                  //     height: CustomSize.sizeWidth(context) / 6,
                                  //     decoration: BoxDecoration(
                                  //       shape: BoxShape.circle,
                                  //       image: DecorationImage(
                                  //         image: AssetImage("assets/devus.png"),
                                  //       ),
                                  //     ),
                                  //     // child: FullScreenWidget(
                                  //     //   child: Image.asset("assets/devus.png",
                                  //     //     width: CustomSize.sizeWidth(context) / 6,
                                  //     //     height: CustomSize.sizeWidth(context) / 6,
                                  //     //   ),
                                  //     //   backgroundColor: Colors.white,
                                  //     // ),
                                  //
                                  //     // decoration: (user[index].img == "/".substring(0, 1))?BoxDecoration(
                                  //     //     color: CustomColor.primaryLight,
                                  //     //     shape: BoxShape.circle
                                  //     // ):BoxDecoration(
                                  //     //   shape: BoxShape.circle,
                                  //     //   image: new DecorationImage(
                                  //     //       image: (user[index].img != null)?NetworkImage(Links.subUrl +
                                  //     //           user[index].img!):AssetImage('assets/default.png') as ImageProvider,
                                  //     //       fit: BoxFit.cover
                                  //     //   ),
                                  //     // ),
                                  //     // child: (user[index].img == "/".substring(0, 1))?Center(
                                  //     //   child: CustomText.text(
                                  //     //       size: double.parse(((MediaQuery.of(context).size.width*0.093).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.093)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.093)).toString()),
                                  //     //       weight: FontWeight.w800,
                                  //     //       // text: initial,
                                  //     //       color: Colors.white
                                  //     //   ),
                                  //     // ):Container(),
                                  //   ),
                                  // ),
                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                  GestureDetector(
                                    onTap: (){
                                      if (PhoneDriver == '0' || PhoneDriver == '-') {

                                      } else {
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
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: (){
                                                            if (status != 'cancel') {
                                                              Navigator.pop(context);
                                                              chat((PhoneDriver.toString().substring(0, 1).toString() == '0')?"whatsapp://send?phone=+62"+PhoneDriver.toString().substring(1):"whatsapp://send?phone="+PhoneDriver.toString());
                                                              setState((){});
                                                            } else {
                                                              Fluttertoast.showToast(msg: "Fitur chat tidak tersedia karena pesanan anda sudah ditolak.");
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(FontAwesome.comments_o, color: (status != 'cancel')?CustomColor.accent:Colors.grey, size: 31,),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 72,),
                                                                Stack(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 8.0),
                                                                      child: CustomText.textHeading5(
                                                                          text: "Chat",
                                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.043).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.043)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.043)).toString()),
                                                                          maxLines: 1,
                                                                          color: (status != 'cancel')?CustomColor.accent:Colors.grey
                                                                      ),
                                                                    ),
                                                                    Positioned(  // draw a red marble
                                                                      top: 0,
                                                                      right: 0,
                                                                      child: Stack(
                                                                        alignment: Alignment.center,
                                                                        children: [
                                                                          Icon(Icons.circle, color: (status != 'cancel')?(chatUserCount != '0')?CustomColor.redBtn:Colors.transparent:Colors.transparent, size: 22,),
                                                                          CustomText.bodyMedium14(text: chatUserCount, color: (status != 'cancel')?(chatUserCount != '0')?Colors.white:Colors.transparent:Colors.transparent, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: (){
                                                            // Navigator.pop(context);
                                                            print(phoneRestoTrans);
                                                            Navigator.pop(context);
                                                            (PhoneDriver.toString().contains('+') != true)?launch("tel:$PhoneDriver"):launch("tel:"+PhoneDriver.toString().replaceAll('+62', '0'));
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(FontAwesome.phone, color: CustomColor.redBtn, size: 27.5,),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 88,),
                                                                CustomText.textHeading5(
                                                                    text: "Telpon",
                                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.043).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.043)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.043)).toString()),
                                                                    maxLines: 1,
                                                                    color: CustomColor.redBtn
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 42,),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: CustomSize.sizeWidth(context) / 1.6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: CustomSize.sizeWidth(context) / 1.2,
                                            child: CustomText.textHeading4(
                                                text: (tungguProses != 'true')?(statusTrans != 'cancel')?(StatusDriver != 'pending')?NameDriver:'Mencari . . .':'Tidak ditemukan':'Tunggu . . .',
                                                maxLines: 1,
                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText.bodyLight16(
                                                  text: 'Status: ',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                              ),
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 2.2,
                                                child: CustomText.bodyLight16(
                                                  // text: (tungguProses != 'true')?(statusTrans != 'cancel')?(StatusDriver != 'pending')?(StatusDriver != 'Tidak Ditemukan')?(StatusDriver != 'active')?StatusDriver:'Sedang perjalanan':'Transaksi tidak ditemukan':'Sedang mencari driver':'Pemesanan dibatalkan pihak toko':'Menunggu proses dari pihak toko',
                                                    text: (tungguProses != 'true')?(statusTrans != 'cancel')?(StatusDriver != 'pending')?(StatusDriver != 'Tidak Ditemukan')?(StatusDriver != 'completed')?(StatusDriver == 'parcel_picked_up')?'Kurir menuju tempat anda':(StatusDriver == 'Tunggu sebentar')?'Silahkan bayar terlebih dahulu':'Menunggu':'Pengiriman selesai':'Transaksi tidak ditemukan':'Sedang mencari driver':'Pemesanan dibatalkan pihak toko':'Menunggu proses dari pihak toko',
                                                    maxLines: 5,
                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText.bodyLight16(
                                                  text: 'Telpon: ',
                                                  maxLines: 1,
                                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                              ),
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 2.2,
                                                child: CustomText.bodyLight16(
                                                    text: (tungguProses != 'true')?(statusTrans != 'cancel')?(StatusDriver != 'pending')?(StatusDriver != 'Tidak Ditemukan')?(StatusDriver != 'active')?PhoneDriver:'+'+PhoneDriver:'-':'-':'-':'-',
                                                    maxLines: 1,
                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                ),
                                              ),
                                            ],
                                          ),

                                          // CustomText.bodyLight16(text: 'Status', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                          // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ):Container(),
                    // Divider(thickness: 6, color: CustomColor.secondary,),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: CustomSize.sizeWidth(context) / 32,
                    //       vertical: CustomSize.sizeHeight(context) / 55
                    //   ),
                    //   child: Container(
                    //     width: CustomSize.sizeWidth(context),
                    //     decoration: BoxDecoration(
                    //         color: Colors.white
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         CustomText.textHeading7(text: "Data Usaha"),
                    //         SizedBox(height: CustomSize.sizeHeight(context) * 0.01,),
                    //         Container(
                    //           padding: EdgeInsets.only(
                    //             left: CustomSize.sizeWidth(context) / 25,
                    //             right: CustomSize.sizeWidth(context) / 25,
                    //           ),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               (nameRestoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Nama Usaha: "+nameRestoTrans, maxLines: 4):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nama Usaha: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (restoAddress != '')?
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 4),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         _launchURL();
                    //                       },
                    //                       child: Container(
                    //                           width: CustomSize.sizeWidth(context) / 1.8,
                    //                           child: CustomText.bodyRegular17(text: restoAddress, maxLines: 1, minSize: 15)
                    //                       )
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Alamat Usaha: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (emailTokoTrans != '')?
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         launch('mailto:$emailTokoTrans');
                    //                       },
                    //                       child: Container(
                    //                           width: CustomSize.sizeWidth(context) / 1.8,
                    //                           child: CustomText.bodyRegular17(text: emailTokoTrans, maxLines: 1)
                    //                       )
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Email Usaha: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (phoneRestoTrans != '')?
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2),
                    //                   GestureDetector(
                    //                       onTap: (){
                    //                         launch('tel:$phoneRestoTrans');
                    //                       },
                    //                       child: CustomText.bodyRegular17(text: phoneRestoTrans, maxLines: 2)
                    //                   ),
                    //                 ],
                    //               ):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Telepon Usaha: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (ownerTokoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Nama Pemilik: "+ownerTokoTrans, maxLines: 2):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nama Pemilik: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (pjTokoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Nama Penanggung Jawab: "+pjTokoTrans, maxLines: 2):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nama Penanggung Jawab: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (nameNorekTokoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: "+nameNorekTokoTrans, maxLines: 2):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nomor Rekening atas Nama: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (bankTokoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Rekening Bank: "+bankTokoTrans, maxLines: 2):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Rekening Bank: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //               SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    //
                    //               (norekTokoTrans != '')?
                    //               CustomText.bodyRegular17(text: "Nomor Rekening: "+norekTokoTrans, maxLines: 2):
                    //               Row(
                    //                 children: [
                    //                   CustomText.bodyRegular17(text: "Nomor Rekening: ", maxLines: 2),
                    //                   CustomText.bodyRegular17(text: "kosong", maxLines: 2, color: CustomColor.redBtn),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Container(
                      width: CustomSize.sizeWidth(context),
                      decoration: BoxDecoration(
                          color: CustomColor.secondary
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              height: (type != 'delivery')?(type != 'takeaway')?CustomSize.sizeHeight(context) / 3.8:CustomSize.sizeHeight(context) / 3.4:CustomSize.sizeHeight(context) / 3.4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                    CustomText.textTitle3(text: "Rincian Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText.bodyLight16(text: "Harga", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                        CustomText.bodyLight16(text: (total == 0)?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      ],
                                    ),
                                    SizedBox(height: (type == 'delivery')?CustomSize.sizeHeight(context) / 100:0,),
                                    (type == 'delivery')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText.bodyLight16(text: "Ongkir", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                        CustomText.bodyLight16(text: (ongkir == 0)?'Gratis Ongkir':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      ],
                                    ):SizedBox(),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 100,),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText.bodyLight16(text: "Platform Fee", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                        CustomText.bodyLight16(text: (_platformfee.toString() == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_platformfee), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      ],
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                    Divider(thickness: 1,),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText.textTitle3(text: "Total Pembayaran", minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                        CustomText.textTitle3(text: (totalAll.toString() == '0')?'Free':NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalAll+1000), minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                      ],
                                    ),
                                    // SizedBox(height: CustomSize.sizeHeight(context) / 34,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                          // (phone == '')?GestureDetector(
                          //   onTap: (){
                          //     // Navigator.push(
                          //     //     context,
                          //     //     PageTransition(
                          //     //         type: PageTransitionType.rightToLeft,
                          //     //         child: new ChatActivity(chatroom, userName, status)));
                          //   },
                          //   child: Center(
                          //     child: Container(
                          //       width: CustomSize.sizeWidth(context) / 1.1,
                          //       height: CustomSize.sizeHeight(context) / 14,
                          //       decoration: BoxDecoration(
                          //           color: CustomColor.accent,
                          //           borderRadius: BorderRadius.circular(50)
                          //       ),
                          //       child: Center(
                          //         child: Padding(
                          //           padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          //           child: CustomText.textTitle2(text: "Telpon Penjual", color: Colors.white),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ):SizedBox(),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          (statusTrans != 'cancel')?(statusPay == 'true')?(total.toString() == '0' && type.toString() != 'delivery')?Container():GestureDetector(
                            onTap: (){
                              if (loadQr == false) {
                                _getQrBCA();

                                // if (type != 'dinein') {
                                //   _getQrBCA();
                                // } else {
                                //   showDialog(
                                //       context: context,
                                //       builder: (context) {
                                //         return AlertDialog(
                                //           contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                //           shape: RoundedRectangleBorder(
                                //               borderRadius: BorderRadius.all(Radius.circular(10))
                                //           ),
                                //           title: Center(child: Text('Transaksi', style: TextStyle(color: CustomColor.primary))),
                                //           content: Text('Pilih metode pembayaran!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                //           // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                //           actions: <Widget>[
                                //             Center(
                                //               child: Row(
                                //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                //                 children: [
                                //                   FlatButton(
                                //                     // minWidth: CustomSize.sizeWidth(context),
                                //                     color: Colors.blue,
                                //                     textColor: Colors.white,
                                //                     shape: RoundedRectangleBorder(
                                //                         borderRadius: BorderRadius.all(Radius.circular(10))
                                //                     ),
                                //                     child: Text('Qris'),
                                //                     onPressed: () async{
                                //                       setState(() {
                                //                         // codeDialog = valueText;
                                //                         Navigator.pop(context);
                                //                         _getQrBCA();
                                //                       });
                                //                     },
                                //                   ),
                                //                   FlatButton(
                                //                     color: CustomColor.primaryLight,
                                //                     textColor: Colors.white,
                                //                     shape: RoundedRectangleBorder(
                                //                         borderRadius: BorderRadius.all(Radius.circular(10))
                                //                     ),
                                //                     child: Text('Tunai / Debit'),
                                //                     onPressed: () async{
                                //                       statusPay = 'false';
                                //                       setState((){});
                                //                       Navigator.pop(context);
                                //                       showDialog(
                                //                           context: context,
                                //                           builder: (context) {
                                //                             return AlertDialog(
                                //                               contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                //                               shape: RoundedRectangleBorder(
                                //                                   borderRadius: BorderRadius.all(Radius.circular(10))
                                //                               ),
                                //                               title: Center(child: Text('Lanjutkan', style: TextStyle(color: CustomColor.primary))),
                                //                               content: Text('Silahkan langsung menuju ke kasir untuk menyelesaikan pembayaran terlebih dahulu!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                //                               // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                //                               actions: <Widget>[
                                //                                 Center(
                                //                                   child: Row(
                                //                                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                                //                                     children: [
                                //                                       FlatButton(
                                //                                         color: CustomColor.accent,
                                //                                         textColor: Colors.white,
                                //                                         shape: RoundedRectangleBorder(
                                //                                             borderRadius: BorderRadius.all(Radius.circular(10))
                                //                                         ),
                                //                                         child: Text('Oke'),
                                //                                         onPressed: () async{
                                //                                           Navigator.pop(context);
                                //                                         },
                                //                                       ),
                                //                                     ],
                                //                                   ),
                                //                                 ),
                                //
                                //                               ],
                                //                             );
                                //                           });
                                //                     },
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //
                                //           ],
                                //         );
                                //       });
                                // }
                              }
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //         type: PageTransitionType.rightToLeft,
                              //         child: new ChatActivity(chatroom, userName, status)));
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 1.1,
                              height: CustomSize.sizeHeight(context) / 14,
                              decoration: BoxDecoration(
                                  color: CustomColor.accent,
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                        child: CustomText.textTitle2(text: "Bayar Sekarang", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                      ),
                                      // Positioned(  // draw a red marble
                                      //   top: 0,
                                      //   right: 0,
                                      //   child: Stack(
                                      //     alignment: Alignment.center,
                                      //     children: [
                                      //       Icon(Icons.circle, color: (chatUserCount != '0')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                      //       CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0')?Colors.white:Colors.transparent, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                      //     ],
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ):Container():Container(),
                          (statusPay == 'true')?SizedBox(height: CustomSize.sizeHeight(context) / 96,):Container(),
                          (chatroom != 'null')?GestureDetector(
                            onTap: (){
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
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  if (status != 'cancel') {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type: PageTransitionType.rightToLeft,
                                                            child: new ChatActivity(chatroom, userName, status)));
                                                  } else {
                                                    Fluttertoast.showToast(msg: "Fitur chat tidak tersedia karena pesanan anda sudah ditolak.");
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(FontAwesome.comments_o, color: (status != 'cancel')?CustomColor.accent:Colors.grey, size: 31,),
                                                      SizedBox(width: CustomSize.sizeWidth(context) / 72,),
                                                      Stack(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 19.0, vertical: 8.0),
                                                            child: CustomText.textHeading5(
                                                                text: "Chat",
                                                                minSize: double.parse(((MediaQuery.of(context).size.width*0.043).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.043)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.043)).toString()),
                                                                maxLines: 1,
                                                                color: (status != 'cancel')?CustomColor.accent:Colors.grey
                                                            ),
                                                          ),
                                                          Positioned(  // draw a red marble
                                                            top: 0,
                                                            right: 0,
                                                            child: Stack(
                                                              alignment: Alignment.center,
                                                              children: [
                                                                Icon(Icons.circle, color: (status != 'cancel')?(chatUserCount != '0')?CustomColor.redBtn:Colors.transparent:Colors.transparent, size: 22,),
                                                                CustomText.bodyMedium14(text: chatUserCount, color: (status != 'cancel')?(chatUserCount != '0')?Colors.white:Colors.transparent:Colors.transparent, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  // Navigator.pop(context);
                                                  print(phoneRestoTrans);
                                                  launch("tel:$phoneRestoTrans");
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Row(
                                                    children: [
                                                      Icon(FontAwesome.phone, color: CustomColor.redBtn, size: 27.5,),
                                                      SizedBox(width: CustomSize.sizeWidth(context) / 88,),
                                                      CustomText.textHeading5(
                                                          text: "Telpon",
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.043).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.043)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.043)).toString()),
                                                          maxLines: 1,
                                                          color: CustomColor.redBtn
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 42,),
                                      ],
                                    );
                                  }
                              );
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //         type: PageTransitionType.rightToLeft,
                              //         child: new ChatActivity(chatroom, userName, status)));
                            },
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
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                        child: CustomText.textTitle2(text: "Hubungi Penjual", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                      ),
                                      Positioned(  // draw a red marble
                                        top: 0,
                                        right: 0,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle, color: (chatUserCount != '0')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                            CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0')?Colors.white:Colors.transparent, minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ):SizedBox(),
                          (status == 'cancel' && type != 'dinein')?SizedBox(height: CustomSize.sizeHeight(context) / 88,):SizedBox(),
                          (status == 'cancel' && type != 'dinein')?GestureDetector(
                            onTap: (){
                              if (inCart.toString() == '') {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                    ),
                                    context: context,
                                    builder: (_){
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                              child: Divider(thickness: 4,),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                            GestureDetector(
                                              onTap: ()async{
                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                setState(() {
                                                  if (can_delivery == 'true') {
                                                    toCart().whenComplete((){
                                                      Navigator.push(context, PageTransition(
                                                          type: PageTransitionType.rightToLeft,
                                                          child: CartActivity()));
                                                    });
                                                    setState(() {});

                                                    pref.setString("metodeBeli", '1');
                                                  } else {
                                                    Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                  }
                                                });
                                                Navigator.pop(_);
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 8,
                                                    height: CustomSize.sizeWidth(context) / 8,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.primaryLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(
                                                      child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                    ),
                                                  ),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                  CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            GestureDetector(
                                              onTap: ()async{
                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                setState(() {
                                                  if (can_takeaway == 'true') {
                                                    toCart().whenComplete((){
                                                      Navigator.push(context, PageTransition(
                                                          type: PageTransitionType.rightToLeft,
                                                          child: CartActivity()));
                                                    });
                                                    setState(() {});

                                                    pref.setString("metodeBeli", '2');
                                                  } else {
                                                    Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                  }
                                                });
                                                Navigator.pop(_);
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 8,
                                                    height: CustomSize.sizeWidth(context) / 8,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.primaryLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(
                                                      child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                    ),
                                                  ),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                  CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                            GestureDetector(
                                              onTap: ()async{
                                                SharedPreferences pref = await SharedPreferences.getInstance();
                                                toCart().whenComplete((){
                                                  Navigator.push(context, PageTransition(
                                                      type: PageTransitionType.rightToLeft,
                                                      child: CartActivity()));
                                                });

                                                setState(() {
                                                  pref.setString("metodeBeli", '3');
                                                });
                                                Navigator.pop(_);
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: CustomSize.sizeWidth(context) / 8,
                                                    height: CustomSize.sizeWidth(context) / 8,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.primaryLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(
                                                      child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                    ),
                                                  ),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                  CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          ],
                                        ),
                                      );
                                    }
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: new Text("Hapus cart"),
                                      content: new Text("Apakah anda ingin mengganti item di cart dengan item yang baru ?"),
                                      actions: <Widget>[
                                        new TextButton(
                                          child: new Text("Batal", style: TextStyle(color: CustomColor.primaryLight)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        new TextButton(
                                          child: new Text("Oke", style: TextStyle(color: CustomColor.primaryLight)),
                                          onPressed: () async{
                                            delCart().whenComplete((){
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                                  ),
                                                  context: context,
                                                  builder: (_){
                                                    return Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                                            child: Divider(thickness: 4,),
                                                          ),
                                                          SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                                          GestureDetector(
                                                            onTap: ()async{
                                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                                              setState(() {
                                                                if (can_delivery == 'true') {
                                                                  // Navigator.pop(_);
                                                                  toCart2().whenComplete((){
                                                                  });
                                                                  // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                                  //   Navigator.push(context, PageTransition(
                                                                  //       type: PageTransitionType.rightToLeft,
                                                                  //       child: CartActivity()));
                                                                  // });

                                                                  setState(() {});

                                                                  pref.setString("metodeBeli", '1');
                                                                } else {
                                                                  Fluttertoast.showToast(msg: "Pesan antar tidak tersedia.");
                                                                }
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: CustomSize.sizeWidth(context) / 8,
                                                                  height: CustomSize.sizeWidth(context) / 8,
                                                                  decoration: BoxDecoration(
                                                                      color: CustomColor.primaryLight,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                                  ),
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                CustomText.textHeading6(text: "Pesan Antar", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                          GestureDetector(
                                                            onTap: ()async{
                                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                                              setState(() {
                                                                if (can_takeaway == 'true') {
                                                                  // Navigator.pop(_);
                                                                  toCart2().whenComplete((){
                                                                  });
                                                                  // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                                  //   Navigator.push(context, PageTransition(
                                                                  //       type: PageTransitionType.rightToLeft,
                                                                  //       child: CartActivity()));
                                                                  // });

                                                                  setState(() {});

                                                                  pref.setString("metodeBeli", '2');
                                                                } else {
                                                                  Fluttertoast.showToast(msg: "Ambil langsung tidak tersedia.");
                                                                }
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: CustomSize.sizeWidth(context) / 8,
                                                                  height: CustomSize.sizeWidth(context) / 8,
                                                                  decoration: BoxDecoration(
                                                                      color: CustomColor.primaryLight,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                                  ),
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                CustomText.textHeading6(text: "Ambil Langsung", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                          GestureDetector(
                                                            onTap: ()async{
                                                              SharedPreferences pref = await SharedPreferences.getInstance();
                                                              // Navigator.pop(_);
                                                              toCart2().whenComplete((){
                                                              });
                                                              // Future.delayed(Duration(seconds: 2)).whenComplete((){
                                                              //   Navigator.push(context, PageTransition(
                                                              //       type: PageTransitionType.rightToLeft,
                                                              //       child: CartActivity()));
                                                              // });

                                                              // setState(() {});

                                                              setState(() {
                                                                pref.setString("metodeBeli", '3');
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: CustomSize.sizeWidth(context) / 8,
                                                                  height: CustomSize.sizeWidth(context) / 8,
                                                                  decoration: BoxDecoration(
                                                                      color: CustomColor.primaryLight,
                                                                      shape: BoxShape.circle
                                                                  ),
                                                                  child: Center(
                                                                    child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                                  ),
                                                                ),
                                                                SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                                                CustomText.textHeading6(text: "Makan Ditempat", minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                              );
                                            });
                                            // await Future.delayed(Duration(seconds: 2));
                                            Navigator.of(context).pop();
                                            // Navigator.pushReplacement(
                                            //     context,
                                            //     PageTransition(
                                            //         type: PageTransitionType.rightToLeft,
                                            //         child: new DetailResto(id)));
                                            // pref.remove('inCart');
                                            // pref.setString("menuJson", "");
                                            // inCart = pref.getString("inCart");
                                            // cart = pref.getString("inCart");
                                            // qty.addAll([]);
                                            // json2 = pref.getString("menuJson");
                                            // pref.setString("qty", "");
                                            // pref.remove("restoIdUsr");

                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 1.1,
                              height: CustomSize.sizeHeight(context) / 14,
                              decoration: BoxDecoration(
                                  color: CustomColor.accent,
                                  borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
                                        child: CustomText.textTitle2(text: "Lanjut Lagi", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())),
                                      ),
                                      // Positioned(  // draw a red marble
                                      //   top: 0,
                                      //   right: 0,
                                      //   child: Stack(
                                      //     alignment: Alignment.center,
                                      //     children: [
                                      //       Icon(Icons.circle, color: (chatUserCount != '0')?CustomColor.redBtn:Colors.transparent, size: 22,),
                                      //       CustomText.bodyMedium14(text: chatUserCount, color: (chatUserCount != '0')?Colors.white:Colors.transparent)
                                      //     ],
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ):SizedBox(),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                        ],
                      ),
                    ),
                  ],
              ),
            ),
                ),
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: (chatroom != 'null')?GestureDetector(
          //   onTap: (){
          //     showModalBottomSheet(
          //         isScrollControlled: true,
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
          //         ),
          //         context: context,
          //         builder: (_){
          //           return Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               SizedBox(height: CustomSize.sizeHeight(context) / 86,),
          //               Padding(
          //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
          //                 child: Divider(thickness: 4,),
          //               ),
          //               SizedBox(height: CustomSize.sizeHeight(context) / 106,),
          //               Padding(
          //                 padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
          //                 child: Row(
          //                   crossAxisAlignment: CrossAxisAlignment.center,
          //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //                   children: [
          //                     GestureDetector(
          //                       onTap: (){
          //                         // Navigator.pop(context);
          //                         Navigator.push(
          //                             context,
          //                             PageTransition(
          //                                 type: PageTransitionType.rightToLeft,
          //                                 child: new ChatActivity(chatroom, userName, status)));
          //                       },
          //                       child: Padding(
          //                         padding: const EdgeInsets.symmetric(vertical: 8.0),
          //                         child: Row(
          //                           children: [
          //                             Icon(FontAwesome.comments_o, color: CustomColor.accent, size: 31,),
          //                             SizedBox(width: CustomSize.sizeWidth(context) / 72,),
          //                             CustomText.textHeading5(
          //                                 text: "Chat",
          //                                 minSize: 17,
          //                                 maxLines: 1,
          //                                 color: CustomColor.accent
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                     GestureDetector(
          //                       onTap: (){
          //                         // Navigator.pop(context);
          //                         launch("tel:$phone");
          //                       },
          //                       child: Padding(
          //                         padding: const EdgeInsets.symmetric(vertical: 8.0),
          //                         child: Row(
          //                           children: [
          //                             Icon(FontAwesome.phone, color: CustomColor.redBtn, size: 27.5,),
          //                             SizedBox(width: CustomSize.sizeWidth(context) / 88,),
          //                             CustomText.textHeading5(
          //                                 text: "Telpon",
          //                                 minSize: 17,
          //                                 maxLines: 1,
          //                                 color: CustomColor.redBtn
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               SizedBox(height: CustomSize.sizeHeight(context) / 42,),
          //             ],
          //           );
          //         }
          //     );
          //     // Navigator.push(
          //     //     context,
          //     //     PageTransition(
          //     //         type: PageTransitionType.rightToLeft,
          //     //         child: new ChatActivity(chatroom, userName, status)));
          //   },
          //   child: Container(
          //     width: CustomSize.sizeWidth(context) / 1.1,
          //     height: CustomSize.sizeHeight(context) / 14,
          //     decoration: BoxDecoration(
          //         color: CustomColor.accent,
          //         borderRadius: BorderRadius.circular(50)
          //     ),
          //     child: Center(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //         child: CustomText.textTitle2(text: "Hubungi Penjual", color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ):SizedBox(),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
