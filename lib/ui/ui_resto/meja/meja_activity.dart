import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam5ia/model/CategoryMenu.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/MenuJson.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/model/Promo.dart';
import 'package:kam5ia/model/Meja.dart';
import 'package:kam5ia/ui/ui_resto/menu/add_menu.dart';
import 'package:kam5ia/ui/ui_resto/menu/edit_menu.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:kam5ia/model/Transaction.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MejaActivity extends StatefulWidget {
  @override
  _MejaActivityState createState() => _MejaActivityState();
}

class _MejaActivityState extends State<MejaActivity> {
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  List<Meja> meja = [];
  Future<void> _getQr()async{
    List<Meja> _meja = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/table', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print(data);

    for(var v in data['table']){
      Meja p = Meja(
          id: v['id'],
          name: v['name'],
          qr: v['barcode'],
          url: v['img'],
      );
      _meja.add(p);
    }

    setState(() {
      meja = _meja;
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
        _delMeja(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus Meja"),
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

  Future _delMeja(String id)async{
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/table/delete/$id', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['msg'].toString() == 'Success') {
      Navigator.pop(context);
      // print('SUKSESSSS');
      Navigator.pushReplacement(context,
          PageTransition(
              type: PageTransitionType.fade,
              child: MejaActivity()));
    }

    setState(() {
      isLoading = false;
    });
  }

  String downloadAll = '';
  Future<void> getDownloadAll()async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.get(Links.mainUrl + '/resto/qrcode', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    var link = data['link'];

    setState(() {
      downloadAll = data['link'];
      // print(url + 'aa');
      // meja = _meja;
      isLoading = false;
    });
  }

  Future<void> AddMeja()async{

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Links.mainUrl + '/table', headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);
    // var link = data['link'];

    if (data['msg'].toString() == 'Success') {
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
    }

    setState(() {
      // downloadAll = data['link'];
      // print(url + 'aa');
      // meja = _meja;
      isLoading = false;
    });
  }

  List<String?>? items;
  getNumber() async {

  }

  @override
  void initState() {
    _getQr();
    getDownloadAll();
    items= List<String>.generate(meja.length, (i) => (meja.length + 1).toString());
    print(items);
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
                    Row(
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
                              text: "Qr Code",
                              sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                              maxLines: 1
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: meja.length,
                        itemBuilder: (_, index){
                          // print(meja.length);
                          return Padding(
                            padding: EdgeInsets.only(top: CustomSize.sizeHeight(context) / 48),
                            child: GestureDetector(
                              onTap: () async{
                                print(meja[index]);
                                print(meja.length);
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                    ),
                                    context: context,
                                    builder: (_){
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 2.4),
                                            child: Divider(thickness: 4,),
                                          ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                          Center(
                                            child: Container(
                                              width: CustomSize.sizeWidth(context) / 1.2,
                                              height: CustomSize.sizeWidth(context) / 1.2,
                                              child: QrImage(
                                                data: meja[index].qr.toString(),
                                                version: QrVersions.auto,
                                                // size: 200.0,
                                              ),
                                              // decoration: BoxDecoration(
                                              //   image: DecorationImage(
                                              //       image: NetworkImage(Links.subUrl + categoryMenu[categoryMenu.indexWhere((v) => v.name == nameCategory)].menu[index].urlImg),
                                              //       fit: BoxFit.cover
                                              //   ),
                                              //   borderRadius: BorderRadius.circular(10),
                                              // ),
                                            ),
                                          ),
                                          // SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                                          // Padding(
                                          //   padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeHeight(context) / 20),
                                          //   child: Column(
                                          //     crossAxisAlignment: CrossAxisAlignment.start,
                                          //     children: [
                                          //       CustomText.textHeading5(
                                          //           text: "Meja "+meja[index].name,
                                          //           minSize: 18,
                                          //           maxLines: 1
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 52,),
                                          (int.parse(meja[index].name) == meja.length)?Center(
                                            child: Container(
                                              width: CustomSize.sizeWidth(context) / 1.1,
                                              height: CustomSize.sizeHeight(context) / 14,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      _delMeja(meja[index].id.toString());
                                                      // Navigator.pop(context);
                                                      // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new MejaActivity()));
                                                    },
                                                    child: Center(
                                                      child: Container(
                                                        width: CustomSize.sizeWidth(context) / 1.1,
                                                        height: CustomSize.sizeHeight(context) / 14,
                                                        decoration: BoxDecoration(
                                                            color: CustomColor.redBtn,
                                                            borderRadius: BorderRadius.circular(50)
                                                        ),
                                                        child: Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                CustomText.textHeading7(text: "Hapus Meja", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                                // CustomText.textHeading7(text: "Meja", color: Colors.white),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ):Container(),
                                          SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                                        ],
                                      );
                                    }
                                );
                              },
                              child: Container(
                                width: CustomSize.sizeWidth(context),
                                height: CustomSize.sizeWidth(context) / 5.4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 7,
                                      offset: Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: CustomSize.sizeWidth(context) / 32,
                                    ),
                                    Container(
                                      width: CustomSize.sizeWidth(context) / 1.2,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText.textHeading4(
                                                  text: "Meja "+meja[index].name.toString(),
                                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                                                  maxLines: 1
                                              ),
                                              // Row(
                                              //   children: [
                                              //     GestureDetector(
                                              //       onTap: () async{
                                              //         showAlertDialog(meja[index].id.toString());
                                              //         },
                                              //         child: Icon(Icons.delete, color: CustomColor.redBtn, size: 20,)
                                              //     ),
                                              //     // GestureDetector(
                                              //     //   onTap: () async{
                                              //     //     await launch(meja[index].url);
                                              //     //     },
                                              //     //     child: Icon(FontAwesome.download, color: CustomColor.primary, size: 20,)
                                              //     // ),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: CustomSize.sizeWidth(context) / 32,
                                          ),
                                        ],
                                      ),
                                    )
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
          floatingActionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async{
                  launch(downloadAll);
                },
                child: Container(
                  width: CustomSize.sizeWidth(context) / 6.6,
                  height: CustomSize.sizeWidth(context) / 6.6,
                  decoration: BoxDecoration(
                      color: CustomColor.accent,
                      shape: BoxShape.circle
                  ),
                  child: Center(child: Icon(FontAwesome.download, color: Colors.white, size: 29,)),
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 72,),
              GestureDetector(
                onTap: (){
                  // Navigator.push(
                  //     context,
                  //     PageTransition(
                  //         type: PageTransitionType.rightToLeft,
                  //         child: AddMenu()));
                  if (meja.length == 100) {
                    Fluttertoast.showToast(
                        msg: "Meja terlalu banyak",
                        backgroundColor: Colors.grey,
                        textColor: Colors.black,
                        fontSize: 16.0
                    );
                  } else {
                    AddMeja();
                    Fluttertoast.showToast(
                      msg: "Tunggu sebentar.",);
                  }
                },
                child: Container(
                  width: CustomSize.sizeWidth(context) / 6.6,
                  height: CustomSize.sizeWidth(context) / 6.6,
                  decoration: BoxDecoration(
                      color: CustomColor.primaryLight,
                      shape: BoxShape.circle
                  ),
                  child: Center(child: Icon(FontAwesome.plus, color: Colors.white, size: 29,)),
                ),
              ),
            ],
          ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
