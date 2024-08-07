import 'dart:io';

import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/webview_activity.dart';

class Maintenance extends StatefulWidget {
  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  Future<bool> onWillPop() async {
    exit(0);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatingButtonComponent(context),
    );
  }

  GestureDetector floatingButtonComponent(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        CustomNavigator.navigatorPushReplacement(
            context,
            new WebViewActivity(
              codeNotif: '',
              url: "",
            ));
      },
      child: Container(
        height: CustomSize.sizeHeight(context) / 16,
        width: CustomSize.sizeWidth(context) / 1.4,
        decoration: BoxDecoration(
            color: CustomColor.accent, borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: CustomText.bodyMedium16(
              text: "Coba Lagi!",
              color: Colors.white,
              maxLines: 1,
              sizeNew: double.parse(((MediaQuery.of(context).size.width * 0.04)
                          .toString()
                          .contains('.') ==
                      true)
                  ? (MediaQuery.of(context).size.width * 0.04)
                      .toString()
                      .split('.')[0]
                  : (MediaQuery.of(context).size.width * 0.04).toString())),
        ),
      ),
    );
  }
}
