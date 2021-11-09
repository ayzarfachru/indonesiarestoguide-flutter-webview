import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';

class AboutActivity extends StatefulWidget {
  @override
  _AboutActivityState createState() => _AboutActivityState();
}

class _AboutActivityState extends State<AboutActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        title: Text("About", style: TextStyle(fontFamily: 'merriweather', fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black,),),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FullScreenWidget(
              child: Image.asset("assets/imajilogo.png",
                width: CustomSize.sizeWidth(context) / 1.4,
                height: CustomSize.sizeWidth(context) / 1.4,
              ),
              backgroundColor: Colors.white,
            ),
            // SizedBox(height: CustomSize.sizeHeight(context) / 86,),
            MediaQuery(
                child: CustomText.bodyLight10(text: "PoweredBy", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.025).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.025).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.025).toString())),
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            ),
            // SizedBox(height: CustomSize.sizeHeight(context) / 86,),
            // FullScreenWidget(
            //   child: Image.asset("assets/devus.png",
            //     width: CustomSize.sizeWidth(context) / 1.4,
            //     height: CustomSize.sizeWidth(context) / 1.4,
            //   ),
            //   backgroundColor: Colors.white,
            // ),
            // SizedBox(height: CustomSize.sizeHeight(context) / 86,),
            // // Image.asset("assets/devus_logo.png", width: CustomSize.sizeWidth(context) / 1.8,),
            // MediaQuery(
            //     child: CustomText.bodyRegular10(text: "Version App 1.1.0", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.025).toString().contains('.')==true)?(MediaQuery.of(context).size.width*0.025).toString().split('.')[0]:(MediaQuery.of(context).size.width*0.025).toString())),
            //   data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            // ),
          ],
        ),
      ),
    );
  }
}
