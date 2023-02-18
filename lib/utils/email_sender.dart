import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kam5ia/ui/home/home_activity.dart';
import 'package:kam5ia/ui/profile/profile_activity.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EmailSender extends StatefulWidget {
  const EmailSender({Key? key}) : super(key: key);

  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  List<String> attachments = [];
  bool isHTML = false;

  final _recipientController = TextEditingController(
    text: 'imaji.cipta@gmail.com',
  );

  final _subjectController = TextEditingController(text: 'Klaim Hadiah Ngupon Yuk!');

  var _bodyController = TextEditingController(text: '');
  ScrollController _scrollController = ScrollController();

  void Mailer() async {
    String myEmail = '';
    String myName = '';
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      myEmail = (pref.getString('email')??'');
      myName = (pref.getString('name')??'');
      print(myEmail);
    });

    String username = 'sender.imajicipta@gmail.com';
    String password = 'ewjdxowvqqkdaxko';
    // String password = 'imajiciptasurabaya70';
    print(username);
    print(password);

    final smtpServer = gmail(username, password);

    //Create our Message
    Fluttertoast.showToast(msg: 'Tunggu sebentar!');
    final message = Message()
      ..from = Address(username, myEmail)
      ..recipients.add('imaji.cipta@gmail.com')
    // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    // ..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Klaim Hadiah Ngupon Yuk!'
      ..text = _bodyController.text.toString();
    var yourHtmlTemplate= _bodyController.text.toString();
    message.html = yourHtmlTemplate;


    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      Fluttertoast.showToast(msg: 'Pengajuan klaim hadiah terkirim');
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: new HomeActivity()));
    } on MailerException catch (e) {
      print(e);
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  // Future<void> send() async {
  //   final Email email = Email(
  //     body: _bodyController.text,
  //     subject: _subjectController.text,
  //     recipients: [_recipientController.text],
  //     attachmentPaths: attachments,
  //     isHTML: false,
  //   );
  //
  //   String platformResponse;
  //
  //   try {
  //     await FlutterEmailSender.send(email);
  //     platformResponse = 'success';
  //   } catch (error) {
  //     print(error);
  //     platformResponse = error.toString();
  //   }
  //
  //   if (!mounted) return;
  //
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   SnackBar(
  //   //     content: Text(platformResponse),
  //   //   ),
  //   // );
  // }

  String name = '';
  String email = '';
  String notelp = '';
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = (pref.getString('name')??'');
      print(name);
      email = (pref.getString('email')??'');
      print(email);
      notelp = (pref.getString('notelp')??"");
      print(notelp);
      _bodyController = TextEditingController(
        text: 'Nama: $name\nEmail: $email\nNo.Telp: $notelp\nNo.Rek: \nVoucher resto yang anda pilih: ',
      );
      // gender = (pref.getString('gender'));
      // print(gender);
      // tgl = (pref.getString('tgl'));
      // print(tgl);
    });
  }

  getRes(String rest) async {
    setState(() {
      _bodyController = TextEditingController(
        text: _bodyController.text.split('Voucher resto yang anda pilih: ')[0]+'Voucher resto yang anda pilih: $rest',
      );
      print(restoNgupon);
      // gender = (pref.getString('gender'));
      // print(gender);
      // tgl = (pref.getString('tgl'));
      // print(tgl);
    });
  }

  String restoNgupon = '';
  List<String> nguponYuk = [];
  Future<void> getResto() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token") ?? "";
    var data = await http.get(Uri.parse(Links.nguponUrl +'/resto'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    var jsonData = jsonDecode(data.body);
    print(jsonData);

    for(var v in jsonData['data']['data']){
      nguponYuk.add(v['name']);
    }
    setState(() {});
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    // TODO: implement initState
    getPref();
    getResto();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: Text('Form Klaim Hadiah'),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              _bodyController = TextEditingController(
                text: _bodyController.text.split('Voucher resto yang anda pilih: ')[0]+'Voucher resto yang anda pilih: $restoNgupon',
              );
              if (restoNgupon != '') {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        contentPadding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        title: Center(child: Text('Peringatan!', style: TextStyle(color: CustomColor.primary))),
                        content: Text('Apakah sudah yakin dengan data anda?', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        // '\n \nSemua proses pembayaran dan transaksi di luar tanggung jawab IRG!', style: TextStyle(fontSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        actions: <Widget>[
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [

                                TextButton(
                                  // minWidth: CustomSize.sizeWidth(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: CustomColor.redBtn,
                                    padding: EdgeInsets.all(0),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                  ),
                                  child: Text('Batal', style: TextStyle(color: Colors.white)),
                                  onPressed: () async{
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  // minWidth: CustomSize.sizeWidth(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: CustomColor.accent,
                                    padding: EdgeInsets.all(0),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                  ),
                                  child: Text('Iya', style: TextStyle(color: Colors.white)),
                                  onPressed: () async{
                                    // send();
                                    Navigator.pop(context);
                                    Mailer();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),

                        ],
                      );
                    });
              } else {
                Fluttertoast.showToast(msg: 'Tentukan resto yang anda inginkan terlebih dahulu!');
              }
              setState(() {});
            },
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                readOnly: true,
                controller: _recipientController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                readOnly: true,
                controller: _subjectController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Subject',
                ),
              ),
            ),
            (nguponYuk.toString() != '[]')?Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: ()async{
                  // Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          title: Text('Ngupon Yuk Resto', style: TextStyle(color: CustomColor.primary)),
                          content: Container(
                            height: CustomSize.sizeHeight(context) / 2.2,
                            width: CustomSize.sizeWidth(context) / 1.1,
                            child: ListView.builder(
                                shrinkWrap: true,
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                itemCount: nguponYuk.length,
                                itemBuilder: (_, index){
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 22, vertical: CustomSize.sizeHeight(context) * 0.0075),
                                    child: GestureDetector(
                                      onTap: () async{
                                        restoNgupon = nguponYuk[index].toString();
                                        getRes(nguponYuk[index].toString());
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                      child: Container(
                                        // width: CustomSize.sizeWidth(context),
                                        // height: CustomSize.sizeHeight(context) / 7.5,
                                        color: Colors.white,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: CustomSize.sizeWidth(context) / 2.5,
                                                  // width: CustomSize.sizeWidth(context) / 1.6,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CustomText.textHeading4(
                                                          text: nguponYuk[index],
                                                          maxLines: 2,
                                                          minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())
                                                      ),

                                                      // CustomText.bodyLight16(text: user[index].email, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())),
                                                      // (user[index].notelp != null)?CustomText.bodyLight16(text: user[index].notelp, maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString())):CustomText.bodyLight16(text: 'Belum diisi.', maxLines: 1, minSize: double.parse(((MediaQuery.of(context).size.width*0.04).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.04)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.04)).toString()), color: CustomColor.redBtn),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                restoNgupon = nguponYuk[index].toString();
                                                getRes(nguponYuk[index].toString());
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: Container(
                                                height: CustomSize.sizeHeight(context) / 32,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: CustomColor.accent)
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 48),
                                                  child: Center(
                                                    child: CustomText.textTitle8(
                                                        text: "Pilih",
                                                        color: CustomColor.accent,
                                                        sizeNew: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ),
                        );
                      });

                },
                child: Container(
                  height: CustomSize.sizeHeight(context) / 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CustomSize.sizeWidth(context) / 32),
                    child: Center(
                      child: CustomText.textTitle8(
                          text: "Pilih resto yang anda inginkan",
                          color: Colors.grey,
                          minSize: double.parse(((MediaQuery.of(context).size.width*0.035).toString().contains('.')==true)?((MediaQuery.of(context).size.width*0.035)).toString().split('.')[0]:((MediaQuery.of(context).size.width*0.035)).toString())
                      ),
                    ),
                  ),
                ),
              ),
            ):Container(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      labelText: 'Body', border: OutlineInputBorder()),
                ),
              ),
            ),
            // CheckboxListTile(
            //   contentPadding:
            //   EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            //   title: Text('HTML'),
            //   onChanged: (bool? value) {
            //     if (value != null) {
            //       setState(() {
            //         isHTML = value;
            //       });
            //     }
            //   },
            //   value: isHTML,
            // ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Column(
            //     children: <Widget>[
            //       // for (var i = 0; i < attachments.length; i++)
            //         // Row(
            //         //   children: <Widget>[
            //         //     Expanded(
            //         //       child: Text(
            //         //         attachments[i],
            //         //         softWrap: false,
            //         //         overflow: TextOverflow.fade,
            //         //       ),
            //         //     ),
            //         //     IconButton(
            //         //       icon: Icon(Icons.remove_circle),
            //         //       onPressed: () => {_removeAttachment(i)},
            //         //     )
            //         //   ],
            //         // ),
            //       // Align(
            //       //   alignment: Alignment.centerRight,
            //       //   child: IconButton(
            //       //     icon: Icon(Icons.attach_file),
            //       //     onPressed: _openImagePicker,
            //       //   ),
            //       // ),
            //       TextButton(
            //         child: Text('Attach file in app documents directory'),
            //         onPressed: () => _attachFileFromAppDocumentsDirectoy(),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _openImagePicker() async {
    final picker = ImagePicker();
    PickedFile? pick = await picker.getImage(source: ImageSource.gallery);
    if (pick != null) {
      setState(() {
        attachments.add(pick.path);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<void> _attachFileFromAppDocumentsDirectoy() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path + '/file.txt';
      final file = File(filePath);
      await file.writeAsString('Text file in app directory');

      setState(() {
        attachments.add(filePath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create file in applicion directory'),
        ),
      );
    }
  }
}