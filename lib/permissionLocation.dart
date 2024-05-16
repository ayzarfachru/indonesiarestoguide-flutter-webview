import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/webview_activity.dart';
import 'package:permission_handler/permission_handler.dart';

class permissionLocation extends StatefulWidget {
  // String? url;

  // permissionLocation({Key? key, @required this.url})
  //     : super(key: key);

  @override
  State<permissionLocation> createState() => _permissionLocationState();
}

class _permissionLocationState extends State<permissionLocation> {
  // String mainUrl = 'https://m.kam5ia.com';
  // String url = "";

  bool isLocationEnabled = false;

  Future reqHandlePermission() async{
    await Permission.location.request().whenComplete(() async {
      await Permission.location.status.isGranted.then((value) async {
        print(value);
        if (value) {
          final locationPermissionStatus = await Geolocator.checkPermission();
          final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

          setState(() {
            isLocationEnabled =
                locationPermissionStatus == LocationPermission.always &&
                    isLocationServiceEnabled;
          });


          if (!isLocationEnabled) {
            AppSettings.openAppSettings(type: AppSettingsType.location);
            Fluttertoast.showToast(msg: 'Aktifkan lokasi anda untuk menggunakan aplikasi ini');
          } else {
            CustomNavigator.navigatorPushReplacement(
                context,
                new WebViewActivity(
                  codeNotif: "",
                  url: "",
                ));
          }
        } else {
          Fluttertoast.showToast(msg: 'Aktifkan izin berbagi lokasi anda');
          openAppSettings();
        }
      });
    });
  }

  @override
  void initState() {
    // setState(() {
    //   if (widget.url == "") {
    //     url = '$mainUrl';
    //   } else {
    //     url = widget.url ?? '$mainUrl';
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: CustomSize.sizeWidth(context) / 86),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/irgLogo.png",
                width: CustomSize.sizeWidth(context) / 1.4,
                height: CustomSize.sizeWidth(context) / 1.4,
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 24,
              ),
              Container(
                alignment: Alignment.center,
                width: CustomSize.sizeWidth(context) / 1.1,
                child: CustomText.textHeading9(
                    text: "Indonesia Resto Guide",
                    color: Colors.black,
                    sizeNew: double.parse(
                        ((MediaQuery.of(context).size.width * 0.075)
                                    .toString()
                                    .contains('.') ==
                                true)
                            ? (MediaQuery.of(context).size.width * 0.075)
                                .toString()
                                .split('.')[0]
                            : (MediaQuery.of(context).size.width * 0.075)
                                .toString())),
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 48,
              ),
              Container(
                width: CustomSize.sizeWidth(context) / 1.2,
                child: CustomText.permissionText(
                    text: "Aktifkan izin pengambilan lokasi pada perangkat anda untuk mengakses aplikasi ini",
                    color: Colors.black,
                    maxLines: 2,
                    sizeNew: double.parse(((MediaQuery.of(context).size.width *
                                    0.04)
                                .toString()
                                .contains('.') ==
                            true)
                        ? (MediaQuery.of(context).size.width * 0.04)
                            .toString()
                            .split('.')[0]
                        : (MediaQuery.of(context).size.width * 0.04).toString())),
              ),
              // CustomText.bodyMedium16(
              //     text: "Restaurant in Indonesia",
              //     maxLines: 1,
              //     sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.04).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.04).toString())
              // ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 18,
              ),
              GestureDetector(
                onTap: () async {
                  await Permission.location.status.isGranted.then((value) async {
                    print(value);
                    if (!value) {
                      reqHandlePermission();
                    } else {
                      final locationPermissionStatus = await Geolocator.checkPermission();
                      final isLocationServiceEnabled =
                      await Geolocator.isLocationServiceEnabled();

                      setState(() {
                        isLocationEnabled = isLocationServiceEnabled;
                      });

                      print('isLocationEnabled');
                      print(isLocationEnabled);

                      if (!isLocationEnabled) {
                        AppSettings.openAppSettings(type: AppSettingsType.location);
                        Fluttertoast.showToast(msg: 'Aktifkan lokasi anda untuk menggunakan aplikasi ini');
                      } else {
                        CustomNavigator.navigatorPushReplacement(
                            context,
                            new WebViewActivity(
                              codeNotif: "",
                              url: "",
                            ));
                      }
                    }
                  });
                },
                child: Container(
                  height: CustomSize.sizeHeight(context) / 16,
                  width: CustomSize.sizeWidth(context) / 1.4,
                  decoration: BoxDecoration(
                      color: CustomColor.primary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: CustomText.bodyMedium16(
                        text: "Aktifkan",
                        color: Colors.white,
                        maxLines: 1,
                        sizeNew: double.parse(
                            ((MediaQuery.of(context).size.width * 0.04)
                                        .toString()
                                        .contains('.') ==
                                    true)
                                ? (MediaQuery.of(context).size.width * 0.04)
                                    .toString()
                                    .split('.')[0]
                                : (MediaQuery.of(context).size.width * 0.04)
                                    .toString())),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
