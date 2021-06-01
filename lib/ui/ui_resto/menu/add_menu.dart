import 'dart:convert';
import 'dart:io';

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

class AddMenu extends StatefulWidget {
  @override
  _AddMenuState createState() => _AddMenuState();
}

class MenuChip extends StatefulWidget {
  final List<String> menuList;
  final Function(List<String>) onSelectionChanged;

  MenuChip(this.menuList, {this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<MenuChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.menuList.forEach((item) {
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
              if (selectedChoices.contains(item) != null) {
                selectedChoices.clear();
                selectedChoices.add(item);
              } else {
                selectedChoices.add(item);
              }
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

class _AddMenuState extends State<AddMenu> {
  TextEditingController namaMenu = TextEditingController(text: "");
  TextEditingController hargaMenu = TextEditingController(text: "");
  TextEditingController hargaDeliv = TextEditingController(text: "");
  TextEditingController tipeMenu = TextEditingController(text: "");
  TextEditingController deskMenu = TextEditingController(text: "");
  TextEditingController tOngkir = TextEditingController(text: "");
  TextEditingController tReser4 = TextEditingController(text: "");
  TextEditingController tTable = TextEditingController(text: "");

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
    "Opening Course",
    "Main Course",
    "Dessert",
    "Drink",
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
            content: MenuChip(
              menuList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedMenuList = selectedList;
                  tipe = selectedMenuList.single;
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

  @override
  void initState() {
    super.initState();
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
                    text: "Isi data menumu",
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
                    CustomText.bodyLight12(text: "Nama Menu"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: namaMenu,
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
                    CustomText.bodyLight12(text: "Harga"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: hargaMenu,
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
                    CustomText.bodyLight12(text: "Harga Delivery"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: hargaDeliv,
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
                    CustomText.bodyLight12(text: "Tipe Menu"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      readOnly: true,
                      controller: tipeMenu,
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
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () async{
                              _showCuisineDialog();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: CustomSize.sizeWidth(context) / 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: CustomColor.accent, width: 1),
                                    // color: CustomColor.accentLight
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Center(
                                      child: CustomText.textTitle8(
                                          text: "Ganti",
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
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "Deskripsikan Menu ini"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: deskMenu,
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
                    CustomText.bodyLight12(text: "Tambahkan Foto Menu"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.015,
                    ),
                    GestureDetector(
                      onTap: () async{
                        getImage();
                      },
                      child: Row(
                        children: [
                          (image == null)?Container(
                        height: CustomSize.sizeHeight(context) / 6.5,
                        width: CustomSize.sizeWidth(context) / 3.2,
                        child: Icon(FontAwesome.plus, color: CustomColor.primary, size: 50,),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: CustomColor.primary,
                              width: 3.0
                          ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(10.0) //         <--- border radius here
                          ),
                        ),
                      ):Container(
                        height: CustomSize.sizeHeight(context) / 6.5,
                        width: CustomSize.sizeWidth(context) / 3.2,
                        decoration: (image==null)?(img == "/".substring(0, 1))?BoxDecoration(
                          border: Border.all(
                              color: CustomColor.primary,
                              width: 3.0
                          ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(10.0) //         <--- border radius here
                          ),
                        ):BoxDecoration(
                          border: Border.all(
                              color: CustomColor.primary,
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
                        ):Padding(
                          padding: const EdgeInsets.only(left: 1.5),
                          child: Center(
                            child: (image == null)?CustomText.text(
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
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.0075,
                    ),
                    //------------------------------------ checkbox favorite -------------------------------------
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: favorite,
                          onChanged: (bool value) {
                            setState(() {
                              favorite = value;
                              print(favorite);
                            });
                          },
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText.bodyMedium14(
                                text: "Apakah Menu ini adalah menu",
                                minSize: 14,
                                maxLines: 1
                            ),
                            CustomText.bodyMedium14(
                                text: "andalan di restomu ?",
                                minSize: 14,
                                maxLines: 1
                            ),
                          ],
                        ),
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
      floatingActionButton:
      GestureDetector(
        onTap: () async{
          setState(() {
            isLoading = false;
          });
          // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivityResto()));
          // SharedPreferences pref = await SharedPreferences.getInstance();
          // pref.setString("name", namaMenu.text.toString());
          // pref.setString("email", hargaDeliv.text.toString());
          // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
          // pref.setString("gender", gender);
          // pref.setString("tgl", tgl);
          // pref.setString("notelp", hargaMenu.text.toString());
          print(namaMenu);
          print(hargaMenu);
          print(hargaDeliv);
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