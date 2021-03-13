import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoActivity extends StatefulWidget {
  @override
  _PromoActivityState createState() => _PromoActivityState();
}

class _PromoActivityState extends State<PromoActivity> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";

  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      homepg = (pref.getString('homepg'));
      print(homepg);
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch

    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getHomePg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: CustomSize.sizeHeight(context) / 32,
                ),
                (homepg != "1")?CustomText.textHeading3(
                  text: "Penawaran Terbaik",
                  color: CustomColor.primary,
                  minSize: 18,
                  maxLines: 1
                ):CustomText.textHeading3(
                    text: "Promo di Restoranmu",
                    color: CustomColor.primary,
                    minSize: 18,
                    maxLines: 1
                ),
                (homepg != "1")?CustomText.textHeading3(
                    text: "di Sekitarmu",
                    color: CustomColor.primary,
                    minSize: 18,
                    maxLines: 1
                ):Container(),
                SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropMaterialHeader(
                    distance: 30,
                    backgroundColor: Colors.white,
                    color: CustomColor.primary,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 6,
                      itemBuilder: (_, index){
                        return Padding(
                          padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                          child: Container(
                            width: CustomSize.sizeWidth(context),
                            height: CustomSize.sizeWidth(context) / 2.6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 7,
                                  offset: Offset(0, 7), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: CustomSize.sizeWidth(context) / 2.6,
                                  height: CustomSize.sizeWidth(context) / 2.6,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                SizedBox(
                                  width: CustomSize.sizeWidth(context) / 32,
                                ),
                                Container(
                                  width: CustomSize.sizeWidth(context) / 2.1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText.bodyLight12(
                                              text: "0.9 km",
                                            maxLines: 1,
                                              minSize: 12
                                          ),
                                          (homepg != "1")?Container():Row(
                                            children: [
                                              Icon(Icons.edit, color: CustomColor.primary,),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 86,),
                                              Icon(Icons.delete, color: CustomColor.primary,),
                                              SizedBox(width: CustomSize.sizeWidth(context) / 98,),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.textHeading4(
                                          text: "Burger Enak",
                                          minSize: 18,
                                          maxLines: 1
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                      CustomText.bodyMedium12(
                                          text: "Resto Biasa",
                                        maxLines: 1,
                                        minSize: 12
                                      ),
                                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                      Row(
                                        children: [
                                          CustomText.bodyRegular12(text: "IDR 15.000", minSize: 12,
                                              decoration: TextDecoration.lineThrough),
                                          SizedBox(width: CustomSize.sizeWidth(context) / 48,),
                                          CustomText.bodyRegular12(text: "IDR 12.000", minSize: 12),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 48,)
              ],
            ),
          ),
        ),
      ),
        floatingActionButton: (homepg != '1')?Container():GestureDetector(
          onTap: (){
            // Navigator.push(
            //     context,
            //     PageTransition(
            //         type: PageTransitionType.rightToLeft,
            //         child: CartActivity()));
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 6.6,
            height: CustomSize.sizeWidth(context) / 6.6,
            decoration: BoxDecoration(
                color: CustomColor.primary,
                shape: BoxShape.circle
            ),
            child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
          ),
        )
    );
  }
}
