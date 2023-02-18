import 'dart:convert';

import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
// import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kam5ia/ui/cart/final_trans_reser.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

  // TextEditingController _textPerson = TextEditingController(text: "0");
  TextEditingController _textPerson = TextEditingController(text: "0");

  DateTime now = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String tgl ='';
  String time ='';
  String total ='0';

  List<bool> menuReady = [];
  String qr_available = "false";
  String nameRestoTrans = '';
  String nameUser = '';

  bool loadTrans = false;

  Future<void> makeReservation()async{
    String t = (time != '')?time:_time.toString().split('(')[1].split(')')[0];

    setState((){
      loadTrans = true;
    });

    if(_textPerson.text != '' && _textPerson.text != '0'){
      SharedPreferences pref = await SharedPreferences.getInstance();
      var token = pref.getString("token") ?? "";
      nameUser = (pref.getString('name')??"");

      var apiResult = await http.post(Uri.parse(Links.mainUrl + '/reservation'),
          body: {
            'people': _textPerson.text,
            'resto': id,
            'time': (tgl != '')?tgl + " " + time.toString().replaceAll(' AM', '').replaceAll(' PM', ''):DateFormat('kk:mm').format(now).toString()+' '+time.toString(),
            // 'price': total
            'price': (10000*int.parse(_textPerson.text.toString())).toString()
          },
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print("TEST");
      print(apiResult.body.toString());
      print(_textPerson.text);
      print(id);
      print(tgl + " " + time.toString().replaceAll(' AM', '').replaceAll(' PM', ''));
      print(total);
      print(apiResult.body);
      var data = json.decode(apiResult.body);

      for(var v in data['device_id']){
        // User p = User.resto(
        //   name: v['device_id'],
        // );
        List<String> id = [];
        id.add(v);
        print('099');
        print(id);
        OneSignal.shared.postNotification(OSCreateNotification(
          playerIds: id,
          heading: "$nameUser telah memesan reservasi di resto Anda",
          content: "Cek sekarang !",
          androidChannelId: "9af3771b-b272-4757-9902-b23ee8da77f2",
          collapseId: "forAdmin_$id",
          androidSound: 'irg_order.wav',
        ));
        // await OneSignal.shared.postNotificationWithJson();
        // user3.add(v['device_id']);
        // _user.add(p);
      }

      if(data['status_code'].toString() == "200"){
        setState((){
          loadTrans = false;
        });
        // Fluttertoast.showToast(
        //   msg: 'Berhasil',);
        // Navigator.pushReplacement(
        //     context,
        //     PageTransition(
        //         type: PageTransitionType.rightToLeft,
        //         child: HomeActivity()));
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("jmlhMeja", _textPerson.text.toString());
        pref.setString("tglReser", tgl);
        pref.setString("jamReser", (time != '')?time.replaceAll(' AM', '').replaceAll(' PM', '').toString():DateFormat('kk:mm').format(now));
        pref.setString("hargaReser", reservationFee);
        // pref.setString("totalReser", total);
        pref.setInt("totalReser", int.parse((10000*int.parse(_textPerson.text.toString())).toString()));
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: FinalTransReser()));
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
      nameRestoTrans = pref.getString("restoNameTrans")??'';
      notelp = pref.getString('notelp')??'';
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
                      // CustomText.bodyLight12(text: "Pesan berapa meja (1 meja untuk 4 orang)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
                      CustomText.bodyLight12(text: "Jumlah meja yang di pesan", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.03).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.03).toString())),
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
                            total = (t + 1000).toString();
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
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
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
                          // height: CustomSize.sizeHeight(context) / 3.8,
                          height: CustomSize.sizeHeight(context) / 4.6,
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
                                // SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     CustomText.bodyLight16(text: "Harga" + " x " +_textPerson.text, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                //     CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(reservationFee.toString()))+" (1)", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                //   ],
                                // ),
                                SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyLight16(text: "Harga per meja (10.000 x "+_textPerson.text.toString()+')', sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(10000*int.parse(_textPerson.text.toString())), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
                                    // CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(10000*int.parse(_textPerson.text.toString())), sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
                                  print('qr_available');
                                  print(qr_available);
                                  if (qr_available == 'true') {
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
                                              Center(
                                                child: CustomText.textHeading2(
                                                    text: "Qris",
                                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                                                    maxLines: 1
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
                                              Center(
                                                child: FullScreenWidget(
                                                  child: Image.asset("assets/imajilogo.png",
                                                    width: CustomSize.sizeWidth(context) / 1.2,
                                                    height: CustomSize.sizeWidth(context) / 1.2,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomText.textTitle2(
                                                          text: 'Total harga:',
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                          maxLines: 1
                                                      ),
                                                      CustomText.textTitle2(
                                                          text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)),
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                          maxLines: 1
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: CustomText.textTitle1(
                                                      text: 'Scan disini untuk melakukan pembayaran',
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                      maxLines: 1
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: CustomSize.sizeWidth(context) / 1.2,
                                                  child: CustomText.textTitle1(
                                                      text: 'ke $nameRestoTrans!',
                                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                      maxLines: 3
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                              GestureDetector(
                                                onTap: ()async{
                                                  Fluttertoast.showToast(
                                                    msg: "Anda belum membayar!",);
                                                },
                                                child: Center(
                                                  child: Container(
                                                    width: CustomSize.sizeWidth(context) / 1.1,
                                                    height: CustomSize.sizeHeight(context) / 14,
                                                    decoration: BoxDecoration(
                                                        color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
                                                        borderRadius: BorderRadius.circular(50)
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                        child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                                              // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
                                            ],
                                          );
                                        }
                                    );
                                  } else {
                                    if (loadTrans == true) {
                                      Fluttertoast.showToast(msg: 'Tunggu data anda sedang diproses');
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
                                              content: Text('Reservasi ini hanya berlaku 15 menit dari jam dan tanggal yang sudah anda tentukan!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                              actions: <Widget>[
                                                Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 25, right: 25),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        // OutlineButton(
                                                        //   // minWidth: CustomSize.sizeWidth(context),
                                                        //   shape: StadiumBorder(),
                                                        //   highlightedBorderColor: CustomColor.secondary,
                                                        //   borderSide: BorderSide(
                                                        //       width: 2,
                                                        //       color: CustomColor.redBtn
                                                        //   ),
                                                        //   child: Text('Batal'),
                                                        //   onPressed: () async{
                                                        //     setState(() {
                                                        //       // codeDialog = valueText;
                                                        //       Navigator.pop(context);
                                                        //     });
                                                        //   },
                                                        // ),
                                                        TextButton(
                                                          // minWidth: CustomSize.sizeWidth(context),
                                                          style: TextButton.styleFrom(
                                                            backgroundColor: CustomColor.accent,
                                                            padding: EdgeInsets.all(0),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                          ),
                                                          child: Text('Oke', style: TextStyle(color: Colors.white)),
                                                          onPressed: () async{
                                                            Navigator.pop(context);
                                                            showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                                    ),
                                                                    title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                                                                    content: Text('Silahkan hubungi penjual melalui fitur chat pada aplikasi kami jika ingin bertanya lebih lanjut kepada pihak resto. \n \n Apakah anda yakin melakukan pemesanan?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                                                    actions: <Widget>[
                                                                      Center(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            TextButton(
                                                                              // minWidth: CustomSize.sizeWidth(context),
                                                                              style: TextButton.styleFrom(
                                                                                backgroundColor: CustomColor.redBtn,
                                                                                padding: EdgeInsets.all(0),
                                                                                shape: const RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                ),
                                                                              ),
                                                                              child: Text('Batal', style: TextStyle(color: Colors.white)),
                                                                              onPressed: () async{
                                                                                setState(() {
                                                                                  // codeDialog = valueText;
                                                                                  Navigator.pop(context);
                                                                                });
                                                                              },
                                                                            ),
                                                                            TextButton(
                                                                              // minWidth: CustomSize.sizeWidth(context),
                                                                              style: TextButton.styleFrom(
                                                                                backgroundColor: CustomColor.accent,
                                                                                padding: EdgeInsets.all(0),
                                                                                shape: const RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                                                ),
                                                                              ),
                                                                              child: Text('Setuju', style: TextStyle(color: Colors.white)),
                                                                              onPressed: () async{
                                                                                Navigator.pop(context);
                                                                                makeReservation();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),

                                                                    ],
                                                                  );
                                                                });
                                                            // String qrcode = '';
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            );
                                          });
                                    }
                                  }
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
                                    // CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(total)), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
                                    CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(10000*int.parse(_textPerson.text.toString())), color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())),
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
