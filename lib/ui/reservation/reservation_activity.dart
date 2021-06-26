import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
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
            'time': (tgl != '')?tgl:now.toString().split(' ')[0] + " " + t,
            'price': total
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print(apiResult.body);
      var data = json.decode(apiResult.body);

      if(data['status_code'].toString() == "200"){
        Fluttertoast.showToast(
          msg: 'Berhasil',);
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: HomeActivity()));
      }
    }else{
      Fluttertoast.showToast(
        msg: 'Wah, datamu kurang lengkap nih ! ',);
    }
  }

  @override
  void initState() {
    _textPerson.addListener(() {
      print(_textPerson.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                    CustomText.bodyLight12(text: "Alamat Restoran"),
                    SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                    CustomText.textHeading6(
                        text: address,
                        minSize: 16,
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
                    CustomText.bodyLight12(text: "Pesan berapa meja (1 meja untuk 4 orang)"),
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
                          _textPerson = TextEditingController(text: (_textPerson.text != '')?v:"0");
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
                    CustomText.bodyLight12(text: "Tanggal Reservation"),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) * 0.005,
                    ),
                    GestureDetector(
                      onTap: (){
                        DatePicker.showDatePicker(context, showTitleActions: true,
                            onConfirm: (date) {
                              setState(() {
                                tgl = DateFormat('dd-MM-yyyy').format(date);
                              });
                              print(DateFormat('dd-MM-yyyy').format(date));
                            },
                            currentTime: DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day),
                            locale: LocaleType.id,
                            maxTime: DateTime(DateTime.now().year, 12, 31)
                        );
                      },
                      child: CustomText.textHeading4(
                          text: (tgl != '')?tgl:DateFormat('dd-MM-yyyy').format(now),
                          minSize: 18,
                          maxLines: 1
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                    CustomText.bodyLight12(text: "Waktu Reservation"),
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
                            context: context,
                            value: _time,
                            onChange: (t){
                              setState(() {
                                time = t.format(context);
                              });
                            },
                            disableHour: false,
                            disableMinute: false,
                          ),
                        );
                      },
                      child: CustomText.textHeading4(
                          text: (time != '')?time:DateFormat('kk:mm').format(now),
                          minSize: 18,
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
                              CustomText.textTitle3(text: "Rincian Pembayaran"),
                              SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Harga" + " x " +_textPerson.text),
                                  CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(reservationFee))),
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
                                  CustomText.textTitle3(text: "Total Pembayaran"),
                                  CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total))),
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
                        makeReservation();
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
                                  CustomText.textTitle3(text: "Reservasi Sekarang", color: Colors.white),
                                  CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)), color: Colors.white),
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
    );
  }
}
