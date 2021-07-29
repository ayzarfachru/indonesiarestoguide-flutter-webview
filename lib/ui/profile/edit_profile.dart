import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _loginTextName = TextEditingController(text: "");
  TextEditingController _loginEmailName = TextEditingController(text: "");
  TextEditingController _loginNotelpName = TextEditingController(text: "");
  TextEditingController newPass = TextEditingController(text: "");
  TextEditingController _newPass = TextEditingController(text: "");

  String name = "";
  String initial = "";
  String email = "";
  String img = "";
  String gender = "pria";
  String tgl = "";
  String notelp = "";
  bool Pass = false;

  bool isLoading = false;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = (pref.getString('name'));
      print(name);
      email = (pref.getString('email'));
      print(email);
      img = (pref.getString('img'));
      print(img);
      notelp = (pref.getString('notelp'));
      print(notelp);
      gender = (pref.getString('gender'));
      print(gender);
      tgl = (pref.getString('tgl'));
      print(tgl);
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
      img = pref.getString('img');
      print(img);
    });
  }

  String img2 = "";
  getImg2() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img2 = (pref.getString('img')).toString();
      // print(img2);
    });
  }


  getNotelp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      notelp = (pref.getString('notelp'));
      print(notelp);
    });
  }

  getTnotelp() async {
    setState(() {
      _loginNotelpName = TextEditingController(text: (notelp != "null")?notelp:"");
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
    setState(() {
      isLoading = true;
    });

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
          'photo': 'data:image/$extension;base64,' +
              base64Encode(newImage.readAsBytesSync()),
        },
        headers: {
          "Accept" : "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("name", _loginTextName.text.toString());
      pref.setString("email", _loginEmailName.text.toString());
      pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
      print('ini lohh'+ img.substring(0,1));
      // debugPrint('ini image baru '+base64Encode(image.readAsBytesSync()).toString(), wrapWidth: 9024);
      // printWrapped(base64Encode(image.readAsBytesSync()).toString());
      pref.setString("gender", gender);
      pref.setString("tgl", tgl);
      pref.setString("notelp", _loginNotelpName.text.toString());
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivity()));
    } else {
      Fluttertoast.showToast(
          msg: "The field is required",
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0
      );
    }
    final responseJson = jsonDecode(response.body);
    print(newName+'tsnl');
    print(newEmail+'tsnl');
    print(newTgl+'tsnl');
    print(newGender+'tsnl');
    print(newNotelp+'tsnl');
    print(image != null ? 'data:image/$extension;base64,' +
        base64Encode(newImage.readAsBytesSync()) +'tsnl': img+'tsnl');
    print(responseJson);
    setState(() {
      isLoading = false;
    });
    return responseJson["message"];
  }

  Future<String> editProfile2(String newName, String newEmail, String newTgl, String newGender, String newNotelp, File newImage, String newImg) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var id = pref.getInt("id") ?? "";
    setState(() {
      isLoading = true;
    });

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
        },
        headers: {
          "Accept" : "Application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("name", _loginTextName.text.toString());
      pref.setString("email", _loginEmailName.text.toString());
      pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
      print('ini lohh'+ img.substring(0,1));
      // debugPrint('ini image baru '+base64Encode(image.readAsBytesSync()).toString(), wrapWidth: 9024);
      // printWrapped(base64Encode(image.readAsBytesSync()).toString());
      pref.setString("gender", gender);
      pref.setString("tgl", tgl);
      pref.setString("notelp", _loginNotelpName.text.toString());
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivity()));
    } else {
      Fluttertoast.showToast(
          msg: "The field is required",
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0
      );
    }
    final responseJson = jsonDecode(response.body);
    print(newName+'tsnl');
    print(newEmail+'tsnl');
    print(newTgl+'tsnl');
    print(newGender+'tsnl');
    print(newNotelp+'tsnl');
    print(image != null ? 'data:image/$extension;base64,' +
        base64Encode(newImage.readAsBytesSync()) +'tsnl': img+'tsnl');
    print(responseJson);
    setState(() {
      isLoading = false;
    });
    return responseJson["message"];
  }


  String id;
  List<User> user = [];
  Future<void> _editPass()async{
    List<User> _user = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/auth/password',
        body: {
          'password': _newPass.text,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(json.encode({
        'password': _newPass.text,
      }));
    } else {
      print(data);
      print("gagal");
      print(json.encode({
        'password': _newPass.text,
      }));
    }
    setState(() {
      user = _user;
    });
  }


  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _obscureText2 = true;

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }


  void printWrapped(String text) {
    final pattern = new RegExp('.{1,9800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPref();
    // getEmail();
    // getImg();
    // (img != '/'.substring(0, 1))?getImg2():print('');
    // getNotelp();
    // getGender();
    // getTgl();
    print('ini lohh'+ img);
    final _byteImage = Base64Decoder().convert(img2.toString());
    Future.delayed(Duration.zero, () async {
      setState(() {
        getTname();
        getTemail();
        getTnotelp();
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
                    text: "Edit Profile",
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
                    CustomText.bodyLight12(text: "Foto Profile"),
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
                            decoration: (image==null)?(img == "" || img == null)?BoxDecoration(
                                color: CustomColor.primary,
                                shape: BoxShape.circle
                            ):BoxDecoration(
                              shape: BoxShape.circle,
                              image: ("$img".substring(0, 8) == '/storage')?DecorationImage(
                                image: NetworkImage(Links.subUrl +
                                    "$img"),
                                fit: BoxFit.cover
                              ):DecorationImage(
                                  image: Image.memory(Base64Decoder().convert(img)).image,
                                  fit: BoxFit.cover
                              ),
                            ): BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                image: new FileImage(image),
                                  fit: BoxFit.cover
                              ),
                            ),
                            child: (img == "" || img == null)?Center(
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
                        CustomText.bodyLight12(text: "Upload foto profile"),
                      ],
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: _loginNotelpName,
                      keyboardType: TextInputType.numberWithOptions(),
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
                    GestureDetector(
                        onTap: (){
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
                        child: CustomText.textHeading4(
                            text: gender.substring(0, 1).toUpperCase()+gender.substring(1),
                            minSize: 18,
                            maxLines: 1
                        )
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
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
                    // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    //------------------------------------ checkbox pass -------------------------------------
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: Pass,
                          onChanged: (bool value) {
                            setState(() {
                              print(value);
                              Pass = value;
                            });
                          },
                        ),
                        // Text('Apakah Restomu melayani reservasi ?', style: TextStyle(fontWeight: FontWeight.bold))
                        Text('Apakah anda ingin mengganti password ?', style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),),
                      ],
                    ),
                    //------------------------------------- new pass ----------------------------------------
                    (Pass)?CustomText.bodyLight12(text: "Masukkan password baru"):Container(),
                    (Pass)?TextField(
                      maxLines: 1,
                      controller: newPass,
                      obscureText: _obscureText,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          highlightColor: Colors.transparent,
                          onPressed: _toggle,
                          icon: Icon(
                              _obscureText
                                  ? MaterialCommunityIcons.eye
                                  : MaterialCommunityIcons.eye_off,
                              color: Colors.black),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        hintStyle: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 14, color: Colors.grey)),
                        helperStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14)),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(),
                      ),
                    ):Container(),
                    (Pass)?SizedBox(height: CustomSize.sizeHeight(context) / 48,):Container(),
                    //------------------------------------- confirm pass ----------------------------------------
                    (Pass)?CustomText.bodyLight12(text: "Konfirmasi password baru"):Container(),
                    (Pass)?TextField(
                      maxLines: 1,
                      controller: _newPass,
                      obscureText: _obscureText2,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          highlightColor: Colors.transparent,
                          onPressed: _toggle2,
                          icon: Icon(
                              _obscureText2
                                  ? MaterialCommunityIcons.eye
                                  : MaterialCommunityIcons.eye_off,
                              color: Colors.black),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        hintStyle: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 14, color: Colors.grey)),
                        helperStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14)),
                        enabledBorder: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(),
                      ),
                    ):Container(),
                    (Pass)?SizedBox(height: CustomSize.sizeHeight(context) / 68,):Container(),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    (isLoading != true)?GestureDetector(
                      onTap: () async{
                        setState(() {
                          isLoading = false;
                        });

                        print(image.toString() + 'Ini Image');
                        if (_loginEmailName.text == '') {
                          Fluttertoast.showToast(msg: 'Email wajib diisi!');
                        } else {
                          if (Pass == false) {
                            if (image != null) {
                              editProfile(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                            } else if (image == null) {
                              editProfile2(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                            }
                          } else if (Pass == true) {
                            if (newPass.text.toString() == _newPass.text.toString()) {
                              if (image != null) {
                                editProfile(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                                _editPass();
                              } else if (image == null) {
                                editProfile2(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                                _editPass();
                              }
                            } else {
                              Future.delayed(Duration(seconds: 1)).then((_) {
                                Fluttertoast.showToast(msg: 'Konfirmasi password gagal!');
                                // setState(() {
                                //   isLoading = true;
                                // });
                              });
                            }
                          }
                        }


                        // if (image != null || image.toString() != '' && Pass == false) {
                        //   editProfile(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                        // } else if (image == null || image.toString() == '' && Pass == false){
                        //   editProfile2(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                        // } else if (image != null || image.toString() != '' && Pass == true) {
                        //   if (newPass.text.toString() == _newPass.text.toString()) {
                        //     print(newPass.text.toString() == _newPass.text.toString());
                        //     editProfile(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                        //     _editPass();
                        //   } else if (newPass.text.toString() != _newPass.text.toString()){
                        //     Fluttertoast.showToast(msg: 'Konfirmasi password gagal!');
                        //   }
                        // } else if (image == null || image.toString() == '' && Pass == true) {
                        //   if (newPass.text.toString() == _newPass.text.toString()) {
                        //     print(newPass.text.toString() == _newPass.text.toString());
                        //     editProfile2(_loginTextName.text.toString(), _loginEmailName.text.toString(), tgl.toString(), gender.toString(), _loginNotelpName.text.toString(), image, img.toString());
                        //     _editPass();
                        //   } else if (newPass.text.toString() != _newPass.text.toString()){
                        //     Fluttertoast.showToast(msg: 'Konfirmasi password gagal!');
                        //   }
                        // }


                      },
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColor.accent
                        ),
                        child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white,)),
                      ),
                    ):Container(
                      width: CustomSize.sizeWidth(context),
                      height: CustomSize.sizeHeight(context) / 14,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomColor.accent
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
