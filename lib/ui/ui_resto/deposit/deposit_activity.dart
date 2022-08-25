import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kam5ia/model/Category.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class DepositActivity extends StatefulWidget {
  // const DepositActivity({ required Key key }) : super(key: key);

  @override
  State<DepositActivity> createState() => _DepositActivityState();
}

class _DepositActivityState extends State<DepositActivity> {
  int balance = 0;
  String topup = '0';
  String code = '';
  List<Category> history = [];

  Future getData() async {
    initializeDateFormatting();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    String id = pref.getString("idHomeResto") ?? "";

    history = [];
    var apiResult3 = await http.get(Uri.parse(Links.mainUrl + "/deposit/$id"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(id);
    print('check');
    print(apiResult3.body);
    var apiResult = await http.get(Uri.parse(Links.mainUrl + "/page/deposit"), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oi');
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    var apiResult1 = await http.post(Uri.parse(Links.mainUrl + '/payment/inquiry-deposit'),
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print('inquiry: ' + apiResult1.body.toString());

    for (var h in data['history']) {
      Category c = Category(
          id: int.parse(h['amount']),
          nama: h['trans_code'] ?? "topup",
          created: h['created_at'],
          img: '');
      history.add(c);
    }

    setState(() {
      balance = int.parse(data['balance']);
    });
  }

  Future getData2() async {
    initializeDateFormatting();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    history = [];
    var apiResult = await http
        .get(Uri.parse(Links.mainUrl + "/page/deposit/"+DateFormat('d-M-y').format(selectedDate).toString()), headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print('oi');
    print(DateFormat('d-M-y').format(selectedDate).toString());
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    // var apiResult1 = await http.post(Uri.parse(Links.mainUrl + '/payment/inquiry-deposit'),
    //     headers: {
    //       "Accept": "Application/json",
    //       "Authorization": "Bearer $token"
    //     });
    // print('inquiry: '+apiResult1.body.toString());

    if (data.toString().contains('history') == true ) {
      for(var h in data['history']){
        Category c = Category(
            id: int.parse(h['amount']),
            nama: h['trans_code']??"topup",
            created: h['created_at'], img: ''
        );
        history.add(c);
      }
    }

    setState(() {
      if (data.toString().contains('history') == true ) {
        balance = int.parse(data['balance'].toString());
      }
    });
  }

  Future reqTopup() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";

    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/payment/deposit'), body: {
      'deposit': topup
    }, headers: {
      "Accept": "Application/json",
      "Authorization": "Bearer $token"
    });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    if (data['code'] != null) {
      setState(() {
        code = data['code'];
      });
      showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          context: context,
          builder: (_) {
            return StatefulBuilder(builder: (_, setStateModal) {
              return Padding(
                padding: EdgeInsets.all(CustomSize.sizeWidth(context) / 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.infoCircle, size: 12),
                        SizedBox(
                          width: CustomSize.sizeWidth(context) / 86,
                        ),
                        Expanded(
                          child: CustomText.bodyMedium16a(
                            text: "Scan Qrcode Qris",
                            sizeNew: double.parse(
                                ((MediaQuery.of(context).size.width * 0.04)
                                            .toString()
                                            .contains('.') ==
                                        true)
                                    ? (MediaQuery.of(context).size.width * 0.04)
                                        .toString()
                                        .split('.')[0]
                                    : (MediaQuery.of(context).size.width * 0.04)
                                        .toString()),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 86,
                    ),
                    CustomText.bodyMedium16a(
                        text:
                            "Screenshot layar lalu buka aplikasi pembayaran Qris dan lakukan pembayaran",
                        sizeNew: double.parse(
                            ((MediaQuery.of(context).size.width * 0.04)
                                        .toString()
                                        .contains('.') ==
                                    true)
                                ? (MediaQuery.of(context).size.width * 0.04)
                                    .toString()
                                    .split('.')[0]
                                : (MediaQuery.of(context).size.width * 0.04)
                                    .toString()),
                        maxLines: 5),
                    SizedBox(
                      height: CustomSize.sizeHeight(context) / 48,
                    ),
                    QrImage(
                      data: code,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ],
                ),
              );
            });
          });
    } else {
      Fluttertoast.showToast(
        msg: "Mohon maaf masih dalam perbaikan",
      );
    }
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    getData();
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

  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      helpText: "Pilih Tanggal",
      cancelText: "Batal",
      confirmText: "Simpan",
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
              backgroundColor: Colors.black,
              primaryColor: CustomColor.secondary, //Head background
              accentColor: CustomColor.secondary //s //Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        print(selectedDate);
        history = [];
        getData2();
        // _dateController.text = DateFormat('d-M-y').format(selectedDate);
      });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: CustomColor.primary,
              child: Column(
                children: [
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: CustomSize.sizeWidth(context) / 24,
                        vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              FaIcon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: CustomSize.sizeWidth(context) / 88,
                              ),
                              CustomText.textHeading4(
                                text: "Pendapatan",
                                // minSize: 20,
                                sizeNew: double.parse(
                                    ((MediaQuery.of(context).size.width * 0.045)
                                                .toString()
                                                .contains('.') ==
                                            true)
                                        ? ((MediaQuery.of(context).size.width *
                                                0.045))
                                            .toString()
                                            .split('.')[0]
                                        : ((MediaQuery.of(context).size.width *
                                                0.045))
                                            .toString()),
                                color: Colors.white,
                                // weight: FontWeight.w600
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    title: Center(child: Text('Informasi', style: TextStyle(color: Colors.blue))),
                                    content: Text('Data yang ditampilkan di halaman ini adalah data pendapatan anda!\n\n Untuk transaksi pembelian menu, pendapatan anda sudah dikurangi tanpa Platform Fee\n\n Dan untuk reservasi, Rp.5000 permejanya adalah hak PT. Imaji Cipta', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                    actions: <Widget>[
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 25, right: 25),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // OutlineButton(
                                              //   // minWidth: CustomSize.sizeWidth(context),
                                              //   shape: StadiumBorder(),
                                              //   highlightedBorderColor: CustomColor.secondary,
                                              //   borderSide: BorderSide(
                                              //       width: 2,
                                              //       color: CustomColor.redBtn
                                              //   ),
                                              //   child: Text('Batal'),
                                              //   onPressed: () async{
                                              //     setState(() {
                                              //       // codeDialog = valueText;
                                              //       Navigator.pop(context);
                                              //     });
                                              //   },
                                              // ),
                                              FlatButton(
                                                color: CustomColor.accent,
                                                textColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                child: Text('Oke'),
                                                onPressed: () async{
                                                  Navigator.pop(context);
                                                  // String qrcode = '';
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    ],
                                  );
                                });
                          },
                          child: FaIcon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 48,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomText.bodyMedium16a(
                          sizeNew: double.parse(
                              ((MediaQuery.of(context).size.width * 0.04)
                                          .toString()
                                          .contains('.') ==
                                      true)
                                  ? (MediaQuery.of(context).size.width * 0.04)
                                      .toString()
                                      .split('.')[0]
                                  : (MediaQuery.of(context).size.width * 0.04)
                                      .toString()),
                          textAlign: TextAlign.left,
                          text: "Saldo Anda",
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context);
                            // showModalBottomSheet(
                            //     isScrollControlled: true,
                            //     shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.only(
                            //             topLeft: Radius.circular(20),
                            //             topRight: Radius.circular(20))),
                            //     context: context,
                            //     builder: (_) {
                            //       return StatefulBuilder(
                            //           builder: (_, setStateModal) {
                            //         return Padding(
                            //           padding: EdgeInsets.all(
                            //               CustomSize.sizeWidth(context) / 24),
                            //           child: Column(
                            //             mainAxisSize: MainAxisSize.min,
                            //             children: [
                            //               CustomText.bodyMedium16a(
                            //                 sizeNew: double.parse(
                            //                     ((MediaQuery.of(context)
                            //                                         .size
                            //                                         .width *
                            //                                     0.04)
                            //                                 .toString()
                            //                                 .contains('.') ==
                            //                             true)
                            //                         ? (MediaQuery.of(context)
                            //                                     .size
                            //                                     .width *
                            //                                 0.04)
                            //                             .toString()
                            //                             .split('.')[0]
                            //                         : (MediaQuery.of(context)
                            //                                     .size
                            //                                     .width *
                            //                                 0.04)
                            //                             .toString()),
                            //                 textAlign: TextAlign.left,
                            //                 text: "List Harga Topup",
                            //               ),
                            //               SizedBox(
                            //                 height:
                            //                     CustomSize.sizeHeight(context) /
                            //                         48,
                            //               ),
                            //               Row(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.spaceAround,
                            //                 children: [
                            //                   Container(
                            //                     width: CustomSize.sizeWidth(
                            //                             context) /
                            //                         2.3,
                            //                     height: CustomSize.sizeHeight(
                            //                             context) /
                            //                         16,
                            //                     decoration: BoxDecoration(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: CustomColor.primary,
                            //                     ),
                            //                     child: Material(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: Colors.transparent,
                            //                       child: InkWell(
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 8),
                            //                         splashColor: Colors.white,
                            //                         highlightColor:
                            //                             CustomColor.primary,
                            //                         onTap: () {
                            //                           setState(() {
                            //                             topup = '50000';
                            //                           });
                            //                           Navigator.pop(context);
                            //                           reqTopup()
                            //                               .whenComplete(() {});
                            //                         },
                            //                         child: Container(
                            //                           width:
                            //                               CustomSize.sizeWidth(
                            //                                       context) /
                            //                                   2.3,
                            //                           height:
                            //                               CustomSize.sizeHeight(
                            //                                       context) /
                            //                                   16,
                            //                           decoration: BoxDecoration(
                            //                             borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(8),
                            //                           ),
                            //                           child: Center(
                            //                             child: CustomText
                            //                                 .bodyMedium16b(
                            //                               text: NumberFormat
                            //                                       .currency(
                            //                                           locale:
                            //                                               'id',
                            //                                           symbol:
                            //                                               'Rp. ',
                            //                                           decimalDigits:
                            //                                               0)
                            //                                   .format(50000),
                            //                               textAlign:
                            //                                   TextAlign.center,
                            //                               color: Colors.white,
                            //                               maxLines: 1,
                            //                               sizeNew: double.parse(((MediaQuery.of(context)
                            //                                                   .size
                            //                                                   .width *
                            //                                               0.04)
                            //                                           .toString()
                            //                                           .contains(
                            //                                               '.') ==
                            //                                       true)
                            //                                   ? (MediaQuery.of(
                            //                                                   context)
                            //                                               .size
                            //                                               .width *
                            //                                           0.04)
                            //                                       .toString()
                            //                                       .split('.')[0]
                            //                                   : (MediaQuery.of(
                            //                                                   context)
                            //                                               .size
                            //                                               .width *
                            //                                           0.04)
                            //                                       .toString()),
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   SizedBox(
                            //                     width: 6,
                            //                   ),
                            //                   Container(
                            //                     width: CustomSize.sizeWidth(
                            //                             context) /
                            //                         2.3,
                            //                     height: CustomSize.sizeHeight(
                            //                             context) /
                            //                         16,
                            //                     decoration: BoxDecoration(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: CustomColor.primary,
                            //                     ),
                            //                     child: Material(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: Colors.transparent,
                            //                       child: InkWell(
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 8),
                            //                         splashColor: Colors.white,
                            //                         highlightColor:
                            //                             CustomColor.primary,
                            //                         onTap: () {
                            //                           setState(() {
                            //                             topup = '250000';
                            //                           });
                            //                           Navigator.pop(context);
                            //                           reqTopup()
                            //                               .whenComplete(() {});
                            //                         },
                            //                         child: Container(
                            //                           width:
                            //                               CustomSize.sizeWidth(
                            //                                       context) /
                            //                                   2.3,
                            //                           height:
                            //                               CustomSize.sizeHeight(
                            //                                       context) /
                            //                                   16,
                            //                           decoration: BoxDecoration(
                            //                             borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(8),
                            //                           ),
                            //                           child: Center(
                            //                             child: CustomText.bodyMedium16b(
                            //                                 sizeNew: double.parse(((MediaQuery.of(context).size.width * 0.04)
                            //                                             .toString()
                            //                                             .contains(
                            //                                                 '.') ==
                            //                                         true)
                            //                                     ? (MediaQuery.of(context).size.width * 0.04)
                            //                                         .toString()
                            //                                         .split(
                            //                                             '.')[0]
                            //                                     : (MediaQuery.of(context).size.width *
                            //                                             0.04)
                            //                                         .toString()),
                            //                                 text: NumberFormat.currency(
                            //                                         locale: 'id',
                            //                                         symbol: 'Rp. ',
                            //                                         decimalDigits: 0)
                            //                                     .format(250000),
                            //                                 textAlign: TextAlign.center,
                            //                                 color: Colors.white,
                            //                                 maxLines: 1),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //               SizedBox(
                            //                 height:
                            //                     CustomSize.sizeHeight(context) /
                            //                         86,
                            //               ),
                            //               Row(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.spaceAround,
                            //                 children: [
                            //                   Container(
                            //                     width: CustomSize.sizeWidth(
                            //                             context) /
                            //                         2.3,
                            //                     height: CustomSize.sizeHeight(
                            //                             context) /
                            //                         16,
                            //                     decoration: BoxDecoration(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: CustomColor.primary,
                            //                     ),
                            //                     child: Material(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: Colors.transparent,
                            //                       child: InkWell(
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 8),
                            //                         splashColor: Colors.white,
                            //                         highlightColor:
                            //                             CustomColor.primary,
                            //                         onTap: () {
                            //                           setState(() {
                            //                             topup = '500000';
                            //                           });
                            //                           Navigator.pop(context);
                            //                           reqTopup()
                            //                               .whenComplete(() {});
                            //                         },
                            //                         child: Container(
                            //                           width:
                            //                               CustomSize.sizeWidth(
                            //                                       context) /
                            //                                   2.3,
                            //                           height:
                            //                               CustomSize.sizeHeight(
                            //                                       context) /
                            //                                   16,
                            //                           decoration: BoxDecoration(
                            //                             borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(8),
                            //                           ),
                            //                           child: Center(
                            //                             child: CustomText.bodyMedium16b(
                            //                                 sizeNew: double.parse(((MediaQuery.of(context).size.width * 0.04)
                            //                                             .toString()
                            //                                             .contains(
                            //                                                 '.') ==
                            //                                         true)
                            //                                     ? (MediaQuery.of(context).size.width * 0.04)
                            //                                         .toString()
                            //                                         .split(
                            //                                             '.')[0]
                            //                                     : (MediaQuery.of(context).size.width *
                            //                                             0.04)
                            //                                         .toString()),
                            //                                 text: NumberFormat.currency(
                            //                                         locale: 'id',
                            //                                         symbol: 'Rp. ',
                            //                                         decimalDigits: 0)
                            //                                     .format(500000),
                            //                                 textAlign: TextAlign.center,
                            //                                 color: Colors.white,
                            //                                 maxLines: 1),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                   SizedBox(
                            //                     width: 6,
                            //                   ),
                            //                   Container(
                            //                     width: CustomSize.sizeWidth(
                            //                             context) /
                            //                         2.3,
                            //                     height: CustomSize.sizeHeight(
                            //                             context) /
                            //                         16,
                            //                     decoration: BoxDecoration(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: CustomColor.primary,
                            //                     ),
                            //                     child: Material(
                            //                       borderRadius:
                            //                           BorderRadius.circular(8),
                            //                       color: Colors.transparent,
                            //                       child: InkWell(
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 8),
                            //                         splashColor: Colors.white,
                            //                         highlightColor:
                            //                             CustomColor.primary,
                            //                         onTap: () {
                            //                           setState(() {
                            //                             topup = '1000000';
                            //                           });
                            //                           Navigator.pop(context);
                            //                           reqTopup()
                            //                               .whenComplete(() {});
                            //                         },
                            //                         child: Container(
                            //                           width:
                            //                               CustomSize.sizeWidth(
                            //                                       context) /
                            //                                   2.3,
                            //                           height:
                            //                               CustomSize.sizeHeight(
                            //                                       context) /
                            //                                   16,
                            //                           decoration: BoxDecoration(
                            //                             borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(8),
                            //                           ),
                            //                           child: Center(
                            //                             child: CustomText.bodyMedium16b(
                            //                                 sizeNew: double.parse(((MediaQuery.of(context).size.width * 0.04)
                            //                                             .toString()
                            //                                             .contains(
                            //                                                 '.') ==
                            //                                         true)
                            //                                     ? (MediaQuery.of(context).size.width * 0.04)
                            //                                         .toString()
                            //                                         .split(
                            //                                             '.')[0]
                            //                                     : (MediaQuery.of(context).size.width *
                            //                                             0.04)
                            //                                         .toString()),
                            //                                 text: NumberFormat.currency(
                            //                                         locale: 'id',
                            //                                         symbol: 'Rp. ',
                            //                                         decimalDigits: 0)
                            //                                     .format(1000000),
                            //                                 textAlign: TextAlign.center,
                            //                                 color: Colors.white,
                            //                                 maxLines: 1),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ],
                            //           ),
                            //         );
                            //       });
                            //     });
                          },
                          child: CustomText.bodyMedium16c(
                            textAlign: TextAlign.right,
                            text: "Pilih Tanggal",
                            color: CustomColor.primary,
                            sizeNew: double.parse(
                                ((MediaQuery.of(context).size.width * 0.04)
                                            .toString()
                                            .contains('.') ==
                                        true)
                                    ? (MediaQuery.of(context).size.width * 0.04)
                                        .toString()
                                        .split('.')[0]
                                    : (MediaQuery.of(context).size.width * 0.04)
                                        .toString()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                  Row(
                    children: [
                      CustomText.bodyMedium16a(
                        textAlign: TextAlign.left,
                        text: NumberFormat.currency(
                                locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
                            .format(balance),
                        sizeNew: double.parse(
                            ((MediaQuery.of(context).size.width * 0.06)
                                        .toString()
                                        .contains('.') ==
                                    true)
                                ? (MediaQuery.of(context).size.width * 0.06)
                                    .toString()
                                    .split('.')[0]
                                : (MediaQuery.of(context).size.width * 0.06)
                                    .toString()),
                      ),
                      CustomText.bodyMedium16a(
                        textAlign: TextAlign.left,
                        text: "  Rupiah",
                        sizeNew: double.parse(
                            ((MediaQuery.of(context).size.width * 0.03)
                                        .toString()
                                        .contains('.') ==
                                    true)
                                ? (MediaQuery.of(context).size.width * 0.03)
                                    .toString()
                                    .split('.')[0]
                                : (MediaQuery.of(context).size.width * 0.03)
                                    .toString()),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 86,
                  ),
                  (history.toString() != "[]")
                      ? CustomText.bodyMedium16a(
                          textAlign: TextAlign.left,
                          text: "Riwayat Pendapatan",
                          sizeNew: double.parse(
                              ((MediaQuery.of(context).size.width * 0.05)
                                          .toString()
                                          .contains('.') ==
                                      true)
                                  ? (MediaQuery.of(context).size.width * 0.05)
                                      .toString()
                                      .split('.')[0]
                                  : (MediaQuery.of(context).size.width * 0.05)
                                      .toString()),
                        )
                      : Container(),
                  SizedBox(
                    height: CustomSize.sizeHeight(context) / 63,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SmartRefresher(
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
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          SizedBox(
                            height: CustomSize.sizeHeight(context) / 86,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText.bodyMedium16a(
                                      textAlign: TextAlign.left,
                                      text: (history[index].nama == "topup" ||
                                              history[index].nama == "Saldo")
                                          ? (history[index].nama == "Saldo")
                                              ? history[index].nama
                                              : "💸 Topup"
                                          : "💸 Transaksi " +
                                              history[index].nama,
                                      sizeNew: double.parse(
                                          ((MediaQuery.of(context).size.width *
                                                          0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                  true)
                                              ? (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03)
                                                  .toString()
                                                  .split('.')[0]
                                              : (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03)
                                                  .toString()),
                                    ),
                                    CustomText.bodyMedium16c(
                                      textAlign: TextAlign.right,
                                      text: (history[index].nama == "topup" ||
                                              history[index].nama == "Saldo")
                                          ? (history[index].nama == "Saldo")
                                              ? NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp. ',
                                                      decimalDigits: 0)
                                                  .format(history[index].id)
                                              : "+ " +
                                                  NumberFormat.currency(
                                                          locale: 'id',
                                                          symbol: 'Rp. ',
                                                          decimalDigits: 0)
                                                      .format(history[index].id)
                                          : "+ " +
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp. ',
                                                      decimalDigits: 0)
                                                  .format(history[index].id),
                                      sizeNew: double.parse(
                                          ((MediaQuery.of(context).size.width *
                                                          0.03)
                                                      .toString()
                                                      .contains('.') ==
                                                  true)
                                              ? (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03)
                                                  .toString()
                                                  .split('.')[0]
                                              : (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03)
                                                  .toString()),
                                      color: (history[index].nama == "topup" ||
                                              history[index].nama == "Saldo")
                                          ? (history[index].nama == "Saldo")
                                              ? Colors.black
                                              : CustomColor.accent
                                          : CustomColor.accent,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: CustomText.bodyMedium16a(
                                  textAlign: TextAlign.left,
                                  sizeNew: double.parse(
                                      ((MediaQuery.of(context).size.width *
                                                      0.04)
                                                  .toString()
                                                  .contains('.') ==
                                              true)
                                          ? (MediaQuery.of(context).size.width *
                                                  0.04)
                                              .toString()
                                              .split('.')[0]
                                          : (MediaQuery.of(context).size.width *
                                                  0.04)
                                              .toString()),
                                  text: DateFormat("d MMM yyyy - HH:mm").format(
                                      DateTime.parse(history[index].created)),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.black,
                          )
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
