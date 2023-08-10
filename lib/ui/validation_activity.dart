import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ValidationActivity extends StatefulWidget {

  ValidationActivity();

  @override
  _ValidationActivityState createState() => _ValidationActivityState();
}

class _ValidationActivityState extends State<ValidationActivity> {

  _ValidationActivityState();

  var newDate = new DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
  var newDateBea = new DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
  bool isInterest = false;
  bool agree = false;

  String code = '';
  String tipe = '';
  String homepg = '';
  String owner = '';

  tipE() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString("homepg", "3");
      // tipe = (pref.getString("jUsaha")) ?? "";
      // owner = (pref.getString('owner')??'');
    });

    print("homepg 3");
  }

  Future<bool> reqPay() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/payment/checkout'), body: {
      'amount': '550000'
    }, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('checkout '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      if (apiResult.statusCode == 200) {
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        }
      }
      return true;
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      return false;
    }
  }

  Future<bool> reqPay2() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/payment/checkout'), body: {
      'amount': '330000'
    }, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('checkout '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      if (apiResult.statusCode == 200) {
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        }
      }
      return true;
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      return false;
    }
  }

  String status = '';
  // String homepg = '';

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

    status = data['status'];
    // setState(() {});
    if (apiResult.statusCode == 200) {
      if (status == 'done' && homepg != "1") {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
      } else if (status != 'done' && homepg != "1") {
        Fluttertoast.showToast(msg: "Anda belum membayar!");
      } else if (status == 'done' && homepg == "1"){
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      } else if (status != 'done' && homepg == "1"){
        Fluttertoast.showToast(msg: "Anda belum membayar!");
      }
    }
  }

  Future checkTest2() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Uri.parse(Links.mainUrl + '/payment/inquiry'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('inquiry '+apiResult.body.toString());
    print('apiResult.statusCode');
    print(apiResult.statusCode);
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data['code']);

    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      print('apiResult.statusCode');
      print(apiResult.statusCode);
      if (apiResult.statusCode == 200) {
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status != 'done' && homepg != "1") {
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        } else if (status != 'done' && homepg == "1"){
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Simpan qr bila ingin membayar nanti.");
        reqPay2().then((value) {
          if(value){
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                context: context,
                builder: (_){
                  return StatefulBuilder(builder: (_, setStateModal){
                    return Padding(
                      padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText.textHeading4a(
                              text: 'Scan Qr Code',
                              minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                          ),
                          QrImage(
                            data: code,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText.text(
                                    text: "Total Pembayaran",
                                    weight: FontWeight.w400,
                                    size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                ),
                                CustomText.textHeading7(
                                    text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                    color: CustomColor.redBtn,
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 86,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CustomColor.primaryLight,
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                splashColor: Colors.white.withOpacity(.2),
                                highlightColor: CustomColor.primaryLight,
                                onTap: (){
                                  // Navigator.push(
                                  //     context,
                                  //     PageTransition(
                                  //         type: PageTransitionType.fade,
                                  //         child: new HomeActivity()));
                                  checkTest();
                                  // Navigator.pop(context, "success");
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: CustomText.text(
                                        text: "Sudah Membayar",
                                        size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        maxLines: 1
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                }
            );
          }
        });
      }
      // return true;
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      // return false;
    }



  }

  Future checkTest3() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Uri.parse(Links.mainUrl + '/payment/inquiry'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('inquiry '+apiResult.body.toString());
    var data = json.decode(apiResult.body);

    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      if (apiResult.statusCode == 200) {
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status != 'done' && homepg != "1") {
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        } else if (status != 'done' && homepg == "1"){
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Simpan qr bila ingin membayar nanti.");
        reqPay().then((value) {
          if(value){
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                context: context,
                builder: (_){
                  return StatefulBuilder(builder: (_, setStateModal){
                    return Padding(
                      padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText.textHeading4a(
                              text: 'Scan Qr Code',
                              minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                          ),
                          QrImage(
                            data: code,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText.text(
                                    text: "Total Pembayaran",
                                    weight: FontWeight.w400,
                                    size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                ),
                                CustomText.textHeading7(
                                    text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                    color: CustomColor.redBtn,
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 86,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CustomColor.primaryLight,
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                splashColor: Colors.white.withOpacity(.2),
                                highlightColor: CustomColor.primaryLight,
                                onTap: (){
                                  // Navigator.push(
                                  //     context,
                                  //     PageTransition(
                                  //         type: PageTransitionType.fade,
                                  //         child: new HomeActivity()));
                                  checkTest();
                                  // Navigator.pop(context);
                                  // Navigator.pop(context, "success");
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: CustomText.text(
                                        text: "Sudah Membayar",
                                        size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        maxLines: 1
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                }
            );
          }
        });
      }
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      // return false;
    }
  }


  Future<bool> reqPayBea() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/payment/checkout'), body: {
      'amount': priceReferral.toString(),
      // 'amount': '5000',
      'ref': codeProgram.text.toUpperCase().toString()
    }, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('checkout '+apiResult.body.toString());
    var data = json.decode(apiResult.body);


    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      if (apiResult.statusCode == 200) {
        print(data);
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        }
      }
      return true;
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      return false;
    }
  }

  bool loading = false;
  Future Free() async{
    setState((){
      loading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/payment/activate'), body: {
      // 'amount': '200000',
      // 'amount': '5000',
      'ref': codeProgram.text
    }, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('checkout '+apiResult.body.toString());
    var data = json.decode(apiResult.body);


    status = data['status'];
    if (apiResult.statusCode == 200) {
      loading = false;
      print(data);
      if (homepg != "1") {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
      } else if (homepg == "1"){
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      }
    }
    setState(() {});
  }

  Future checkTestBea() async{
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

    status = data['status'];
    // setState(() {});
    if (apiResult.statusCode == 200) {
      if (status == 'done' && homepg != "1") {
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
      } else if (status != 'done' && homepg != "1") {
        Fluttertoast.showToast(msg: "Anda belum membayar!");
      } else if (status == 'done' && homepg == "1"){
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
      } else if (status != 'done' && homepg == "1"){
        Fluttertoast.showToast(msg: "Anda belum membayar!");
      }
    }
  }

  Future programBea() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http
        .post(Uri.parse(Links.mainUrl + '/payment/inquiry'), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('inquiry '+apiResult.body.toString());
    var data = json.decode(apiResult.body);
    print(data);

    if(data['code'] != null){
      setState(() {
        code = data['code'];
      });

      status = data['status'];
      // setState(() {});
      if (apiResult.statusCode == 200) {
        if (status == 'done' && homepg != "1") {
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
        } else if (status != 'done' && homepg != "1") {
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        } else if (status == 'done' && homepg == "1"){
          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
        } else if (status != 'done' && homepg == "1"){
          Fluttertoast.showToast(msg: "Anda belum membayar!");
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
              ),
              context: context,
              builder: (_){
                return StatefulBuilder(builder: (_, setStateModal){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText.textHeading4a(
                            text: 'Scan Qr Code',
                            minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                        ),
                        QrImage(
                          data: code,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText.text(
                                  text: "Total Pembayaran",
                                  weight: FontWeight.w400,
                                  size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                              ),
                              CustomText.textHeading7(
                                  text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                  color: CustomColor.redBtn,
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) / 86,
                        ),
                        Container(
                          width: CustomSize.sizeWidth(context),
                          height: CustomSize.sizeHeight(context) / 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: CustomColor.primaryLight,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.white.withOpacity(.2),
                              highlightColor: CustomColor.primaryLight,
                              onTap: (){
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.fade,
                                //         child: new HomeActivity()));
                                checkTest();
                                // Navigator.pop(context);
                                // Navigator.pop(context, "success");
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: CustomText.text(
                                      text: "Sudah Membayar",
                                      size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                      maxLines: 1
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Simpan qr bila ingin membayar nanti.");
        reqPayBea().then((value) {
          if(value){
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                context: context,
                builder: (_){
                  return StatefulBuilder(builder: (_, setStateModal){
                    return Padding(
                      padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText.textHeading4a(
                              text: 'Scan Qr Code',
                              minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString())
                          ),
                          QrImage(
                            data: code,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText.text(
                                    text: "Total Pembayaran",
                                    weight: FontWeight.w400,
                                    size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                ),
                                CustomText.textHeading7(
                                    text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                    color: CustomColor.redBtn,
                                    minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 86,
                          ),
                          Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: CustomColor.primaryLight,
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                splashColor: Colors.white.withOpacity(.2),
                                highlightColor: CustomColor.primaryLight,
                                onTap: (){
                                  // Navigator.push(
                                  //     context,
                                  //     PageTransition(
                                  //         type: PageTransitionType.fade,
                                  //         child: new HomeActivity()));
                                  checkTest();
                                  // Navigator.pop(context);
                                  // Navigator.pop(context, "success");
                                },
                                child: Container(
                                  width: CustomSize.sizeWidth(context),
                                  height: CustomSize.sizeHeight(context) / 16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: CustomText.text(
                                        text: "Sudah Membayar",
                                        size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        maxLines: 1
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                }
            );
          }
        });
      }
    }else{
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",);

      // return false;
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            title: Center(child: Text('Perhatian!', style: TextStyle(color: CustomColor.redBtn))),
            content: Text('Anda tidak dapat melakukan apapun sebelum menyelesaikan pembayaran!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      // minWidth: CustomSize.sizeWidth(context),
                      style: TextButton.styleFrom(
                        backgroundColor: CustomColor.accent,
                        padding: EdgeInsets.all(0),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                      onPressed: () async{
                        setState(() {
                          // codeDialog = valueText;
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              ),

            ],
          );
        });
    return Future.value(true);
  }

  Future<bool> onWillPop2() async{
    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
    //   return Future.value(false);
    // }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity()));

    return Future.value(true);
  }

  TextEditingController codeProgram = TextEditingController(text: '');

  bool isLoading = false;
  bool checking = false;
  bool kosong = false;
  String priceReferral = '';
  bool available = false;
  Future<void> _cekReferral()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoading = true;
      checking = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Uri.parse('https://erp.devastic.com/api/ref?ref='+codeProgram.text), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    setState(() {
      isLoading = false;
    });

    if (data['message'] == 'available') {
      Navigator.pop(context);
      available = true;
      priceReferral = data['price'].toString();
      print(available);
      Fluttertoast.showToast(msg: "Kode tersedia.");
      setState((){});
    } else {
      Fluttertoast.showToast(msg: "Kode referral tidak tersedia.");
    }

    setState(() {
      checking = false;
    });
  }


  bool isLoadChekPay = false;
  String statusPay = '';
  Future<void> _checkPayBCA()async{
    // List<Menu> _menu = [];

    setState(() {
      isLoadChekPay = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    // var apiResult = await http.get(Uri.parse('https://erp.devastic.com:443/api/bca/inquiry?app_id=IRG&trx_id=$id'),
    // );
    // var data = json.decode(apiResult.body);
    print('QR CODE 2');
    // print(data);
    // print(data['response']['detail_info'].toString().contains('Unpaid').toString());
    // statusPay = data['response']['detail_info'].toString().contains('Unpaid').toString();
    // if (data['response']['detail_info'].toString().contains('Unpaid') == true) {
    if (statusPay == '') {
      Fluttertoast.showToast(
        msg: "Anda belum membayar!",);
    } else {
      statusPay = 'false';
      // if (type == 'delivery') {
      //   _getDetail(idResto).whenComplete((){
      //     _getDetailTrans(id.toString()).whenComplete((){
      //       cariKurir();
      //       pref.setString("statusTrans", 'process');
      //       _getPending('process', id.toString());
      //     });
      //   });
      // } else {
      //   if (statusTrans == 'pending') {
      //     pref.setString("statusTrans", 'process');
      //     _getPending('process', id.toString());
      //   }
      // }
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Pembayaran berhasil",);
    }
    // _base64 = data['response']['qr_image'];
    // Uint8List bytes = Base64Codec().decode(_base64);

    // if (_base64 != '') {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
    //       ),
    //       context: context,
    //       builder: (_){
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
    //               child: Divider(thickness: 4,),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: CustomText.textHeading2(
    //                   text: "Qris",
    //                   minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
    //                   maxLines: 1
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
    //             Center(
    //               child: FullScreenWidget(
    //                 child: Image.memory(bytes,
    //                   width: CustomSize.sizeWidth(context) / 1.2,
    //                   height: CustomSize.sizeWidth(context) / 1.2,
    //                 ),
    //                 backgroundColor: Colors.white,
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     CustomText.textTitle2(
    //                         text: 'Total harga:',
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                     CustomText.textTitle2(
    //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'Scan disini untuk melakukan pembayaran',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 1
    //                 ),
    //               ),
    //             ),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'ke $nameRestoTrans!',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 3
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
    //             GestureDetector(
    //               onTap: ()async{
    //                 Fluttertoast.showToast(
    //                   msg: "Anda belum membayar!",);
    //               },
    //               child: Center(
    //                 child: Container(
    //                   width: CustomSize.sizeWidth(context) / 1.1,
    //                   height: CustomSize.sizeHeight(context) / 14,
    //                   decoration: BoxDecoration(
    //                     // color: (menuReady.contains(false))?CustomColor.textBody:CustomColor.primaryLight,
    //                       borderRadius: BorderRadius.circular(50)
    //                   ),
    //                   child: Center(
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                       child: CustomText.textTitle3(text: "Sudah Membayar", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
    //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //           ],
    //         );
    //       }
    //   );
    // }
    // for(var v in data['menu']){
    //   Menu p = Menu(
    //       id: v['id'],
    //       name: v['name'],
    //       desc: v['desc'],
    //       urlImg: v['img'],
    //       type: v['type'],
    //       is_recommended: v['is_recommended'],
    //       price: Price(original: int.parse(v['price'].toString()), discounted: null, delivery: null),
    //       delivery_price: Price(original: int.parse(v['price']), delivery: null, discounted: null), restoId: '', restoName: '', distance: null, qty: ''
    //   );
    //   _menu.add(p);
    // }
    setState(() {
      isLoadChekPay = false;
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  bool loadQr = false;
  Future<void> _getQrBCA()async{
    // List<Menu> _menu = [];

    setState(() {
      loadQr = true;
    });
    Fluttertoast.showToast(
      msg: "Tunggu sebentar!",);
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    // var apiResult = await http.post(Uri.parse('https://erp.devastic.com/api/bca/generate'),
    //     body: {'app_id': 'IRG', 'trx_id': id.toString(), 'name_resto': nameRestoTrans.toString(), 'amount': (totalAll+1000).toString()},
    //     headers: {
    //       "Accept": "Application/json",
    //       "Authorization": "Bearer $token"
    //     }
    // );
    // var data = json.decode(apiResult.body);
    // print('QR CODE');
    // print(data);
    // print(data['response']['qr_image']);
    // _base64 = data['response']['qr_image'];
    // Uint8List bytes = Base64Codec().decode(_base64);
    //
    // if (_base64 != '') {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
    //       ),
    //       context: context,
    //       builder: (_){
    //         return Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             SizedBox(height: CustomSize.sizeHeight(context) / 86,),
    //             Padding(
    //               padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
    //               child: Divider(thickness: 4,),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //             // Center(
    //             //   child: CustomText.textHeading2(
    //             //       text: "Qris",
    //             //       minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
    //             //       maxLines: 1
    //             //   ),
    //             // ),
    //             // SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
    //             Center(
    //               child: FullScreenWidget(
    //                 child: Image.memory(bytes,
    //                   width: CustomSize.sizeWidth(context) / 1.2,
    //                   height: CustomSize.sizeWidth(context) / 1.2,
    //                 ),
    //                 backgroundColor: Colors.white,
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 88,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     CustomText.textTitle2(
    //                         text: 'Total harga:',
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                     CustomText.textTitle2(
    //                         text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse((totalAll+1000).toString())),
    //                         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
    //                         maxLines: 1
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'Scan disini untuk melakukan pembayaran',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 1
    //                 ),
    //               ),
    //             ),
    //             Center(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: CustomSize.sizeWidth(context) / 1.2,
    //                 child: CustomText.textTitle1(
    //                     text: 'ke $nameRestoTrans!',
    //                     minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
    //                     maxLines: 3
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 48,),
    //             GestureDetector(
    //               onTap: ()async{
    //                 if (isLoadChekPay != true) {
    //                   _checkPayBCA();
    //                 }
    //                 // Fluttertoast.showToast(
    //                 //   msg: "Anda belum membayar!",);
    //               },
    //               child: Center(
    //                 child: Container(
    //                   width: CustomSize.sizeWidth(context) / 1.1,
    //                   height: CustomSize.sizeHeight(context) / 14,
    //                   decoration: BoxDecoration(
    //                       color: CustomColor.primaryLight,
    //                       borderRadius: BorderRadius.circular(50)
    //                   ),
    //                   child: Center(
    //                     child: Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //                       child: CustomText.textTitle3(text: "Cek Pembayaran", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             SizedBox(height: CustomSize.sizeHeight(context) / 54,),
    //             // SizedBox(height: CustomSize.sizeHeight(context) / 106,),
    //           ],
    //         );
    //       }
    //   );
    // }

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
                // Center(
                //   child: CustomText.textHeading2(
                //       text: "Qris",
                //       minSize: double.parse(((MediaQuery.of(context).size.width*0.05).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.05)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.05)).toString()),
                //       maxLines: 1
                //   ),
                // ),
                // SizedBox(height: CustomSize.sizeHeight(context) * 0.003,),
                Center(
                  child: FullScreenWidget(
                    child:
                    Container(
                      color: Colors.grey,
                      width: CustomSize.sizeWidth(context) / 1.2,
                      height: CustomSize.sizeWidth(context) / 1.2,
                    ),
                    // Image.memory(bytes,
                    //   width: CustomSize.sizeWidth(context) / 1.2,
                    //   height: CustomSize.sizeWidth(context) / 1.2,
                    // ),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 88,),
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
                            text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(100000),
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
                        text: 'ke PT. Imaji Cipta',
                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                        maxLines: 3
                    ),
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                GestureDetector(
                  onTap: ()async{
                    if (isLoadChekPay != true) {
                      _checkPayBCA();
                    }
                    // Fluttertoast.showToast(
                    //   msg: "Anda belum membayar!",);
                  },
                  child: Center(
                    child: Container(
                      width: CustomSize.sizeWidth(context) / 1.1,
                      height: CustomSize.sizeHeight(context) / 14,
                      decoration: BoxDecoration(
                          color: CustomColor.primaryLight,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomText.textTitle3(text: "Cek Pembayaran", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
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
    setState(() {
      loadQr = false;
      // emailTokoTrans = data['email'].toString();
      // ownerTokoTrans = data['name_owner'].toString();
      // pjTokoTrans = data['name_pj'].toString();
      // // bankTokoTrans = data['bank'].toString();
      // // nameNorekTokoTrans = data['namaNorek'].toString();
      // nameRekening = data['nama_norek'].toString();
      // nameBank = data['bank_norek'].toString();
      // norekTokoTrans = data['norek'].toString();
      // phone = data['resto']['phone_number'].toString();
      // addressRes = data['resto']['address'].toString();
      // nameRestoTrans = data['resto']['name'];
      // restoAddress = data['resto']['address'];
      // isLoading = false;
    });

    // if (apiResult.statusCode == 200 && menu.toString() == '[]') {
    //   kosong = true;
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    tipE();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: (available != true)?(agree == true)?MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: CustomColor.primaryLight,
                  child: Column(
                    children: [
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            children: [
                              // FaIcon(
                              //   FontAwesomeIcons.arrowLeft,
                              //   color: Colors.white,
                              // ),
                              // SizedBox(
                              //   width: CustomSize.sizeWidth(context) / 18,
                              // ),
                              Icon(Icons.chevron_left, color: Colors.white, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString())),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 88,
                              ),
                              Expanded(
                                child: CustomText.textHeading4(
                                  color: Colors.white,
                                  text: "Aktivasi Resto",
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: CustomColor.secondary,
                      child: (isInterest)?
                      Column(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(CustomSize.sizeHeight(context) / 48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText.textTitle3(
                                      text: "Informasi Resto",
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  CustomText.textHeading5a(
                                      text: 'name',
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.055).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.055)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.055)).toString()),
                                      maxLines: 5
                                  ),
                                  CustomText.textHeading7(
                                      text: 'phone',
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  CustomText.textTitle3(
                                      text: 'address',
                                      maxLines: 10,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 20),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                child: Column(
                                  children: [
                                    CustomText.textHeading8(
                                        text: "Rp $priceReferral / tahun",
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.07)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.07)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    CustomText.textTitle2c(
                                        text: "1. Mempermudah mendapatkan pembeli / konsumen \n2. Mempermudah transaksi \n3. Biaya terjangkau \n4. Produk makin dikenal",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(CustomSize.sizeHeight(context) / 48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  CustomText.textTitle3(
                                      text: "Rincian Pembayaran",
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 32,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.text(
                                        text: "Aktivasi resto 1 tahun",
                                      ),
                                      CustomText.textHeading7(
                                          text: "$priceReferral",
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.text(
                                          text: "Biaya PPN 10%",
                                          weight: FontWeight.w400,
                                          size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      ),
                                      CustomText.textHeading7(
                                          text: "50.000",
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText.text(
                                          text: "Total Pembayaran",
                                          weight: FontWeight.w400,
                                          size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      ),
                                      CustomText.textHeading7(
                                          text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                          color: CustomColor.redBtn,
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 48,
                                  ),
                                  Container(
                                    width: CustomSize.sizeWidth(context),
                                    height: CustomSize.sizeHeight(context) / 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: CustomColor.primaryLight,
                                    ),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(100),
                                        splashColor: Colors.white.withOpacity(.2),
                                        highlightColor: CustomColor.primaryLight,
                                        onTap: (){
                                          if (tipe.toString() != 'Kaki Lima') {
                                            Fluttertoast.showToast(msg: "Mohon tunggu sebentar.");
                                            checkTest3();

                                          } else {
                                            Fluttertoast.showToast(msg: "Mohon tunggu sebentar.");
                                            checkTest2();
                                            // reqPay2().then((value) {
                                            //   if(value){
                                            //     showModalBottomSheet(
                                            //         isScrollControlled: true,
                                            //         shape: RoundedRectangleBorder(
                                            //             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                            //         ),
                                            //         context: context,
                                            //         builder: (_){
                                            //           return StatefulBuilder(builder: (_, setStateModal){
                                            //             return Padding(
                                            //               padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                            //               child: Column(
                                            //                 mainAxisSize: MainAxisSize.min,
                                            //                 children: [
                                            //                   CustomText.textHeading4a(
                                            //                     text: 'Scan Qr Code',
                                            //                   ),
                                            //                   QrImage(
                                            //                     data: code,
                                            //                     version: QrVersions.auto,
                                            //                     size: 200.0,
                                            //                   ),
                                            //                   Padding(
                                            //                     padding: EdgeInsets.symmetric(horizontal: 20),
                                            //                     child: Row(
                                            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //                       children: [
                                            //                         CustomText.text(
                                            //                             text: "Total Pembayaran",
                                            //                             weight: FontWeight.w400,
                                            //                             size: 14
                                            //                         ),
                                            //                         CustomText.textHeading7(
                                            //                             text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                            //                             color: CustomColor.redBtn
                                            //                         ),
                                            //                       ],
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     height: CustomSize.sizeHeight(context) / 86,
                                            //                   ),
                                            //                   Container(
                                            //                     width: CustomSize.sizeWidth(context),
                                            //                     height: CustomSize.sizeHeight(context) / 16,
                                            //                     decoration: BoxDecoration(
                                            //                       borderRadius: BorderRadius.circular(100),
                                            //                       color: CustomColor.primaryLight,
                                            //                     ),
                                            //                     child: Material(
                                            //                       borderRadius: BorderRadius.circular(100),
                                            //                       color: Colors.transparent,
                                            //                       child: InkWell(
                                            //                         borderRadius: BorderRadius.circular(100),
                                            //                         splashColor: Colors.white.withOpacity(.2),
                                            //                         highlightColor: CustomColor.primaryLight,
                                            //                         onTap: (){
                                            //                           // Navigator.push(
                                            //                           //     context,
                                            //                           //     PageTransition(
                                            //                           //         type: PageTransitionType.fade,
                                            //                           //         child: new HomeActivity()));
                                            //                           checkTest();
                                            //                           Navigator.pop(context);
                                            //                           // Navigator.pop(context, "success");
                                            //                         },
                                            //                         child: Container(
                                            //                           width: CustomSize.sizeWidth(context),
                                            //                           height: CustomSize.sizeHeight(context) / 16,
                                            //                           decoration: BoxDecoration(
                                            //                             borderRadius: BorderRadius.circular(100),
                                            //                           ),
                                            //                           child: Center(
                                            //                             child: CustomText.text(
                                            //                                 text: "Sudah Membayar",
                                            //                                 size: 16,
                                            //                                 weight: FontWeight.w600,
                                            //                                 color: Colors.white,
                                            //                                 maxLines: 1
                                            //                             ),
                                            //                           ),
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             );
                                            //           });
                                            //         }
                                            //     );
                                            //   }
                                            // });
                                          }
                                          // showModalBottomSheet(
                                          //     isScrollControlled: true,
                                          //     shape: RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                          //     ),
                                          //     context: context,
                                          //     builder: (_){
                                          //       return StatefulBuilder(builder: (_, setStateModal){
                                          //         return Padding(
                                          //           padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                          //           child: Column(
                                          //             mainAxisSize: MainAxisSize.min,
                                          //             children: [
                                          //               CustomText.textHeading4a(
                                          //                 text: 'Scan Qr Code',
                                          //               ),
                                          //               QrImage(
                                          //                 data: code,
                                          //                 version: QrVersions.auto,
                                          //                 size: 200.0,
                                          //               ),
                                          //               Padding(
                                          //                 padding: EdgeInsets.symmetric(horizontal: 20),
                                          //                 child: Row(
                                          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //                   children: [
                                          //                     CustomText.text(
                                          //                         text: "Total Pembayaran",
                                          //                         weight: FontWeight.w400,
                                          //                         size: 14
                                          //                     ),
                                          //                     CustomText.textHeading7(
                                          //                         text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                          //                         color: CustomColor.redBtn
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //               ),
                                          //               SizedBox(
                                          //                 height: CustomSize.sizeHeight(context) / 86,
                                          //               ),
                                          //               Container(
                                          //                 width: CustomSize.sizeWidth(context),
                                          //                 height: CustomSize.sizeHeight(context) / 16,
                                          //                 decoration: BoxDecoration(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   color: CustomColor.primaryLight,
                                          //                 ),
                                          //                 child: Material(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   color: Colors.transparent,
                                          //                   child: InkWell(
                                          //                     borderRadius: BorderRadius.circular(100),
                                          //                     splashColor: Colors.white.withOpacity(.2),
                                          //                     highlightColor: CustomColor.primaryLight,
                                          //                     onTap: (){
                                          //                         // Navigator.push(
                                          //                         //     context,
                                          //                         //     PageTransition(
                                          //                         //         type: PageTransitionType.fade,
                                          //                         //         child: new HomeActivity()));
                                          //                       // Navigator.pop(context);
                                          //                       // Navigator.pop(context, "success");
                                          //                     },
                                          //                     child: Container(
                                          //                       width: CustomSize.sizeWidth(context),
                                          //                       height: CustomSize.sizeHeight(context) / 16,
                                          //                       decoration: BoxDecoration(
                                          //                         borderRadius: BorderRadius.circular(100),
                                          //                       ),
                                          //                       child: Center(
                                          //                         child: CustomText.text(
                                          //                             text: "Sudah Membayar",
                                          //                             size: 16,
                                          //                             weight: FontWeight.w600,
                                          //                             color: Colors.white,
                                          //                             maxLines: 1
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //             ],
                                          //           ),
                                          //         );
                                          //       });
                                          //     }
                                          // );
                                        },
                                        child: Container(
                                          width: CustomSize.sizeWidth(context),
                                          height: CustomSize.sizeHeight(context) / 16,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.text(
                                                    text: "Bayar Sekarang",
                                                    size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                    weight: FontWeight.w600,
                                                    color: Colors.white,
                                                    maxLines: 1
                                                ),
                                                CustomText.text(
                                                    text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                                    size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                    weight: FontWeight.w600,
                                                    color: Colors.white,
                                                    maxLines: 1
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          :Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                child: Column(
                                  children: [
                                    CustomText.textHeading8(
                                        text: "Rp $priceReferral / tahun",
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.07)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.07)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    CustomText.textTitle2c(
                                        text: "1. Mempermudah mendapatkan pembeli / konsumen \n2. Mempermudah transaksi \n3. Biaya terjangkau \n4. Produk makin dikenal",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 16,),
                                    (priceReferral != '0')?Container(
                                      alignment: Alignment.centerLeft,
                                      child: CustomText.bodyMedium14(
                                          color: CustomColor.redBtn,
                                          text: "Akun anda aktif sampai " + newDate.toString().split(' ')[0],
                                          maxLines: 10,
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      ),
                                    ):Container(),
                                    (priceReferral != '0')?SizedBox(height: CustomSize.sizeHeight(context) / 86,):Container(),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomColor.primaryLight,
                                      ),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: Colors.white.withOpacity(.2),
                                          highlightColor: CustomColor.primaryLight,
                                          onTap: (){
                                            setState(() {
                                              isInterest = true;
                                            });
                                          },
                                          child: Container(
                                            width: CustomSize.sizeWidth(context),
                                            height: CustomSize.sizeHeight(context) / 16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: CustomText.text(
                                                  text: "Aktifkan Sekarang",
                                                  size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                  weight: FontWeight.w600,
                                                  color: Colors.white,
                                                  maxLines: 1
                                              ),
                                            ),
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
                  ),
                )
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ):
      MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: CustomColor.redBtn,
                  child: Column(
                    children: [
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                      GestureDetector(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  title: Center(child: Text('Perhatian!', style: TextStyle(color: CustomColor.redBtn))),
                                  content: Text('Anda tidak dapat melakukan apapun sebelum menyelesaikan pembayaran!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                  actions: <Widget>[
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          TextButton(
                                            // minWidth: CustomSize.sizeWidth(context),
                                            style: TextButton.styleFrom(
                                              backgroundColor: CustomColor.accent,
                                              padding: EdgeInsets.all(0),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                              ),
                                            ),
                                            child: Text('Mengerti', style: TextStyle(color: Colors.white)),
                                            onPressed: () async{
                                              setState(() {
                                                // codeDialog = valueText;
                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            children: [
                              // FaIcon(
                              //   FontAwesomeIcons.arrowLeft,
                              //   color: Colors.white,
                              // ),
                              // SizedBox(
                              //   width: CustomSize.sizeWidth(context) / 18,
                              // ),
                              // Icon(Icons.chevron_left, color: Colors.white, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString())),
                              // SizedBox(
                              //   width: CustomSize.sizeWidth(context) / 88,
                              // ),
                              Expanded(
                                child: CustomText.textHeading4(
                                  color: Colors.white,
                                  text: "Peringatan!",
                                  minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                child: Column(
                                  children: [
                                    CustomText.textTitle8(
                                        text: "Pembayaran validasi dan aktivasi merchant.",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    CustomText.textTitle8(
                                        text: "Pembayaran di luar aplikasi bukan tanggung jawab kami!",
                                        maxLines: 50,
                                        color: CustomColor.redBtn,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                    ),
                                  ],
                                ),
                                // Column(
                                //   children: [
                                //     CustomText.textTitle2c(
                                //         text: "Pembayaran di luar aplikasi bukan tanggung jawab kami.",
                                //         maxLines: 50,
                                //         minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                //     ),
                                //     SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                //     Container(
                                //       width: CustomSize.sizeWidth(context),
                                //       height: CustomSize.sizeHeight(context) / 16,
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(10),
                                //         color: CustomColor.accent,
                                //       ),
                                //       child: Material(
                                //         borderRadius: BorderRadius.circular(10),
                                //         color: Colors.transparent,
                                //         child: InkWell(
                                //           borderRadius: BorderRadius.circular(10),
                                //           splashColor: Colors.white.withOpacity(.2),
                                //           highlightColor: Colors.grey,
                                //           onTap: (){
                                //             showDialog(
                                //                 context: context,
                                //                 builder: (context) {
                                //                   return AlertDialog(
                                //                     shape: RoundedRectangleBorder(
                                //                         borderRadius: BorderRadius.all(Radius.circular(10))
                                //                     ),
                                //                     title: Text('Kode Referral'),
                                //                     content: TextField(
                                //                       autofocus: true,
                                //                       keyboardType: TextInputType.text,
                                //                       controller: codeProgram,
                                //                       decoration: InputDecoration(
                                //                         hintText: "Masukkan kode referral",
                                //                         border: OutlineInputBorder(
                                //                           borderRadius: BorderRadius.circular(10.0),
                                //                         ),
                                //                         enabledBorder: OutlineInputBorder(
                                //                           borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                //                         ),
                                //                         focusedBorder: OutlineInputBorder(
                                //                           borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                //                         ),
                                //                       ),
                                //                     ),
                                //                     actions: <Widget>[
                                //                       Center(
                                //                         child: Padding(
                                //                           padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                //                           child: TextButton(
                                //                             // minWidth: CustomSize.sizeWidth(context),
                                //                             style: TextButton.styleFrom(
                                //                               backgroundColor: CustomColor.primaryLight,
                                //                               padding: EdgeInsets.all(0),
                                //                               shape: const RoundedRectangleBorder(
                                //                                   borderRadius: BorderRadius.all(Radius.circular(10))
                                //                               ),
                                //                             ),
                                //                             child: Text('Cek', style: TextStyle(color: Colors.white, fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),),),
                                //                             onPressed: () async{
                                //                               if (checking == true) {
                                //                                 Fluttertoast.showToast(msg: "Tunggu . . .");
                                //                               } else {
                                //                                 _cekReferral();
                                //                               }
                                //                             },
                                //                           ),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   );
                                //                 });
                                //             setState(() {});
                                //           },
                                //           child: Container(
                                //             width: CustomSize.sizeWidth(context),
                                //             height: CustomSize.sizeHeight(context) / 16,
                                //             decoration: BoxDecoration(
                                //               borderRadius: BorderRadius.circular(10),
                                //             ),
                                //             child: Center(
                                //               child: CustomText.text(
                                //                   text: "Masukkan kode referral",
                                //                   size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                //                   weight: FontWeight.w600,
                                //                   color: Colors.white,
                                //                   maxLines: 1
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     SizedBox(height: CustomSize.sizeHeight(context) / 96,),
                                //     Container(
                                //       width: CustomSize.sizeWidth(context),
                                //       height: CustomSize.sizeHeight(context) / 16,
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(10),
                                //         color: CustomColor.redBtn,
                                //       ),
                                //       child: Material(
                                //         borderRadius: BorderRadius.circular(10),
                                //         color: Colors.transparent,
                                //         child: InkWell(
                                //           borderRadius: BorderRadius.circular(10),
                                //           splashColor: Colors.white.withOpacity(.2),
                                //           highlightColor: Colors.grey,
                                //           onTap: (){
                                //             showDialog(
                                //                 context: context,
                                //                 builder: (context) {
                                //                   return AlertDialog(
                                //                     shape: RoundedRectangleBorder(
                                //                         borderRadius: BorderRadius.all(Radius.circular(10))
                                //                     ),
                                //                     title: Text('Informasi lebih lanjut'),
                                //                     content: Text('Silahkan hubungi +6285852270555'),
                                //                     actions: <Widget>[
                                //                       Center(
                                //                         child: Padding(
                                //                           padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                //                           child: TextButton(
                                //                             // minWidth: CustomSize.sizeWidth(context),
                                //                             style: TextButton.styleFrom(
                                //                               backgroundColor: CustomColor.primaryLight,
                                //                               padding: EdgeInsets.all(10),
                                //                               shape: const RoundedRectangleBorder(
                                //                                   borderRadius: BorderRadius.all(Radius.circular(10))
                                //                               ),
                                //                             ),
                                //                             child: Text('Hubungi sekarang', style: TextStyle(color: Colors.white, fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), ),
                                //                             onPressed: () async{
                                //                               launch("https://wa.me/6285852270555");
                                //                             },
                                //                           ),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   );
                                //                 });
                                //             setState(() {});
                                //           },
                                //           child: Container(
                                //             width: CustomSize.sizeWidth(context),
                                //             height: CustomSize.sizeHeight(context) / 16,
                                //             decoration: BoxDecoration(
                                //               borderRadius: BorderRadius.circular(10),
                                //             ),
                                //             child: Center(
                                //               child: CustomText.text(
                                //                   text: "Saya tidak punya kode referral",
                                //                   size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                //                   weight: FontWeight.w600,
                                //                   color: Colors.white,
                                //                   maxLines: 1
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: GestureDetector(
              onTap: ()async{
                if (loadQr == false) {
                  _getQrBCA();
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: CustomSize.sizeWidth(context) / 1.1,
                height: CustomSize.sizeHeight(context) / 14,
                decoration: BoxDecoration(
                    color: CustomColor.primary,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText.textTitle3(text: "Bayar Sekarang", color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                        CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(100000), color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                      ],
                    ),
                  ),
                ),
              )
            // child: Container(
            //   width: CustomSize.sizeWidth(context) / 1.1,
            //   height: CustomSize.sizeHeight(context) / 14,
            //   decoration: BoxDecoration(
            //       color: CustomColor.primary,
            //       borderRadius: BorderRadius.circular(20)
            //   ),
            //   child: Center(child: MediaQuery(child: CustomText.bodyRegular16(text: "Reservasi Sekarang", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())), data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0))),
            // ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ):
      MediaQuery(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: CustomColor.primaryLight,
                  child: Column(
                    children: [
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: CustomSize.sizeWidth(context) / 24),
                          child: Row(
                            children: [
                              // FaIcon(
                              //   FontAwesomeIcons.arrowLeft,
                              //   color: Colors.white,
                              // ),
                              // SizedBox(
                              //   width: CustomSize.sizeWidth(context) / 18,
                              // ),
                              Icon(Icons.chevron_left, color: Colors.white, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString())),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 88,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    CustomText.textHeading4(
                                      color: Colors.white,
                                      text: "Aktivasi Resto",
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) / 48,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: CustomColor.secondary,
                      child: (isInterest)?
                      Column(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(CustomSize.sizeHeight(context) / 48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText.textTitle3(
                                      text: "Informasi Resto",
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  SizedBox(
                                    height: CustomSize.sizeHeight(context) / 86,
                                  ),
                                  CustomText.textHeading5a(
                                      text: 'name',
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.055).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.055)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.055)).toString()),
                                      maxLines: 5
                                  ),
                                  CustomText.textHeading7(
                                      text: 'phone',
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  CustomText.textTitle3(
                                      text: 'address',
                                      maxLines: 10,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 25),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                child: Column(
                                  children: [
                                    CustomText.textHeading8(
                                      // text: (priceReferral != '0')?"Rp $priceReferral / 1 Tahun":'Percobaan Gratis',
                                        text: (priceReferral != '0')?"Rp $priceReferral / 1 Tahun":'Aktivasi Gratis',
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.07)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.07)).toString())
                                    ),
                                    (priceReferral == '0')?CustomText.textTitle2c(
                                        color: CustomColor.redBtn,
                                        text: "Setiap transaksi dikenakan biaya platform fee sebesar 1000 Rupiah kepada konsumen.",
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                    ):Container(),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    CustomText.textTitle2c(
                                        text: "1. Mempermudah mendapatkan pembeli / konsumen \n2. Mempermudah transaksi \n3. Biaya terjangkau \n4. Produk makin dikenal",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(CustomSize.sizeHeight(context) / 48),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (priceReferral != '0')?Column(
                                    children: [
                                      SizedBox(
                                        height: CustomSize.sizeHeight(context) / 86,
                                      ),
                                      CustomText.textTitle3(
                                          text: "Rincian Pembayaran",
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                      ),
                                      SizedBox(
                                        height: CustomSize.sizeHeight(context) / 32,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText.text(
                                            text: "Aktivasi resto 1 tahun",
                                          ),
                                          CustomText.textHeading7(
                                              text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: CustomSize.sizeHeight(context) / 86,
                                      ),
                                      Divider(),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     CustomText.text(
                                      //         text: "Biaya PPN 10%",
                                      //         weight: FontWeight.w400,
                                      //         size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      //     ),
                                      //     CustomText.textHeading7(
                                      //         text: "50.000",
                                      //         minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(
                                      //   height: CustomSize.sizeHeight(context) / 86,
                                      // ),
                                      // Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText.text(
                                              text: "Total Pembayaran",
                                              weight: FontWeight.w400,
                                              size: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                          ),
                                          CustomText.textHeading7(
                                              text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                              color: CustomColor.redBtn,
                                              minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: CustomSize.sizeHeight(context) / 86,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: CustomSize.sizeHeight(context) / 48,
                                      ),
                                    ],
                                  ):Container(),
                                  Container(
                                    width: CustomSize.sizeWidth(context),
                                    height: CustomSize.sizeHeight(context) / 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: (loading == false)?CustomColor.primaryLight:Colors.grey,
                                    ),
                                    child: Material(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(100),
                                        splashColor: Colors.white.withOpacity(.2),
                                        highlightColor: CustomColor.primaryLight,
                                        onTap: (){
                                          if (priceReferral != '0') {
                                            programBea();
                                          } else {
                                            if (loading == false) {
                                              Free();
                                            } else {
                                              Fluttertoast.showToast(msg: 'Tunggu Sebentar');
                                            }
                                          }
                                          // showModalBottomSheet(
                                          //     isScrollControlled: true,
                                          //     shape: RoundedRectangleBorder(
                                          //         borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                          //     ),
                                          //     context: context,
                                          //     builder: (_){
                                          //       return StatefulBuilder(builder: (_, setStateModal){
                                          //         return Padding(
                                          //           padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                          //           child: Column(
                                          //             mainAxisSize: MainAxisSize.min,
                                          //             children: [
                                          //               CustomText.textHeading4a(
                                          //                 text: 'Scan Qr Code',
                                          //               ),
                                          //               QrImage(
                                          //                 data: code,
                                          //                 version: QrVersions.auto,
                                          //                 size: 200.0,
                                          //               ),
                                          //               Padding(
                                          //                 padding: EdgeInsets.symmetric(horizontal: 20),
                                          //                 child: Row(
                                          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //                   children: [
                                          //                     CustomText.text(
                                          //                         text: "Total Pembayaran",
                                          //                         weight: FontWeight.w400,
                                          //                         size: 14
                                          //                     ),
                                          //                     CustomText.textHeading7(
                                          //                         text: (tipe.toString() != 'Kaki Lima')?"Rp 550.000":"Rp 330.000",
                                          //                         color: CustomColor.redBtn
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //               ),
                                          //               SizedBox(
                                          //                 height: CustomSize.sizeHeight(context) / 86,
                                          //               ),
                                          //               Container(
                                          //                 width: CustomSize.sizeWidth(context),
                                          //                 height: CustomSize.sizeHeight(context) / 16,
                                          //                 decoration: BoxDecoration(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   color: CustomColor.primaryLight,
                                          //                 ),
                                          //                 child: Material(
                                          //                   borderRadius: BorderRadius.circular(100),
                                          //                   color: Colors.transparent,
                                          //                   child: InkWell(
                                          //                     borderRadius: BorderRadius.circular(100),
                                          //                     splashColor: Colors.white.withOpacity(.2),
                                          //                     highlightColor: CustomColor.primaryLight,
                                          //                     onTap: (){
                                          //                         // Navigator.push(
                                          //                         //     context,
                                          //                         //     PageTransition(
                                          //                         //         type: PageTransitionType.fade,
                                          //                         //         child: new HomeActivity()));
                                          //                       // Navigator.pop(context);
                                          //                       // Navigator.pop(context, "success");
                                          //                     },
                                          //                     child: Container(
                                          //                       width: CustomSize.sizeWidth(context),
                                          //                       height: CustomSize.sizeHeight(context) / 16,
                                          //                       decoration: BoxDecoration(
                                          //                         borderRadius: BorderRadius.circular(100),
                                          //                       ),
                                          //                       child: Center(
                                          //                         child: CustomText.text(
                                          //                             text: "Sudah Membayar",
                                          //                             size: 16,
                                          //                             weight: FontWeight.w600,
                                          //                             color: Colors.white,
                                          //                             maxLines: 1
                                          //                         ),
                                          //                       ),
                                          //                     ),
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //             ],
                                          //           ),
                                          //         );
                                          //       });
                                          //     }
                                          // );
                                        },
                                        child: Container(
                                          width: CustomSize.sizeWidth(context),
                                          height: CustomSize.sizeHeight(context) / 16,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 20),
                                            child: (priceReferral != '0')?Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText.text(
                                                    text: "Bayar Sekarang",
                                                    size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                    weight: FontWeight.w600,
                                                    color: Colors.white,
                                                    maxLines: 1
                                                ),
                                                CustomText.text(
                                                    text: 'Rp '+NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(priceReferral.toString())),
                                                    size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                    weight: FontWeight.w600,
                                                    color: Colors.white,
                                                    maxLines: 1
                                                ),
                                              ],
                                            ):Center(
                                              child: CustomText.text(
                                                  text: "Aktifkan Sekarang",
                                                  size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                  weight: FontWeight.w600,
                                                  color: Colors.white,
                                                  maxLines: 1
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          :Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                            child: Container(
                              width: CustomSize.sizeWidth(context),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                                child: Column(
                                  children: [
                                    CustomText.textHeading8(
                                      // text: (priceReferral != '0')?"Rp $priceReferral / 1 Tahun":'Percobaan Gratis',
                                        text: (priceReferral != '0')?"Rp $priceReferral / 1 Tahun":'Aktivasi Gratis',
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.07).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.07)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.07)).toString())
                                    ),
                                    (priceReferral == '0')?CustomText.textTitle2c(
                                        color: CustomColor.redBtn,
                                        // text: "Sampai total pendapatan anda pada aplikasi ini menyentuh angka Rp 12.500.000",
                                        text: "Setiap transaksi dikenakan biaya platform fee sebesar 1000 Rupiah kepada konsumen.",
                                        maxLines: 10,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                    ):Container(),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    CustomText.textTitle2c(
                                        text: "1. Mempermudah mendapatkan pembeli / konsumen \n2. Mempermudah transaksi \n3. Biaya terjangkau \n4. Produk makin dikenal",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 16,),
                                    (priceReferral != '0')?Container(
                                      alignment: Alignment.centerLeft,
                                      child: CustomText.bodyMedium14(
                                          color: CustomColor.primary,
                                          text: "Akun anda aktif sampai " + newDateBea.toString().split(' ')[0],
                                          maxLines: 10,
                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                      ),
                                    ):Container(),
                                    (priceReferral != '0')?SizedBox(height: CustomSize.sizeHeight(context) / 86,):Container(),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomColor.primaryLight,
                                      ),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: Colors.white.withOpacity(.2),
                                          highlightColor: CustomColor.primaryLight,
                                          onTap: (){
                                            setState(() {
                                              isInterest = true;
                                            });
                                          },
                                          child: Container(
                                            width: CustomSize.sizeWidth(context),
                                            height: CustomSize.sizeHeight(context) / 16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: CustomText.text(
                                                  text: "Aktifkan Sekarang",
                                                  size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                                  weight: FontWeight.w600,
                                                  color: Colors.white,
                                                  maxLines: 1
                                              ),
                                            ),
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
                  ),
                )
              ],
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
