import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/model/Category.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/model/Price.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_detail_resto.dart';
import 'package:kam5ia/ui/ui_resto/add_resto/add_view_resto.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/menu_activity.dart';
import 'package:kam5ia/ui/ui_resto/menu/sub_kategori/sub_kategori.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class EditSubKategori extends StatefulWidget {
  Category detailCategory;

  EditSubKategori(this.detailCategory);

  @override
  _EditSubKategoriState createState() => _EditSubKategoriState(detailCategory);
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

class _EditSubKategoriState extends State<EditSubKategori> {
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  Category detailCategory;

  _EditSubKategoriState(this.detailCategory);


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
              TextButton(
                child: Text("Simpan", style: TextStyle(color: CustomColor.accent),),
                onPressed: () async{
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString("tipeMenu", tipe.toString());
                  setState(() {
                    print(tipe);
                    // getNewTipeMenu();
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
    namaMenu = TextEditingController(text: detailCategory.nama);
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
  Future<void> _editSubKat()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.put(Uri.parse(Links.mainUrl + '/category/$id'),
        body: {
          'name': namaMenu.text,
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(apiResult.statusCode == 200){
      print("success");
      Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new SubKategoriActivity()));
      print(json.encode({
        'name': namaMenu.text,
      }));
    } else {
      print(data);
      print(json.encode({
        'name': namaMenu.text,
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
    setState(() {
      id = detailCategory.id.toString();
      // is_available = detailCategory.is_available.toString();
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
                              text: "Edit Sub Kategori",
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
                      ],
                    ),
                  ),
                  SizedBox(height: CustomSize.sizeHeight(context) / 8,),
                ],
              ),
            ),
          ),
          floatingActionButton:
          (isLoading != true)?GestureDetector(
            onTap: () async{
              setState(() {
                isLoading = false;
              });
              _editSubKat();
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
          )
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
