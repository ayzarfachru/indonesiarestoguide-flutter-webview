import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/model/Menu.dart';
import 'package:kam5ia/ui/ui_resto/detail/detail_resto.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

import 'package:http/http.dart' as http;

class AddSlider extends StatefulWidget {
  String id;
  AddSlider(this.id);

  @override
  _AddSliderState createState() => _AddSliderState(id);
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

class _AddSliderState extends State<AddSlider> {
  String id;
  _AddSliderState(this.id);

  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

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

  bool isLoading = true;

  bool favorite = false;
  bool reservation = false;
  bool delivery = false;

  List<String> typeList = [];

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
                    getTipeMenu();
                  });
                  Navigator.of(context).pop();
                },
                // => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  getTipeMenu() async {
    tipeMenu = TextEditingController(text: tipe);
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


  List<Menu> menu = [];
  Future<void> AddSlider()async{
    List<Menu> _menu = [];

    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/resto/img'),
        body: {
          'resto': id,
          'img': 'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString(),
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(json.encode({
        'resto': id,
        'img': 'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString(),
      }));
      Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: DetailRestoAdmin(id)));
    } else {
      // print(data);
      print(json.encode({
        'resto': id,
        'img': 'data:image/$extension;base64,'+base64Encode(image!.readAsBytesSync()).toString(),
      }));
    }
    setState(() {
      menu = _menu;
      isLoading = false;
    });
  }

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
  }

  int load = 0;
  void animateButton() {
    setState(() {
      load = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        load = 2;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print(id);
    getInitial();
    getType();
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
                            text: "Tambah Foto Resto",
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
                      GestureDetector(
                        onTap: () async{
                          getImage();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (image == null)?Container(
                              height: CustomSize.sizeHeight(context) / 4.5,
                              width: CustomSize.sizeWidth(context) / 2.2,
                              child: Icon(FontAwesome.plus, color: CustomColor.primaryLight, size: 50,),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CustomColor.primaryLight,
                                    width: 3.0
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0) //         <--- border radius here
                                ),
                              ),
                            ):Container(
                              height: CustomSize.sizeHeight(context) / 4.5,
                              width: CustomSize.sizeWidth(context) / 2.2,
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
                    ],
                  ),
                ),
                SizedBox(height: CustomSize.sizeHeight(context) / 8,),
              ],
            ),
          ),
        ),
        floatingActionButton:
        GestureDetector(
          onTap: () async{
            setState(() {
              isLoading = false;
            });
            // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: new HomeActivityResto()));
            // SharedPreferences pref = await SharedPreferences.getInstance();
            // pref.setString("name", namaMenu.text.toString());
            // pref.setString("email", hargaDeliv.text.toString());
            // pref.setString("img", (image == null)?img:base64Encode(image.readAsBytesSync()).toString());
            // pref.setString("gender", gender);
            // pref.setString("tgl", tgl);
            // pref.setString("notelp", hargaMenu.text.toString());
            // print(namaMenu);
            // print(hargaMenu);
            // print(hargaDeliv);
            // print(tipeMenu);
            // print(deskMenu);
            // print(base64Encode(image.readAsBytesSync()).toString());
            // print(favorite);
            AddSlider();
            animateButton();
          },
          child: Container(
            width: CustomSize.sizeWidth(context) / 1.1,
            height: CustomSize.sizeHeight(context) / 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: CustomColor.accent
            ),
            child: Center(child: (load == 0)?CustomText.bodyRegular16(text: "Simpan", color: Colors.white, sizeNew: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )),
          ),
        ),
      ),
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    );
  }
}
