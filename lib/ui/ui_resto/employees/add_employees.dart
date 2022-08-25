import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/ui_resto/employees/employees_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class AddEmployeesActivity extends StatefulWidget {
  @override
  _AddEmployeesActivityState createState() => _AddEmployeesActivityState();
}

class _AddEmployeesActivityState extends State<AddEmployeesActivity> {
  TextEditingController _loginTextName = TextEditingController(text: "");
  TextEditingController _loginEmailName = TextEditingController(text: "");
  TextEditingController _loginNotelpName = TextEditingController(text: "");
  TextEditingController _gender = TextEditingController(text: "");

  String name = "";
  String initial = "";
  String email = "";
  String img = "";
  String gender = "";
  String tgl = "";
  String notelp = "";

  bool isLoading = true;

  getName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = (pref.getString('name')??'');
      print(name);
    });
  }

  getTname() async {
    setState(() {
      _loginTextName = TextEditingController(text: name);
    });
  }

  getEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      email = (pref.getString('email')??'');
      print(email);
    });
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img')??'');
      print(img);
    });
  }

  getNotelp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      // notelp = (pref.getString('notelp'));
      notelp = "";
      print(notelp);
    });
  }

  getTnotelp() async {
    setState(() {
      _loginNotelpName = TextEditingController(text: (notelp != "null")?notelp:"+62");
    });
  }

  getGenderField() async {
    setState(() {
      _gender = TextEditingController(text: (gender != "null")?gender:"Mohon di isi!");
    });
  }

  getGender() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      gender = (pref.getString('gender')??'');
      print(gender);
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

  getTgl() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      tgl = (pref.getString('tgl')??'');
      print(tgl);
    });
  }

  //------------------------------= IMAGE PICKER =----------------------------------
  File? image;
  String? extension;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      image = File(pickedFile!.path);
      extension = pickedFile.path.split('.').last;
    });
  }

  Future<String?>? addEployees() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var id = pref.getInt("id") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/karyawan'),
        body: {
          'email': _loginEmailName.text,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    var data = json.decode(apiResult.body);
    print(apiResult.body);
    // print(newName+'tsnl');
    // print(newEmail+'tsnl');
    // print(newTgl+'tsnl');
    // print(newGender+'tsnl');
    // print(newNotelp+'tsnl');
    // print(image != null ? 'data:image/$extension;base64,' +
    //     base64Encode(newImage.readAsBytesSync()) +'tsnl': img+'tsnl');
  }

  @override
  void initState() {
    super.initState();
    // getName();
    // getEmail();
    // getImg();
    // getNotelp();
    // getGender();
    // getGenderField();
    // getTgl();
    Future.delayed(Duration.zero, () async {
      setState(() {
        // getTname();
        // getTemail();
        // getTnotelp();
      });
    });
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
                            text: "Tambah Pegawai",
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
                      // CustomText.bodyLight12(text: "Foto Profile"),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () async{
                      //         getImage();
                      //       },
                      //       child: Container(
                      //         width: CustomSize.sizeWidth(context) / 6,
                      //         height: CustomSize.sizeWidth(context) / 6,
                      //         decoration: (image==null)?(img == "/".substring(0, 1))?BoxDecoration(
                      //             color: CustomColor.primary,
                      //             shape: BoxShape.circle
                      //         ):BoxDecoration(
                      //           shape: BoxShape.circle,
                      //           image: new DecorationImage(
                      //               image: NetworkImage(Links.subUrl +
                      //                   "$img"),
                      //               fit: BoxFit.cover
                      //           ),
                      //         ): BoxDecoration(
                      //           shape: BoxShape.circle,
                      //           image: new DecorationImage(
                      //               image: new FileImage(image),
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
                      //         ):Container(),
                      //       ),
                      //     ),
                      //     SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                      //     CustomText.bodyLight12(text: "Upload foto profile"),
                      //   ],
                      // ),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Email", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        controller: _loginEmailName,
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
        floatingActionButton: GestureDetector(
          onTap: () async{
            setState(() {
              isLoading = false;
            });
            // SharedPreferences pref = await SharedPreferences.getInstance();
            // pref.setString("name", _loginTextName.text.toString());
            // pref.setString("email", _loginEmailName.text.toString());
            // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
            // pref.setString("gender", gender);
            // pref.setString("tgl", tgl);
            // pref.setString("notelp", _loginNotelpName.text.toString());

            if (_loginEmailName.text != '') {
              addEployees()!.whenComplete((){
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: EmployeesActivity()));
              });
            } else {
              Fluttertoast.showToast(msg: "Isi email terlebih dahulu!",);
            }
          },
          child: Container(
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
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
