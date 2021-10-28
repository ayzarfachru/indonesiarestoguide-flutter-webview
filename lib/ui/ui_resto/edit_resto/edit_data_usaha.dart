import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/ui_resto/edit_resto/edit_detail_resto.dart';
import 'package:kam5ia/utils/search_address_maps_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';

import 'package:http/http.dart' as http;

class EditDataUsaha extends StatefulWidget {

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
  String nameRekening = '';
  String nameBank = '';
  String nomorRekening = '';
  String foto_pj = '';
  String ktp = '';

  @override
  _EditDataUsahaState createState() => _EditDataUsahaState(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nameRekening, nameBank, nomorRekening, foto_pj, ktp);

  EditDataUsaha(this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.idResto, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nameRekening, this.nameBank, this.nomorRekening, this.foto_pj, this.ktp);
}

class _EditDataUsahaState extends State<EditDataUsaha> {
  TextEditingController _NameBadanUsaha = TextEditingController(text: "");
  TextEditingController _NamePemilik = TextEditingController(text: "");
  TextEditingController _NamePenanggungJawab = TextEditingController(text: "");
  TextEditingController _Address = TextEditingController(text: "");
  TextEditingController _NameRekening = TextEditingController(text: "");
  TextEditingController _NameBank = TextEditingController(text: "");
  TextEditingController _NoRekeningBank = TextEditingController(text: "");
  TextEditingController _Desc = TextEditingController(text: "");

  String initial = "";
  String img = "";

  String foto_pj = "";
  String ktp = "";

  bool isLoading = true;
  bool btnAddress = false;

  String? latitude;
  String? longitude;

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
  String nameRekening = '';
  String nameBank = '';
  String nomorRekening = '';

  _EditDataUsahaState(this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.idResto, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nameRekening, this.nameBank, this.nomorRekening, this.foto_pj, this.ktp);

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      karyawan = (pref.getString("karyawan"));
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

  String karyawan = "";

  getEditView() async {
    // _Name = TextEditingController(text: name);
    // _Email = TextEditingController(text: email);
    _NameBadanUsaha = TextEditingController(text: badanU);
    _NamePemilik = TextEditingController(text: pemilikU);
    _NamePenanggungJawab = TextEditingController(text: penanggungJwb);
    _NameRekening = TextEditingController(text: nameRekening);
    _NameBank = TextEditingController(text: nameBank);
    _NoRekeningBank = TextEditingController(text: nomorRekening);
    // _NoTelp = TextEditingController(text: (phone.split('')[0] == '+')?'0'+phone.split('+62')[1]:phone);
    // _Desc = TextEditingController(text: desc);
  }

  @override
  void initState() {
    super.initState();
    getInitial();
    getEditView();
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: (karyawan == '1')?Column(
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
                    CustomText.bodyLight12(text: "Nama Badan Usaha (PT/CV/UD)"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // readOnly: (btnAddress == true)?true:false,
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
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
                    CustomText.bodyLight12(text: "Nama Pemilik Resto"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
                      controller: _NamePemilik,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        hintText: 'Pemilik Usaha',
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
                    CustomText.bodyLight12(text: "Nama Penanggung Jawab"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
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
                    CustomText.bodyLight12(text: "Tambahkan Selfie Pemilik/Penanggung Jawab"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.015,
                    ),
                    GestureDetector(
                      onTap: () async{
                        Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                        // getImage2();
                      },
                      child: Row(
                        children: [
                          (image2 == null)?Container(
                            height: CustomSize.sizeHeight(context) / 6.5,
                            width: CustomSize.sizeWidth(context) / 3.2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(Links.subUrl + foto_pj),
                                  fit: BoxFit.cover
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
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initial,
                                  color: Colors.white
                              ),
                            ):Padding(
                              padding: const EdgeInsets.only(left: 1.5),
                              child: Center(
                                child: (image2 == null)?CustomText.text(
                                    size: 38,
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
                    CustomText.bodyLight12(text: "Tambahkan KTP Pemilik/Penanggung Jawab"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.015,
                    ),
                    GestureDetector(
                      onTap: () async{
                        // getImage3();
                        Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      },
                      child: Row(
                        children: [
                          (image3 == null)?Container(
                            height: CustomSize.sizeHeight(context) / 6.5,
                            width: CustomSize.sizeWidth(context) / 2.2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(Links.subUrl + ktp),
                                  fit: BoxFit.cover
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
                                  size: 38,
                                  weight: FontWeight.w800,
                                  text: initial,
                                  color: Colors.white
                              ),
                            ):Padding(
                              padding: const EdgeInsets.only(left: 1.5),
                              child: Center(
                                child: (image3 == null)?CustomText.text(
                                    size: 38,
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
                    CustomText.bodyLight12(text: "Nama Sesuai Rekening"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
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
                    CustomText.bodyLight12(text: "Bank"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
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
                    CustomText.bodyLight12(text: "Nomor Rekening Bank"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      // onTap: (){
                      //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                      // },
                      // readOnly: true,
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
                    (btnAddress == true)?Container():Center(
                      child: GestureDetector(
                        onTap: () async{
                          setState(() {
                            isLoading = false;
                          });
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          if (image2 != null && image3 != null) {
                            pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                            pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                          } else if (image2 != null && image3 == null) {
                            pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                            pref.setString("imgKTP", '');
                          } else if (image2 == null && image3 != null) {
                            pref.setString("imgSelfie", '');
                            pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                          } else if (image2 == null && image3 == null) {
                            pref.setString("imgSelfie", '');
                            pref.setString("imgKTP", '');
                          }
                          pref.setString("nameBadanUsaha", _NameBadanUsaha.text.toString());
                          pref.setString("namePemilik", _NamePemilik.text.toString());
                          pref.setString("namePenanggungJawab", _NamePenanggungJawab.text.toString());
                          pref.setString("nameRekening", _NameRekening.text.toString());
                          pref.setString("nameBank", _NameBank.text.toString());
                          pref.setString("noRekeningBank", _NoRekeningBank.text.toString());
                          print(pref.getString("imgSelfie"));
                          print(pref.getString("imgKTP")+'ini ktp');
                          print(pref.getString("nameBadanUsaha"));
                          print(pref.getString("namePemilik"));
                          print(pref.getString("namePenanggungJawab"));
                          print(pref.getString("noRekeningBank"));

                          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDetailResto(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nomorRekening)));
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
            ],
          )
              :Stack(
              // alignment: Alignment.topCenter,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    //   child: CustomText.textHeading4(
                    //       text: "Edit data usahamu",
                    //       minSize: 18,
                    //       maxLines: 1
                    //   ),
                    // ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                    // Divider(
                    //   thickness: 8,
                    //   color: CustomColor.secondary,
                    // ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          // CustomText.bodyLight12(text: "Nama Badan Usaha (PT/CV/UD)"),
                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) * 0.005,
                          // ),
                          // TextField(
                          //   // readOnly: (btnAddress == true)?true:false,
                          //   controller: _NameBadanUsaha,
                          //   keyboardType: TextInputType.text,
                          //   cursorColor: Colors.black,
                          //   style: GoogleFonts.poppins(
                          //       textStyle:
                          //       TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                          //   decoration: InputDecoration(
                          //     hintText: 'Badan Usaha',
                          //     isDense: true,
                          //     contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          //     hintStyle: GoogleFonts.poppins(
                          //         textStyle:
                          //         TextStyle(fontSize: 14, color: Colors.grey)),
                          //     helperStyle: GoogleFonts.poppins(
                          //         textStyle: TextStyle(fontSize: 14)),
                          //     enabledBorder: UnderlineInputBorder(
                          //
                          //     ),
                          //     focusedBorder: UnderlineInputBorder(
                          //
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyLight12(text: "Nama Pemilik Usaha", color: Colors.transparent),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          TextField(
                            // onTap: (){
                            //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                            // },
                            readOnly: true,
                            controller: _NamePemilik,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.transparent, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              hintText: 'Pemilik Usaha',
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.transparent)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14, color: Colors.transparent)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyLight12(text: "Nama Penanggung Jawab", color: Colors.transparent),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          TextField(
                            // onTap: (){
                            //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                            // },
                            // readOnly: true,
                            // readOnly: (btnAddress == true)?true:false,
                            controller: _NamePenanggungJawab,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.transparent, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              hintText: 'Penanggung Jawab Usaha',
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.transparent)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          // CustomText.bodyLight12(text: "Tambahkan Selfie Pemilik/Penanggung Jawab"),
                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) * 0.015,
                          // ),
                          // GestureDetector(
                          //   onTap: () async{
                          //     Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                          //     // getImage2();
                          //   },
                          //   child: Row(
                          //     children: [
                          //       (image2 == null)?Container(
                          //         height: CustomSize.sizeHeight(context) / 6.5,
                          //         width: CustomSize.sizeWidth(context) / 3.2,
                          //         decoration: BoxDecoration(
                          //           image: DecorationImage(
                          //               image: NetworkImage(Links.subUrl + foto_pj),
                          //               fit: BoxFit.cover
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ),
                          //       ):Container(
                          //         height: CustomSize.sizeHeight(context) / 6.5,
                          //         width: CustomSize.sizeWidth(context) / 3.2,
                          //         decoration: (image2==null)?(img == "/".substring(0, 1))?BoxDecoration(
                          //           border: Border.all(
                          //               color: CustomColor.primaryLight,
                          //               width: 3.0
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ):BoxDecoration(
                          //           border: Border.all(
                          //               color: CustomColor.primaryLight,
                          //               width: 3.0
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ): BoxDecoration(
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //           image: new DecorationImage(
                          //               image: new FileImage(image2!),
                          //               fit: BoxFit.cover
                          //           ),
                          //         ),
                          //         child: (img == "/".substring(0, 1))?Center(
                          //           child: CustomText.text(
                          //               size: 38,
                          //               weight: FontWeight.w800,
                          //               text: initial,
                          //               color: Colors.white
                          //           ),
                          //         ):Padding(
                          //           padding: const EdgeInsets.only(left: 1.5),
                          //           child: Center(
                          //             child: (image2 == null)?CustomText.text(
                          //                 size: 38,
                          //                 weight: FontWeight.w800,
                          //                 text: initial,
                          //                 color: Colors.white
                          //             ):Container(),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          // CustomText.bodyLight12(text: "Tambahkan KTP Pemilik/Penanggung Jawab"),
                          // SizedBox(
                          //   height: CustomSize.sizeHeight(context) * 0.015,
                          // ),
                          // GestureDetector(
                          //   onTap: () async{
                          //     // getImage3();
                          //     Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                          //   },
                          //   child: Row(
                          //     children: [
                          //       (image3 == null)?Container(
                          //         height: CustomSize.sizeHeight(context) / 6.5,
                          //         width: CustomSize.sizeWidth(context) / 2.2,
                          //         decoration: BoxDecoration(
                          //           image: DecorationImage(
                          //               image: NetworkImage(Links.subUrl + ktp),
                          //               fit: BoxFit.cover
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ),
                          //       ):Container(
                          //         height: CustomSize.sizeHeight(context) / 6.5,
                          //         width: CustomSize.sizeWidth(context) / 2.2,
                          //         decoration: (image3==null)?(img == "/".substring(0, 1))?BoxDecoration(
                          //           border: Border.all(
                          //               color: CustomColor.primaryLight,
                          //               width: 3.0
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ):BoxDecoration(
                          //           border: Border.all(
                          //               color: CustomColor.primaryLight,
                          //               width: 3.0
                          //           ),
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //         ): BoxDecoration(
                          //           borderRadius: BorderRadius.all(
                          //               Radius.circular(10.0) //         <--- border radius here
                          //           ),
                          //           image: new DecorationImage(
                          //               image: new FileImage(image3!),
                          //               fit: BoxFit.cover
                          //           ),
                          //         ),
                          //         child: (img == "/".substring(0, 1))?Center(
                          //           child: CustomText.text(
                          //               size: 38,
                          //               weight: FontWeight.w800,
                          //               text: initial,
                          //               color: Colors.white
                          //           ),
                          //         ):Padding(
                          //           padding: const EdgeInsets.only(left: 1.5),
                          //           child: Center(
                          //             child: (image3 == null)?CustomText.text(
                          //                 size: 38,
                          //                 weight: FontWeight.w800,
                          //                 text: initial,
                          //                 color: Colors.white
                          //             ):Container(),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyLight12(text: "Nama Sesuai Rekening", color: Colors.transparent),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          TextField(
                            // onTap: (){
                            //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                            // },
                            // readOnly: true,
                            // readOnly: (btnAddress == true)?true:false,
                            controller: _NameRekening,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.transparent, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              hintText: 'Nama Sesuai Rekening Bank',
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.transparent)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyLight12(text: "Bank", color: Colors.transparent),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          TextField(
                            // onTap: (){
                            //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                            // },
                            // readOnly: true,
                            // readOnly: (btnAddress == true)?true:false,
                            controller: _NameBank,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.transparent, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              hintText: 'Rekening Bank',
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.transparent)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          CustomText.bodyLight12(text: "Nomor Rekening Bank", color: Colors.transparent),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) * 0.005,
                          ),
                          TextField(
                            // onTap: (){
                            //   Fluttertoast.showToast(msg: 'Anda tidak dapat merubah apapun di halaman ini.',);
                            // },
                            // readOnly: true,
                            // readOnly: (btnAddress == true)?true:false,
                            controller: _NoRekeningBank,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 18, color: Colors.transparent, fontWeight: FontWeight.w600)),
                            decoration: InputDecoration(
                              hintText: 'Rekening Bank',
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                              hintStyle: GoogleFonts.poppins(
                                  textStyle:
                                  TextStyle(fontSize: 14, color: Colors.transparent)),
                              helperStyle: GoogleFonts.poppins(
                                  textStyle: TextStyle(fontSize: 14)),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                          // (btnAddress == true)?Container():Center(
                          //   child: GestureDetector(
                          //     onTap: () async{
                          //       setState(() {
                          //         isLoading = false;
                          //       });
                          //       SharedPreferences pref = await SharedPreferences.getInstance();
                          //       if (image2 != null && image3 != null) {
                          //         pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                          //         pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                          //       } else if (image2 != null && image3 == null) {
                          //         pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
                          //         pref.setString("imgKTP", '');
                          //       } else if (image2 == null && image3 != null) {
                          //         pref.setString("imgSelfie", '');
                          //         pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
                          //       } else if (image2 == null && image3 == null) {
                          //         pref.setString("imgSelfie", '');
                          //         pref.setString("imgKTP", '');
                          //       }
                          //       pref.setString("nameBadanUsaha", _NameBadanUsaha.text.toString());
                          //       pref.setString("namePemilik", _NamePemilik.text.toString());
                          //       pref.setString("namePenanggungJawab", _NamePenanggungJawab.text.toString());
                          //       pref.setString("nameRekening", _NameRekening.text.toString());
                          //       pref.setString("nameBank", _NameBank.text.toString());
                          //       pref.setString("noRekeningBank", _NoRekeningBank.text.toString());
                          //       print(pref.getString("imgSelfie"));
                          //       print(pref.getString("imgKTP")+'ini ktp');
                          //       print(pref.getString("nameBadanUsaha"));
                          //       print(pref.getString("namePemilik"));
                          //       print(pref.getString("namePenanggungJawab"));
                          //       print(pref.getString("noRekeningBank"));
                          //
                          //       Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDetailResto(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nomorRekening)));
                          //     },
                          //     child: Container(
                          //       width: CustomSize.sizeWidth(context) / 1.1,
                          //       height: CustomSize.sizeHeight(context) / 14,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(30),
                          //           color: CustomColor.accent
                          //       ),
                          //       child: Center(child: CustomText.bodyRegular16(text: "Lanjut", color: Colors.white,)),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                  ],
                ),


                // Container(
                //   // height: CustomSize.sizeHeight(context),
                //   width: CustomSize.sizeWidth(context),
                //   color: Colors.white,
                // ),

                Container(
                  height: CustomSize.sizeHeight(context) / 1.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          SizedBox(height: CustomSize.sizeHeight(context) / 88,),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              // height: CustomSize.sizeHeight(context) / 3.8,
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                    CustomText.bodyRegular18(text: "*Pada halaman ini data pemilik resto tidak dapat dilihat maupun diubah oleh pegawai resto!", color: CustomColor.redBtn, minSize: 15, maxLines: 3),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                ]
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
      (karyawan == '1')?Container():GestureDetector(
        onTap: () async{
          setState(() {
            isLoading = false;
          });
          SharedPreferences pref = await SharedPreferences.getInstance();
          if (image2 != null && image3 != null) {
            pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
            pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
          } else if (image2 != null && image3 == null) {
            pref.setString("imgSelfie", 'data:image/$extension;base64,'+base64Encode(image2!.readAsBytesSync()).toString());
            pref.setString("imgKTP", '');
          } else if (image2 == null && image3 != null) {
            pref.setString("imgSelfie", '');
            pref.setString("imgKTP", 'data:image/$extension;base64,'+base64Encode(image3!.readAsBytesSync()).toString());
          } else if (image2 == null && image3 == null) {
            pref.setString("imgSelfie", '');
            pref.setString("imgKTP", '');
          }
          pref.setString("nameBadanUsaha", _NameBadanUsaha.text.toString());
          pref.setString("namePemilik", _NamePemilik.text.toString());
          pref.setString("namePenanggungJawab", _NamePenanggungJawab.text.toString());
          pref.setString("nameRekening", _NameRekening.text.toString());
          pref.setString("nameBank", _NameBank.text.toString());
          pref.setString("noRekeningBank", _NoRekeningBank.text.toString());
          print(pref.getString("imgSelfie"));
          print(pref.getString("imgKTP")+'ini ktp');
          print(pref.getString("nameBadanUsaha"));
          print(pref.getString("namePemilik"));
          print(pref.getString("namePenanggungJawab"));
          print(pref.getString("noRekeningBank"));

          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDetailResto(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nomorRekening)));
        },
        child: Container(
          alignment: Alignment.bottomCenter,
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
