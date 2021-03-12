import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/3as_logo.jpg"),
          CustomText.bodyLight10(text: "PoweredBy"),
          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
          Image.asset("assets/devus_logo.png", width: CustomSize.sizeWidth(context) / 1.8,),
          CustomText.bodyRegular10(text: "Version App 1.1.0"),
        ],
      ),
    );
  }
}
