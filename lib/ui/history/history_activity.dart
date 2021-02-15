import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class HistoryActivity extends StatefulWidget {
  @override
  _HistoryActivityState createState() => _HistoryActivityState();
}

class _HistoryActivityState extends State<HistoryActivity> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: CustomSize.sizeHeight(context) / 32,
                child: Container(
                  color: Colors.white,
                ),
              ),
              Container(
                width: CustomSize.sizeWidth(context),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: CustomText.textHeading3(
                      text: "Riwayat",
                      minSize: 18,
                      maxLines: 1
                  ),
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (_, index){
                    return Padding(
                      padding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 4,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 38),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: CustomSize.sizeWidth(context) / 2.8,
                                height: CustomSize.sizeWidth(context) / 2.8,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              SizedBox(width: CustomSize.sizeWidth(context) / 24,),
                              Container(
                                width: CustomSize.sizeWidth(context) / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText.textHeading4(
                                        text: "Rumah Makan Sederhana",
                                        minSize: 18,
                                        maxLines: 1
                                    ),
                                    CustomText.bodyLight12(
                                        text: "01 Jan 2021, 10:00",
                                        maxLines: 1,
                                        minSize: 12
                                    ),
                                    CustomText.bodyMedium12(
                                        text: "Pesan antar",
                                        maxLines: 1,
                                        minSize: 12
                                    ),
                                    CustomText.bodyLight12(
                                        text: "Selesai",
                                        maxLines: 1,
                                        minSize: 12,
                                      color: CustomColor.accent
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText.textHeading4(
                                            text: "35.000",
                                            minSize: 18,
                                            maxLines: 1
                                        ),
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 4.2,
                                          height: CustomSize.sizeHeight(context) / 24,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: CustomColor.accent)
                                          ),
                                          child: Center(child: CustomText.bodyRegular16(text: "Pesan Lagi", color: CustomColor.accent)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,)
            ],
          ),
        ),
      ),
    );
  }
}
