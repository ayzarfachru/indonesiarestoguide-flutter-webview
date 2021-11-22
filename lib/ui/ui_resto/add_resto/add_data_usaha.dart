import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/utils/search_address_maps_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';

import 'package:http/http.dart' as http;

class AddDataUsaha extends StatefulWidget {
  @override
  _AddDataUsahaState createState() => _AddDataUsahaState();
}

class _AddDataUsahaState extends State<AddDataUsaha> {
  TextEditingController _NameBadanUsaha = TextEditingController(text: "");
  TextEditingController _NamePemilik = TextEditingController(text: "");
  TextEditingController _NamePenanggungJawab = TextEditingController(text: "");
  TextEditingController _NameRekening = TextEditingController(text: "");
  TextEditingController _NameBank = TextEditingController(text: "");
  TextEditingController _NoRekeningBank = TextEditingController(text: "");
  TextEditingController _Address = TextEditingController(text: "");
  TextEditingController _Desc = TextEditingController(text: "");

  String initial = "";
  String img = "";

  bool isLoading = true;
  bool btnAddress = false;

  String? latitude;
  String? longitude;

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }


  //------------------------------= IMAGE PICKER =----------------------------------
  File? image2;
  String? extension;
  final picker2 = ImagePicker();

  Future getImage2() async {
    final pickedFile = await picker2.getImage(source: ImageSource.gallery);

    setState(() {
      image2 = File(pickedFile.path);
      extension = pickedFile.path.split('.').last;
    });
  }

  //------------------------------= IMAGE PICKER =----------------------------------
  File? image3;
  final picker3 = ImagePicker();

  Future getImage3() async {
    final pickedFile = await picker3.getImage(source: ImageSource.gallery);

    setState(() {
      image3 = File(pickedFile.path);
      extension = pickedFile.path.split('.').last;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitial();
    Location.instance.getLocation().then((value) {
      setState(() {
        latitude = value.latitude.toString();
        longitude = value.longitude.toString();
      });
    });
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
                      CustomText.bodyLight12(text: "Nama Badan Usaha (PT/CV/UD)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NameBadanUsaha,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Badan Usaha',
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama Pemilik Resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NamePemilik,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Pemilik Resto',
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama Penanggung Jawab", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NamePenanggungJawab,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Penanggung Jawab Resto',
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tambahkan Selfie Pemilik/Penanggung Jawab", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.015,
                      ),
                      GestureDetector(
                        onTap: () async{
                          getImage2();
                        },
                        child: Row(
                          children: [
                            (image2 == null)?Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 3.2,
                              child: Icon(FontAwesome.plus, color: CustomColor.primaryLight, size: 50,),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ),
                            ):Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 3.2,
                              decoration: (image2==null)?(img == "/".substring(0, 1))?BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ):BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ): BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                                image: new DecorationImage(
                                    image: new FileImage(image2!),
                                    fit: BoxFit.cover
                                ),
                              ),
                              child: (img == "/".substring(0, 1))?Center(
                                child: CustomText.text(
                                    size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                    weight: FontWeight.w800,
                                    text: initial,
                                    color: Colors.white
                                ),
                              ):Padding(
                                padding: const EdgeInsets.only(left: 1.5),
                                child: Center(
                                  child: (image2 == null)?CustomText.text(
                                      size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                      weight: FontWeight.w800,
                                      text: initial,
                                      color: Colors.white
                                  ):Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tambahkan KTP Pemilik/Penanggung Jawab", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.015,
                      ),
                      GestureDetector(
                        onTap: () async{
                          getImage3();
                        },
                        child: Row(
                          children: [
                            (image3 == null)?Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 2.2,
                              child: Icon(FontAwesome.plus, color: CustomColor.primaryLight, size: 50,),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ),
                            ):Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 2.2,
                              decoration: (image3==null)?(img == "/".substring(0, 1))?BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ):BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ): BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                                image: new DecorationImage(
                                    image: new FileImage(image3!),
                                    fit: BoxFit.cover
                                ),
                              ),
                              child: (img == "/".substring(0, 1))?Center(
                                child: CustomText.text(
                                    size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                    weight: FontWeight.w800,
                                    text: initial,
                                    color: Colors.white
                                ),
                              ):Padding(
                                padding: const EdgeInsets.only(left: 1.5),
                                child: Center(
                                  child: (image3 == null)?CustomText.text(
                                      size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                      weight: FontWeight.w800,
                                      text: initial,
                                      color: Colors.white
                                  ):Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama Sesuai Rekening", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NameRekening,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Nama Sesuai Rekening Bank',
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Bank", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NameBank,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Rekening Bank',
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nomor Rekening Bank", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NoRekeningBank,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Rekening Bank',
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
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Container(
                        width: CustomSize.sizeWidth(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async{
                                setState(() {
                                  isLoading = false;
                                });
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                print('LOOP '+_NameBadanUsaha.toString()+'P');
                                if (image2.toString() == 'null') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (image3.toString() == 'null') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NameBadanUsaha.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NamePemilik.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NamePenanggungJawab.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NameRekening.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NameBank.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NoRekeningBank.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else {
                                  pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                                  pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                                  pref.setString("nameBadanUsaha", _NameBadanUsaha.text);
                                  pref.setString("namePemilik", _NamePemilik.text.toString());
                                  pref.setString("namePenanggungJawab", _NamePenanggungJawab.text.toString());
                                  pref.setString("nameRekening", _NameRekening.text.toString());
                                  pref.setString("nameBank", _NameBank.text.toString());
                                  pref.setString("noRekeningBank", _NoRekeningBank.text.toString());
                                  print(pref.getString("imgSelfie"));
                                  print(pref.getString("imgKTP"));
                                  print(pref.getString("nameBadanUsaha"));
                                  print(pref.getString("namePemilik"));
                                  print(pref.getString("namePenanggungJawab"));
                                  print(pref.getString("namePemilik"));
                                  print(pref.getString("namePenanggungJawab"));
                                  print(pref.getString("noRekeningBank"));
                                  print('PPPPP');
                                  print(_NameRekening.text.toString().toLowerCase());
                                  print(_NameBadanUsaha.text.toString().toLowerCase());
                                  print(_NameBadanUsaha.text.toString().toLowerCase());
                                  print(_NamePenanggungJawab.text.toString().toLowerCase());
                                  print(_NamePemilik.text.toString().toLowerCase());

                                  if (_NameRekening.text.toString().toLowerCase() != _NameBadanUsaha.text.toString().toLowerCase() && _NameRekening.text.toString().toLowerCase() != _NamePenanggungJawab.text.toString().toLowerCase() && _NameRekening.text.toString().toLowerCase() != _NamePemilik.text.toString().toLowerCase()) {
                                    Fluttertoast.showToast(msg: 'Nama rekening harus sesuai dengan nama badan usaha / pemilik / penanggung jawab');
                                  } else {
                                    Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new AddDetailResto()));
                                  }
                                }

                                // SharedPreferences pref = await SharedPreferences.getInstance();
                                // pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                                // pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                                // pref.setString("nameBadanUsaha", _NameBadanUsaha.text);
                                // pref.setString("namePemilik", _NamePemilik.text.toString());
                                // pref.setString("namePenanggungJawab", _NamePenanggungJawab.text.toString());
                                // pref.setString("nameRekening", _NameRekening.text.toString());
                                // pref.setString("nameBank", _NameBank.text.toString());
                                // pref.setString("noRekeningBank", _NoRekeningBank.text.toString());
                                // print(pref.getString("imgSelfie"));
                                // print(pref.getString("imgKTP"));
                                // print(pref.getString("nameBadanUsaha"));
                                // print(pref.getString("namePemilik"));
                                // print(pref.getString("namePenanggungJawab"));
                                // print(pref.getString("namePemilik"));
                                // print(pref.getString("namePenanggungJawab"));
                                // print(pref.getString("noRekeningBank"));
                                // print('PPPPP');
                                // print(_NameRekening.text.toString().toLowerCase());
                                // print(_NameBadanUsaha.text.toString().toLowerCase());
                                // print(_NameBadanUsaha.text.toString().toLowerCase());
                                // print(_NamePenanggungJawab.text.toString().toLowerCase());
                                // print(_NamePemilik.text.toString().toLowerCase());
                                //
                                // if (_NameRekening.text.toString().toLowerCase() != _NameBadanUsaha.text.toString().toLowerCase() && _NameRekening.text.toString().toLowerCase() != _NamePenanggungJawab.text.toString().toLowerCase() && _NameRekening.text.toString().toLowerCase() != _NamePemilik.text.toString().toLowerCase()) {
                                //   Fluttertoast.showToast(msg: 'Nama rekening harus sesuai dengan nama badan usaha / pemilik / penanggung jawab');
                                // } else {
                                //   Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new AddDetailResto()));
                                // }
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context) / 1.1,
                                height: CustomSize.sizeHeight(context) / 14,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: CustomColor.accent
                                ),
                                child: Center(child: CustomText.bodyRegular16(text: "Lanjut", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              ],
            ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
