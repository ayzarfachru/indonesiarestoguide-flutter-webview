import 'dart:convert';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/model/History.dart';
import 'package:kam5ia/model/Schedule.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/schedule_resto/edit_schedule.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kam5ia/ui/detail/detail_history.dart';

class ScheduleActivity extends StatefulWidget {
  String id = '';
  ScheduleActivity(this.id);

  @override
  _ScheduleActivityState createState() => _ScheduleActivityState(id);
}

class DayChip extends StatefulWidget {
  final List<String> dayList;
  final Function(List<String>) onSelectionChanged;

  DayChip(this.dayList, {required this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<DayChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

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
  String id = '';

  _ScheduleActivityState(this.id);

  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();
  TextEditingController _JamOperasionalBuka = TextEditingController(text: "");
  TextEditingController _JamOperasionalTutup = TextEditingController(text: "");
  TextEditingController _openDayController = TextEditingController();
  TextEditingController _closeDayController = TextEditingController();
  String homepg = "";
  String img = "";

  TimeOfDay jamBuka = TimeOfDay.now();
  TimeOfDay jamTutup = TimeOfDay.now();
  String? buka;
  String? tutup;

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

  List<String> selectedDayList = [];
  String? openDay;

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
                    selectedList = openDay!.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("openDay", openDay.toString());
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

  String? closeDay;

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
                    selectedList = closeDay!.split(",");
                  } else {}
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("closeDay", closeDay.toString());
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

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg')??'');
      print(homepg);
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  Future<List<Schedule?>?>? future;
  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new ScheduleActivity(id)));
    });
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
  String? dates;
  String? dates2;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      helpText: "Pilih Tanggal",
      cancelText: "Batal",
      confirmText: "Simpan",
      firstDate: DateTime(2009),
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
    if (picked != null && dates == null) {
      setState(() {
        selectedDate = picked;
        dates = DateFormat('dd-MM-yyyy').format(selectedDate);
        selectedDateList = dates!.split(",");
        print(selectedDateList);
        // selectedDate = picked;
        _openDayController.text = dates!;
      });
    } else if (picked != null && dates != null) {
      setState(() {
        selectedDate = picked;
        dates = DateFormat('dd-MM-yyyy').format(selectedDate);
        selectedDateList.add(dates!);
        dates2 = selectedDateList.join(",");
        print(selectedDateList);
        _openDayController.text = selectedDateList.join(",");
      });
    } else {}
  }



  // String day;
  // Future<void> _getSchedule()async{
  //   List<Schedule> _schedule = [];
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String token = pref.getString("token") ?? "";
  //   var apiResult = await http.get(Links.mainUrl + '/resto/day', headers: {
  //     "Accept": "Application/json",
  //     "Authorization": "Bearer $token"
  //   });
  //   print(apiResult.body);
  //   var data = json.decode(apiResult.body);
  //
  //   setState(() {
  //     day = data['menu']['day'];
  //     print(day);
  //     print(data);
  //     isLoading = false;
  //   });
  // }

  getOpenAndClose() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      openAndClose = pref.getString('openclose')??'';
      print(openAndClose);
      // isOpen = pref.getString('isOpen');
    });
  }

  String openAndClose = "0";
  List<Schedule> _schedule = [];
  List<Schedule> schedule = [];
  Future<void> _getSchedule() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Uri.parse(Links.mainUrl +'/resto/day'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print(jsonData);

    for(var v in jsonData['menu']){
      Schedule a = Schedule(
        id: v['id'],
        day: v['day'],
        open_at: v['open_at'],
        closed_at: v['closed_at'],
      );
      _schedule.add(a);
    }
    setState(() {
      schedule = _schedule;
      isLoading = false;
    });
  }

  Future<void> _closeNow()async{
    List<Schedule> _schedule = [];
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/close'),
        body: {},
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      schedule = _schedule;
      isLoading = false;
    });
  }

  String isOpen = "";
  String status = "";
  Future _getDetail()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse(Links.mainUrl + '/resto/detail/$id'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    var data = json.decode(apiResult.body);
    print('PIII'+data['data']['status'].toString()+','+data['data']['isOpen'].toString());

    setState(() {
      isOpen = data['data']['isOpen'].toString();
      status = data['data']['status'].toString();
    });
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   // Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
    SharedPreferences pref = await SharedPreferences.getInstance();
    // pref.setString("homepg", "");
    // pref.setString("idresto", "");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivityResto()));
    return Future.value(true);
  }

  String statusPay = 'ongoing';
  Future checkTest() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Uri.parse(Links.mainUrl + '/payment/inquiry'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('inquiry '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    // if(data['code'] != null){
    //   setState(() {
    //     code = data['code'];
    //   });
    //
    //   return true;
    // }else{
    //   Fluttertoast.showToast(
    //     msg: "Mohon maaf masih dalam perbaikan",);
    //
    //   return false;
    // }

    statusPay = data['status'];
    isOpen = (statusPay == 'done')?isOpen:'false';
    setState(() {});
    if (apiResult.statusCode == 200) {
      if (statusPay == 'ongoing') {
        // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
      }
    }
  }

  @override
  void initState() {
    getOpenAndClose();
    _getSchedule();
    getHomePg();
    getTutup();
    getBuka();
    getHariBuka();
    print(selectedDateList);
    _getDetail().whenComplete(() {
      checkTest();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: MediaQuery(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: (isLoading)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primaryLight,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 32,
                      ),
                      Row(
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
                                text: "Jadwal Operasional",
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                maxLines: 1
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: schedule.length,
                          itemBuilder: (_, index){
                            return Padding(
                              padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeWidth(context) / 5.4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: CustomSize.sizeWidth(context) / 32,
                                    ),
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 1.2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText.textHeading4(
                                                      text: schedule[index].day,
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                                                      maxLines: 1
                                                  ),
                                                  SizedBox(
                                                    width: CustomSize.sizeWidth(context) / 32,
                                                  ),
                                                  (schedule[index].open_at == "00:00:00" && schedule[index].closed_at == "00:00:00")?
                                                  CustomText.bodyMedium12(
                                                      text: "Hari ini tutup",
                                                      color: CustomColor.redBtn,
                                                      maxLines: 1,
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                                  )
                                                  :CustomText.bodyMedium12(
                                                      text: schedule[index].open_at.split(':')[0]+':'+schedule[index].open_at.split(':')[1]
                                                          +' - '+schedule[index].closed_at.split(':')[0]+':'+schedule[index].closed_at.split(':')[1],
                                                      maxLines: 1,
                                                      sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type: PageTransitionType.rightToLeft,
                                                            child: EditSchedule(schedule[index], id)));
                                                  },
                                                  child: Icon(Icons.edit, color: Colors.grey, size: 20,)
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: CustomSize.sizeWidth(context) / 32,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 9,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: (isOpen == '')?Container():Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async{
                  // if(openAndClose == '0'){
                  //   SharedPreferences pref = await SharedPreferences.getInstance();
                  //   pref.setString("openclose", "1");
                  // }else if(openAndClose == '1'){
                  //   SharedPreferences pref = await SharedPreferences.getInstance();
                  //   pref.setString("openclose", '0');
                  // }
                  setState(() {
                    isLoading = false;
                  });

                  if (status == 'active') {
                    if (isOpen == 'true') {
                      _closeNow();
                    } else {
                      Fluttertoast.showToast(msg: "Tokomu saat ini sudah tutup",);
                    }
                  } else {
                    _closeNow();
                  }
                  // if (isOpen != 'false') {
                  //   _closeNow();
                  // } else {
                  //   Fluttertoast.showToast(msg: "Tokomu saat ini sudah tutup",);
                  // }

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
                      color: (status == 'active')?(isOpen == 'true')?CustomColor.redBtn:CustomColor.redBtn:CustomColor.accent
                  ),
                  child: Center(child: CustomText.bodyRegular16(text: (status == 'active')?(isOpen == 'true')?"Tutup Sekarang!":"Tutup Sekarang!":"Buka Sekarang!", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()))),
                ),
              ),
              // SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
            ],
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
