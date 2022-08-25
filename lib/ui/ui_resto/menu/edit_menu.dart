import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class EditMenu extends StatefulWidget {
  Menu detailMenu;

  EditMenu(this.detailMenu);

  @override
  _EditMenuState createState() => _EditMenuState(detailMenu);
}

class MenuChip extends StatefulWidget {
  final List<String> typeList;
  final Function(List<String>) onSelectionChanged;

  MenuChip(this.typeList, {required this.onSelectionChanged});

  @override
  CuisineChipState createState() => CuisineChipState();
}

class CuisineChipState extends State<MenuChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.typeList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          checkmarkColor: Colors.black,
          selectedColor: Colors.green[100],
          selectedShadowColor: Colors.green,
          label: Text(item),
          selected: selectedChoices.contains(item),
          labelStyle: TextStyle(color: Colors.black),
          onSelected: (selected) {
            setState(() {
              if (selectedChoices.contains(item) != null) {
                selectedChoices.clear();
                selectedChoices.add(item);
              } else {
                selectedChoices.add(item);
              }
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class _EditMenuState extends State<EditMenu> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  Menu detailMenu;

  _EditMenuState(this.detailMenu);


  TextEditingController namaMenu = TextEditingController(text: "");
  TextEditingController hargaMenu = TextEditingController(text: "");
  TextEditingController hargaDeliv = TextEditingController(text: "");
  TextEditingController tipeMenu = TextEditingController(text: "");
  TextEditingController deskMenu = TextEditingController(text: "");
  TextEditingController tOngkir = TextEditingController(text: "");
  TextEditingController tReser4 = TextEditingController(text: "");
  TextEditingController tTable = TextEditingController(text: "");

  String name = "";
  String initial = "";
  String img = "";

  bool isLoading = false;

  bool favorite = false;
  bool reservation = false;
  bool delivery = false;
  String is_available = '';

  List<String> menuList = [];

  List<String> selectedMenuList = [];
  String? tipe;

  _showCuisineDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("Tipe Menu"),
            content: MenuChip(
              typeList,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedMenuList = selectedList;
                  tipe = selectedMenuList.single;
                });
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("tipeMenu", tipe.toString());
                  setState(() {
                    print(tipe);
                    getNewTipeMenu();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  getNameMenu() async {
    namaMenu = TextEditingController(text: detailMenu.name);
  }

  getHargaMenu() async {
    hargaMenu = TextEditingController(text: detailMenu.price!.original.toString());
  }

  getDelivMenu() async {
    hargaDeliv = TextEditingController(text: detailMenu.delivery_price!.delivery.toString());
  }

  getTipeMenu() async {
    tipeMenu = TextEditingController(text: detailMenu.type);
  }
  getNewTipeMenu() async {
    tipeMenu = TextEditingController(text: tipe);
  }

  getDescMenu() async {
    deskMenu = TextEditingController(text: detailMenu.desc);
  }

  getFavMenu() async {
    favorite = (detailMenu.is_recommended != '1')?false:true;
  }

  getInitial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      initial = (pref.getString('name')!.substring(0, 1).toUpperCase());
      print(initial);
    });
  }


  //------------------------------= IMAGE PICKER =----------------------------------
  File? image;
  String? extension;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      image = File(pickedFile!.path);
      extension = pickedFile.path.split('.').last;
    });
  }


  List<String> typeList = [];
  List<String> typeList2 = [
    'makanan pembuka',
    'makanan utama',
    'makanan penutup',
    'minuman dingin',
    'minuman panas'
  ];

  List<String?>? dataCuisine;
  Future<void> getType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Uri.parse(Links.mainUrl +'/util/data?q=menutype'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print(jsonData);

    for(var v in jsonData['data']){
      typeList.add(v['name']);
    }
    setState(() {});
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10))
    //         ),
    //         title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
    //         content: Text('Masukkan harga menu yang sudah dihitung beserta biaya PPN dan biaya Service Charge sesuai resto anda.', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
    //         actions: <Widget>[
    //           Center(
    //             child: Padding(
    //               padding: EdgeInsets.only(left: 25, right: 25),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   // OutlineButton(
    //                   //   // minWidth: CustomSize.sizeWidth(context),
    //                   //   shape: StadiumBorder(),
    //                   //   highlightedBorderColor: CustomColor.secondary,
    //                   //   borderSide: BorderSide(
    //                   //       width: 2,
    //                   //       color: CustomColor.redBtn
    //                   //   ),
    //                   //   child: Text('Batal'),
    //                   //   onPressed: () async{
    //                   //     setState(() {
    //                   //       // codeDialog = valueText;
    //                   //       Navigator.pop(context);
    //                   //     });
    //                   //   },
    //                   // ),
    //                   FlatButton(
    //                     color: CustomColor.accent,
    //                     textColor: Colors.white,
    //                     shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.all(Radius.circular(10))
    //                     ),
    //                     child: Text('Oke'),
    //                     onPressed: () async{
    //                       Navigator.pop(context);
    //                       // String qrcode = '';
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //
    //         ],
    //       );
    //     });
  }


  String? id;
  List<Menu> menu = [];
  Future<void> _editMenu()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/menu/$id'),
        body: {
          'name': namaMenu.text,
          'desc': deskMenu.text,
          'price': hargaMenu.text,
          'is_recommended': (favorite == true)?'true':'false',
          'is_available': is_available,
          'type': tipeMenu.text,
          'img': (image != null)?'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString():'',
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new MenuActivity()));
      print(json.encode({
        'name': namaMenu.text,
        'desc': deskMenu.text,
        'price': hargaMenu.text,
        'is_recommended': (favorite == true)?'true':'false',
        'is_available': is_available,
        'type': tipeMenu.text,
        'img': (image != null)?'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString():'',
      }));
    } else {
      print(data);
      print(json.encode({
        'name': namaMenu.text,
        'desc': deskMenu.text,
        'price': hargaMenu.text,
        // 'delivery_price': hargaDeliv.text,
        'is_recommended': favorite.toString(),
        'type': tipeMenu.text,
        'img': (image != null)?'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString():'',
      }));
    }
    setState(() {
      menu = _menu;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitial();
    getType();
    getNameMenu();
    getHargaMenu();
    getDelivMenu();
    getTipeMenu();
    getDescMenu();
    getFavMenu();
    setState(() {
      id = detailMenu.id.toString();
      is_available = detailMenu.is_available.toString();
    });
    // Future.delayed(Duration.zero, () async {
    //
    // });
  }
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: CustomSize.sizeHeight(context) / 38,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.chevron_left, size: double.parse(((MediaQuery.of(context).size.width*0.075).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.075)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.075)).toString()),)
                      ),
                      SizedBox(
                        width: CustomSize.sizeWidth(context) / 88,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: CustomText.textHeading4(
                            text: "Edit data menu",
                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.045).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.045)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.045)).toString()),
                            maxLines: 1
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 86,),
                Divider(
                  thickness: 8,
                  color: CustomColor.secondary,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Nama", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        controller: namaMenu,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Harga", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        // readOnly: true,
                        // onTap: (){
                        //   showDialog(
                        //       context: context,
                        //       builder: (context) {
                        //         return AlertDialog(
                        //           contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                        //           shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10))
                        //           ),
                        //           title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.redBtn))),
                        //           content: Text('Harga menu anda tidak dapat di ubah. \n\n Jika anda ingin mengganti harga menu kirim foto, harga terbaru dan nama menu yang anda gunakan saat ini ke info@irg.com', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        //           actions: <Widget>[
                        //             Center(
                        //               child: Padding(
                        //                 padding: EdgeInsets.only(left: 25, right: 25),
                        //                 child: Row(
                        //                   mainAxisAlignment: MainAxisAlignment.center,
                        //                   children: [
                        //                     // OutlineButton(
                        //                     //   // minWidth: CustomSize.sizeWidth(context),
                        //                     //   shape: StadiumBorder(),
                        //                     //   highlightedBorderColor: CustomColor.secondary,
                        //                     //   borderSide: BorderSide(
                        //                     //       width: 2,
                        //                     //       color: CustomColor.redBtn
                        //                     //   ),
                        //                     //   child: Text('Batal'),
                        //                     //   onPressed: () async{
                        //                     //     setState(() {
                        //                     //       // codeDialog = valueText;
                        //                     //       Navigator.pop(context);
                        //                     //     });
                        //                     //   },
                        //                     // ),
                        //                     OutlinedButton(
                        //                       // minWidth: CustomSize.sizeWidth(context),
                        //                       // shape: StadiumBorder(),
                        //                       // highlightedBorderColor: CustomColor.secondary,
                        //                       // borderSide: BorderSide(
                        //                       //     width: 2,
                        //                       //     color: CustomColor.accent
                        //                       // ),
                        //                       style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                        //                       child: Text('Oke'),
                        //                       onPressed: () async{
                        //                         Navigator.pop(context);
                        //                         // String qrcode = '';
                        //                       },
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //
                        //           ],
                        //         );
                        //       });
                        // },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: hargaMenu,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      // CustomText.bodyLight12(text: "Harga menu + Harga kemasan"),
                      // SizedBox(
                      //   height: CustomSize.sizeHeight(context) * 0.005,
                      // ),
                      // TextField(
                      //   controller: hargaDeliv,
                      //   keyboardType: TextInputType.number,
                      //   cursorColor: Colors.black,
                      //   style: GoogleFonts.poppins(
                      //       textStyle:
                      //       TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                      //   decoration: InputDecoration(
                      //     hintText: '*Contoh harga menu: 18000 -> 20000',
                      //     isDense: true,
                      //     contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                      //     hintStyle: GoogleFonts.poppins(
                      //         textStyle:
                      //         TextStyle(fontSize: 14, color: Colors.grey)),
                      //     helperStyle: GoogleFonts.poppins(
                      //         textStyle: TextStyle(fontSize: 14)),
                      //     enabledBorder: UnderlineInputBorder(),
                      //     focusedBorder: UnderlineInputBorder(),
                      //   ),
                      // ),
                      // SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tipe Menu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        readOnly: true,
                        controller: tipeMenu,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () async{
                                _showCuisineDialog();
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: CustomSize.sizeWidth(context) / 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: CustomColor.accent, width: 1),
                                      // color: CustomColor.accentLight
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: CustomText.textTitle8(
                                            text: "Ganti",
                                            color: CustomColor.accent,
                                            sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Deskripsi", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.005,
                      ),
                      TextField(
                        controller: deskMenu,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        style: GoogleFonts.poppins(
                            textStyle:
                            TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600)),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(bottom: CustomSize.sizeHeight(context) / 86),
                          hintStyle: GoogleFonts.poppins(
                              textStyle:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                          helperStyle: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 14)),
                          enabledBorder: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: CustomSize.sizeHeight(context) / 48,),
                      CustomText.bodyLight12(text: "Tambahkan Foto Menu", sizeNew: double.parse(((MediaQuery.of(context).size.width*0.03).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.03)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.03)).toString())),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.015,
                      ),
                      GestureDetector(
                        onTap: () async{
                          getImage();
                        },
                        child: Row(
                          children: [
                            (image == null)?Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 3.2,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(Links.subUrl + detailMenu.urlImg),
                                    fit: BoxFit.cover
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ),
                            ):Container(
                              height: CustomSize.sizeHeight(context) / 6.5,
                              width: CustomSize.sizeWidth(context) / 3.2,
                              decoration: (image==null)?(img == "/".substring(0, 1))?BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ):BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ): BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                                image: new DecorationImage(
                                    image: new FileImage(image!),
                                    fit: BoxFit.cover
                                ),
                              ),
                              child: (img == "/".substring(0, 1))?Center(
                                child: CustomText.text(
                                    size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                    weight: FontWeight.w800,
                                    text: initial,
                                    color: Colors.white
                                ),
                              ):Padding(
                                padding: const EdgeInsets.only(left: 1.5),
                                child: Center(
                                  child: (image == null)?CustomText.text(
                                      size: double.parse(((MediaQuery.of(context).size.width*0.094).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.094)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.094)).toString()),
                                      weight: FontWeight.w800,
                                      text: initial,
                                      color: Colors.white
                                  ):Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: CustomSize.sizeHeight(context) * 0.0150,
                      ),
                      //------------------------------------ checkbox favorite -------------------------------------
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: favorite,
                            onChanged: (bool? value) {
                              setState(() {
                                favorite = value!;
                                print(favorite);
                              });
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.bodyMedium14(
                                  text: "Apakah Menu ini adalah menu",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                  maxLines: 1
                              ),
                              CustomText.bodyMedium14(
                                  text: "andalan di restomu ?",
                                  sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString()),
                                  maxLines: 1
                              ),
                            ],
                          ),
                          // Text(' ', style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 8,),
              ],
            ),
          ),
        ),
        floatingActionButton:
        Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async{
                  if (is_available == '1') {
                    is_available = '0';
                    Fluttertoast.showToast(msg: 'Sekarang menu tidak tersedia.');
                  } else if (is_available == '0'){
                    is_available = '1';
                    Fluttertoast.showToast(msg: 'Sekarang menu tersedia.');
                  }
                  setState(() {});
                  // _editMenu();
                  // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivityResto()));
                  // SharedPreferences pref = await SharedPreferences.getInstance();
                  // pref.setString("name", namaMenu.text.toString());
                  // pref.setString("email", hargaDeliv.text.toString());
                  // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
                  // pref.setString("gender", gender);
                  // pref.setString("tgl", tgl);
                  // pref.setString("notelp", hargaMenu.text.toString());
                  print(favorite);
                },
                child: Container(
                  width: CustomSize.sizeWidth(context) / 1.1,
                  height: CustomSize.sizeHeight(context) / 14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: (is_available != '1')?Colors.blue:CustomColor.redBtn
                  ),
                  child: Center(child: CustomText.bodyRegular16(text: (is_available != '1')?"Menu tersedia.":'Menu tidak tersedia.', color: Colors.white, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
                ),
              ),
              SizedBox(height: CustomSize.sizeHeight(context) * 0.0025,),
              (isLoading != true)?GestureDetector(
                onTap: () async{
                  setState(() {
                    isLoading = false;
                  });
                  _editMenu();
                  // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivityResto()));
                  // SharedPreferences pref = await SharedPreferences.getInstance();
                  // pref.setString("name", namaMenu.text.toString());
                  // pref.setString("email", hargaDeliv.text.toString());
                  // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
                  // pref.setString("gender", gender);
                  // pref.setString("tgl", tgl);
                  // pref.setString("notelp", hargaMenu.text.toString());
                  print(favorite);
                },
                child: Container(
                  width: CustomSize.sizeWidth(context) / 1.1,
                  height: CustomSize.sizeHeight(context) / 14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomColor.accent
                  ),
                  child: Center(child: CustomText.bodyRegular16(text: "Simpan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()))),
                ),
              ):Container(
                width: CustomSize.sizeWidth(context) / 1.1,
                height: CustomSize.sizeHeight(context) / 14,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: CustomColor.accent
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ]
        )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
