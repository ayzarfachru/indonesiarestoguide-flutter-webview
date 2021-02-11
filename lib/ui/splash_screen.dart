import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 86),
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
              CustomText.textHeading2(text: "Indonesia Resto Guide"),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 48,
              ),
              CustomText.bodyMedium16(
                  text: "Get your favourite food from your",
                maxLines: 1
              ),
              CustomText.bodyMedium16(
                  text: "favourite restaurant the fastest way",
                  maxLines: 1
              ),
            ],
          ),
        ),
      ),
    );
  }
}
