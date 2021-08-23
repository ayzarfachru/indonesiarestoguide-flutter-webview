import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  File imageFile;
  final picker = ImagePicker();
  String imageUrl;
  bool isLoading = true;

  void launcherUrl(String url)async{
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'error';
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    setState(() {
      isLoading = true;
    });
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() async{
        messageController.clear();
        await _firestore.collection("room")
            .document(chatRoom)
            .collection('messages').add({
          'type': "1",
          'text': "",
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

  @override
  Widget build(BuildContext context) {

    Future<void> callback() async {
      String txt;
      if (messageController.text.length > 0) {
        txt = messageController.text;
        messageController.clear();
        await _firestore.collection("room")
            .document(chatRoom)
            .collection('messages').add({
          'type': "0",
          'text': txt,
          'img': "",
          'from': userName,
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

      setState(() {
        imageFile = File(pickedFile.path);
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 4,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
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
              child: Text('*In the delivery method, all your transactions are outside the responsibility of IRG',
                style: TextStyle(color: CustomColor.primary, fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20,),
            (isLoading != false)?Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("room")
                    .document(chatRoom)
                    .collection('messages')
                    .orderBy('date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  List<Widget> messages = docs
                      .map((doc) => Message(
                    type: doc.get('type'),
                    from: doc.get('from'),
                    text: doc.get('text'),
                    img: doc.get('img'),
                    me: userName == doc.get('from'),
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
            (status != "Menunggu")?Padding(
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
                      callback: callback,
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

  const Message({Key key, this.type, this.from, this.text, this.img, this.me, this.date}) : super(key: key);

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

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
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

