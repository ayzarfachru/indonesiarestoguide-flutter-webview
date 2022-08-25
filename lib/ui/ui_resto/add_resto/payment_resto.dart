import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentResto extends StatefulWidget {
  String name, phone, address;

  PaymentResto(this.name, this.phone, this.address);

  @override
  _PaymentRestoState createState() => _PaymentRestoState(name, phone, address);
}

class _PaymentRestoState extends State<PaymentResto> {
  String name, phone, address;

  _PaymentRestoState(this.name, this.phone, this.address);

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
      tipe = (pref.getString("jUsaha")) ?? "";
      homepg = (pref.getString('homepg')??'');
      owner = (pref.getString('owner')??'');
    });

    print(tipe);
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
      'ref': codeProgram.text
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
            content: Text('Apakah yakin ingin meninggalkan halaman aktivasi resto?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                      color: CustomColor.primaryLight,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text('Iya'),
                      onPressed: () async{
                        if (homepg != "1") {
                          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
                        } else if (homepg == "1") {
                          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
                        }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tipE();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (owner != 'true')?onWillPop:onWillPop2,
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
                                      text: name,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.055).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.055)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.055)).toString()),
                                      maxLines: 5
                                  ),
                                  CustomText.textHeading7(
                                      text: phone,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  CustomText.textTitle3(
                                      text: address,
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
                                  content: Text('Apakah yakin ingin meninggalkan halaman aktivasi resto?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
                                            color: CustomColor.primaryLight,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),
                                            child: Text('Iya'),
                                            onPressed: () async{
                                              if (homepg != "1") {
                                                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivity()));
                                              } else if (homepg == "1") {
                                                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: HomeActivityResto()));
                                              }
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
                              Icon(Icons.chevron_left, color: Colors.white, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString())),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 88,
                              ),
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
                      color: CustomColor.secondary,
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
                                    CustomText.textTitle2c(
                                        text: "Pembayaran di luar aplikasi bukan tanggung jawab kami.",
                                        maxLines: 50,
                                        minSize: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                    ),
                                    SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomColor.accent,
                                      ),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: Colors.white.withOpacity(.2),
                                          highlightColor: CustomColor.accent,
                                          onTap: (){
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    title: Text('Kode Referral'),
                                                    content: TextField(
                                                      autofocus: true,
                                                      keyboardType: TextInputType.text,
                                                      controller: codeProgram,
                                                      decoration: InputDecoration(
                                                        hintText: "Masukkan kode referral",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                                          child: FlatButton(
                                                            minWidth: CustomSize.sizeWidth(context),
                                                            color: CustomColor.primaryLight,
                                                            textColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                            child: Text('Cek', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),),),
                                                            onPressed: () async{
                                                              if (checking == true) {
                                                                Fluttertoast.showToast(msg: "Tunggu . . .");
                                                              } else {
                                                                _cekReferral();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: CustomSize.sizeWidth(context),
                                            height: CustomSize.sizeHeight(context) / 16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: CustomText.text(
                                                  text: "Masukkan kode referral",
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
                                    SizedBox(height: CustomSize.sizeHeight(context) / 96,),
                                    Container(
                                      width: CustomSize.sizeWidth(context),
                                      height: CustomSize.sizeHeight(context) / 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomColor.redBtn,
                                      ),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: Colors.white.withOpacity(.2),
                                          highlightColor: CustomColor.accent,
                                          onTap: (){
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                                    ),
                                                    title: Text('Informasi lebih lanjut'),
                                                    content: Text('Silahkan hubungi +6285852270555'),
                                                    actions: <Widget>[
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                                                          child: FlatButton(
                                                            minWidth: CustomSize.sizeWidth(context),
                                                            color: CustomColor.primaryLight,
                                                            textColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                            ),
                                                            child: Text('Hubungi sekarang', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),),),
                                                            onPressed: () async{
                                                              launch("https://wa.me/6285852270555");
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: CustomSize.sizeWidth(context),
                                            height: CustomSize.sizeHeight(context) / 16,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: CustomText.text(
                                                  text: "Saya tidak punya kode referral",
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
                                    // SizedBox(height: CustomSize.sizeHeight(context) / 96,),
                                    // Container(
                                    //   width: CustomSize.sizeWidth(context),
                                    //   height: CustomSize.sizeHeight(context) / 16,
                                    //   decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(10),
                                    //     color: CustomColor.accent,
                                    //   ),
                                    //   child: Material(
                                    //     borderRadius: BorderRadius.circular(10),
                                    //     color: Colors.transparent,
                                    //     child: InkWell(
                                    //       borderRadius: BorderRadius.circular(10),
                                    //       splashColor: Colors.white.withOpacity(.2),
                                    //       highlightColor: CustomColor.accent,
                                    //       onTap: (){
                                    //         setState(() {
                                    //           agree = true;
                                    //         });
                                    //       },
                                    //       child: Container(
                                    //         width: CustomSize.sizeWidth(context),
                                    //         height: CustomSize.sizeHeight(context) / 16,
                                    //         decoration: BoxDecoration(
                                    //           borderRadius: BorderRadius.circular(10),
                                    //         ),
                                    //         child: Center(
                                    //           child: CustomText.text(
                                    //               text: "Tidak punya kode referral",
                                    //               size: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()),
                                    //               weight: FontWeight.w600,
                                    //               color: Colors.white,
                                    //               maxLines: 1
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
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
                                      text: name,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.055).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.055)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.055)).toString()),
                                      maxLines: 5
                                  ),
                                  CustomText.textHeading7(
                                      text: phone,
                                      minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                  ),
                                  CustomText.textTitle3(
                                      text: address,
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
