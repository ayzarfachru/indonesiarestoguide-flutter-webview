import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kam5ia/model/History.dart';
import 'package:kam5ia/model/User.dart';
import 'package:kam5ia/ui/ui_resto/employees/add_employees.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:kam5ia/ui/detail/detail_history.dart';

class FollowersActivity extends StatefulWidget {
  @override
  _FollowersActivityState createState() => _FollowersActivityState();
}

class _FollowersActivityState extends State<FollowersActivity> {
  ScrollController _scrollController = ScrollController();
  String homepg = "";
  String img = "";

  bool isLoading = false;

  getImg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      img = (pref.getString('img'));
      print(img);
    });
  }

  List<User> user = [];
  Future _getKaryawan()async{
    List<User> _user = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/follower', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data){
      User p = User.resto(
        id: v['id'],
        name: v['name'],
        email: v['email'],
        notelp: v['phone_number'],
        img: v['img'],
      );
      _user.add(p);
    }

    setState(() {
      user = _user;
      print(user);
      isLoading = false;
    });
  }

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
    _getKaryawan();
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

  Future _delKaryawan(String id)async{
    List<User> _user = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/karyawan/delete/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['msg'].toString() == 'success') {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: FollowersActivity()));
    }

    setState(() {
      isLoading = false;
    });
  }

  showAlertDialog(String id) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Batal", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Hapus", style: TextStyle(color: CustomColor.primary)),
      onPressed:  () {
        _delKaryawan(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Pegawai"),
      content: Text("Apakah anda yakin ingin menghapus data ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    _getKaryawan();
    getHomePg();
    getImg();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: (isLoading)?Container(
                width: CustomSize.sizeWidth(context),
                height: CustomSize.sizeHeight(context),
                child: Center(child: CircularProgressIndicator(
                  color: CustomColor.primaryLight,
                ))):SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                distance: 30,
                backgroundColor: Colors.white,
                color: CustomColor.primaryLight,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
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
                        child: (homepg != "1")?CustomText.textHeading3(
                            text: "Riwayat",
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.06).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.06)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.06)).toString()),
                            maxLines: 1
                        ):Row(
                          children: [
                            GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()), color: Colors.black,)
                            ),
                            SizedBox(
                              width: CustomSize.sizeWidth(context) / 88,
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: CustomText.textHeading4(
                                  text: "Data Followers",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                  maxLines: 1
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                    ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: user.length,
                        itemBuilder: (_, index){
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                            child: GestureDetector(
                              // onTap: (){
                              //   Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new DetailHistory(history[index].id)));
                              // },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeHeight(context) / 7.5,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 6,
                                          height: CustomSize.sizeWidth(context) / 6,
                                          decoration: (user[index].img == "/".substring(0, 1))?BoxDecoration(
                                              color: CustomColor.primaryLight,
                                              shape: BoxShape.circle
                                          ):BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                image: (user[index].img != null)?NetworkImage(Links.subUrl +
                                                    user[index].img!):AssetImage('assets/default.png') as ImageProvider,
                                                fit: BoxFit.cover
                                            ),
                                          ),
                                          child: (user[index].img == "/".substring(0, 1))?Center(
                                            child: CustomText.text(
                                                size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                                weight: FontWeight.w800,
                                                // text: initial,
                                                color: Colors.white
                                            ),
                                          ):Container(),
                                        ),
                                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                                        Container(
                                          width: CustomSize.sizeWidth(context) / 1.6,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomText.textHeading4(
                                                  text: user[index].name,
                                                  maxLines: 1,
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString())
                                              ),
                                              CustomText.bodyLight16(text: user[index].email, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                              (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(right: 8.0),
                                    //   child: GestureDetector(
                                    //       onTap: () async{
                                    //         setState(() {
                                    //           showAlertDialog(user[index].id.toString());
                                    //         });
                                    //       },
                                    //       child: Icon(Icons.delete, color: CustomColor.redBtn,)
                                    //   ),
                                    // )
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
          ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
