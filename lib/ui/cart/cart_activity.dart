import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/model/MenuJson.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/search_address_maps.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:http/http.dart' as http;

class Location {
  /// Initializes the plugin and starts listening for potential platform events.
  factory Location() => instance;

  Location._();

  static final Location instance = Location._();

  /// Change settings of the location request.
  ///
  /// The [accuracy] argument is controlling the precision of the
  /// [LocationData]. The [interval] and [distanceFilter] are controlling how
  /// often a new location is sent through [onLocationChanged].
  ///
  /// [interval] and [distanceFilter] are not used on web.

  /// Gets the current location of the user.
  ///
  /// Throws an error if the app has no permission to access location.
  /// Returns a [LocationData] object.
  Future<LocationData> getLocation() async {
    return LocationPlatform.instance.getLocation();
  }

  /// Checks if the app has permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> hasPermission() {
    return LocationPlatform.instance.hasPermission();
  }

  /// Requests permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> requestPermission() {
    return LocationPlatform.instance.requestPermission();
  }

  /// Checks if the location service is enabled.
  Future<bool> serviceEnabled() {
    return LocationPlatform.instance.serviceEnabled();
  }

  /// Request the activation of the location service.
  Future<bool> requestService() {
    return LocationPlatform.instance.requestService();
  }

  /// Returns a stream of [LocationData] objects.
  /// The frequency and accuracy of this stream can be changed with
  /// [changeSettings]
  ///
  /// Throws an error if the app has no permission to access location.
  Stream<LocationData> get onLocationChanged {
    return LocationPlatform.instance.onLocationChanged;
  }
}

class CartActivity extends StatefulWidget {
  @override
  _CartActivityState createState() => _CartActivityState();
}

class _CartActivityState extends State<CartActivity> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _srchAddress = TextEditingController(text: "");
  bool isLoading = false;

  String name = '';
  int harga = 0;
  List<String> restoId = [];
  List<String> qty = [];
  String _restId = '';
  String _qty = '';
  String restoAddress = '';
  bool srchAddress = false;
  bool srchAddress2 = false;
  List<int> indexCart = [];
  List<MenuJson> _tempMenu = [];
  List<String> _tempRestoId = [];
  List<String> _tempQty = [];

  //delivery = 1
  //takeaway = 2
  //dinein = 3
  int _transCode = 1;

  double latitude;
  double longitude;

  String ongkir;
  String totalOngkir = "0";
  String totalHarga = "0";

  List<MenuJson> menuJson = [];
  List<bool> menuReady = [];
  Future _getData()async{
    List<MenuJson> _menuJson = [];
    List<String> _menuId = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    name = (pref2.getString('menuJson')??"");
    restoId.addAll(pref2.getStringList('restoId')??[]);
    qty.addAll(pref2.getStringList('qty')??[]);
    _tempRestoId.addAll(pref2.getStringList('restoId')??[]);
    _tempQty.addAll(pref2.getStringList('qty')??[]);
    var data = json.decode(name);
    print(data);

    for(var v in data){
      _menuId.add(v['id'].toString());
      MenuJson j = MenuJson(
          id: v['id'],
          name: v['name'],
          restoName: v['restoName'],
          desc: v['desc'],
          distance: v['distance'],
          price: v['price'],
          discount: v['discounted_price'],
          urlImg: v['urlImg']
      );
      _menuJson.add(j);
      harga = harga + int.parse(v['price']) * int.parse(qty[restoId.indexOf(v['id'].toString())]);
      totalHarga = harga.toString();
    }
    print(_menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', ''));

    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/trans/check',
        body: {'menu': _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '')},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    print(apiResult.body);
    var data1 = json.decode(apiResult.body);

    for(var v in data1['menu']){
      menuReady.add(v['ready']);
      // deleteAnimation.add(false);
    }

    // print(deleteAnimation);
    setState(() {
      ongkir = data1['ongkir'].toString();
      restoAddress = data1['address'];
      menuJson = _menuJson;
      _tempMenu = _menuJson;
      _restId = _menuId.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      _qty = qty.toString().split('[')[1].split(']')[0].replaceAll(' ', '');
      isLoading = false;
    });
  }

  Future<String> makeTransaction(String qrscan)async{
    print(qrscan);
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.post(Links.mainUrl + '/trans',
        body: {
          'address': (_transCode == 1)?_srchAddress.text.toString():'',
          'type': (_transCode == 1)?'delivery':(_transCode == 2)?'takeaway':'dinein',
          'ongkir': totalOngkir??'0',
          'discount': '0',
          'menu': _restId,
          'qty': _qty,
          'barcode': qrscan
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('menuJson');
      await preferences.remove('restoId');
      await preferences.remove('qty');
      await preferences.remove('address');
      await preferences.remove('inCart');
    }
  }

  @override
  void initState() {
    Location.instance.getLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: HomeActivity()));
      },
      child: Scaffold(
        body: SafeArea(
          child: (isLoading)?Container(
              width: CustomSize.sizeWidth(context),
              height: CustomSize.sizeHeight(context),
              child: Center(child: CircularProgressIndicator())):SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (_transCode == 2)?Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      CustomText.bodyLight12(text: "Alamat Restoran"),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      CustomText.textHeading6(
                          text: restoAddress,
                          minSize: 16,
                          maxLines: 10
                      ),
                    ],
                  ),
                ):SizedBox(),
                (_transCode == 1)?Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      CustomText.bodyLight12(text: "Alamat Pengiriman"),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      (srchAddress != true)?CustomText.textHeading4(
                          text: (_srchAddress.text.toString() == "")?"Masukkan alamat anda.":_srchAddress.text.toString(),
                          minSize: 16,
                          maxLines: 10
                      ):TextField(
                        controller: _srchAddress,
                        keyboardType: TextInputType.name,
                        cursorColor: Colors.black,
                        autofocus: true,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.008,),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async{
                              SharedPreferences pref2 = await SharedPreferences.getInstance();
                              if (srchAddress == false) {
                                srchAddress = true;
                              } else {
                                srchAddress = false;
                                List<Placemark> placemark = await Geolocator().placemarkFromAddress(_srchAddress.text);
                                double distan = await Geolocator().distanceBetween( double.parse(pref2.getString('latResto')), double.parse(pref2.getString('longResto')), placemark[0].position.latitude, placemark[0].position.longitude);
                                int _ongkir = int.parse(ongkir);
                                String dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(distan.toString().split('.')[0]));
                                int _distan = int.parse(dist.split('.')[0]);
                                if (_distan != 0) {
                                  int _totalOngkir = _ongkir * _distan;
                                  totalOngkir = _totalOngkir.toString();
                                  int _totalHarga = harga + _totalOngkir;
                                  totalHarga = _totalHarga.toString();
                                } else {
                                  totalOngkir = ongkir;
                                  int _totalHarga = harga + int.parse(totalOngkir);
                                  totalHarga = _totalHarga.toString();
                                }
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 3,
                              height: CustomSize.sizeHeight(context) / 22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black, width: 0.5)
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (srchAddress != true)?Icon(Octicons.pencil, size: 14,):Container(),
                                    (srchAddress != true)?SizedBox(width: CustomSize.sizeWidth(context) / 86,):Container(),
                                    (srchAddress != true)?CustomText.bodyMedium12(text: "Ganti Alamat"):CustomText.bodyMedium12(text: "Simpan")
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: CustomSize.sizeWidth(context) / 45,),
                          (srchAddress != true)?GestureDetector(
                            onTap: () async{
                              var result = await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: SearchAddressMaps(latitude,longitude)));
                              if(result != ""){
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                _srchAddress = TextEditingController(text: pref.getString('address'));
                                int _ongkir = int.parse(ongkir);
                                String dist = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(pref.getString('distan')));
                                int _distan = int.parse(dist.split('.')[0]);
                                if (_distan != 0) {
                                  int _totalOngkir = _ongkir * _distan;
                                  totalOngkir = _totalOngkir.toString();
                                  int _totalHarga = harga + _totalOngkir;
                                  totalHarga = _totalHarga.toString();
                                } else {
                                  totalOngkir = ongkir;
                                  int _totalHarga = harga + int.parse(totalOngkir);
                                  totalHarga = _totalHarga.toString();
                                }
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 3,
                              height: CustomSize.sizeHeight(context) / 22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black, width: 0.5)
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (srchAddress2 != true)?Icon(FontAwesome.map_marker, size: 14,):Container(),
                                    (srchAddress2 != true)?SizedBox(width: CustomSize.sizeWidth(context) / 86,):Container(),
                                    (srchAddress2 != true)?CustomText.bodyMedium12(text: "Via Map"):CustomText.bodyMedium12(text: "Simpan")
                                  ],
                                ),
                              ),
                            ),
                          ):Container(),
                        ],
                      ),
                    ],
                  ),
                ):SizedBox(),
                (_transCode == 1 || _transCode == 2)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                (_transCode == 1 || _transCode == 2)?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: CustomSize.sizeWidth(context) / 8,
                            height: CustomSize.sizeWidth(context) / 8,
                            decoration: BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                            ),
                            child: Center(
                              child: Icon((_transCode == 1)?FontAwesome.motorcycle:(_transCode == 2)?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                            ),
                          ),
                          SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          CustomText.textHeading6(text: (_transCode == 1)?"Pesan Antar":(_transCode == 2)?"Ambil Langsung":"Makan Ditempat",),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                        child: GestureDetector(
                          onTap: (){
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
                                          onTap: (){
                                            setState(() {
                                              _transCode = 1;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 8,
                                                height: CustomSize.sizeWidth(context) / 8,
                                                decoration: BoxDecoration(
                                                    color: CustomColor.primary,
                                                    shape: BoxShape.circle
                                                ),
                                                child: Center(
                                                  child: Icon(FontAwesome.motorcycle, color: Colors.white, size: 20,),
                                                ),
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                              CustomText.textHeading6(text: "Pesan Antar",),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              _transCode = 2;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 8,
                                                height: CustomSize.sizeWidth(context) / 8,
                                                decoration: BoxDecoration(
                                                    color: CustomColor.primary,
                                                    shape: BoxShape.circle
                                                ),
                                                child: Center(
                                                  child: Icon(MaterialCommunityIcons.shopping, color: Colors.white, size: 20,),
                                                ),
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                              CustomText.textHeading6(text: "Ambil Langsung",),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              _transCode = 3;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: CustomSize.sizeWidth(context) / 8,
                                                height: CustomSize.sizeWidth(context) / 8,
                                                decoration: BoxDecoration(
                                                    color: CustomColor.primary,
                                                    shape: BoxShape.circle
                                                ),
                                                child: Center(
                                                  child: Icon(Icons.restaurant, color: Colors.white, size: 20,),
                                                ),
                                              ),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                              CustomText.textHeading6(text: "Makan Ditempat",),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      ],
                                    ),
                                  );
                                }
                            );
                          },
                          child: Container(
                            height: CustomSize.sizeHeight(context) / 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: CustomColor.accent, width: 1),
                              // color: CustomColor.accentLight
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                              child: Center(
                                child: CustomText.textTitle8(
                                    text: "Ganti",
                                    color: CustomColor.accent
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                Divider(thickness: 6, color: CustomColor.secondary,),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: menuJson.length,
                    itemBuilder: (_, index){
                      return Padding(
                        padding: EdgeInsets.only(
                          top: CustomSize.sizeWidth(context) / 32,
                          left: CustomSize.sizeWidth(context) / 32,
                          right: CustomSize.sizeWidth(context) / 32,
                        ),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: CustomSize.sizeWidth(context),
                          height: (int.parse(qty[restoId.indexOf(menuJson[index].id.toString())]) <= 0) ? 0 : CustomSize.sizeHeight(context) / 4.4,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  child: Container(
                                    height: CustomSize.sizeHeight(context) / 5.3,
                                    child: Row(
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
                                                children: [
                                                  CustomText.textHeading4(
                                                      text: menuJson[index].name,
                                                      minSize: 18,
                                                      maxLines: 1
                                                  ),
                                                  CustomText.bodyRegular14(
                                                      text: menuJson[index].desc,
                                                      maxLines: 2,
                                                      minSize: 14
                                                  ),
                                                  SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                                  CustomText.bodyMedium14(
                                                      text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(menuJson[index].price)),
                                                      maxLines: 1,
                                                      minSize: 16
                                                  ),
                                                ],
                                              ),
                                              (menuReady[index])?Container():CustomText.bodyMedium14(
                                                  text: "Menu tidak tersedia.",
                                                  maxLines: 1,
                                                  color: Colors.red
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
                                                      image: NetworkImage(Links.subUrl + menuJson[index].urlImg),
                                                      fit: BoxFit.cover
                                                  ),
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: ()async{
                                                    print(index);
                                                    String s = qty[restoId.indexOf(menuJson[index].id.toString())];
                                                    int i = int.parse(s) - 1;
                                                    print(i);
                                                    qty[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setStringList("qty", qty);
                                                    harga = harga - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price);
                                                    int _total = int.parse(totalHarga) - int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price);
                                                    totalHarga = _total.toString();

                                                    if(i == 0){
                                                      qty.removeAt(index);
                                                      menuJson.removeAt(index);
                                                      restoId.removeAt(index);
                                                      String json = jsonEncode(menuJson.map((m) => m.toJson()).toList());
                                                      print(json);
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      pref.setString("menuJson", json);
                                                      pref.setStringList("restoId", restoId);
                                                      pref.setStringList("qty", qty);

                                                      if(_tempMenu.length == 0){
                                                        pref.setString("inCart", '');
                                                      }
                                                    }
                                                    print(harga);
                                                    setState(() {});
                                                    // if(deleteAnimation[index] != true){
                                                    // if(int.parse(qty[restoId.indexOf(menuJson[index].id.toString())]) > 1){

                                                    // }else{
                                                    // setState(() {
                                                    //   deleteAnimation[index] = true;
                                                    // });
                                                    // print(deleteAnimation);
                                                    // _tempQty.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // _tempMenu.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // _tempRestoId.removeAt(_tempRestoId.indexOf(menuJson[index].id.toString()));
                                                    // String json = jsonEncode(_tempMenu.map((m) => m.toJson()).toList());
                                                    // print(json);
                                                    // SharedPreferences pref = await SharedPreferences.getInstance();
                                                    // pref.setString("menuJson", json);
                                                    // pref.setStringList("restoId", _tempRestoId);
                                                    // pref.setStringList("qty", _tempQty);
                                                    //
                                                    // if(_tempMenu.length == 0){
                                                    //   pref.setString("inCart", '');
                                                    // }
                                                    // }
                                                    // }
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 12,
                                                    height: CustomSize.sizeWidth(context) / 12,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.accentLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(child: CustomText.textHeading1(text: "-", color: CustomColor.accent)),
                                                  ),
                                                ),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                CustomText.bodyRegular16(text: qty[index]),
                                                SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                                                GestureDetector(
                                                  onTap: ()async{
                                                    String s = qty[restoId.indexOf(menuJson[index].id.toString())];
                                                    print(s);
                                                    int i = int.parse(s) + 1;
                                                    print(i);
                                                    qty[restoId.indexOf(menuJson[index].id.toString())] = i.toString();
                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                    pref.setStringList("qty", qty);
                                                    harga = harga + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price);
                                                    int _total = int.parse(totalHarga) + int.parse(menuJson[restoId.indexOf(menuJson[index].id.toString())].price);
                                                    totalHarga = _total.toString();
                                                    print(harga);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 12,
                                                    height: CustomSize.sizeWidth(context) / 12,
                                                    decoration: BoxDecoration(
                                                        color: CustomColor.accentLight,
                                                        shape: BoxShape.circle
                                                    ),
                                                    child: Center(child: CustomText.textHeading1(text: "+", color: CustomColor.accent)),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider()
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //       horizontal: CustomSize.sizeWidth(context) / 32,
                //       vertical: CustomSize.sizeHeight(context) / 86
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Container(
                //         width: CustomSize.sizeWidth(context) / 1.6,
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             CustomText.textHeading4(text: "Ada lagi pesanannya ?"),
                //             CustomText.bodyRegular16(text: "Masih bisa tambah lagi loo")
                //           ],
                //         ),
                //       ),
                //       Padding(
                //         padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                //         child: Container(
                //           height: CustomSize.sizeHeight(context) / 24,
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(20),
                //               border: Border.all(color: CustomColor.accent)
                //           ),
                //           child: Padding(
                //             padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                //             child: Center(
                //               child: CustomText.textTitle8(
                //                   text: "Tambah",
                //                   color: CustomColor.accent
                //               ),
                //             ),
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                Container(
                  width: CustomSize.sizeWidth(context),
                  decoration: BoxDecoration(
                      color: CustomColor.secondary
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 22.5,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                        child: Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 3.8,
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
                                CustomText.textTitle3(text: "Rincian Pembayaran"),
                                SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Harga"),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)),
                                  ],
                                ),
                                (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                                (_transCode == 1)?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Ongkir"),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalOngkir))),
                                  ],
                                ):SizedBox(),
                                SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                Divider(thickness: 1,),
                                SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Total Pembayaran"),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                      GestureDetector(
                        onTap: ()async{
                          String qrcode = '';
                          if(_transCode == 3){
                            try {
                              qrcode = await BarcodeScanner.scan();
                              setState(() {});
                              makeTransaction(qrcode);
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      child: HomeActivity()));
                            } on PlatformException catch (error) {
                              if (error.code == BarcodeScanner.CameraAccessDenied) {
                                print('Izin kamera tidak diizinkan oleh si pengguna');
                              } else {
                                print('Error: $error');
                              }
                            }
                          }else{
                            if(_transCode == 1){
                              if(_srchAddress.text != ''){
                                makeTransaction(qrcode);
                                Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.leftToRight,
                                        child: HomeActivity()));
                              }else{
                                Fluttertoast.showToast(
                                  msg: "Alamat tujuan Anda dimana?",);
                              }
                            }else{
                              makeTransaction(qrcode);
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.leftToRight,
                                      child: HomeActivity()));
                            }
                          }
                        },
                        child: Center(
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                                color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primary,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Pesan Sekarang", color: Colors.white),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(totalHarga)), color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
