import 'dart:convert';
import 'dart:io';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/model/Cuisine.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/payment_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class AddDetailResto extends StatefulWidget {
  @override
  _AddDetailRestoState createState() => _AddDetailRestoState();
}

class CuisineChip extends StatefulWidget {
  final List cuisineList;
  final Function(List<String>) onSelectionChanged;

  CuisineChip(this.cuisineList, {required this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<CuisineChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.cuisineList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          checkmarkColor: Colors.black,
          selectedColor: Colors.green[100],
          selectedShadowColor: Colors.green,
          label: Text(item),
          selected: selectedChoices.contains(item),
          labelStyle: TextStyle(color: Colors.black),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}


class FacilityChip extends StatefulWidget {
  final List<String> facilityList;
  final Function(List<String>) onSelectionChanged;

  FacilityChip(this.facilityList, {required this.onSelectionChanged});

  @override
  _FacilityChipState createState() => _FacilityChipState();
}

class _FacilityChipState extends State<FacilityChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.facilityList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          checkmarkColor: Colors.black,
          selectedColor: Colors.green[100],
          selectedShadowColor: Colors.green,
          label: Text(item),
          selected: selectedChoices.contains(item),
          labelStyle: TextStyle(color: Colors.black),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
              // if (selectedChoices.contains(item) != null) {
              //   selectedChoices.clear();
              //   selectedChoices.add(item);
              // } else {
              //   selectedChoices.add(item);
              // }
              // widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}


class _AddDetailRestoState extends State<AddDetailResto> {
  TextEditingController _Tipe = TextEditingController(text: "");
  TextEditingController _Fasilitas = TextEditingController(text: "");
  TextEditingController _JamOperasional = TextEditingController(text: "");
  TextEditingController _MulaiHarga = TextEditingController(text: "");
  TextEditingController _SampaiHarga = TextEditingController(text: "");
  TextEditingController _Ongkir = TextEditingController(text: "");
  TextEditingController _HargaPerMeja = TextEditingController(text: "");
  TextEditingController _JumlahMeja = TextEditingController(text: "");
  TextEditingController _JamOperasionalBuka = TextEditingController(text: "");
  TextEditingController _JamOperasionalTutup = TextEditingController(text: "");

  TimeOfDay jamBuka = TimeOfDay.now();
  TimeOfDay jamTutup = TimeOfDay.now();
  String? buka;
  String? tutup;

  bool isLoading = false;

  bool takeaway = false;
  bool reservation = false;
  bool delivery = false;

  List cuisineList = [];
  List cuisineList2 = [
    'Indonesian Food',
    'Chinese Food',
    'Japanese Food',
    'Australian Food',
    'Korean Food',
    'Coffe',
    'Orther Drinks'
  ];

  List<String> selectedCuisineList = [];
  String? cuisine;

  _showCuisineDialog() {
    // ListView(
    //     // controller: _controller,
    //     physics: BouncingScrollPhysics(),
    //     padding: EdgeInsets.zero,
    //     shrinkWrap: true,
    //     children: [
    //
    //     ]);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Tipe Resto"),
            content: Container(
              height: CustomSize.sizeHeight(context) / 2.2,
              width: CustomSize.sizeWidth(context) / 1.5,
              child: ListView(
                // controller: _controller,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  CuisineChip(
                    cuisineList,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        selectedCuisineList = selectedList;
                        cuisine = selectedCuisineList.join(",");
                        print(cuisine);
                        if (cuisine != "") {
                          selectedList = cuisine!.split(",");
                        } else {}
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan"),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("cuisine", cuisine);
                  setState(() {
                    print(cuisine);
                    FieldCuisine();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }


  List<String> facilityList = [];
  List<String> facilityList2 = [
    'Kaki Lima',
    'Food Stall',
    'Food Truck',
    'Toko Roti/Kue',
    'Toko Oleh-Oleh',
    'Other'
  ];

  List<String> selectedFacilityList = [];
  String facility = '';

  _showFacilityDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Fasilitas Resto"),
            content: Container(
              height: CustomSize.sizeHeight(context) / 2.2,
              width: CustomSize.sizeWidth(context) / 1.5,
              child: ListView(
                // controller: _controller,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  FacilityChip(
                    facilityList,
                    onSelectionChanged: (selectedList) {
                      setState(() {
                        print(facility);
                        selectedFacilityList = selectedList;
                        facility = selectedFacilityList.join(",");
                        print(facility);
                        if (facility != "") {
                          selectedList = facility.split(",");
                        } else {}
                        // if (facility != "") {
                        //   selectedList = facility!.split(",");
                        // } else {}
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan"),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("facility", facility);
                  setState(() {
                    print(facility);
                    FieldFacility();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }


  FieldCuisine() async {
    _Tipe = TextEditingController(text: cuisine!.replaceAll(',', ', '));
  }

  String cuiOk = '';
  List<String?>? dataCuisine;
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

    if (data.statusCode == 200) {
      cuiOk = 'true';
    }
    setState(() {});
  }

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
    print(jsonData);

    for(var v in jsonData['data']){
      facilityList.add(v['name']);
    }
    setState(() {});
  }

  FieldFacility() async {
    _Fasilitas = TextEditingController(text: facility!.replaceAll(',', ', '));
  }

  void onTimeOpenChanged(TimeOfDay newTime) {
    setState(() {
      jamBuka = newTime;
    });
  }

  void onTimeClosedChanged(TimeOfDay newTime) {
    setState(() {
      jamTutup = newTime;
    });
  }

  getBuka() async {
    _JamOperasionalBuka = (jamBuka.hour != null)?TextEditingController(text: jamBuka.hour.toString() + ':' + jamBuka.minute.toString()):TextEditingController(text: "");
  }

  getTutup() async {
    _JamOperasionalTutup = (jamTutup.hour != null)?TextEditingController(text: jamTutup.hour.toString() + ':' + jamTutup.minute.toString()):TextEditingController(text: "");
  }

  String name = '';
  String email = '';
  String desc = '';
  String latitude = '';
  String longitude = '';
  String address = '';
  String phone = '';
  String img = '';
  String badanUsaha = '';
  String namaPemilik = '';
  String namaPenanggungJwb = '';
  String imgSelfie = '';
  String imgKtp = '';
  String nameRekening = '';
  String nameBank = '';
  String norek = '';

  getShared()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    // var token = pref.getString("token") ?? "";
    name = pref.getString("nameResto") ?? "";
    email = pref.getString("emailResto");
    desc = pref.getString("descResto") ?? "";
    latitude = pref.getString("latitudeResto") ?? "";
    longitude = pref.getString("longitudeResto") ?? "";
    address = pref.getString("addressResto") ?? "";
    phone = pref.getString("notelpResto") ?? "";
    img = pref.getString("imgResto") ?? "";
    badanUsaha = pref.getString("nameBadanUsaha");
    namaPemilik = pref.getString("namePemilik") ?? "";
    namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    imgSelfie = pref.getString("imgSelfie") ?? "";
    imgKtp = pref.getString("imgKTP") ?? "";
    nameRekening = pref.getString("nameRekening");
    nameBank = pref.getString("nameBank");
    norek = pref.getString("noRekeningBank") ?? "";
    print('1'+email);
    print('2'+badanUsaha);
    print('3'+nameRekening);
    print('4'+nameBank);
  }

  Future<String?>? addResto()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // var name = pref.getString("nameResto") ?? "";
    // var email = pref.getString("emailResto") ?? "";
    // var desc = pref.getString("descResto") ?? "";
    // var latitude = pref.getString("latitudeResto") ?? "";
    // var longitude = pref.getString("longitudeResto") ?? "";
    // var address = pref.getString("addressResto") ?? "";
    // var phone = pref.getString("notelpResto") ?? "";
    // var img = pref.getString("imgResto") ?? "";
    // var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    // var namaPemilik = pref.getString("namePemilik") ?? "";
    // var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    // var imgSelfie = pref.getString("imgSelfie") ?? "";
    // var imgKtp = pref.getString("imgKTP") ?? "";
    // var nameRekening = pref.getString("nameRekening") ?? "";
    // var nameBank = pref.getString("nameBank") ?? "";
    // var norek = pref.getString("noRekeningBank") ?? "";
    // pref.setString('jUsaha', _Fasilitas.text.toString());
    setState(() {
      isLoading = true;
    });

    var apiResult = await http.post(Links.mainUrl + '/resto',
        body: {
          'name': name,
          'data_email': email,
          'desc': desc,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'phone': phone,
          'hours': buka! + '-' + tutup!,
          'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          'takeaway': (takeaway == true)?'1':'0',
          'img': img,
          'type': _Tipe.text.toString(),
          // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
          'fasilitas': _Fasilitas.text.toString(),
          // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
          'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',
          'data_pt': badanUsaha,
          'data_owner': namaPemilik,
          'data_name_pj': namaPenanggungJwb,
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          'data_nama_norek': nameRekening,
          'data_bank_norek': nameBank,
          'data_norek': norek,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    print(email);
    print(badanUsaha);
    print(namaPemilik);
    print(namaPenanggungJwb);
    print(imgSelfie);
    print(imgKtp);
    print(nameRekening);
    print(nameBank);
    print(norek);

    if(apiResult.statusCode == 200){
      print("success");
      print(data);
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: PaymentResto(name, phone, address)));
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
    } else {
      print(data);
      setState(() {
        isLoading = false;
      });
      print(json.encode({
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'hours': buka + '-' + tutup,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
        // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
      }));
    }
  }

  Future<String?>? addResto2()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    // var name = pref.getString("nameResto") ?? "";
    // var email = pref.getString("emailResto") ?? "";
    // var desc = pref.getString("descResto") ?? "";
    // var latitude = pref.getString("latitudeResto") ?? "";
    // var longitude = pref.getString("longitudeResto") ?? "";
    // var address = pref.getString("addressResto") ?? "";
    // var phone = pref.getString("notelpResto") ?? "";
    // var img = pref.getString("imgResto") ?? "";
    // var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    // var namaPemilik = pref.getString("namePemilik") ?? "";
    // var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    // var imgSelfie = pref.getString("imgSelfie") ?? "";
    // var imgKtp = pref.getString("imgKTP") ?? "";
    // var nameRekening = pref.getString("nameRekening") ?? "";
    // var nameBank = pref.getString("nameBank") ?? "";
    // var norek = pref.getString("noRekeningBank") ?? "";
    // pref.setString('jUsaha', _Fasilitas.text.toString());
    setState(() {
      isLoading = true;
    });

    var apiResult = await http.post(Links.mainUrl + '/resto',
        body: {
          'name': name,
          'data_email': email,
          'desc': desc,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'phone': phone,
          'hours': buka! + '-' + tutup!,
          're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          'takeaway': (takeaway == true)?'1':'0',
          'img': img,
          'type': _Tipe.text.toString(),
          // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
          'fasilitas': _Fasilitas.text.toString(),
          // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
          'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',
          'data_pt': badanUsaha,
          'data_owner': namaPemilik,
          'data_name_pj': namaPenanggungJwb,
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          'data_nama_norek': nameRekening,
          'data_bank_norek': nameBank,
          'data_norek': norek,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    print(email);
    print(badanUsaha);
    print(namaPemilik);
    print(namaPenanggungJwb);
    print(imgSelfie);
    print(imgKtp);
    print(nameRekening);
    print(nameBank);
    print(norek);

    if(apiResult.statusCode == 200){
      print("success");
      print(data);
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: PaymentResto(name, phone, address)));
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
    } else {
      print(data);
      setState(() {
        isLoading = false;
      });
      print(json.encode({
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'hours': buka + '-' + tutup,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
        // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
      }));
    }
  }

  showAlertDialog() {

    // set up the button
    Widget okButton = TextButton(
      child: Text("Oke", style: TextStyle(color: CustomColor.primary),),
      onPressed: () {
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: HomeActivity()));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      // backgroundColor: CustomColor.primary,

      title: Text("Metode Pembayaran"),
      content: Text("Silahkan hubungi 0838********* untuk lebih lanjut."),
      actions: [
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

  @override
  void initState() {
    super.initState();
    getShared();
    // getTutup();
    // getBuka();
    getCuisine();
    getFacility();
    // getCuisine();
    // Future.delayed(Duration.zero, () async {
    //
    // });
  }


  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
                      ),
                      SizedBox(
                        width: CustomSize.sizeWidth(context) / 88,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: CustomText.textHeading4(
                            text: "Isi data restomu",
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                Divider(
                  thickness: 8,
                  color: CustomColor.secondary,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tipe Resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _Tipe,
                        keyboardType: TextInputType.name,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                print(cuisine);
                                // print(cuisine.split(",")[0]);
                              });
                              if (cuiOk == 'true') {
                                _showCuisineDialog();
                              } else {
                                Fluttertoast.showToast(msg: 'Coba lagi sebentar lagi');
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: CustomSize.sizeWidth(context) / 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: CustomColor.accent, width: 1),
                                    // color: CustomColor.accentLight
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: CustomText.textTitle8(
                                          text: (cuisine == null)?"Pilih":"Ganti",
                                          color: CustomColor.accent,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Fasilitas Restomu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _Fasilitas,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                print(facility);
                                // print(cuisine.split(",")[0]);
                              });
                              _showFacilityDialog();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: CustomSize.sizeWidth(context) / 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: CustomColor.accent, width: 1),
                                    // color: CustomColor.accentLight
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: CustomText.textTitle8(
                                          text: (facility == null)?"Pilih":"Ganti",
                                          color: CustomColor.accent,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      // CustomText.bodyLight12(text: "Rentan Harga Mulai Dari"),
                      // TextField(
                      //   controller: _MulaiHarga,
                      //   keyboardType: TextInputType.number,
                      //   cursorColor: Colors.black,
                      //   style: GoogleFonts.poppins(
                      //       textStyle:
                      //       TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                      //     hintStyle: GoogleFonts.poppins(
                      //         textStyle:
                      //         TextStyle(fontSize: 14, color: Colors.grey)),
                      //     helperStyle: GoogleFonts.poppins(
                      //         textStyle: TextStyle(fontSize: 14)),
                      //     enabledBorder: UnderlineInputBorder(),
                      //     focusedBorder: UnderlineInputBorder(),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: CustomSize.sizeHeight(context) / 48,
                      // ),
                      // CustomText.bodyLight12(text: "Sampai Harga"),
                      // TextField(
                      //   controller: _SampaiHarga,
                      //   keyboardType: TextInputType.number,
                      //   cursorColor: Colors.black,
                      //   style: GoogleFonts.poppins(
                      //       textStyle:
                      //       TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                      //     hintStyle: GoogleFonts.poppins(
                      //         textStyle:
                      //         TextStyle(fontSize: 14, color: Colors.grey)),
                      //     helperStyle: GoogleFonts.poppins(
                      //         textStyle: TextStyle(fontSize: 14)),
                      //     enabledBorder: UnderlineInputBorder(),
                      //     focusedBorder: UnderlineInputBorder(),
                      //   ),
                      // ),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 48,),

                      CustomText.bodyLight12(text: "Jam Buka", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _JamOperasionalBuka,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                            hintStyle: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 14, color: Colors.grey)),
                            helperStyle: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 14)),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  jamBuka = TimeOfDay.now().replacing(minute: 30);
                                  print(_JamOperasionalTutup);
                                  // print(cuisine.split(",")[0]);
                                });
                                Navigator.of(context).push(
                                    showPicker(
                                      is24HrFormat: true,
                                      blurredBackground: true,
                                      accentColor: Colors.blue[400],
                                      context: context,
                                      value: (jamBuka != null)?jamBuka:null,
                                      onChange: onTimeOpenChanged,
                                      minuteInterval: MinuteInterval.ONE,
                                      disableHour: false,
                                      disableMinute: false,
                                      minMinute: 0,
                                      maxMinute: 59,
                                      cancelText: 'batal',
                                      okText: 'simpan',
                                      // Optional onChange to receive value as DateTime
                                      onChangeDateTime: (DateTime dateTime) {
                                        print(jamBuka.hour.toString() + '.' + jamBuka.minute.toString());
                                        buka = jamBuka.hour.toString() + ':' + jamBuka.minute.toString();
                                        getBuka();
                                      },
                                    ));
                              },
                              // onTap: () async{
                              //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new AddViewResto()));
                              // },
                              child: Stack(
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: CustomColor.accent, width: 1),
                                      // color: CustomColor.accentLight
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: CustomText.textTitle8(
                                            text: "Atur",
                                            color: CustomColor.accent,
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Jam Tutup", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _JamOperasionalTutup,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                // buka = jamBuka.hour.toString() + ':' + jamBuka.minute.toString();
                                jamTutup = TimeOfDay.now().replacing(minute: 30);
                                print(_JamOperasionalTutup.toString() + 'ini');
                                // print(cuisine.split(",")[0]);
                              });
                              Navigator.of(context).push(
                                  showPicker(
                                    is24HrFormat: true,
                                    blurredBackground: true,
                                    accentColor: Colors.blue[400],
                                    context: context,
                                    value: jamTutup,
                                    onChange: onTimeClosedChanged,
                                    minuteInterval: MinuteInterval.ONE,
                                    disableHour: false,
                                    disableMinute: false,
                                    minMinute: 0,
                                    maxMinute: 59,
                                    cancelText: 'batal',
                                    okText: 'simpan',
                                    // Optional onChange to receive value as DateTime
                                    onChangeDateTime: (DateTime dateTime) {
                                      print(jamBuka.hour.toString() + ':' + jamBuka.minute.toString());
                                      print(jamTutup.hour.toString() + ':' + jamTutup.minute.toString()+'ini tutup');
                                      print(buka! + 'ini buka');
                                      tutup = jamTutup.hour.toString() + ':' + jamTutup.minute.toString();
                                      getTutup();
                                    },
                                  ));
                            },
                            // onTap: () async{
                            //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new AddViewResto()));
                            // },
                            child: Stack(
                              children: [
                                Container(
                                  width: CustomSize.sizeWidth(context) / 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: CustomColor.accent, width: 1),
                                    // color: CustomColor.accentLight
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: CustomText.textTitle8(
                                          text: "Atur",
                                          color: CustomColor.accent,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.035).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.035).toString())
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Layanan Restomu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      //------------------------------------ checkbox delivery -------------------------------------
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: delivery,
                            onChanged: (bool? value) {
                              setState(() {
                                delivery = value!;
                              });
                            },
                          ),
                          // Text('Apakah Restomu melayani pesan antar ?', style: TextStyle(fontWeight: FontWeight.bold))
                          Text('Apakah Restomu melayani pesan antar ?', style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),),
                        ],
                      ),
                      //------------------------------------- biaya kirim ----------------------------------------
                      // (delivery)?CustomText.bodyLight12(text: "Ongkir per 1 km", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())):Container(),
                      // (delivery)?TextField(
                      //   controller: _Ongkir,
                      //   keyboardType: TextInputType.number,
                      //   cursorColor: Colors.black,
                      //   style: GoogleFonts.poppins(
                      //       textStyle:
                      //       TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                      //     hintStyle: GoogleFonts.poppins(
                      //         textStyle:
                      //         TextStyle(fontSize: 14, color: Colors.grey)),
                      //     helperStyle: GoogleFonts.poppins(
                      //         textStyle: TextStyle(fontSize: 14)),
                      //     enabledBorder: UnderlineInputBorder(),
                      //     focusedBorder: UnderlineInputBorder(),
                      //   ),
                      // ):Container(),
                      //------------------------------------ checkbox reservation -------------------------------------
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: reservation,
                            onChanged: (bool? value) {
                              setState(() {
                                reservation = value!;
                              });
                            },
                          ),
                          // Text('Apakah Restomu melayani reservasi ?', style: TextStyle(fontWeight: FontWeight.bold))
                          Text('Apakah Restomu melayani reservasi ?', style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),),
                        ],
                      ),
                      //------------------------------------- harga pesan ----------------------------------------
                      (reservation)?CustomText.bodyLight12(text: "Harga pesan per meja (1 meja 4 kursi)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())):Container(),
                      (reservation)?TextField(
                        controller: _HargaPerMeja,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                      ):Container(),
                      (reservation)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                      //------------------------------------- meja yang disediakan ----------------------------------------
                      (reservation)?CustomText.bodyLight12(text: "Meja yang disediakan restomu untuk reservasi", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())):Container(),
                      (reservation)?TextField(
                        controller: _JumlahMeja,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                      ):Container(),
                      // ------------------------------------ checkbox takeaway -------------------------------------
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: takeaway,
                            onChanged: (bool? value) {
                              setState(() {
                                takeaway = value!;
                              });
                            },
                          ),
                          // Text('Apakah Restomu melayani ambil ditempat ?', style: TextStyle(fontWeight: FontWeight.bold))
                          Text('Apakah Restomu melayani ambil ditempat ?', style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),),
                        ],
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      (isLoading != true)?Container(
                        width: CustomSize.sizeWidth(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async{
                                setState(() {
                                  isLoading = false;
                                });
                                if (_Tipe.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_Fasilitas.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (buka.toString() == 'null') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (tutup.toString() == 'null') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else {
                                  if (delivery == true) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                            title: Center(child: Text('Perhatian!', style: TextStyle(color: CustomColor.redBtn))),
                                            content: Text('Apakah data anda sudah diisi dengan benar dan dapat dipertanggung jawabkan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                            actions: <Widget>[
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    FlatButton(
                                                      // minWidth: CustomSize.sizeWidth(context),
                                                      color: CustomColor.redBtn,
                                                      textColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      child: Text('Batal'),
                                                      onPressed: () async{
                                                        setState(() {
                                                          // codeDialog = valueText;
                                                          Navigator.pop(context);
                                                        });
                                                      },
                                                    ),
                                                    FlatButton(
                                                      color: CustomColor.primaryLight,
                                                      textColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      child: Text('Iya'),
                                                      onPressed: () async{
                                                        Navigator.pop(context);
                                                        String qrcode = '';
                                                        addResto();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          );
                                        });
                                    // SharedPreferences pref = await SharedPreferences.getInstance();
                                    // var token = pref.getString("token") ?? "";
                                    // var name = pref.getString("nameResto") ?? "";
                                    // var desc = pref.getString("descResto") ?? "";
                                    // var latitude = pref.getString("latitudeResto") ?? "";
                                    // var longitude = pref.getString("longitudeResto") ?? "";
                                    // var address = pref.getString("addressResto") ?? "";
                                    // var phone = pref.getString("notelpResto") ?? "";
                                    // var img = pref.getString("imgResto") ?? "";
                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     PageTransition(
                                    //         type: PageTransitionType.fade,
                                    //         child: PaymentResto(name, phone, address)));
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                            title: Center(child: Text('Perhatian!', style: TextStyle(color: CustomColor.redBtn))),
                                            content: Text('Apakah data anda sudah diisi dengan benar dan dapat dipertanggung jawabkan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                            actions: <Widget>[
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    FlatButton(
                                                      // minWidth: CustomSize.sizeWidth(context),
                                                      color: CustomColor.redBtn,
                                                      textColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      child: Text('Batal'),
                                                      onPressed: () async{
                                                        setState(() {
                                                          // codeDialog = valueText;
                                                          Navigator.pop(context);
                                                        });
                                                      },
                                                    ),
                                                    FlatButton(
                                                      color: CustomColor.primaryLight,
                                                      textColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                                      ),
                                                      child: Text('Iya'),
                                                      onPressed: () async{
                                                        Navigator.pop(context);
                                                        String qrcode = '';
                                                        addResto2();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          );
                                        });
                                    // SharedPreferences pref = await SharedPreferences.getInstance();
                                    // var token = pref.getString("token") ?? "";
                                    // var name = pref.getString("nameResto") ?? "";
                                    // var desc = pref.getString("descResto") ?? "";
                                    // var latitude = pref.getString("latitudeResto") ?? "";
                                    // var longitude = pref.getString("longitudeResto") ?? "";
                                    // var address = pref.getString("addressResto") ?? "";
                                    // var phone = pref.getString("notelpResto") ?? "";
                                    // var img = pref.getString("imgResto") ?? "";
                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     PageTransition(
                                    //         type: PageTransitionType.fade,
                                    //         child: PaymentResto(name, phone, address)));
                                  }
                                }
                                // showAlertDialog();


                                // SharedPreferences pref = await SharedPreferences.getInstance();
                                // pref.setString("name", _loginTextName.text.toString());
                                // pref.setString("email", _loginEmailName.text.toString());
                                // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
                                // pref.setString("gender", gender);
                                // pref.setString("tgl", tgl);
                                // pref.setString("notelp", _loginNotelpName.text.toString());
                              },
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: CustomSize.sizeWidth(context) / 1.1,
                                  height: CustomSize.sizeHeight(context) / 14,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: CustomColor.accent
                                  ),
                                  child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ):Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: CustomSize.sizeWidth(context) / 1.1,
                          height: CustomSize.sizeHeight(context) / 14,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: CustomColor.accent
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 8,),
              ],
            ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
