import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indonesiarestoguide/utils/search_address_maps_resto.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:indonesiarestoguide/ui/ui_resto/edit_resto/edit_detail_resto.dart';

import 'package:http/http.dart' as http;

class EditViewResto extends StatefulWidget {
  String name = '';
  String img = '';
  String address = '';
  String phone = '';
  String desc = '';
  String lat = '';
  String long = '';
  String facility = '';
  String cuisine = '';
  String can_delivery = '';
  String can_takeaway = '';
  String ongkir = '';
  String reservation_fee = '';
  String idResto = '';

  EditViewResto(this.idResto, this.name, this.img, this.address, this.phone, this.desc, this.lat, this.long, this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, );

  @override
  _EditViewRestoState createState() => _EditViewRestoState(idResto, name, img, address, phone, desc, lat, long, facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee);
}

class _EditViewRestoState extends State<EditViewResto> {
  String name = '';
  String img = '';
  String address = '';
  String phone = '';
  String desc = '';
  String lat = '';
  String long = '';
  String facility = '';
  String cuisine = '';
  String can_delivery = '';
  String can_takeaway = '';
  String ongkir = '';
  String reservation_fee = '';
  String idResto = '';

  _EditViewRestoState(this.idResto, this.name, this.img, this.address, this.phone, this.desc, this.lat, this.long, this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee,);

  TextEditingController _Name = TextEditingController(text: "");
  TextEditingController _Address = TextEditingController(text: "");
  TextEditingController _NoTelp = TextEditingController(text: "");
  TextEditingController _Desc = TextEditingController(text: "");

  String initial = "";

  bool isLoading = true;
  bool btnAddress = false;

  double latitude;
  double longitude;

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  getEditView() async {
    _Name = TextEditingController(text: name);
    _Address = TextEditingController(text: address);
    _NoTelp = TextEditingController(text: (phone.split('')[0] == '+')?'0'+phone.split('+62')[1]:phone);
    _Desc = TextEditingController(text: desc);
  }


  //------------------------------= IMAGE PICKER =----------------------------------
  File image;
  String extension;
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
    getEditView();
    print(facility);
    Location.instance.getLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
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
                    text: "Edit data restomu",
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
                    CustomText.bodyLight12(text: "Foto Resto"),
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
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  image: NetworkImage(Links.subUrl +
                                      "$img"),
                                  fit: BoxFit.cover
                              ),
                            ): BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  image: new FileImage(image),
                                  fit: BoxFit.cover
                              ),
                            ),
                            child: (img == "/".substring(0, 1))?Center(
                              child: CustomText.text(
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initial,
                                  color: Colors.white
                              ),
                            ):Container(),
                          ),
                        ),
                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        CustomText.bodyLight12(text: "Edit foto profile resto"),
                      ],
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "Nama"),
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
                    CustomText.bodyLight12(text: "Alamat"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      onTap: () {
                        btnAddress = true;
                      },
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
                                    child: SearchAddressMapsResto(latitude,longitude)));
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
                                        color: CustomColor.accent
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
                              List<Placemark> placemark = await Geolocator().placemarkFromAddress(_Address.text);
                              print(placemark[0].position.latitude);
                              print(placemark[0].position.longitude);
                              pref.setString("latitudeResto", placemark[0].position.latitude.toString());
                              pref.setString("longitudeResto", placemark[0].position.longitude.toString());
                              FocusScope.of(context).unfocus();
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
                    CustomText.bodyLight12(text: "No Telp"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // readOnly: (btnAddress == true)?true:false,
                      controller: _NoTelp,
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
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "Deskripsi Resto"),
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton:
      GestureDetector(
        onTap: () async{
          setState(() {
            isLoading = false;
          });
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("imgResto", (image != null)?'data:image/$extension;base64,'+base64Encode(image.readAsBytesSync()).toString():'');
          pref.setString("nameResto", _Name.text.toString());
          pref.setString("notelpResto", _NoTelp.text.toString());
          pref.setString("descResto", _Desc.text.toString());
          pref.setString("addressResto", _Address.text.toString());
          pref.setString("latitudeResto", lat);
          pref.setString("longitudeResto", long);
          print(pref.getString("imgResto"));
          print(pref.getString("nameResto"));
          print(pref.getString("notelpResto"));
          print(pref.getString("latitudeResto"));
          print(pref.getString("longitudeResto"));
          print(pref.getString("notelpResto"));
          print(pref.getString("descResto"));

          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDetailResto(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto)));
        },
        child: Container(
          width: CustomSize.sizeWidth(context) / 1.1,
          height: CustomSize.sizeHeight(context) / 14,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: CustomColor.accent
          ),
          child: Center(child: CustomText.bodyRegular16(text: "Lanjut", color: Colors.white,)),
        ),
      ),
    );
  }
}
