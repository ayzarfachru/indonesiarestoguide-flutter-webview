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
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/ui/promo/pilih_menu.dart';
import 'package:kam5ia/ui/promo/promo_activity.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class AddPromo extends StatefulWidget {
  @override
  _AddPromoState createState() => _AddPromoState();
}

class MenuChip extends StatefulWidget {
  final List<String> menuList;
  final Function(List<String>) onSelectionChanged;

  MenuChip(this.menuList, {required this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<MenuChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

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

class _AddPromoState extends State<AddPromo> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  TextEditingController descPromo = TextEditingController(text: "");
  TextEditingController typePromo = TextEditingController(text: "");
  TextEditingController percentPromo = TextEditingController(text: "");
  TextEditingController endPromo = TextEditingController(text: "");
  TextEditingController tipeMenu = TextEditingController(text: "");
  TextEditingController _Jam = TextEditingController(text: "");
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
    "Nasi Goreng",
    "Mie Pedas DarDerDor",
    "Sang Pisang Kaesang",
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
            content: MenuChip(
              type,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedMenuList = selectedList;
                  tipe = selectedMenuList.single;
                  // print(tipe);
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
                    getTipePromo();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  // getTipeMenu() async {
  //   tipeMenu = TextEditingController(text: nameMenu);
  // }

  getTipePromo() async {
    typePromo = TextEditingController(text: tipe);
  }

  String nameRes = '';
  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name').substring(0, 1).toUpperCase());
      nameRes = (pref.getString('resProm'));
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

  List<String> menu = [];
  List<String> menu2 = [];
  List<String> type = [
    'diskon',
    'potongan',
    // 'ongkir'
  ];
  String menus = '';
  String menus2 = '';
  Future<void> _getMenu()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/menu', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['menu']){
      // Menu p = Menu(
      //     id: v['id'],
      //     name: v['name'],
      // );
      menu.add(v['name']);
    }

    for(var v in data['menu']){
      // Menu p = Menu(
      //     id: v['id'],
      //     name: v['name'],
      // );
      // menu2.add(v['id'].toString());
      menu2.add(v['name'].toString()+'{id:'+v['id'].toString()+'}');
    }
    setState(() {
      menus2 = menu2.toString();
      menus = menu.toString();
      print(menus2);
      print(menus);
      isLoading = false;
    });
  }

  String idMenu = '';
  String nameMenu = '';
  getMenu() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      idMenu = (pref.getString('idMenu'));
      nameMenu = (pref.getString('nameMenu'));
      tipeMenu = TextEditingController(text: nameMenu);
      print(idMenu);
      print(nameMenu);
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

  Future<void> AddPromo()async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/promo',
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

  List<User> user = [];
  String user2 = '';
  List<String> user3 = [];
  Future _getKaryawan()async{
    List<User> _user = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/follower', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data){
      // User p = User.resto(
      //   name: v['device_id'],
      // );
      List<String> id = [];
      id.add(v['device_id']);
      OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: id,
        heading: "Ada promo baru di $nameRes nih...",
        content: "Cek sekarang !",
        androidChannelId: "28c77296-719c-46b3-9331-93a100bac57c",
      ));
      // await OneSignal.shared.postNotificationWithJson();
      user3.add(v['device_id']);
      // _user.add(p);
    }

    setState(() {
      // user = _user;
      // user2 = _user.toList().toString().replaceAll('[', '').replaceAll(']', '');
      print(user3.toSet().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', null', ''));
      // isLoading = false;
    });


    if (apiResult.statusCode == 200) {
      // notif(user3.toSet().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', null', '').replaceAll('{', '').replaceAll('}', ''));
      // print('print u3 '+user3.toString());
    }
  }

  Future _getKaryawan2()async{
    List<User> _user = [];

    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/follower', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data){
      // User p = User.resto(
      //   name: v['device_id'],
      // );
      user3.add(v['device_id']);
      // _user.add(p);
    }

    setState(() {
      user = _user;
      // user3.toSet().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', null', '').replaceAll('{', '').replaceAll('}', '');
      print(user3.toSet().toList().toString().replaceAll(', null', '').replaceAll('{', '').replaceAll('}', ''));

      // isLoading = false;
    });


    // if (apiResult.statusCode == 200) {
    //   notif(user2.toString());
    //   print('print u2 '+user2);
    // }
  }

  Future notif(String device)async{
    print('dev '+device);
    List<String> id = [];
    id.add(device);
    print('iki '+id.toString());
    await OneSignal.shared.postNotification(OSCreateNotification(
      playerIds: id,
      heading: "Ada promo baru di $nameRes nih...",
      content: "Cek sekarang !",
      androidChannelId: "2482eb14-bcdf-4045-b69e-422011d9e6ef",
    ));
  }

  @override
  void initState() {
    super.initState();
    // _dateController.text = DateFormat('d-M-y').format(DateTime.now().add(const Duration(days: 7)));
    getInitial();
    _getMenu();
    getMenu();
    _getKaryawan2().whenComplete((){
      print('print u3 '+tipeMenu.text.toString()+'O');
    });
    typePromo = TextEditingController(text: 'diskon');
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
                    text: "Add promo",
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
                    CustomText.bodyLight12(text: "Menu"),
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
                        hintText: "Pilih menu",
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
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: PilihMenuActivity()));
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
                                          text: "Pilih",
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
                    CustomText.bodyLight12(text: "Tipe Promo"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    TextField(
                      readOnly: true,
                      controller: typePromo,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.black,
                      style: GoogleFonts.poppins(
                          textStyle:
                          TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Pilih tipe",
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
                                          text: "Pilih",
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
                    CustomText.bodyLight12(text: (typePromo.text == 'diskon')?"Diskon Harga (sudah dalam bentuk %)":(typePromo.text == 'potongan')?"Potongan Harga (sudah dalam bentuk Rupiah)":"Potongan Ongkir (sudah dalam bentuk %)"),
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
                        hintText: (typePromo.text == 'diskon')?"Diskon 10 - 100 %":(typePromo.text == 'potongan')?"":"",
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
                    CustomText.bodyLight12(text: "Jam Berakhir"),
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
                                    value: (jam != null)?jam:null,
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
                                          color: CustomColor.accent
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
          if (tipeMenu.text != '' && descPromo.text != '' && percentPromo.text != '' && _dateController.text != '' && _Jam.text != '') {
            AddPromo().whenComplete((){
              _getKaryawan();
              Navigator.pop(context);
              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new PromoActivity()));
            });
          } else {
            Fluttertoast.showToast(msg: 'Lengkapi data promo terlebih dahulu!');
          }
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
