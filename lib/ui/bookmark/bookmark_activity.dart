import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/utils/utils.dart';

class BookmarkActivity extends StatefulWidget {
  @override
  _BookmarkActivityState createState() => _BookmarkActivityState();
}

class _BookmarkActivityState extends State<BookmarkActivity> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(
                height: CustomSize.sizeHeight(context) / 32,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: CustomText.textHeading3(
                    text: "Restoran Favoritmu Nih !",
                    minSize: 18,
                    maxLines: 1
                ),
              ),
              GridView.count(
                  crossAxisCount: 2,
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: List.generate(10, (index){
                  return Padding(
                    padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 52),
                    child: Container(
                      width: CustomSize.sizeWidth(context) / 2.3,
                      height: CustomSize.sizeHeight(context) / 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeHeight(context) / 5.8,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                          Padding(
                            padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                            child: CustomText.bodyRegular14(text: "1.8 Km"),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: CustomSize.sizeWidth(context) / 24),
                            child: CustomText.bodyMedium16(text: "Resto Biasa"),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
