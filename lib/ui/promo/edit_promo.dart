import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class EditPromo extends StatefulWidget {
  Promo promoResto;

  EditPromo(this.promoResto);

  @override
  _EditPromoState createState() => _EditPromoState(promoResto);
}

class _EditPromoState extends State<EditPromo> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  TextEditingController descPromo = TextEditingController(text: "");
  TextEditingController percentPromo = TextEditingController(text: "");
  TextEditingController endPromo = TextEditingController(text: "");
  TextEditingController tipeMenu = TextEditingController(text: "");
  TextEditingController deskMenu = TextEditingController(text: "");
  TextEditingController tOngkir = TextEditingController(text: "");
  TextEditingController tReser4 = TextEditingController(text: "");
  TextEditingController _Jam = TextEditingController(text: "");
  TextEditingController typePromo = TextEditingController(text: "");
  TextEditingController tTable = TextEditingController(text: "");
  TextEditingController _dateController = TextEditingController();

  Promo promoResto;

  _EditPromoState(this.promoResto);

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

  List<String> menuList = [];
  List<String> type = [
    'diskon',
    'potongan',
    'ongkir',
  ];

  List<String> selectedMenuList = [];
  String? tipe;

  _showCuisineDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Tipe Menu"),
            content: CuisineChip(
              type,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedMenuList = selectedList;
                  tipe = selectedMenuList.join(",");
                  print(tipe);
                  if (tipe != "") {
                    selectedList = tipe!.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("tipeMenu", tipe.toString());
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
      initial = (pref.getString('name')!.substring(0, 1).toUpperCase());
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

  TimeOfDay jam = TimeOfDay.now();

  void onTimeOpenChanged(TimeOfDay newTime) {
    setState(() {
      jam = newTime;
    });
  }

  getBuka() async {
    _Jam = (jam.hour != null)?TextEditingController(text: jam.hour.toString() + ':' + jam.minute.toString()):TextEditingController(text: "");
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


  //------------------------------= DATE PICKER =----------------------------------
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      helpText: "Pilih Tanggal",
      cancelText: "Batal",
      confirmText: "Simpan",
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
              backgroundColor: Colors.black,
              primaryColor: CustomColor.secondary, //Head background
              accentColor: CustomColor.secondary //s //Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
        _dateController.text = DateFormat('d-M-y').format(selectedDate);
      });
  }

  String idMenu = '';
  getMenuId() async {
    idMenu = promoResto.menus_id.toString();
  }

  getDescPromo() async {
    descPromo = TextEditingController(text: promoResto.word);
  }

  getTypePromo() async {
    typePromo = TextEditingController(text: (promoResto.discountedPrice != null)?'diskon'
        :(promoResto.potongan != null)?'potongan':'ongkir');
  }

  getDiscPromo() async {
    percentPromo = TextEditingController(text: (promoResto.discountedPrice != null)?promoResto.discountedPrice.toString()
        :(promoResto.potongan != null)?promoResto.potongan.toString():promoResto.ongkir.toString());
  }

  getDatePromo() async {
    _dateController = TextEditingController(text: promoResto.expired_at!.split(' ')[0]);
  }

  getJamPromo() async {
    _Jam = TextEditingController(text: promoResto.expired_at!.split(' ')[1].split(':')[0]+':'+promoResto.expired_at!.split(' ')[1].split(':')[1]);
  }

  Future<void> EditPromo(String id)async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/promo/$id'),
        body: {
          'menu_id': idMenu,
          'desc': descPromo.text,
          'expire': _dateController.text+' '+_Jam.text,
          'type': typePromo.text,
          'amount': percentPromo.text,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(json.encode({
        'menu': idMenu,
        'deskripsi': descPromo.text,
        'expire': _dateController.text+' '+_Jam.text,
        'type': typePromo.text,
        'amount': percentPromo.text,
      }));
      // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
    } else {
      // print(data);
      print(json.encode({
        'menu_id': idMenu,
        'desc': descPromo.text,
        'expire': _dateController.text+' '+_Jam.text,
        'type': typePromo.text,
        'amount': percentPromo.text,
      }));
    }
    setState(() {
      isLoading = false;
    });
  }

  String? id;

  @override
  void initState() {
    super.initState();
    // _dateController.text = DateFormat.yMd().format(DateTime.now().add(const Duration(days: 7)));
    getInitial();
    getMenuId();
    getDescPromo();
    getTypePromo();
    getDiscPromo();
    getDatePromo();
    getJamPromo();
    setState(() {
      id = promoResto.id.toString();
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
                          child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                      ),
                      SizedBox(
                        width: CustomSize.sizeWidth(context) / 88,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: CustomText.textHeading4(
                            text: "Edit promo",
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
                      CustomText.bodyLight12(text: "Deskripsi Promo", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
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
                          hintText: "Isi deskripsi",
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
                      CustomText.bodyLight12(text: (promoResto.discountedPrice != null)?"Diskon Harga":(promoResto.potongan != null)?"Potongan Harga":"Potongan Ongkir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: percentPromo,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          hintText: (promoResto.discountedPrice != null)?"Diskon 10 - 100 %":(promoResto.potongan != null)?"":"",
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
                      CustomText.bodyLight12(text: "Tanggal Berakhir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
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
                          hintText: "Atur tanggal berakhir",
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
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Jam Berakhir", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _Jam,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                            hintText: "Atur jam berakhir",
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                            hintStyle: GoogleFonts.poppins(
                                textStyle:
                                TextStyle(fontSize: 14, color: Colors.grey)),
                            helperStyle: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 14)),
                            enabledBorder: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  jam = TimeOfDay.now().replacing(minute: 30);
                                  print(_Jam);
                                  // print(cuisine.split(",")[0]);
                                });
                                Navigator.of(context).push(
                                    showPicker(
                                      is24HrFormat: true,
                                      blurredBackground: true,
                                      accentColor: Colors.blue[400],
                                      context: context,
                                      value: (jam != null)?jam:TimeOfDay.now(),
                                      onChange: onTimeOpenChanged,
                                      minuteInterval: MinuteInterval.ONE,
                                      disableHour: false,
                                      disableMinute: false,
                                      minMinute: 0,
                                      maxMinute: 59,
                                      cancelText: 'batal',
                                      okText: 'simpan',
                                      // Optional onChange to receive value as DateTime
                                      onChangeDateTime: (DateTime dateTime) {
                                        print(jam.hour.toString() + '.' + jam.minute.toString());
                                        getBuka();
                                      },
                                    ));
                              },
                              // onTap: () async{
                              //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new AddViewResto()));
                              // },
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
                                            text: "Atur",
                                            color: CustomColor.accent,
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
            // print(descPromo);
            // print(percentPromo);
            // print(endPromo);
            // print(tipeMenu);
            // print(deskMenu);
            // print(base64Encode(image.readAsBytesSync()).toString());
            // print(favorite);
            EditPromo(id!);
            Navigator.pop(context);
            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: CustomColor.accent
            ),
            child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
