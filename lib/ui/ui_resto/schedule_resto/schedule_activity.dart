import 'dart:convert';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/model/History.dart';
import 'package:indonesiarestoguide/ui/ui_resto/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:indonesiarestoguide/ui/detail/detail_history.dart';

class ScheduleActivity extends StatefulWidget {
  @override
  _ScheduleActivityState createState() => _ScheduleActivityState();
}

class DayChip extends StatefulWidget {
  final List<String> dayList;
  final Function(List<String>) onSelectionChanged;

  DayChip(this.dayList, {this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<DayChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.dayList.forEach((item) {
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
                selectedChoices.remove(item);
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

class _ScheduleActivityState extends State<ScheduleActivity> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _JamOperasionalBuka = TextEditingController(text: "");
  TextEditingController _JamOperasionalTutup = TextEditingController(text: "");
  TextEditingController _openDayController = TextEditingController();
  TextEditingController _closeDayController = TextEditingController();
  String homepg = "";
  String img = "";

  TimeOfDay jamBuka = TimeOfDay();
  TimeOfDay jamTutup = TimeOfDay();
  String buka;
  String tutup;

  bool isLoading = false;

  List<String> dayList = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  List<String> selectedDayList = List();
  String openDay;

  _showOpenDayDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Hari Buka"),
            content: DayChip(
              dayList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedDayList = selectedList;
                  openDay = selectedDayList.join(",");
                  if (openDay != "") {
                    selectedList = openDay.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("openDay", openDay);
                  setState(() {
                    print(openDay);
                    getHariBuka();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  getHariBuka() async {
    _openDayController = TextEditingController(text: openDay);
  }

  String closeDay;

  _showCloseDayDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Hari Tutup"),
            content: DayChip(
              dayList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedDayList = selectedList;
                  closeDay = selectedDayList.join(",");
                  if (closeDay != "") {
                    selectedList = closeDay.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("closeDay", closeDay);
                  setState(() {
                    print(closeDay);
                    getHariTutup();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  getHariTutup() async {
    _closeDayController = TextEditingController(text: closeDay);
  }

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
      print(img);
    });
  }

  List<History> history = [];
  Future _getHistory()async{
    List<History> _history = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/page/history', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['trans']){
      History h = History(
          id: v['id'],
          name: v['resto_name'],
          time: v['time'],
          price: v['price'],
          img: v['resto_img'],
          type: v['type']
      );
      _history.add(h);
    }

    setState(() {
      history = _history;
      isLoading = false;
    });
  }

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    _getHistory();
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  void onTimeOpenChanged(TimeOfDay newTime) {
    setState(() {
      jamBuka = newTime;
    });
  }

  void onTimeClosedChanged(TimeOfDay newTime) {
    setState(() {
      jamTutup = newTime;
    });
  }

  getBuka() async {
    _JamOperasionalBuka = (jamBuka.hour != null)?TextEditingController(text: jamBuka.hour.toString() + ':' + jamBuka.minute.toString()):TextEditingController(text: "");
  }

  getTutup() async {
    _JamOperasionalTutup = (jamTutup.hour != null)?TextEditingController(text: jamTutup.hour.toString() + ':' + jamTutup.minute.toString()):TextEditingController(text: "");
  }

  //------------------------------= DATE PICKER =----------------------------------
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  List<String> selectedDateList = [];
  String dates;
  String dates2;

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
    if (picked != null && dates == null) {
      setState(() {
        selectedDate = picked;
        dates = DateFormat('dd-MM-yyyy').format(selectedDate);
        selectedDateList = dates.split(",");
        print(selectedDateList);
        // selectedDate = picked;
        _openDayController.text = dates;
      });
    } else if (picked != null && dates != null) {
      setState(() {
        selectedDate = picked;
        dates = DateFormat('dd-MM-yyyy').format(selectedDate);
        selectedDateList.add(dates);
        dates2 = selectedDateList.join(",");
        print(selectedDateList);
        _openDayController.text = selectedDateList.join(",");
      });
    } else {}
  }

  @override
  void initState() {
    _getHistory();
    getHomePg();
    getImg();
    getTutup();
    getBuka();
    print(selectedDateList);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (isLoading)?Container(
            width: CustomSize.sizeWidth(context),
            height: CustomSize.sizeHeight(context),
            child: Center(child: CircularProgressIndicator())):SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            distance: 30,
            backgroundColor: Colors.white,
            color: CustomColor.primary,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: CustomText.textHeading3(
                      text: "Jadwal Operasional",
                      color: CustomColor.primary,
                      minSize: 18,
                      maxLines: 1
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Jam Buka"),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _JamOperasionalBuka,
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
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                jamBuka = TimeOfDay.now().replacing(minute: 30);
                                print(_JamOperasionalTutup);
                                // print(cuisine.split(",")[0]);
                              });
                              Navigator.of(context).push(
                                  showPicker(
                                    blurredBackground: true,
                                    accentColor: Colors.blue[400],
                                    context: context,
                                    value: (jamBuka != null)?jamBuka:null,
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
                                      print(jamBuka.hour.toString() + ':' + jamBuka.minute.toString());
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
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Jam Tutup"),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _JamOperasionalTutup,
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
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                buka = jamBuka.hour.toString() + ':' + jamBuka.minute.toString();
                                jamTutup = TimeOfDay.now().replacing(minute: 30);
                                print(_JamOperasionalTutup.toString() + 'ini');
                                // print(cuisine.split(",")[0]);
                              });
                              Navigator.of(context).push(
                                  showPicker(
                                    blurredBackground: true,
                                    accentColor: Colors.blue[400],
                                    context: context,
                                    value: jamTutup,
                                    onChange: onTimeClosedChanged,
                                    minuteInterval: MinuteInterval.ONE,
                                    disableHour: false,
                                    disableMinute: false,
                                    minMinute: 0,
                                    maxMinute: 59,
                                    cancelText: 'batal',
                                    okText: 'simpan',
                                    // Optional onChange to receive value as DateTime
                                    onChangeDateTime: (DateTime dateTime) {
                                      print(jamBuka.hour.toString() + ':' + jamBuka.minute.toString());
                                      print(jamTutup.hour.toString() + ':' + jamTutup.minute.toString()+'ini tutup');
                                      print(buka + 'ini buka');
                                      tutup = jamTutup.hour.toString() + ':' + jamTutup.minute.toString();
                                      getTutup();
                                    },
                                  ));
                            },
                            // onTap: () async{
                            //   Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new AddViewResto()));
                            // },
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
                                          text: "Atur",
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
                      CustomText.bodyLight12(text: "Hari Buka"),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _openDayController,
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
                          suffixIcon: GestureDetector(
                            onTap: () async{
                              _showOpenDayDialog();
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
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Hari Tutup"),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: _closeDayController,
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
                          suffixIcon: GestureDetector(
                            onTap: () async{
                              _showCloseDayDialog();
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
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 8,),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async{
              setState(() {
                isLoading = false;
              });
              // addResto();
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: HomeActivityResto()));
              // SharedPreferences pref = await SharedPreferences.getInstance();
              // pref.setString("name", _loginTextName.text.toString());
              // pref.setString("email", _loginEmailName.text.toString());
              // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
              // pref.setString("gender", gender);
              // pref.setString("tgl", tgl);
              // pref.setString("notelp", _loginNotelpName.text.toString());
            },
            child: Container(
              width: CustomSize.sizeWidth(context) / 1.1,
              height: CustomSize.sizeHeight(context) / 14,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: CustomColor.redBtn
              ),
              child: Center(child: CustomText.bodyRegular16(text: "Tutup Sekarang!", color: Colors.white,)),
            ),
          ),
          SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
          GestureDetector(
            onTap: () async{
              setState(() {
                isLoading = false;
              });
              // addResto();
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: HomeActivityResto()));
              // SharedPreferences pref = await SharedPreferences.getInstance();
              // pref.setString("name", _loginTextName.text.toString());
              // pref.setString("email", _loginEmailName.text.toString());
              // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
              // pref.setString("gender", gender);
              // pref.setString("tgl", tgl);
              // pref.setString("notelp", _loginNotelpName.text.toString());
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
        ],
      ),
    );
  }
}
