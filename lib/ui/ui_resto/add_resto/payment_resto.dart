import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/ui/auth/login_activity.dart';
import 'package:indonesiarestoguide/ui/home/home_activity.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';

class PaymentResto extends StatefulWidget {
  @override
  _PaymentRestoState createState() => _PaymentRestoState();
}

class _PaymentRestoState extends State<PaymentResto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: CustomColor.secondary,
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
              Container(
                alignment: Alignment.center,
                width: CustomSize.sizeWidth(context) / 1.1,
                child: CustomText.textHeading2(text: "Indonesia Resto Guide"),
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 48,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 12),
                child: Container(
                  width: CustomSize.sizeWidth(context),
                  decoration: BoxDecoration(
                    color: CustomColor.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.textHeading7(
                            text: "Metode Pembayaran",
                            maxLines: 1
                        ),
                        SizedBox(
                          height: CustomSize.sizeHeight(context) * 0.005,
                        ),
                        CustomText.bodyMedium16(
                            text: "Silahkan hubungi 0838********* untuk lebih lanjut.",
                            maxLines: 4,

                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: CustomSize.sizeHeight(context) / 26,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: HomeActivity()));
                },
                child: Container(
                  height: CustomSize.sizeHeight(context) / 15,
                  width: CustomSize.sizeWidth(context) / 1.8,
                  decoration: BoxDecoration(
                      color: CustomColor.primary,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Center(
                    child: CustomText.bodyMedium16(
                        text: "Selesai",
                        color: Colors.white,
                        maxLines: 1
                    ),
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
