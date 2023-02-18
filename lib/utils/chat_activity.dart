import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/home/home_activity.dart';
import 'package:kam5ia/ui/ui_resto/order/order_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ChatActivity extends StatefulWidget {
  String chatRoom;
  String userName;
  String status;

  ChatActivity(this.chatRoom, this.userName, this.status);

  @override
  _ChatActivityState createState() => _ChatActivityState(chatRoom, userName, status);
}

class _ChatActivityState extends State<ChatActivity> {
  String chatRoom;
  String userName;
  String status;

  _ChatActivityState(this.chatRoom, this.userName, this.status);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  File? imageFile;
  final picker = ImagePicker();
  String? imageUrl;
  bool isLoading = true;

  void launcherUrl(String url)async{
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'error';
    }
  }

  final _formKey = GlobalKey<FormState>();

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    setState(() {
      isLoading = true;
    });
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() async{
        messageController.clear();
        await _firestore.collection("room")
            .doc(chatRoom)
            .collection('messages').add({
          'type': "1",
          'text': "",
          'from': email,
          'img': imageUrl,
          'date': DateTime.now().toIso8601String().toString(),
        });
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });
    }, onError: (err) {
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  // DateTime? currentBackPressTime;
  // Future<bool> onWillPop() async{
  //   DateTime now = DateTime.now();
  //   if (currentBackPressTime == null ||
  //       now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  //     currentBackPressTime = now;
  //     countChat();
  //     Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
  //     return Future.value(false);
  //   }
  //   // SystemNavigator.pop();
  //   // SharedPreferences pref = await SharedPreferences.getInstance();
  //   // pref.setString("homepg", "");
  //   // pref.setString("idresto", "");
  //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivityResto()));
  //   return Future.value(true);
  // }

  String timeNow = '';
  String total = '';
  Future<void> countChat()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/chat'),
        body: {
          'amount': totalChat.toString(),
          'type': 'user',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('apiResult.body');
    print(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> countChat2()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/chat'),
        body: {
          'amount': totalChat.toString(),
          'type': 'resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);
    print('apiResult.body2');
    print(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> countChat3()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/reservation/chat'),
        body: {
          'amount': totalChat.toString(),
          'type': 'user',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> countChat4()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    print(totalChat.toString());
    print(idnyatrans.toString());
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/reservation/chat'),
        body: {
          'amount': totalChat.toString(),
          'type': 'resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    print('TOKREV '+rev.toString());
    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  // String timeNow = '';
  // String total = '';
  Future<void> delCountChatUser()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/chat'),
        body: {
          'amount': '0',
          'type': (homepg != "1")?'chat_user':'chat_resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> delCountChatResto()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/trans/chat'),
        body: {
          'amount': '0',
          'type': 'resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> delCountChatUser2()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/reservation/chat'),
        body: {
          'amount': '0',
          'type': (homepg != "1")?'chat_user':'chat_resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  Future<void> delCountChatResto2()async{
    // List<Schedule> _schedule = [];
    setState(() {
      // isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var apiResult = await http.post(Uri.parse(Links.mainUrl + '/reservation/chat'),
        body: {
          'amount': '0',
          'type': 'resto',
          'id': idnyatrans
        },
        headers: {
          "Accept": "Application/json",
          "Authorization": "Bearer $token"
        });
    // print(apiResult.body);
    var data = json.decode(apiResult.body);

    if(data['status_code'] == 200){
      print("success");
      print(data["status"]);
      // Navigator.pushReplacement(
      //     context,
      //     PageTransition(
      //         type: PageTransitionType.fade,
      //         child: HomeActivityResto()));
    } else {
      print(data);
    }
    setState(() {
      // schedule = _schedule;
      // isLoading = false;
    });
  }

  String homepg = "";
  String email = "";
  String rev = "";
  String idnyatrans = "";
  getHomePg() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString("timeLog", DateTime.now().toString().toString().split('-')[2].replaceAll('.', '').replaceAll(':', '').replaceAll('T', '')).toString();
      timeNow = (pref.getString('timeLog')??'');
      homepg = (pref.getString('homepg')??'');
      email = (pref.getString('email')??'');
      print('homepg '+email);
      rev = (pref.getString('rev')??'');
      idnyatrans = (pref.getString('idnyatrans')??'');
      print(homepg);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    totalChat = 0;
    getHomePg().whenComplete((){
      if (rev == '0') {
        if (homepg != '1') {
          delCountChatResto();
        } else {
          delCountChatUser();
        }
      } else {
        if (homepg != '1') {
          delCountChatResto2();
        } else {
          delCountChatUser2();
        }
      }
      print('TOKREV '+rev.toString());
    });
    super.initState();
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      // countChat();
      Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
      return Future.value(false);
    }
//    SystemNavigator.pop();
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("homepg", "");
//     pref.setString("idresto", "");
    String inDetail = '';
    SharedPreferences pref = await SharedPreferences.getInstance();
    inDetail = pref.getString('inDetail')??'';
    if (inDetail == '1') {
      Navigator.pop(context);
    } else if (inDetail == '2') {
      Navigator.pop(context);
    } else if (inDetail == '3') {
      Navigator.pop(context);
    } else {
      (homepg != '1')?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity())):Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: HomeActivityResto()));
    }
    return Future.value(true);
  }


  int totalChat = 0;
  @override
  Widget build(BuildContext context) {

    Future<void> callback() async {
      String txt;
      totalChat = totalChat+1;
      if (rev == '0') {
        if (homepg != '1') {
          countChat();
        } else {
          countChat2();
        }
      } else {
        if (homepg != '1') {
          countChat3();
        } else {
          countChat4();
        }
      }
      print(totalChat);
      if (messageController.text.length > 0) {
        txt = messageController.text;
        messageController.clear();
        await _firestore.collection("room")
            .doc(chatRoom)
            .collection('messages').add({
          'type': "0",
          'text': txt,
          'img': "",
          'from': email,
          'date': DateTime.now().toIso8601String().toString(),
        });
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    Future getImage() async {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (rev == '0') {
        if (homepg != '1') {
          countChat();
        } else {
          countChat2();
        }
      } else {
        if (homepg != '1') {
          countChat3();
        } else {
          countChat4();
        }
      }
      setState(() {
        imageFile = File(pickedFile!.path);
        isLoading = false;
        Fluttertoast.showToast(
            msg: "Wait for a moment",
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0
        );
      });

      uploadFile();
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () async{
                      print('homepg '+homepg);
                      String inDetail = '';
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      inDetail = pref.getString('inDetail')??'';
                      if (inDetail == '1') {
                        Navigator.pop(context);
                      } else if (inDetail == '2') {
                        Navigator.pop(context);
                      } else if (inDetail == '3') {
                        Navigator.pop(context);
                      } else {
                        (homepg != '1')?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeActivity())):Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: HomeActivityResto()));
                      }
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Container(
              //       margin: EdgeInsets.only(top: 10),
              //       decoration: BoxDecoration(
              //         gradient: LinearGradient(
              //             colors: [Colors.greenAccent[200], Colors.green[500]],
              //             end: Alignment.bottomRight
              //         ),
              //         borderRadius: BorderRadius.circular(10.0),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.5),
              //             spreadRadius: 2,
              //             blurRadius: 7,
              //             offset: Offset(0, 2), // changes position of shadow
              //           ),
              //         ],
              //       ),
              //       child: Material(
              //         borderRadius: BorderRadius.circular(10.0),
              //         color: Colors.transparent,
              //         child: InkWell(
              //           onTap: ()async{
              //
              //           },
              //           splashColor: Colors.green,
              //           borderRadius: BorderRadius.circular(10.0),
              //           child: Center(
              //             child: Padding(
              //               padding: EdgeInsets.symmetric(
              //                   horizontal: 22.0, vertical: 6.0),
              //               child: Text("Check order menus",
              //                   style: TextStyle(color: Colors.white, fontSize: 18)),
              //             ),
              //           ),
              //         ),
              //       )
              //   ),
              // ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('*Segala metode pembayaran dan semua transaksi Anda di luar tanggung jawab IRG',
                  style: TextStyle(color: CustomColor.primary, fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 20,),
              (isLoading != false)?Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection("room")
                      .doc(chatRoom)
                      .collection('messages')
                      .orderBy('date')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                    List<DocumentSnapshot> docs = snapshot.data!.docs;

                    // total =
                    // String where = '';
                    // List<String> B = [];
                    // B = json.decode('['+(docs.map((doc) => doc.get('date')).toString().split('-')[2].split('.')[0].replaceAll(':', '').replaceAll('T', ''))+']');
                    // where = B.where((element) => element > timeNow).toString();
                    // print('oy ap '+(docs.map((doc) => doc.get('date'))).toString());
                    // print('oy ap '+(docs.map((doc) => doc.get('date'))).toString().split('-')[2].split('.')[0].replaceAll(':', '').replaceAll('T', ''));
                    // print('oy ap2 '+(docs.map((doc) => doc.get('from'))).toString());
                    List<Widget> messages = docs
                        .map((doc) => Message(
                      type: doc.get('type'),
                      from: doc.get('from'),
                      text: doc.get('text'),
                      img: doc.get('img'),
                      me: email == doc.get('from'),
                      date: doc.get('date'),
                    ))
                        .toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        controller: scrollController,
                        children: <Widget>[
                          ...messages,
                          SizedBox(height: 10,)
                        ],
                      ),
                    );
                  },
                ),
              ) : Expanded(
                child: Container(child: Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(CustomColor.primary),
                ))),
              ),
              // (status != "Menunggu")?
              (status != "")?Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: getImage,
                      ),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) => callback(),
                          decoration: InputDecoration(
                            hintText: "Enter a Message...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                          ),
                          controller: messageController,
                        ),
                      ),
                      SendButton(
                        text: "Send",
                        callback: callback, key: _formKey,
                      )
                    ],
                  ),
                ),
              ) : Container(
                  decoration: BoxDecoration(
                      color: Color(0xffff9234)
                  ),
                  child: Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Wait confirmation from the restaurant", style: TextStyle(color: Colors.white),),
                  ))
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  final String type;
  final String from;
  final String text;
  final String img;
  final String date;

  final bool me;

  const Message({key, required this.type, required this.from, required this.text, required this.img, required this.me, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (type != "1")?Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            color: me ? Color(0xff1cc97c) : Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
            elevation: 1.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: me ? Text(
                text, style: TextStyle(color: Colors.white),
              ) : Text(
                text,
              ),
            ),
          ),
          Text(date.substring(11,16)),
          SizedBox(height: 10,)
        ],
      ) : Column(
        crossAxisAlignment:
        me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              // Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: FullImage(img)));
            },
            child: FullScreenWidget(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                    )
                ),
              ),
            ),
          ),
          Text(date.substring(11,16)),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({required Key key, required this.text, required this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.black,
      onPressed: callback,
      icon: Icon(Icons.send),
      iconSize: 30,
      splashColor: Colors.white,
    );
  }
}

