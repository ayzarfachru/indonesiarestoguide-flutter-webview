import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
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
      name = (pref.getString('name'));
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
      email = (pref.getString('email'));
      print(email);
    });
  }

  getTemail() async {
    setState(() {
      _loginEmailName = TextEditingController(text: email);
    });
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
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
      gender = (pref.getString('gender'));
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
      tgl = (pref.getString('tgl'));
      print(tgl);
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

  Future<String> editProfile(String newName, String newEmail, String newTgl, String newGender, String newNotelp, File newImage, String newImg) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var id = pref.getInt("id") ?? "";

    String apiUrl = Links.mainUrl+"/auth/edit/user";
    var postUri = Uri.parse(apiUrl);

    final response = await http.post(
        postUri,
        body: {
          'name': newName,
          'email' : newEmail,
          'ttl': newTgl,
          'gender': newGender,
          'phone': newNotelp,
          'photo': image != null ? 'data:image/$extension;base64,' +
              base64Encode(newImage.readAsBytesSync()) : '',
        },
        headers: {
          "Accept" : "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    final responseJson = jsonDecode(response.body);
    print(newName+'tsnl');
    print(newEmail+'tsnl');
    print(newTgl+'tsnl');
    print(newGender+'tsnl');
    print(newNotelp+'tsnl');
    print(image != null ? 'data:image/$extension;base64,' +
        base64Encode(newImage.readAsBytesSync()) +'tsnl': img+'tsnl');
    print(responseJson);
    return responseJson["message"];
  }

  @override
  void initState() {
    super.initState();
    getName();
    getEmail();
    getImg();
    getNotelp();
    getGender();
    getGenderField();
    getTgl();
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
                    text: "Isi data pegawai",
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
                    CustomText.bodyLight12(text: "Nama Lengkap"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: _loginTextName,
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
                        enabledBorder: UnderlineInputBorder(

                        ),
                        focusedBorder: UnderlineInputBorder(

                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "No Telepon"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      controller: _loginNotelpName,
                      keyboardType: TextInputType.numberWithOptions(),
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        prefixText: "+62 ",
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                        hintStyle: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
                        helperStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14)),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "Email"),
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
                    CustomText.bodyLight12(text: "Jenis Kelamin"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      readOnly: true,
                      controller: _gender,
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
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                  ),
                                  context: context,
                                  builder: (_){
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                          child: Divider(thickness: 4,),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onTap: (){
                                                  pria();
                                                  getGenderField();
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: CustomText.textHeading5(
                                                      text: "Pria",
                                                      minSize: 17,
                                                      maxLines: 1
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  wanita();
                                                  getGenderField();
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: CustomText.textHeading5(
                                                      text: "Wanita",
                                                      minSize: 17,
                                                      maxLines: 1
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: CustomSize.sizeHeight(context) / 72,),
                                      ],
                                    );
                                  }
                              );
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
                    CustomText.bodyLight12(text: "Tanggal Lahir"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    GestureDetector(
                      onTap: (){
                        DatePicker.showDatePicker(context, showTitleActions: true,
                            onConfirm: (date) {
                              setState(() {
                                tgl = date.toString().split(' ')[0];
                              });
                              print(date.toString().split(' ')[0]);
                            },
                            currentTime: DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day),
                            locale: LocaleType.id,
                            maxTime: DateTime(DateTime.now().year, 12, 31)
                        );
                      },
                      child: CustomText.textHeading4(
                          text: tgl,
                          minSize: 18,
                          maxLines: 1
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
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

          editProfile(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString()).then((onValue) {
            if(onValue == "Success"){
              Fluttertoast.showToast(
                  msg: "Success",
                  backgroundColor: Colors.grey,
                  textColor: Colors.black,
                  fontSize: 16.0
              );
              setState(() {
                isLoading = true;
              });
              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivity()));
            } else {
              setState(() {
                isLoading = true;
              });
              Fluttertoast.showToast(
                  msg: "The field is required",
                  backgroundColor: Colors.grey,
                  textColor: Colors.black,
                  fontSize: 16.0
              );
            }
          });
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
