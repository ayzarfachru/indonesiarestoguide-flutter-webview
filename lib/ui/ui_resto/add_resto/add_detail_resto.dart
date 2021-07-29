import 'dart:convert';
import 'dart:io';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indonesiarestoguide/model/Cuisine.dart';
import 'package:indonesiarestoguide/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:indonesiarestoguide/ui/ui_resto/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
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

  CuisineChip(this.cuisineList, {this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<CuisineChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

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

  FacilityChip(this.facilityList, {this.onSelectionChanged});

  @override
  _FacilityChipState createState() => _FacilityChipState();
}

class _FacilityChipState extends State<FacilityChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

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

  TimeOfDay jamBuka = TimeOfDay();
  TimeOfDay jamTutup = TimeOfDay();
  String buka;
  String tutup;

  bool isLoading = true;

  bool takeaway = false;
  bool reservation = false;
  bool delivery = false;

  List cuisineList = [];

  List<String> selectedCuisineList = List();
  String cuisine;

  _showCuisineDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Tipe Resto"),
            content: CuisineChip(
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

  List<String> selectedFacilityList = List();
  String facility;

  _showFacilityDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Fasilitas Resto"),
            content: FacilityChip(
              facilityList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedFacilityList = selectedList;
                  facility = selectedFacilityList.join(",");
                  print(facility);
                  if (facility != "") {
                    selectedList = facility.split(",");
                  } else {}
                });
              },
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
    _Tipe = TextEditingController(text: cuisine);
  }

  List<String> dataCuisine;
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
    _Fasilitas = TextEditingController(text: facility);
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

  Future<String> addResto()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var name = pref.getString("nameResto") ?? "";
    var desc = pref.getString("descResto") ?? "";
    var latitude = pref.getString("latitudeResto") ?? "";
    var longitude = pref.getString("longitudeResto") ?? "";
    var address = pref.getString("addressResto") ?? "";
    var phone = pref.getString("notelpResto") ?? "";
    var img = pref.getString("imgResto") ?? "";

    var apiResult = await http.post(Links.mainUrl + '/resto',
        body: {
          'name': name,
          'desc': desc,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'phone': phone,
          'hours': buka + '-' + tutup,
          'ongkir': (_Ongkir.text.toString() != null)?_Ongkir.text.toString():'',
          're_price': (_HargaPerMeja.text.toString() != '')?_HargaPerMeja.text.toString():'',
          'takeaway': (takeaway == true)?'1':'',
          'img': img,
          'type': _Tipe.text.toString(),
          'fasilitas': _Fasilitas.text.toString(),
          'table': (_JumlahMeja.text.toString() != '')?_JumlahMeja.text.toString():''
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(apiResult.statusCode == 200){
      print("success");
      print(data);
      showAlertDialog();
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
      child: Text("Oke"),
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
    getTutup();
    getBuka();
    getCuisine();
    getFacility();
    // getCuisine();
    // Future.delayed(Duration.zero, () async {
    //
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: CustomSize.sizeHeight(context) / 38,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                child: CustomText.textHeading4(
                    text: "Lengkapi data restomu",
                    minSize: 18,
                    maxLines: 1
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
                    CustomText.bodyLight12(text: "Tipe Restomu"),
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
                                        text: (cuisine == null)?"Pilih":"Ganti",
                                        color: CustomColor.accent
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
                    CustomText.bodyLight12(text: "Fasilitas Restomu"),
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
                                        color: CustomColor.accent
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
                    CustomText.bodyLight12(text: "Jam Buka"),
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
                                          color: CustomColor.accent
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
                    CustomText.bodyLight12(text: "Jam Tutup"),
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
                              buka = jamBuka.hour.toString() + ':' + jamBuka.minute.toString();
                              jamTutup = TimeOfDay.now().replacing(minute: 30);
                              print(_JamOperasionalTutup.toString() + 'ini');
                              // print(cuisine.split(",")[0]);
                            });
                            Navigator.of(context).push(
                                showPicker(
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
                                    print(buka + 'ini buka');
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
                                        color: CustomColor.accent
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
                    CustomText.bodyLight12(text: "Layanan Restomu"),
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
                          onChanged: (bool value) {
                            setState(() {
                              delivery = value;
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
                    (delivery)?CustomText.bodyLight12(text: "Ongkir per 1 km"):Container(),
                    (delivery)?TextField(
                      controller: _Ongkir,
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
                    //------------------------------------ checkbox reservation -------------------------------------
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: reservation,
                          onChanged: (bool value) {
                            setState(() {
                              reservation = value;
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
                    (reservation)?CustomText.bodyLight12(text: "Harga pesan per meja (1 meja 4 kursi)"):Container(),
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
                    (reservation)?CustomText.bodyLight12(text: "Meja yang disediakan restomu untuk reservasi"):Container(),
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
                    //------------------------------------ checkbox takeaway -------------------------------------
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: takeaway,
                          onChanged: (bool value) {
                            setState(() {
                              takeaway = value;
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
                    GestureDetector(
                      onTap: () async{
                        setState(() {
                          isLoading = false;
                        });
                        addResto();
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
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: CustomSize.sizeWidth(context) / 1.1,
                          height: CustomSize.sizeHeight(context) / 14,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: CustomColor.accent
                          ),
                          child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white,)),
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
    );
  }
}
