import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_data_usaha.dart';
import 'package:kam5ia/utils/search_address_maps_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';

import 'package:http/http.dart' as http;

class AddViewResto extends StatefulWidget {
  @override
  _AddViewRestoState createState() => _AddViewRestoState();
}

class _AddViewRestoState extends State<AddViewResto> {
  TextEditingController _Name = TextEditingController(text: "");
  TextEditingController _Email = TextEditingController(text: "");
  TextEditingController _Address = TextEditingController(text: "");
  TextEditingController _NoTelp = TextEditingController(text: "");
  TextEditingController _Desc = TextEditingController(text: "");

  String initial = "";
  String img = "";
  String cekLat = "";
  String cekLong = "";

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
  File? image;
  String? extension;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      image = File(pickedFile.path);
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
                  child: CustomText.textHeading4(
                      text: "Isi data restomu",
                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
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
                      CustomText.bodyLight12(text: "Foto Resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async{
                              getImage();
                            },
                            child: Container(
                              width: CustomSize.sizeWidth(context) / 6,
                              height: CustomSize.sizeWidth(context) / 6,
                              decoration: (image==null)?(img == "/".substring(0, 1))?BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ):BoxDecoration(
                                  color: CustomColor.primary,
                                  shape: BoxShape.circle
                              ): BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    image: new FileImage(image!),
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
                                  child: (image == null)?CustomText.text(
                                      size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                      weight: FontWeight.w800,
                                      text: initial,
                                      color: Colors.white
                                  ):Container(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          CustomText.bodyLight12(text: "Upload foto profile resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                        ],
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _Name,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Nama Resto',
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
                      CustomText.bodyLight12(text: "Alamat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        onTap: () {
                          btnAddress = true;
                        },
                        readOnly: true,
                        controller: _Address,
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
                          suffixIcon: (btnAddress != true)?GestureDetector(
                            onTap: () async{
                              var result = await Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: SearchAddressMapsResto(double.parse(latitude!),double.parse(longitude!))));
                              if(result != ""){
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                _Address = TextEditingController(text: pref.getString('address'));
                                setState(() {});
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
                                          text: "Buka maps",
                                          color: CustomColor.accent,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ):GestureDetector(
                            onTap: () async{
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              if (btnAddress == false) {
                                btnAddress = true;
                              } else {
                                btnAddress = false;
                                // List<Placemark> placemark = await Geolocator.getCurrentPosition(). .placemarkFromAddress();
                                // print(placemark[0].position.latitude);
                                // print(placemark[0].position.longitude);
                                // pref.setString("latitudeResto", placemark[0].position.latitude.toString());
                                // pref.setString("longitudeResto", placemark[0].position.longitude.toString());
                                // FocusScope.of(context).unfocus();
                                // FocusScope.of(context).requestFocus(FocusNode())
                                // print(latitude);
                                // print(longitude);
                              }
                              setState(() {});
                              //search alamat menggunakan text
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
                                          text: "Simpan",
                                          color: CustomColor.accent,
                                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
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
                      CustomText.bodyLight12(text: "Email", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _Email,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Email Resto',
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
                      CustomText.bodyLight12(text: "No Telp", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _NoTelp,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Nomor Telpon Resto',
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
                      CustomText.bodyLight12(text: "Deskripsikan Restomu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: (btnAddress == true)?true:false,
                        controller: _Desc,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: 'Deskripsi Resto',
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
                      (btnAddress == true)?Container():Container(
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
                                cekLat = pref.getString("latitudeResto")??'';
                                cekLong = pref.getString("longitudeResto")??'';
                                if (image.toString() == 'null') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_Name.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_Email.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_NoTelp.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_Desc.text.toString() == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else if (_Address.text.toString() == '' && cekLat == '' && cekLong == '') {
                                  Fluttertoast.showToast(msg: "Lengkapi data terlebih dahulu!");
                                } else {
                                  pref.setString("imgResto", 'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString());
                                  pref.setString("nameResto", _Name.text.toString());
                                  pref.setString("emailResto", _Email.text.toString());
                                  pref.setString("notelpResto", _NoTelp.text.toString());
                                  pref.setString("descResto", _Desc.text.toString());
                                  pref.setString("addressResto", _Address.text.toString());
                                  print(pref.getString("imgResto"));
                                  print(pref.getString("nameResto"));
                                  print('ini loh email '+pref.getString("emailResto"));
                                  print(pref.getString("latitudeResto"));
                                  print(pref.getString("longitudeResto"));
                                  print(pref.getString("notelpResto"));
                                  print(pref.getString("descResto"));

                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new AddDataUsaha()));
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
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
                )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
