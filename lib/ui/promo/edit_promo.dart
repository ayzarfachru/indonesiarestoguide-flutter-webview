import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indonesiarestoguide/ui/ui_resto/add_resto/add_detail_resto.dart';
import 'package:indonesiarestoguide/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:indonesiarestoguide/ui/ui_resto/home/home_activity.dart';
import 'package:indonesiarestoguide/ui/ui_resto/menu/menu_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class EditPromo extends StatefulWidget {
  @override
  _EditPromoState createState() => _EditPromoState();
}

class _EditPromoState extends State<EditPromo> {
  TextEditingController descPromo = TextEditingController(text: "");
  TextEditingController percentPromo = TextEditingController(text: "");
  TextEditingController endPromo = TextEditingController(text: "");
  TextEditingController tipeMenu = TextEditingController(text: "");
  TextEditingController deskMenu = TextEditingController(text: "");
  TextEditingController tOngkir = TextEditingController(text: "");
  TextEditingController tReser4 = TextEditingController(text: "");
  TextEditingController tTable = TextEditingController(text: "");
  TextEditingController _dateController = TextEditingController();

  String name = "";
  String initial = "";
  String email = "";
  String img = "";
  String gender = "wanita";
  String tgl = "";
  String notelp = "";

  bool isLoading = true;

  bool favorite = false;
  bool reservation = false;
  bool delivery = false;

  List<String> menuList = [
    "Chinese Food",
    "Indonesian Food",
    "Western Food",
    "Cafe",
    "Asian Food",
    "Bakery",
    "Bali Food",
    "Uncivil",
    "Catering",
    "Coffee Shop",
    "Dessert",
    "Fine Dining",
    "Halal",
  ];

  List<String> selectedMenuList = List();
  String tipe;

  _showCuisineDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Tipe Menu"),
            content: CuisineChip(
              menuList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedMenuList = selectedList;
                  tipe = selectedMenuList.join(",");
                  print(tipe);
                  if (tipe != "") {
                    selectedList = tipe.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("tipeMenu", tipe);
                  setState(() {
                    print(tipe);
                    getTipeMenu();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  getTipeMenu() async {
    tipeMenu = TextEditingController(text: tipe);
  }

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      print(initial);
    });
  }

  pria() async {
    setState(() {
      gender = "pria";
      print(gender);
    });
  }

  wanita() async {
    setState(() {
      gender = "wanita";
      print(gender);
    });
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


  //------------------------------= DATE PICKER =----------------------------------
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        helpText: "Pilih Tanggal",
        cancelText: "Batal",
        confirmText: "Simpan",
        firstDate: DateTime(2009),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              backgroundColor: Colors.black,
              primaryColor: CustomColor.secondary, //Head background
              accentColor: CustomColor.secondary //s //Background color
            ),
            child: child,
          );
        },
      );
      if (picked != null)
        setState(() {
          selectedDate = picked;
          _dateController.text = DateFormat.yMd().format(selectedDate);
        });
    }

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat.yMd().format(DateTime.now().add(const Duration(days: 7)));
    getInitial();
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
                    text: "Edit promo",
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
                    CustomText.bodyLight12(text: "Deskripsi Promo"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: descPromo,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Isi Deskripsi",
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
                    CustomText.bodyLight12(text: "Potongan Harga"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: percentPromo,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        hintText: "Diskon 10 - 100 %",
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
                    CustomText.bodyLight12(text: "Tanggal Berakhir"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      readOnly: true,
                      controller: _dateController,
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
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () async{
                              _selectDate(context);
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
                                          text: "Pilih Tanggal",
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 8,),
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
          // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivityResto()));
          // SharedPreferences pref = await SharedPreferences.getInstance();
          // pref.setString("name", descPromo.text.toString());
          // pref.setString("email", endPromo.text.toString());
          // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
          // pref.setString("gender", gender);
          // pref.setString("tgl", tgl);
          // pref.setString("notelp", percentPromo.text.toString());
          print(descPromo);
          print(percentPromo);
          print(endPromo);
          print(tipeMenu);
          print(deskMenu);
          print(base64Encode(image.readAsBytesSync()).toString());
          print(favorite);
        },
        child: Container(
          width: CustomSize.sizeWidth(context) / 1.1,
          height: CustomSize.sizeHeight(context) / 14,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: CustomColor.accent
          ),
          child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white,)),
        ),
      ),
    );
  }
}
