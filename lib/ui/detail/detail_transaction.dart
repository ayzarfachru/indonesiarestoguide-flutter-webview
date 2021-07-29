import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indonesiarestoguide/model/Menu.dart';
import 'package:indonesiarestoguide/model/Price.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:indonesiarestoguide/utils/chat_activity.dart';

class DetailTransaction extends StatefulWidget {
  int id;
  String status;

  DetailTransaction(this.id, this.status);

  @override
  _DetailTransactionState createState() => _DetailTransactionState(id, status);
}

class _DetailTransactionState extends State<DetailTransaction> {
  int id;
  String status;

  _DetailTransactionState(this.id, this.status);

  ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  String type = '';
  String address = '';
  int ongkir = 0;
  int harga = 0;
  int total = 0;
  String chatroom = 'null';

  List<Menu> menu = [];
  Future<void> getData()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";

    var apiResult = await http.get(Links.mainUrl + '/trans/$id',
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    print(apiResult.body);
    var data = json.decode(apiResult.body);

    for(var v in data['menu']){
      Menu m = Menu(
          id: v['menus_id'],
          qty: v['qty'].toString(),
          price: Price(original: v['price']),
          name: v['name'],
          urlImg: v['image'],
          desc: v['desc']
      );
      _menu.add(m);
    }
    setState(() {
      menu = _menu;
      type = data['trans']['type'];
      address = data['trans']['address']??'';
      ongkir = data['trans']['ongkir'];
      total = data['trans']['total'];
      harga = data['trans']['total'] - data['trans']['ongkir'];
      chatroom = data['chatroom'].toString();
      isLoading = false;
    });
    print(chatroom);
  }

  String userName = '';
  Future getUser()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = (pref.getString('name'));
    });
  }

  @override
  void initState() {
    getUser();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (isLoading)?Container(
            width: CustomSize.sizeWidth(context),
            height: CustomSize.sizeHeight(context),
            child: Center(child: CircularProgressIndicator())):SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (type == 'delivery' || type == 'takeaway')?Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 32,),
                      CustomText.bodyLight12(text: (type == 'delivery')?"Alamat Pengiriman":"Alamat Pengambilan"),
                      SizedBox(height: CustomSize.sizeHeight(context) * 0.005,),
                      CustomText.textHeading4(
                          text: address,
                          minSize: 16,
                          maxLines: 10
                      ),
                    ],
                  ),
                ),
              ):SizedBox(),
              SizedBox(height: (type == 'delivery')?CustomSize.sizeHeight(context) / 48:0,),
              (type == 'delivery')?Divider(thickness: 6, color: CustomColor.secondary,):SizedBox(),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: CustomSize.sizeWidth(context) / 8,
                          height: CustomSize.sizeWidth(context) / 8,
                          decoration: BoxDecoration(
                              color: CustomColor.primary,
                              shape: BoxShape.circle
                          ),
                          child: Center(
                            child: Icon((type == 'delivery')?FontAwesome.motorcycle:(type == 'takeaway')?MaterialCommunityIcons.shopping:Icons.restaurant, color: Colors.white, size: 20,),
                          ),
                        ),
                        SizedBox(width: CustomSize.sizeWidth(context) / 32,),
                        CustomText.textHeading6(text: (type == 'delivery')?"Pesan Antar":(type == 'takeaway')?"Ambil Langsung":"Makan Ditempat",),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              Divider(thickness: 6, color: CustomColor.secondary,),
              SizedBox(height: CustomSize.sizeHeight(context) / 48,),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: menu.length,
                  itemBuilder: (_, index){
                    return Padding(
                      padding: EdgeInsets.only(
                        top: CustomSize.sizeWidth(context) / 32,
                        left: CustomSize.sizeWidth(context) / 32,
                        right: CustomSize.sizeWidth(context) / 32,
                      ),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 5.2,
                        child: Column(
                          children: [
                            Container(
                              height: CustomSize.sizeHeight(context) / 6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 1.65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CustomText.textHeading4(
                                                text: menu[index].name,
                                                minSize: 18,
                                                maxLines: 1
                                            ),
                                            CustomText.bodyRegular12(
                                                text: menu[index].desc,
                                                maxLines: 2,
                                                minSize: 12
                                            ),
                                            SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                                            Row(
                                              children: [
                                                CustomText.bodyMedium14(
                                                    text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(menu[index].price.original) ,
                                                    maxLines: 1,
                                                    minSize: 16
                                                ),
                                                CustomText.bodyLight14(
                                                    text: "  x  ",
                                                    maxLines: 1,
                                                    minSize: 14
                                                ),
                                                CustomText.bodyMedium14(
                                                    text: menu[index].qty.toString(),
                                                    maxLines: 1,
                                                    minSize: 16
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: CustomSize.sizeWidth(context) / 3.4,
                                        height: CustomSize.sizeWidth(context) / 3.4,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(Links.subUrl + menu[index].urlImg),
                                                fit: BoxFit.cover
                                            ),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider()
                          ],
                        ),
                      ),
                    );
                  }
              ),
              Container(
                width: CustomSize.sizeWidth(context),
                decoration: BoxDecoration(
                    color: CustomColor.secondary
                ),
                child: Column(
                  children: [
                    SizedBox(height: CustomSize.sizeHeight(context) / 22.5,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22),
                      child: Container(
                        width: CustomSize.sizeWidth(context),
                        height: CustomSize.sizeHeight(context) / 3.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: CustomSize.sizeHeight(context) / 36,),
                              CustomText.textTitle3(text: "Rincian Pembayaran"),
                              SizedBox(height: CustomSize.sizeHeight(context) / 50,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Harga"),
                                  CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(harga)),
                                ],
                              ),
                              SizedBox(height: (type == 'delivery')?CustomSize.sizeHeight(context) / 100:0,),
                              (type == 'delivery')?Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.bodyLight16(text: "Ongkir"),
                                  CustomText.bodyLight16(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(ongkir)),
                                ],
                              ):SizedBox(),
                              SizedBox(height: CustomSize.sizeHeight(context) / 64,),
                              Divider(thickness: 1,),
                              SizedBox(height: CustomSize.sizeHeight(context) / 120,),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText.textTitle3(text: "Total Pembayaran"),
                                  CustomText.textTitle3(text: NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: CustomSize.sizeHeight(context) / 40,),
                    (chatroom != 'null')?GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: new ChatActivity(chatroom, userName, status)));
                      },
                      child: Center(
                        child: Container(
                          width: CustomSize.sizeWidth(context) / 1.1,
                          height: CustomSize.sizeHeight(context) / 14,
                          decoration: BoxDecoration(
                              color: CustomColor.accent,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: CustomText.textTitle2(text: "Hubungi Penjual", color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(),
                    SizedBox(height: CustomSize.sizeHeight(context) / 54,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
