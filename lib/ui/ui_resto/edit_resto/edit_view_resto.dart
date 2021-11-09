import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/ui_resto/edit_resto/edit_data_usaha.dart';
// import 'package:kam5ia/utils/search_address_maps_resto.dart';
import 'package:kam5ia/utils/utils.dart';
// import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/ui/ui_resto/edit_resto/edit_detail_resto.dart';

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

  String email = "";
  String badanU = '';
  String pemilikU = '';
  String penanggungJwb = '';
  String nameRekening = '';
  String nameBank = '';
  String nomorRekening = '';
  String foto_pj = '';
  String ktp = '';

  EditViewResto(this.idResto, this.name, this.img, this.address, this.phone, this.desc, this.lat, this.long, this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nameRekening, this.nameBank, this.nomorRekening, this.foto_pj, this.ktp);

  @override
  _EditViewRestoState createState() => _EditViewRestoState(idResto, name, img, address, phone, desc, lat, long, facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, email, badanU, pemilikU, penanggungJwb, nameRekening, nameBank, nomorRekening, foto_pj, ktp);
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

  String email = "";
  String badanU = '';
  String pemilikU = '';
  String penanggungJwb = '';
  String nameRekening = '';
  String nameBank = '';
  String nomorRekening = '';
  String foto_pj = '';
  String ktp = '';

  _EditViewRestoState(this.idResto, this.name, this.img, this.address, this.phone, this.desc, this.lat, this.long, this.facility, this.cuisine, this.can_delivery, this.can_takeaway, this.ongkir, this.reservation_fee, this.email, this.badanU, this.pemilikU, this.penanggungJwb, this.nameRekening, this.nameBank, this.nomorRekening, this.foto_pj, this.ktp);

  TextEditingController _Name = TextEditingController(text: "");
  TextEditingController _Email = TextEditingController(text: "");
  TextEditingController _Address = TextEditingController(text: "");
  TextEditingController _NoTelp = TextEditingController(text: "");
  TextEditingController _Desc = TextEditingController(text: "");

  String initial = "";

  bool isLoading = true;
  bool btnAddress = false;

  double? latitude;
  double? longitude;
  String karyawan = "";

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      karyawan = (pref.getString("karyawan"));
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  getEditView() async {
    _Name = TextEditingController(text: name);
    _Email = TextEditingController(text: email);
    _Address = TextEditingController(text: address);
    _NoTelp = TextEditingController(text: (phone.split('')[0] == '+')?'0'+phone.split('+62')[1]:phone);
    _Desc = TextEditingController(text: desc);
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
    getEditView();
    print(facility);
    // Location.instance.getLocation().then((value) {
    //   setState(() {
    //     latitude = value.latitude;
    //     longitude = value.longitude;
    //   });
    // });
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
                      text: "Edit data restomu",
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
                              // getImage();
                              Fluttertoast.showToast(msg: 'Anda hanya bisa merubah email, nomor telepon, dan deskripsi resto di halaman ini.',);
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
                                    image: new FileImage(image!),
                                    fit: BoxFit.cover
                                ),
                              ),
                              child: (img == "/".substring(0, 1))?Center(
                                child: CustomText.text(
                                    size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.094).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.094).toString()),
                                    weight: FontWeight.w800,
                                    text: initial,
                                    color: Colors.white
                                ),
                              ):Container(),
                            ),
                          ),
                          SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                          // CustomText.bodyLight12(text: "Edit foto profile usaha"),
                        ],
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        onTap: (){
                          Fluttertoast.showToast(msg: 'Anda hanya bisa merubah email, nomor telepon, dan deskripsi resto di halaman ini.',);
                        },
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
                      CustomText.bodyLight12(text: "Alamat", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        onTap: () async{
                          Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk refresh lokasi.',);
                          List<Location> locations = await locationFromAddress(_Address.text.toString());
                          // print('s '+locations.toString());
                          // print(lat);
                          // print(long);
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          pref.setString("latitudeResto", (locations[0].toString().split(': ')[1].split(',')[0]).toString());
                          pref.setString("longitudeResto", (locations[0].toString().split(',')[1].split(': ')[1]).toString());
                          // lat = locations[0].toString().split(': ')[1].split(',')[0];
                          // long = locations[0].toString().split(',')[1].split(': ')[1];
                          print(locations[0].toString().split(': ')[1].split(',')[0]);
                          print(locations[0].toString().split(',')[1].split(': ')[1]);

                          // var result = await Navigator.push(
                          //     context,
                          //     PageTransition(
                          //         type: PageTransitionType.rightToLeft,
                          //         child: SearchAddressMapsResto(latitude!,longitude!)));
                          // if(result != ""){
                          //   SharedPreferences pref = await SharedPreferences.getInstance();
                          //   _Address = TextEditingController(text: pref.getString('address'));
                          //   setState(() {});
                          // }
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
                          // suffixIcon: GestureDetector(
                          //   // onTap: () async{
                          //   //   var result = await Navigator.push(
                          //   //       context,
                          //   //       PageTransition(
                          //   //           type: PageTransitionType.rightToLeft,
                          //   //           child: SearchAddressMapsResto(latitude!,longitude!)));
                          //   //   if(result != ""){
                          //   //     SharedPreferences pref = await SharedPreferences.getInstance();
                          //   //     _Address = TextEditingController(text: pref.getString('address'));
                          //   //     setState(() {});
                          //   //   }
                          //   // },
                          //   child: Stack(
                          //     children: [
                          //       Container(
                          //         width: CustomSize.sizeWidth(context) / 4,
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(25),
                          //           border: Border.all(color: CustomColor.accent, width: 1),
                          //           // color: CustomColor.accentLight
                          //         ),
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(2.0),
                          //           child: Center(
                          //             child: CustomText.textTitle8(
                          //                 text: "Buka maps",
                          //                 color: CustomColor.accent
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // )
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
                      CustomText.bodyLight12(text: "No Telp", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
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
                      CustomText.bodyLight12(text: "Deskripsi Resto", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
        (karyawan == '1')?GestureDetector(
          onTap: () async{
            setState(() {
              isLoading = false;
            });
            List<Location> locations = await locationFromAddress(_Address.text.toString());
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString("latitudeResto", (locations[0].toString().split(': ')[1].split(',')[0]).toString());
            pref.setString("longitudeResto", (locations[0].toString().split(',')[1].split(': ')[1]).toString());
            // lat = locations[0].toString().split(': ')[1].split(',')[0];
            // long = locations[0].toString().split(',')[1].split(': ')[1];
            print(locations[0].toString().split(': ')[1].split(',')[0]);
            print(locations[0].toString().split(',')[1].split(': ')[1]);
            pref.setString("imgResto", (image != null)?'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString():'');
            pref.setString("nameResto", _Name.text.toString());
            pref.setString("emailResto", _Email.text.toString());
            pref.setString("notelpResto", _NoTelp.text.toString());
            pref.setString("descResto", _Desc.text.toString());
            pref.setString("addressResto", _Address.text.toString());
            // pref.setString("latitudeResto", lat);
            // pref.setString("longitudeResto", long);
            print(lat);
            print(long);
            print(pref.getString("imgResto"));
            print(pref.getString("nameResto"));
            print(pref.getString("emailResto"));
            print(pref.getString("notelpResto"));
            print(pref.getString("latitudeResto"));
            print(pref.getString("longitudeResto"));
            print(pref.getString("descResto"));

            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDataUsaha(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nameRekening, nameBank, nomorRekening, foto_pj, ktp)));

          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: CustomColor.accent
            ),
            child: Center(child: CustomText.bodyRegular16(text: "Lanjut", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))),
          ),
        ):GestureDetector(
          onTap: () async{
            setState(() {
              isLoading = false;
            });
            List<Location> locations = await locationFromAddress(_Address.text.toString());
            // print('s '+locations.toString());
            // print(lat);
            // print(long);
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString("latitudeResto", (locations[0].toString().split(': ')[1].split(',')[0]).toString());
            pref.setString("longitudeResto", (locations[0].toString().split(',')[1].split(': ')[1]).toString());
            // lat = locations[0].toString().split(': ')[1].split(',')[0];
            // long = locations[0].toString().split(',')[1].split(': ')[1];
            print(locations[0].toString().split(': ')[1].split(',')[0]);
            print(locations[0].toString().split(',')[1].split(': ')[1]);
            pref.setString("imgResto", (image != null)?'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString():'');
            pref.setString("nameResto", _Name.text.toString());
            pref.setString("emailResto", _Email.text.toString());
            pref.setString("notelpResto", _NoTelp.text.toString());
            pref.setString("descResto", _Desc.text.toString());
            pref.setString("addressResto", _Address.text.toString());
            // pref.setString("latitudeResto", lat);
            // pref.setString("longitudeResto", long);

            print(lat);
            print(long);
            print(pref.getString("imgResto"));
            print(pref.getString("nameResto"));
            print(pref.getString("emailResto"));
            print(pref.getString("notelpResto"));
            print(pref.getString("latitudeResto"));
            print(pref.getString("longitudeResto"));
            print(pref.getString("descResto"));

            Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new EditDataUsaha(facility, cuisine, can_delivery, can_takeaway, ongkir, reservation_fee, idResto, email, badanU, pemilikU, penanggungJwb, nameRekening, nameBank, nomorRekening, foto_pj, ktp)));

          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: CustomColor.accent
            ),
            child: Center(child: CustomText.bodyRegular16(text: "Lanjut", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
