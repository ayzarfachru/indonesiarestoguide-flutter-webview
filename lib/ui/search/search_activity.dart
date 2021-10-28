import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/model/Cuisine.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Resto.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchActivity extends StatefulWidget {
  List<Menu> promo;
  String lat;
  String long;
  String cui;

  SearchActivity(this.promo, this.lat, this.long, this.cui);

  @override
  _SearchActivityState createState() => _SearchActivityState(promo, lat, long, cui);
}

class _SearchActivityState extends State<SearchActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  List<Menu> promo;
  String lat;
  String long;
  String cui;

  _SearchActivityState(this.promo, this.lat, this.long, this.cui);

  TextEditingController _loginTextName = TextEditingController(text: "");
  ScrollController _scrollController = ScrollController();

  bool isSearch = false;
  List<String> recomMenu = ["Nasi Goreng", "Geprek", "Jus Buah", "Soto", "Es Campur"];

  List<Menu> menu = [];
  List<Resto> resto = [];
  Future _search(String q, String type)async{
    List<Menu> _menu = [];
    List<Resto> _resto = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    print("kota1 = $kota1 ");
    var apiResult = await http.get(Links.mainUrl + '/page/search?q=$q&type=$tipe&lat=$lat&long=$long&limit=0&city=$kota1&facility=$facilityList2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['menu'] != null) {
      for(var v in data['menu']){
        Menu m = Menu(
          id: v['id'],
          name: v['name'],
          restoId: v['resto_id'].toString(),
          restoName: v['resto_name'],
          urlImg: v['img'],
          price: Price.discounted(v['price'], v['discounted_price']),
          distance: double.parse(v['resto_distance'].toString()), type: '', delivery_price: null, desc: '', is_recommended: '', qty: '',
        );
        _menu.add(m);
      }
    }

    for(var v in data['resto']){
      Resto r = Resto.all(
          id: v['id'],
          name: v['name'],
          distance: double.parse(v['distance'].toString()),
          img: v['img'],
          isOpen: v['isOpen'].toString(),
          status: v['status'],
      );
      _resto.add(r);
    }
    setState(() {
      menu = _menu;
      resto = _resto;
    });
  }

  List<Cuisine> cuisine = [];
  Future getUtil()async{
    List<Cuisine> _cuisine = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/util/data',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['data']){
      Cuisine c = Cuisine(
        id: v['id'],
        name: v['name']
      );
      _cuisine.add(c);
    }
    setState(() {
      cuisine = _cuisine;
    });
  }

  Widget MyListTileBuilderImplementation() {
    return ListTile (
        title: Center(child: CustomText.bodyMedium12(text: 'Tidak ditemukan.')) //this is the text
    );
  }

  String provinsi = '';
  String fasilitas = '';
  String idFasilitas = '';
  String idProv = '';
  String tipe = '';

  List<String> prov = [];
  Future getProv()async{
    List<String> _prov = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get('http://irg.devus-sby.com/api/v2/util/province',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data){
      prov.add(v['name']);
    }

    // for(var v in data['provinsi']){
    //   Cuisine c = Cuisine(
    //       id: v['id'],
    //       name: v['nama']
    //   );
    //   _prov.add(c);
    // }
    setState(() {
      // prov = _prov;
    });

    if (apiResult.statusCode == 200 && provinsi != '') {
      getProv2();
    }
  }

  // List<String> prov = [];
  List<Cuisine> provId = [];
  String provId2 = '';
  Future getProv2()async{
    List<Cuisine> _prov2 = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get('http://irg.devus-sby.com/api/v2/util/province',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    // for(var v in data['provinsi']){
    //   prov.add(v['nama']);
    // }

    for(var v in data){
      Cuisine c = Cuisine(
          id: int.parse(v['id'].toString()),
          name: v['name']
      );
      _prov2.add(c);
    }
    setState(() {
      provId = _prov2.where((element) => element.name.toLowerCase().contains(provinsi.toLowerCase())).toList();
      provId2 = provId.single.id.toString();
      // prov = _prov;
    });

    if (apiResult.statusCode == 200) {
      getKota();
    }
  }

  List<String> kota = [];
  String kota1 = '';
  Future getKota()async{
    List<String> _kota = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get('http://irg.devus-sby.com/api/v2/util/city/$provId2',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data){
      kota.add(v['name']);
    }

    // for(var v in data['provinsi']){
    //   Cuisine c = Cuisine(
    //       id: v['id'],
    //       name: v['nama']
    //   );
    //   _prov.add(c);
    // }
    setState(() {
      // prov = _prov;
    });

    if (apiResult.statusCode == 200) {
      // getProv2();
      setState(() {

      });
    }
  }


  showAlertDialog() {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Simpan", style: TextStyle(color: CustomColor.primary),),
      onPressed: () async{
        if (provinsi != '' && kota1 == '') {
          Fluttertoast.showToast(msg: "Pilih kota terlebih dahulu!",);
        } else {
          print(provinsi);
          Navigator.pop(context);
          _search(_loginTextName.text, '');
          setState(() {
            isSearch = true;
          });
        }
      },
    );

    Widget cancelButton = TextButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary),),
      onPressed: () {
        provinsi = '';
        kota1 = '';
        kota = [];
        facilityList2 = '';
        fasilitas = '';
        tipe = '';
        setState(() {});
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Filter"),
      content: StatefulBuilder(
          builder: (_, setStateModal){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,
                      emptyBuilder: (context, index) {
                        return MyListTileBuilderImplementation(); //This is where the ListTile will go.
                      },
                      // dropdownSearchDecoration: InputDecoration(counterText: ''),
                      items: prov,
                      label: "Pilih Provinsi",
                      onChanged: (data) {
                        print(data);
                        kota = [];
                        provinsi = data!;
                        getProv2();
                        setState(() {});
                        setStateModal(() {});
                      },
                      selectedItem: (provinsi == '')?null:provinsi,
                      // selectedItem: "Brazil",
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "Search Provinsi",
                        ),
                      ),
                      popupShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  (provinsi != '')?Expanded(
                    flex: 1,
                      child: GestureDetector(
                          onTap: (){
                            kota = [];
                            kota1 = '';
                            provinsi = '';
                            setState(() {});
                            setStateModal(() {});
                          },
                          child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                      )
                  ):Container()
                ],
              ),
              (provinsi.toString() != '')?SizedBox(height: CustomSize.sizeHeight(context) / 86,):Container(),
              (provinsi.toString() != '')?Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,
                      emptyBuilder: (context, index) {
                        return MyListTileBuilderImplementation(); //This is where the ListTile will go.
                      },
                      // dropdownSearchDecoration: InputDecoration(counterText: ''),
                      items: kota,
                      label: "Pilih Kota",
                      onChanged: (data) {
                        print(data);
                        // idProv = data!;
                        kota1 = data!.toString();
                        setState(() {});
                        setStateModal(() {});
                      },
                      selectedItem: (kota1 == '')?null:kota1,
                      // selectedItem: "Brazil",
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "Search Kota",
                        ),
                      ),
                      popupShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // (kota1.toString() != '')?Expanded(
                  //     flex: 1,
                  //     child: GestureDetector(
                  //         onTap: (){
                  //           kota1 = '';
                  //           // print(kota1.toString());
                  //           // kota = [];
                  //           // idProv = '';
                  //           setState(() {});
                  //           setStateModal(() {});
                  //         },
                  //         child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                  //     )
                  // ):Container()
                ],
              ):Container(),
              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,
                      emptyBuilder: (context, index) {
                        return MyListTileBuilderImplementation(); //This is where the ListTile will go.
                      },
                      items: cuisineList,
                      label: "Pilih Cuisine",
                      // emptyBuilder: (child) => Badge(child: child!),
                      onChanged: (data) {
                        print(data);
                        // tipe = data!;
                        // setState(() {});
                        // setStateModal(() {});
                        // idFasilitas = data!;
                        tipe = data!;
                        // getFacilityid();
                        setState(() {});
                        setStateModal(() {});
                        // if (tipe.contains(data!) && tipe != '') {
                        //   Navigator.pop(context);
                        //   Fluttertoast.showToast(msg: "Tipe sudah anda pilih");
                        //   // data = false;
                        // } else {
                        //   if (tipe != "") {
                        //     tipe = tipe+', '+data;
                        //     setState(() {});
                        //     setStateModal(() {});
                        //   } else {
                        //     tipe = data;
                        //     setState(() {});
                        //     setStateModal(() {});
                        //   }
                        // }
                      },
                      selectedItem: (tipe == '')?null:tipe,
                      // selectedItem: "Brazil",
                      showSearchBox: true,

                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "Search Tipe Resto",
                        ),
                      ),
                      popupShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  (tipe != '')?Expanded(
                      flex: 1,
                      child: GestureDetector(
                          onTap: (){
                            tipe = '';
                            setState(() {});
                            setStateModal(() {});
                          },
                          child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                      )
                  ):Container()
                ],
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: DropdownSearch<String>(
                      mode: Mode.BOTTOM_SHEET,
                      emptyBuilder: (context, index) {
                        return MyListTileBuilderImplementation(); //This is where the ListTile will go.
                      },
                      items: facilityList,
                      label: "Pilih Fasilitas",
                      onChanged: (data) {
                        idFasilitas = data!;
                        fasilitas = data;
                        getFacilityid();
                        setState(() {});
                        setStateModal(() {});
                        // print(fasilitas);
                        // fasilitas = data!;
                        // fasilitas = data!.splitMapJoin(',');
                        // if (fasilitas.contains(data) && fasilitas != '') {
                        //   Navigator.pop(context);
                        //   Fluttertoast.showToast(msg: "Fasilitas sudah anda pilih");
                        //   // data = false;
                        // } else {
                        //   if (fasilitas != "") {
                        //     fasilitas = fasilitas+', '+data;
                        //     getFacilityid();
                        //     setState(() {});
                        //     setStateModal(() {});
                        //   } else {
                        //     fasilitas = data;
                        //     getFacilityid();
                        //     setState(() {});
                        //     setStateModal(() {});
                        //   }
                        // }
                      },
                      selectedItem: (fasilitas == '')?null:fasilitas,
                      // selectedItem: "Brazil",
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "Search Fasilitas Resto",
                        ),
                      ),
                      popupShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  (fasilitas != '')?Expanded(
                      flex: 1,
                      child: GestureDetector(
                          onTap: (){
                            fasilitas = '';
                            facilityList2 = '';
                            setState(() {});
                            setStateModal(() {});
                          },
                          child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                      )
                  ):Container()
                ],
              ),
            ],
          );
        }
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List<String> facilityList = [];
  Future<void> getFacility() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Links.mainUrl +'/util/data?q=facility',
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print('ini id'+jsonData.toString());

    for(var v in jsonData['data']){
      facilityList.add(v['name']);
    }
    setState(() {});
  }

  List<Cuisine> facilityList1 = [];
  String facilityList2 = '';
  Future<void> getFacilityid() async {
    List<Cuisine> _fasilitas = [];

    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Links.mainUrl +'/util/data?q=facility',
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    // print(jsonData);

    // facilityList1.add(jsonData['data'].toString().split('[')[1].split(']')[0]);
    // print('serius id'+facilityList1.toString());
    for(var v in jsonData['data']){
      Cuisine h = Cuisine(
        id: v['id'],
        name: v['name'],
      );
      _fasilitas.add(h);
    }

    setState(() {
      facilityList1 = _fasilitas.where((element) => element.name.toLowerCase().contains(idFasilitas.toLowerCase())).toList();
      facilityList2 = facilityList1.single.id.toString();
      print('${facilityList2}'.toString());
      // for(var b in facilityList1){
      //   facilityList1.add(b['id']);
      // }
    });
  }

  List<String> cuisineList = [];
  Future<void> getCuisine() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Links.mainUrl +'/util/data?q=cuisine',
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print(jsonData);

    for(var v in jsonData['data']){
      cuisineList.add(v['name']);
    }
    setState(() {});
  }


  Future searchHome()async{
    _search('', cui);
    setState(() {
      isSearch = true;
    });
  }
  @override
  void initState() {
    getProv();
    if(cui != ''){
      searchHome();
    }
    getFacility();
    getCuisine();
    facilityList2 = '';
    // getFacilityid();
    getUtil();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                Container(
                  width: CustomSize.sizeWidth(context),
                  height: CustomSize.sizeHeight(context) / 16,
                  decoration: BoxDecoration(
                    color: CustomColor.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesome.search, size: 24, color: Colors.grey,),
                        SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                        Expanded(
                          child: TextField(
                            controller: _loginTextName,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (v){
                              _search(_loginTextName.text, '');
                              setState(() {
                                isSearch = true;
                              });
                            },
                            onChanged: (v){
                              print(v.length);
                              if(v.length == 0){
                                setState(() {
                                  isSearch = false;
                                });
                              }
                            },
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              isDense: true,
                              // contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintText: "Apa yang kamu cari",
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
                        // Row(
                        //   children: [
                        //     (provinsi != '' || fasilitas != '' || tipe != '')?GestureDetector(
                        //       onTap: (){
                        //         // showAlertDialog();
                        //         provinsi = '';
                        //         kota1 = '';
                        //         kota = [];
                        //         facilityList2 = '';
                        //         fasilitas = '';
                        //         tipe = '';
                        //         FocusScope.of(context).unfocus();
                        //         setState(() {});
                        //       },
                        //         child: Icon(Icons.clear, size: 26, color: Colors.grey,)
                        //     ):Container(),
                        //     SizedBox(width: CustomSize.sizeWidth(context) / 82,),
                        //     // GestureDetector(
                        //     //   onTap: (){
                        //     //     showAlertDialog();
                        //     //     FocusScope.of(context).unfocus();
                        //     //   },
                        //     //     child: Icon(FontAwesome.filter, size: 24, color: (provinsi != '' || fasilitas != '' || tipe != '')?Colors.blue:Colors.grey,)
                        //     // ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 98,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: (){
                        showAlertDialog();
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                      child: Container(
                        width: (kota1 != '' || fasilitas != '' || tipe != '')?CustomSize.sizeWidth(context) / 2.3:CustomSize.sizeWidth(context) / 1.1,
                        height: CustomSize.sizeHeight(context) / 22,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(FontAwesome.filter, size: 17, color: (kota1 != '' || fasilitas != '' || tipe != '')?Colors.white:Colors.white,),
                            SizedBox(
                              width: CustomSize.sizeWidth(context) * 0.0075,
                            ),
                            CustomText.textHeading7(
                                text: "Filter",
                              color: Colors.white
                            ),
                          ],
                        ),
                      ),
                    ),
                    (kota1 != '' || fasilitas != '' || tipe != '')?GestureDetector(
                      onTap: (){
                        // showAlertDialog();
                        // FocusScope.of(context).unfocus();
                        // setState(() {});
                        provinsi = '';
                        kota1 = '';
                        kota = [];
                        facilityList2 = '';
                        fasilitas = '';
                        tipe = '';
                        isSearch = false;
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                      child: Container(
                        width: CustomSize.sizeWidth(context) / 2.3,
                        height: CustomSize.sizeHeight(context) / 22,
                        decoration: BoxDecoration(
                          color: CustomColor.redBtn,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(FontAwesome.remove, size: 17, color: (kota1 != '' || fasilitas != '' || tipe != '')?Colors.white:Colors.white,),
                            SizedBox(
                              width: CustomSize.sizeWidth(context) * 0.0075,
                            ),
                            CustomText.textHeading7(
                                text: "Hapus Filter",
                              color: Colors.white
                            ),
                          ],
                        ),
                      ),
                    ):Container(),
                  ],
                ),
                (isSearch != true)?Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Paling banyak Dicari"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 18,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: recomMenu.length,
                            itemBuilder: (_, index){
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
                                child: GestureDetector(
                                  onTap: (){
                                    _search(recomMenu[index], '');
                                    _loginTextName.text = recomMenu[index];
                                    setState(() {
                                      isSearch = true;
                                    });
                                  },
                                  child: Container(
                                    height: CustomSize.sizeHeight(context) / 19,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white),
                                        color: CustomColor.primaryLight
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                      child: Center(
                                        child: CustomText.bodyRegular14(
                                            text: recomMenu[index],
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Jelajahi"
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        height: CustomSize.sizeHeight(context) / 7,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: cuisine.length,
                            itemBuilder: (_, index){
                              return Container(
                                width: CustomSize.sizeWidth(context) / 2.7,
                                child: GestureDetector(
                                  onTap: (){
                                    _search('', '');
                                    tipe = cuisine[index].name;
                                    setState(() {
                                      isSearch = true;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 6,
                                        height: CustomSize.sizeWidth(context) / 6,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: CustomColor.secondary,
                                            image: DecorationImage(
                                                image: AssetImage("assets/type/"+cuisine[index].name.replaceAll('food', 'Food').replaceAll('Food ', 'Food').replaceAll('Modern Melayu', 'Malay Food').replaceAll('Cafe', 'Coffee')+".png"),
                                                fit: BoxFit.cover
                                            )
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyMedium16(
                                          text: cuisine[index].name,
                                          minSize: 16,
                                          maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.textHeading4(
                          text: "Rekomendasi"
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: promo.length,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: new DetailResto(promo[index].restoId.toString())));
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeWidth(context) / 2.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 7), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.6,
                                      height: CustomSize.sizeWidth(context) / 2.6,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(Links.subUrl + promo[index].urlImg),
                                          fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: CustomSize.sizeWidth(context) / 32,
                                    ),
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 2.1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText.bodyLight12(
                                              text: promo[index].distance.toString() + " km",
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.textHeading4(
                                              text: promo[index].name,
                                              minSize: 18,
                                              maxLines: 1
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          CustomText.bodyMedium12(
                                              text: promo[index].restoName,
                                              maxLines: 1,
                                              minSize: 12
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                          Row(
                                            children: [
                                              CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.original), minSize: 12,
                                                  decoration: TextDecoration.lineThrough),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                              CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(promo[index].price!.discounted), minSize: 12),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                    :Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isSearch = false;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.chevronLeft, size: 18,),
                          SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                          CustomText.textTitle3(
                              text: "Kembali ke search",
                              maxLines: 1
                          )
                        ],
                      ),
                    ),
                    (menu.isNotEmpty)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                    (menu.isNotEmpty)?Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Menu",
                          maxLines: 1
                      ),
                    ):SizedBox(),
                    (menu.isNotEmpty)?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 5,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: menu.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: new DetailResto(menu[index].restoId.toString())));
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 1.3,
                                  height: CustomSize.sizeHeight(context) / 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3,
                                        height: CustomSize.sizeHeight(context) / 5,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: CustomSize.sizeHeight(context) / 86),
                                        child: Container(
                                          width: CustomSize.sizeWidth(context) / 2.6,
                                          height: CustomSize.sizeHeight(context) / 5,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // CustomText.bodyRegular12(text: menu[index].distance.toString() + " Km", minSize: 12),
                                                  CustomText.textTitle6(text: menu[index].name, minSize: 14, maxLines: 2),
                                                  CustomText.bodyMedium12(text: menu[index].restoName, minSize: 12),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CustomText.bodyRegular12(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.original), minSize: 12,
                                                      decoration: (menu[index].price!.discounted != null && menu[index].price!.discounted.toString() != '0')?TextDecoration.lineThrough:TextDecoration.none),
                                                  SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                                  (menu[index].price!.discounted != null && menu[index].price!.discounted.toString() != '0')
                                                      ?CustomText.bodyRegular12(
                                                      text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price!.discounted), minSize: 12):SizedBox(),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ):SizedBox(),
                    (resto.isNotEmpty)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):SizedBox(),
                    (resto.isNotEmpty)?Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                      child: CustomText.textTitle2(
                          text: "Resto",
                          maxLines: 1
                      ),
                    ):SizedBox(),
                    (resto.isNotEmpty)?Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 3.6,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: resto.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 20,
                                  top: CustomSize.sizeHeight(context) / 86, bottom: CustomSize.sizeHeight(context) / 86),
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: DetailResto(resto[index].id.toString())));
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context) / 2.3,
                                  height: CustomSize.sizeHeight(context) / 3.6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      (resto[index].status.toString() == 'active')?(resto[index].isOpen.toString() == 'true')?Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 5.8,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(Links.subUrl + resto[index].img!),
                                              fit: BoxFit.cover
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ):Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 5.8,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(Links.subUrl + resto[index].img!),
                                                    fit: BoxFit.cover
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ):Container(
                                        width: CustomSize.sizeWidth(context) / 2.3,
                                        height: CustomSize.sizeHeight(context) / 5.8,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(Links.subUrl + resto[index].img!),
                                                    fit: BoxFit.cover
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyRegular14(text: resto[index].distance.toString() + " km"),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                                        child: CustomText.bodyMedium16(text: resto[index].name),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),
                    ):SizedBox(),
                  ],
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}