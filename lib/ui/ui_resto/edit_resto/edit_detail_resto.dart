import 'dart:convert';
import 'dart:io';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/model/Cuisine.dart';
import 'package:kam5ia/ui/detail/detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class EditDetailResto extends StatefulWidget {
  String facility = '';
  String cuisine = '';
  String can_delivery = '';
  String can_takeaway = '';
  String ongkir = '';
  String reservation_fee = '';
  String idResto = '';

  String email = "";
  String badanU = '';
  String pemilikU = '';
  String penanggungJwb = '';
  String nomorRekening = '';

  EditDetailResto(this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.idResto, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nomorRekening);

  @override
  _EditDetailRestoState createState() => _EditDetailRestoState(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nomorRekening);
}

class CuisineChip extends StatefulWidget {
  final List<String> cuisineList;
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


class _EditDetailRestoState extends State<EditDetailResto> {
  String facility = '';
  String cuisine = '';
  String can_delivery = '';
  String can_takeaway = '';
  String ongkir = '';
  String reservation_fee = '';
  String idResto = '';

  String email = "";
  String badanU = '';
  String pemilikU = '';
  String penanggungJwb = '';
  String nomorRekening = '';

  _EditDetailRestoState(this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.idResto, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nomorRekening);

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

  getDelivery() async {
    delivery = (can_delivery != 'true')?false:true;
  }

  getReservation() async {
    reservation = (reservation_fee == '0')?false:true;
  }

  getTakeaway() async {
    takeaway = (can_takeaway != 'true')?false:true;
  }

  List<String> cuisineList = [];
  List<String> cuisineList2 = [
    'Indonesian Food',
    'Chinese Food',
    'Japanese Food',
    'Australian Food',
    'Korean Food',
    'Coffe',
    'Orther Drinks'
  ];

  List<String> selectedCuisineList = [];

  _showCuisineDialog() {
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
                          selectedList = cuisine.split(",");
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
                    getCuisine();
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
                        // selectedFacilityList = selectedList;
                        // facility = selectedFacilityList.single;
                        print(facility);
                        selectedFacilityList = selectedList;
                        facility = selectedFacilityList.join(",");
                        print(facility);
                        if (facility != "") {
                          selectedList = facility.split(",");
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
                  pref.setString("facility", facility);
                  setState(() {
                    print(facility);
                    getFacility();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }


  getOngkir() async {
    _Ongkir = TextEditingController(text: ongkir);
  }

  String imgSelfie = '';
  String imgKtp = '';
  String karyawan = "";
  getImgUsrData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    imgSelfie = pref.getString("imgSelfie") ?? "";
    imgKtp = pref.getString("imgKTP") ?? "";
    karyawan = (pref.getString("karyawan")??'');
  }

  getHargaPerMeja() async {
    _HargaPerMeja = TextEditingController(text: reservation_fee);
  }

  getCuisine() async {
    _Tipe = TextEditingController(text: cuisine.replaceAll(',', ', '));
  }

  getFacility() async {
    _Fasilitas = TextEditingController(text: facility.replaceAll(',', ', '));
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

  Future<String?>? editUserUsaha(String idResto)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var name = pref.getString("nameResto") ?? "";
    var email = pref.getString("emailResto") ?? "";
    var desc = pref.getString("descResto") ?? "";
    var latitude = pref.getString("latitudeResto") ?? "";
    var longitude = pref.getString("longitudeResto") ?? "";
    var address = pref.getString("addressResto") ?? "";
    var phone = pref.getString("notelpResto") ?? "";
    var img = pref.getString("imgResto") ?? "";
    var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    var namaPemilik = pref.getString("namePemilik") ?? "";
    var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    var imgSelfie = pref.getString("imgSelfie") ?? "";
    var imgKtp = pref.getString("imgKTP") ?? "";
    var nameRekening = pref.getString("nameRekening") ?? "";
    var nameBank = pref.getString("nameBank") ?? "";
    var norek = pref.getString("noRekeningBank") ?? "";

    setState(() {
      isLoading = true;
    });

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/userdata'),
        body: {
          'data_email': email,
          'data_pt': badanUsaha,
          'data_owner': namaPemilik,
          'data_name_pj': namaPenanggungJwb,
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          'data_nama_norek': nameRekening,
          'data_bank_norek': nameBank,
          'data_norek': norek,

          // 'data_email': 'admin@admin.com',
          // 'data_pt': 'PT. OI',
          // 'data_owner': 'Admin',
          // 'data_name_pj': 'Admin',
          // 'data_selfie_pj': '',
          // 'data_ktp': '',
          // 'data_nama_norek': 'Admin',
          // 'data_bank_norek': 'BCA',
          // 'data_norek': '9320934',

          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'hours': buka + ',' + tutup,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
          // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(norek);
      print('iki selfie '+imgSelfie);
      print(json.encode({
        'data_email': email,
        'data_pt': badanUsaha,
        'data_owner': namaPemilik,
        'data_name_pj': namaPenanggungJwb,
        'data_selfie_pj': imgSelfie,
        'data_ktp': imgKtp,
        'data_norek': norek,
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        // 'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
      }));
      // Navigator.pop(context);
      // Navigator.pop(context);
      // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
    } else {
      print(data);
      print('selfie gagal '+email);
      print(json.encode({
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        // 'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
      }));
    }
  }
  
  Future<String?>? editUserUsaha2(String idResto)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var name = pref.getString("nameResto") ?? "";
    var email = pref.getString("emailResto") ?? "";
    var desc = pref.getString("descResto") ?? "";
    var latitude = pref.getString("latitudeResto") ?? "";
    var longitude = pref.getString("longitudeResto") ?? "";
    var address = pref.getString("addressResto") ?? "";
    var phone = pref.getString("notelpResto") ?? "";
    var img = pref.getString("imgResto") ?? "";
    var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    var namaPemilik = pref.getString("namePemilik") ?? "";
    var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    var imgSelfie = pref.getString("imgSelfie") ?? "";
    var imgKtp = pref.getString("imgKTP") ?? "";
    var norek = pref.getString("noRekeningBank") ?? "";

    setState(() {
      isLoading = true;
    });

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/userdata'),
        body: {
          'data_email': email,
          'data_pt': badanUsaha,
          'data_owner': namaPemilik,
          'data_name_pj': namaPenanggungJwb,
          'data_norek': norek,

          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'hours': buka + ',' + tutup,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
          // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(norek);
      print(json.encode({
        'data_email': email,
        'data_pt': badanUsaha,
        'data_owner': namaPemilik,
        'data_name_pj': namaPenanggungJwb,
        'data_norek': norek,
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        // 'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
      }));
      // Navigator.pop(context);
      // Navigator.pop(context);
      // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // await preferences.remove('menuJson');
      // await preferences.remove('restoId');
      // await preferences.remove('qty');
      // await preferences.remove('address');
      // await preferences.remove('inCart');
    } else {
      print(data);
      print(json.encode({
        // 'name': name,
        // 'desc': desc,
        // 'latitude': latitude,
        // 'longitude': longitude,
        // 'address': address,
        // 'phone': phone,
        // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
        // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
        // 'takeaway': (takeaway == true)?'1':'',
        // 'img': img,
        // 'type': _Tipe.text.toString(),
        // 'fasilitas': _Fasilitas.text.toString(),
      }));
    }
  }

  Future<String?>? editResto(String idResto)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var name = pref.getString("nameResto") ?? "";
    var email = pref.getString("emailResto") ?? "";
    var desc = pref.getString("descResto") ?? "";
    var latitude = pref.getString("latitudeResto") ?? "";
    var longitude = pref.getString("longitudeResto") ?? "";
    var address = pref.getString("addressResto") ?? "";
    var phone = pref.getString("notelpResto") ?? "";
    var img = pref.getString("imgResto") ?? "";
    var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    var namaPemilik = pref.getString("namePemilik") ?? "";
    var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    var imgSelfie = pref.getString("imgSelfie") ?? "";
    var imgKtp = pref.getString("imgKTP") ?? "";
    var norek = pref.getString("noRekeningBank") ?? "";

    setState(() {
      isLoading = true;
    });

    if (reservation == true) {
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/$idResto'),
          body: {
            'name': name,
            'data_email': email,
            'desc': desc,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'phone': phone,
            'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'0',
            // 're_price': (reservation != false)?(_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'':'0',
            're_price': '1000',
            'takeaway': (takeaway == true)?'1':'',
            'img': img,
            'type': _Tipe.text.toString(),
            // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
            'fasilitas': _Fasilitas.text.toString(),
            // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
            'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',

            // 'name': name,
            // 'desc': desc,
            // 'latitude': latitude,
            // 'longitude': longitude,
            // 'address': address,
            // 'phone': phone,
            // 'hours': buka + ',' + tutup,
            // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
            // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
            // 'takeaway': (takeaway == true)?'1':'',
            // 'img': img,
            // 'type': _Tipe.text.toString(),
            // 'fasilitas': _Fasilitas.text.toString(),
            // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      // print(apiResult);
      var data = json.decode(apiResult.body);

      if(data['status_code'] == 200){
        print("success");
        print(_HargaPerMeja.text.toString());
        print('inii '+latitude);
        print('inii '+longitude);
        print(json.encode({
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // await preferences.remove('menuJson');
        // await preferences.remove('restoId');
        // await preferences.remove('qty');
        // await preferences.remove('address');
        // await preferences.remove('inCart');
      } else {
        print(data);
        print(json.encode({
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
      }
    } else {
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/$idResto'),
          body: {
            'name': name,
            'data_email': email,
            'desc': desc,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'phone': phone,
            'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'0',
            // 're_price': (reservation != false)?(_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'':'0',
            // 're_price': '1000',
            'takeaway': (takeaway == true)?'1':'',
            'img': img,
            'type': _Tipe.text.toString(),
            // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
            'fasilitas': _Fasilitas.text.toString(),
            // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
            'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',

            // 'name': name,
            // 'desc': desc,
            // 'latitude': latitude,
            // 'longitude': longitude,
            // 'address': address,
            // 'phone': phone,
            // 'hours': buka + ',' + tutup,
            // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
            // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
            // 'takeaway': (takeaway == true)?'1':'',
            // 'img': img,
            // 'type': _Tipe.text.toString(),
            // 'fasilitas': _Fasilitas.text.toString(),
            // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      // print(apiResult);
      var data = json.decode(apiResult.body);

      if(data['status_code'] == 200){
        print("success");
        print(_HargaPerMeja.text.toString());
        print('inii '+latitude);
        print('inii '+longitude);
        print(json.encode({
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // await preferences.remove('menuJson');
        // await preferences.remove('restoId');
        // await preferences.remove('qty');
        // await preferences.remove('address');
        // await preferences.remove('inCart');
      } else {
        print(data);
        print(json.encode({
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
      }
    }
  }

  Future<String?>? editResto2(String idResto)async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var name = pref.getString("nameResto") ?? "";
    var email = pref.getString("emailResto") ?? "";
    var desc = pref.getString("descResto") ?? "";
    var latitude = pref.getString("latitudeResto") ?? "";
    var longitude = pref.getString("longitudeResto") ?? "";
    var address = pref.getString("addressResto") ?? "";
    var phone = pref.getString("notelpResto") ?? "";
    var img = pref.getString("imgResto") ?? "";
    var badanUsaha = pref.getString("nameBadanUsaha") ?? "";
    var namaPemilik = pref.getString("namePemilik") ?? "";
    var namaPenanggungJwb = pref.getString("namePenanggungJawab") ?? "";
    var imgSelfie = pref.getString("imgSelfie") ?? "";
    var imgKtp = pref.getString("imgKTP") ?? "";
    var norek = pref.getString("noRekeningBank") ?? "";

    setState(() {
      isLoading = true;
    });

    if (reservation == true) {
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/$idResto'),
          body: {
            'name': name,
            'data_email': email,
            'desc': desc,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'phone': phone,
            // 're_price': (reservation != false)?(_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'':'0',
            're_price': '1000',
            'takeaway': (takeaway == true)?'1':'',
            'img': img,
            'type': _Tipe.text.toString(),
            // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
            'fasilitas': _Fasilitas.text.toString(),
            // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
            'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',

            // 'name': name,
            // 'desc': desc,
            // 'latitude': latitude,
            // 'longitude': longitude,
            // 'address': address,
            // 'phone': phone,
            // 'hours': buka + ',' + tutup,
            // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
            // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
            // 'takeaway': (takeaway == true)?'1':'',
            // 'img': img,
            // 'type': _Tipe.text.toString(),
            // 'fasilitas': _Fasilitas.text.toString(),
            // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print(apiResult);
      var data = json.decode(apiResult.body);

      if(data['status_code'] == 200){
        print("success");
        print(norek);
        print(json.encode({
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // await preferences.remove('menuJson');
        // await preferences.remove('restoId');
        // await preferences.remove('qty');
        // await preferences.remove('address');
        // await preferences.remove('inCart');
      } else {
        print(data);
        print(json.encode({
          'name': name,
          'desc': desc,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'phone': phone,
          'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          're_price': '1000',
          'takeaway': (takeaway == true)?'1':'',
          'img': img,
          'type': _Tipe.text.toString(),
          'fasilitas': _Fasilitas.text.toString(),
        }));
      }
    } else {
      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/$idResto'),
          body: {
            'name': name,
            'data_email': email,
            'desc': desc,
            'latitude': latitude,
            'longitude': longitude,
            'address': address,
            'phone': phone,
            // 're_price': (reservation != false)?(_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'':'0',
            're_price': '1000',
            'takeaway': (takeaway == true)?'1':'',
            'img': img,
            'type': _Tipe.text.toString(),
            // 'type': (_Tipe.text.toString() == 'Indonesian Food' || _Tipe.text.toString() == 'Chinese Food' || _Tipe.text.toString() == 'Japanese Food' || _Tipe.text.toString() == 'Australian Food' || _Tipe.text.toString() == 'Korean Food' || _Tipe.text.toString() == 'Coffe' || _Tipe.text.toString() == 'Orther Drinks')?'Indonesian':_Tipe.text.toString(),
            'fasilitas': _Fasilitas.text.toString(),
            // 'fasilitas': (_Fasilitas.text.toString() == 'Kaki Lima' || _Fasilitas.text.toString() == 'Food Stall' || _Fasilitas.text.toString() == 'Food Truck' || _Fasilitas.text.toString() == 'Toko Roti/Kue' || _Fasilitas.text.toString() == 'Toko Oleh-Oleh' || _Fasilitas.text.toString() == 'Other')?'Smoking Area':_Fasilitas.text.toString(),
            'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():'',

            // 'name': name,
            // 'desc': desc,
            // 'latitude': latitude,
            // 'longitude': longitude,
            // 'address': address,
            // 'phone': phone,
            // 'hours': buka + ',' + tutup,
            // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
            // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
            // 'takeaway': (takeaway == true)?'1':'',
            // 'img': img,
            // 'type': _Tipe.text.toString(),
            // 'fasilitas': _Fasilitas.text.toString(),
            // 'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print(apiResult);
      var data = json.decode(apiResult.body);

      if(data['status_code'] == 200){
        print("success");
        print(norek);
        print(json.encode({
          'data_selfie_pj': imgSelfie,
          'data_ktp': imgKtp,
          // 'name': name,
          // 'desc': desc,
          // 'latitude': latitude,
          // 'longitude': longitude,
          // 'address': address,
          // 'phone': phone,
          // 'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 'takeaway': (takeaway == true)?'1':'',
          // 'img': img,
          // 'type': _Tipe.text.toString(),
          // 'fasilitas': _Fasilitas.text.toString(),
        }));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // await preferences.remove('menuJson');
        // await preferences.remove('restoId');
        // await preferences.remove('qty');
        // await preferences.remove('address');
        // await preferences.remove('inCart');
      } else {
        print(data);
        print(json.encode({
          'name': name,
          'desc': desc,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'phone': phone,
          'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          // 're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          // 're_price': '1000',
          'takeaway': (takeaway == true)?'1':'',
          'img': img,
          'type': _Tipe.text.toString(),
          'fasilitas': _Fasilitas.text.toString(),
        }));
      }
    }
  }

  List<String?>? dataCuisine;
  Future<void> getDataCuisine() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Uri.parse(Links.mainUrl +'/util/data?q=cuisine'),
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

  Future<void> getDataFacility() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Uri.parse(Links.mainUrl +'/util/data?q=facility'),
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

  Future check()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    print((pref.getString("imgSelfie") != '')?'ini ktp':'Oy');
    print('ini ktp '+pref.getString("imgKTP").toString());
  }

  @override
  void initState() {
    super.initState();
    check();
    getImgUsrData();
    getTutup();
    getBuka();
    getOngkir();
    getReservation();
    getHargaPerMeja();
    getCuisine();
    getFacility();
    getDataCuisine();
    getDataFacility();
    getDelivery();
    getTakeaway();
    // print(_Tipe.text);
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
                          child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                      ),
                      SizedBox(
                        width: CustomSize.sizeWidth(context) / 88,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: CustomText.textHeading4(
                            text: "Edit data restomu",
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
                              _showCuisineDialog();
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
                                          text: (_Tipe.text == null || _Tipe.text == '')?"Pilih":"Ganti",
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
                      CustomText.bodyLight12(text: "Fasilitas Resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
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
                                          text: (_Fasilitas.text == null || _Fasilitas.text == "")?"Pilih":"Ganti",
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
                                print(delivery);
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
                      // (reservation)?CustomText.bodyLight12(text: "Harga pesan per meja (1 meja 4 kursi)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())):Container(),
                      // (reservation)?TextField(
                      //   controller: _HargaPerMeja,
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
                      // (reservation)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
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
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 8,),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
        (isLoading != true)?GestureDetector(
          onTap: () async{
            setState(() {
              isLoading = false;
            });
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.getString("imgSelfie");
            pref.getString("imgKtp");
            if (karyawan != '0') {
              if (delivery == true) {
                editUserUsaha(idResto);
                editResto(idResto);
              } else {
                editUserUsaha(idResto);
                editResto2(idResto);
              }
            } else {
              if (delivery == true) {
                editUserUsaha(idResto);
                editResto(idResto);
              } else {
                editUserUsaha(idResto);
                editResto2(idResto);
              }
            }

            // Navigator.pushReplacement(
            //     context,
            //     PageTransition(
            //         type: PageTransitionType.leftToRight,
            //         child: HomeActivityResto()));
            // SharedPreferences pref = await SharedPreferences.getInstance();
            // pref.setString("name", _loginTextName.text.toString());
            // pref.setString("email", _loginEmailName.text.toString());
            // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
            // pref.setString("gender", gender);
            // pref.setString("tgl", tgl);
            // pref.setString("notelp", _loginNotelpName.text.toString());
          },
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
        ):Container(
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
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
