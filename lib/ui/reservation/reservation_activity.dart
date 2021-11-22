import 'dart:convert';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/ui/cart/final_trans.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReservationActivity extends StatefulWidget {
  String id;
  String address;
  String reservationFee;

  ReservationActivity(this.id, this.address, this.reservationFee);

  @override
  _ReservationActivityState createState() => _ReservationActivityState(id, address, reservationFee);
}

class _ReservationActivityState extends State<ReservationActivity> {
  String id;
  String address;
  String reservationFee;

  _ReservationActivityState(this.id, this.address, this.reservationFee);

  TextEditingController _textPerson = TextEditingController(text: "0");

  DateTime now = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String tgl ='';
  String time ='';
  String total ='0';

  Future<void> makeReservation()async{
    String t = (time != '')?time:_time.toString().split('(')[1].split(')')[0];

    if(_textPerson.text != '' && _textPerson.text != '0'){
      SharedPreferences pref = await SharedPreferences.getInstance();
      var token = pref.getString("token") ?? "";

      var apiResult = await http.post(Links.mainUrl + '/reservation',
          body: {
            'people': _textPerson.text,
            'resto': id,
            'time': (tgl != '')?tgl + " " + time.toString().replaceAll(' AM', '').replaceAll(' PM', ''):DateFormat('kk:mm').format(now).toString()+' '+time.toString(),
            'price': total
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print(apiResult.body);
      var data = json.decode(apiResult.body);

      if(data['status_code'].toString() == "200"){
        // Fluttertoast.showToast(
        //   msg: 'Berhasil',);
        // Navigator.pushReplacement(
        //     context,
        //     PageTransition(
        //         type: PageTransitionType.rightToLeft,
        //         child: HomeActivity()));
      }
    }else{
      Fluttertoast.showToast(
        msg: 'Wah, datamu kurang lengkap nih ! ',);
    }
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
        tgl = DateFormat('d-MM-y').format(selectedDate);
      });
  }

  String notelp = "";
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      notelp = (pref.getString('notelp') == '')?'null':pref.getString('notelp');
      print(notelp+' telp');
    });
  }

  @override
  void initState() {
    getPref();
    _textPerson.addListener(() {
      print(_textPerson.text);
    });
    super.initState();
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 98,),
                      Row(
                        children: [
                          GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: CustomSize.sizeWidth(context) / 7,
                                  height: CustomSize.sizeWidth(context) / 7,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0,
                                        blurRadius: 7,
                                        offset: Offset(0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Icon(Icons.chevron_left, size: 38,)))
                          ),
                          SizedBox(
                            width: CustomSize.sizeWidth(context) / 48,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context) / 1.5,
                            child: CustomText.textHeading3(
                                text: "Reservation",
                                color: CustomColor.primary,
                                sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                                maxLines: 2
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      CustomText.bodyLight12(text: "Alamat Restoran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      CustomText.textHeading6(
                          text: address,
                          sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString()),
                          maxLines: 10
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    ],
                  ),
                ),
                Divider(thickness: 6, color: CustomColor.secondary,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Pesan berapa meja (1 meja untuk 4 orang)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        controller: _textPerson,
                        keyboardType: TextInputType.numberWithOptions(),
                        cursorColor: Colors.black,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        onChanged: (v){
                          int i = int.parse(v);
                          int t = int.parse(reservationFee) * i;
                          setState(() {
                            // _textPerson = TextEditingController(text: (_textPerson.text != '')?v:"0");
                            total = t.toString();
                          });
                        },
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(

                          ),
                          focusedBorder: UnderlineInputBorder(

                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tanggal Reservation", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      GestureDetector(
                        onTap: (){
                          // DatePicker.showDatePicker(context, showTitleActions: true,
                          //     onConfirm: (date) {
                          //       setState(() {
                          //         tgl = DateFormat('dd-MM-yyyy').format(date);
                          //       });
                          //       print(DateFormat('dd-MM-yyyy').format(date));
                          //     },
                          //     currentTime: DateTime(DateTime.now().year, DateTime.now().month,
                          //         DateTime.now().day),
                          //     locale: LocaleType.id,
                          //     maxTime: DateTime(DateTime.now().year, 12, 31)
                          // );
                          _selectDate(context);
                        },
                        child: CustomText.textHeading4(
                            text: (tgl != '')?tgl:'belum diisi.',
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                            maxLines: 1
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Waktu Reservation", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _time = TimeOfDay.now();
                          });
                          Navigator.of(context).push(
                            showPicker(
                              is24HrFormat: true,
                              context: context,
                              value: _time,
                              minMinute: 0,
                              maxMinute: 59,
                              cancelText: 'batal',
                              okText: 'simpan',
                              minuteInterval: MinuteInterval.ONE,
                              onChange: (t){
                                setState(() {
                                  time = t.hour.toString()+':'+t.minute.toString();
                                  print(time);
                                });
                              },
                              disableHour: false,
                              disableMinute: false,
                            ),
                          );
                        },
                        child: CustomText.textHeading4(
                            text: (time != '')?time:'belum diisi.',
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.045).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.045).toString()),
                            maxLines: 1
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: CustomSize.sizeWidth(context),
                  decoration: BoxDecoration(
                      color: CustomColor.secondary
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 22.5,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                        child: Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 3.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                                CustomText.textTitle3(text: "Rincian Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Harga" + " x " +_textPerson.text, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(reservationFee))+" (1)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                  ],
                                ),
                                // (_transCode == 1)?SizedBox(height: CustomSize.sizeHeight(context) / 100,):SizedBox(),
                                // (_transCode == 1)?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     CustomText.bodyLight16(text: "Ongkir"),
                                //     CustomText.bodyLight16(text: totalOngkir),
                                //   ],
                                // ):SizedBox(),
                                SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                                Divider(thickness: 1,),
                                SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Total Pembayaran", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                      GestureDetector(
                        onTap: (){
                          if (_textPerson.text != '' || _textPerson.text != '0') {
                            if (tgl != '') {
                              if (time != '') {
                                if (notelp.toString() == "null" || notelp.toString() == '') {
                                  Fluttertoast.showToast(
                                    msg: "Isi nomor telepon anda terlebih dahulu!",);
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: new ProfileActivity()));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),
                                          title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                          content: Text('Semua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                          actions: <Widget>[
                                            Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  FlatButton(
                                                    // minWidth: CustomSize.sizeWidth(context),
                                                    color: CustomColor.redBtn,
                                                    textColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Text('Batal'),
                                                    onPressed: () async{
                                                      setState(() {
                                                        // codeDialog = valueText;
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                  ),
                                                  FlatButton(
                                                    color: CustomColor.accent,
                                                    textColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    child: Text('Setuju'),
                                                    onPressed: () async{
                                                      Navigator.pop(context);
                                                      makeReservation();
                                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                                      pref.setString("jmlhMeja", _textPerson.text.toString());
                                                      pref.setString("tglReser", tgl);
                                                      pref.setString("jamReser", (time != '')?time.replaceAll(' AM', '').replaceAll(' PM', '').toString():DateFormat('kk:mm').format(now));
                                                      pref.setString("hargaReser", reservationFee);
                                                      pref.setString("totalReser", total);
                                                      Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              type: PageTransitionType.fade,
                                                              child: FinalTrans()));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        );
                                      });
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Wah, datamu kurang lengkap nih!',);
                              }
                              // print('ini loh telp '+notelp);
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Wah, datamu kurang lengkap nih!',);
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Wah, datamu kurang lengkap nih!',);
                          }

                        },
                        child: Center(
                          child: Container(
                            width: CustomSize.sizeWidth(context) / 1.1,
                            height: CustomSize.sizeHeight(context) / 14,
                            decoration: BoxDecoration(
                                color: (false)?CustomColor.textBody:CustomColor.primary,
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.textTitle3(text: "Reservasi Sekarang", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
