import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Maintenance extends StatefulWidget {
  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {


  Future maintenance() async {
    var apiResult = await http.get(Uri.parse('https://irg.devus-sby.com/api/index'), headers: {
      "Accept": "Application/json",
    });
    var data = json.decode(apiResult.body);
    print(apiResult.body);

  }


  Future<bool> onWillPop() async{
//     DateTime now = DateTime.now();
//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
//       return Future.value(false);
//     }
// //    SystemNavigator.pop();
//     SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    exit(0);
    // return Future.value(true);
  }


  @override
  void initState() {
    super.initState();
    // checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: MediaQuery(
        child: Scaffold(
          backgroundColor: CustomColor.primaryLight,
          body: Center(
            child: Image.asset(
              "assets/maintenance.png",
              fit: BoxFit.cover,
              height: CustomSize.sizeHeight(context) / 1,
            ),
          ),
        ),
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      ),
    );
  }
}
