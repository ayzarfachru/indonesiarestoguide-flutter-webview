import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:kam5ia/permissionLocation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartIo;
import 'package:http/http.dart' as http;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/maintenance.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WebViewActivity extends StatefulWidget {
  String? codeNotif;
  String? url;

  WebViewActivity({Key? key, @required this.codeNotif, @required this.url})
      : super(key: key);

  @override
  State<WebViewActivity> createState() => _WebViewActivityState();
}

class _WebViewActivityState extends State<WebViewActivity>
    with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  PullToRefreshController? pullToRefreshController;

  String mainUrl = 'https://m.indonesiarestoguide.id';

  // String mainUrl = 'http://192.168.43.184:8080';
  bool notifOrder = false;
  String url = "";
  String link = "";

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<String> createDynamicLink(String urlLink) async {
    var parameters = DynamicLinkParameters(
      uriPrefix: 'https://irgresto.page.link',
      link: Uri.parse('https://irgresto.page.link/open/?url=$urlLink'),
      androidParameters: AndroidParameters(
        packageName: "com.devus.indonesiarestoguide",
      ),
      iosParameters: IOSParameters(
        bundleId: "com.devus.indonesiarestoguide",
      ),
    );
    var shortLink = await dynamicLinks.buildShortLink(parameters);
    var shortUrl = shortLink.shortUrl;
    print(shortUrl.toString());

    link = shortUrl.toString();
    setState(() {});

    return shortUrl.toString();
  }

  // Future initDynamicLinks() async {
  //   final PendingDynamicLinkData? data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //
  //   print('dylink1');
  //   if (data != null) {
  //     print(data.link);
  //   }
  //   FirebaseDynamicLinks.instance.onLink
  //       .listen((PendingDynamicLinkData dynamicLink) async {
  //     print('dylink2');
  //     print(dynamicLink.link.queryParameters["url"]);
  //     _webViewController!.loadUrl(
  //         urlRequest: URLRequest(
  //             url: Uri.parse(
  //                 dynamicLink.link.queryParameters["url"].toString())));
  //   });
  // }

  String dataLink = '';

  Future initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    print('dylink1');
    print(data?.link);
    if (data != null) {
      // dataLink = data.link.toString();
      print(data.link);
      if (widget.url.toString().contains('resto-detail')) {
        _webViewController!.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(widget.url.toString())));
      }
      // print(dataLink.split('open')[1].toString());
      // print(dataLink.split('open/?url=')[1].toString());
      // if (dataLink.toString().contains('resto-detail')) {
      //   _webViewController!.loadUrl(
      //       urlRequest: URLRequest(
      //           url: Uri.parse(
      //               dataLink.split('open/?url=')[1].toString())));
      // }
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      print('getDynamicLink');
      print(dynamicLink.link.toString());
      if (dynamicLink.link.hasQuery) {
        if (dynamicLink.link.toString().contains('resto-detail')) {
          if (dynamicLink.link.toString().contains("/?qr")) {
            handleTableLink(
                    (dynamicLink.link.toString().contains('resto-detail/'))
                        ? dynamicLink.link.toString()
                        : dynamicLink.link
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/'))
                .whenComplete(() {
              _webViewController!.loadUrl(
                  urlRequest: URLRequest(
                      url: Uri.parse((dynamicLink.link.queryParameters["url"]
                              .toString()
                              .contains('resto-detail/'))
                          ? dynamicLink.link.queryParameters["url"].toString()
                          : dynamicLink.link.queryParameters["url"]
                              .toString()
                              .replaceAll('resto-detail', 'resto-detail/'))));
            });
          } else {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: Uri.parse((dynamicLink.link.queryParameters["url"]
                            .toString()
                            .contains('resto-detail/'))
                        ? dynamicLink.link.queryParameters["url"].toString()
                        : dynamicLink.link.queryParameters["url"]
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/'))));
          }
        } else {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        }
      } else {
        _webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
      }
    });
  }


  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;
  StreamSubscription? _streamSubscription;
  bool _initialURILinkHandled = false;
  String urlDeepLinks = '';

  void _incomingLinkHandler() {
    if (!kIsWeb) {
      // 2
      _streamSubscription = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) {
          return;
        }
        // uri = Uri.parse('irg://indonesiarestoguide.id/?url=https://m.indonesiarestoguide.id/resto-detail/36?qr=ca4deab5-ceda-40a9-b888-07d065097432');
        debugPrint('Received URI: $uri');
        print(uri?.queryParameters['qr']);
        print(uri?.queryParameters['url']);

        if (uri.toString().contains('url')) {
          if (uri.toString().contains('qr')) {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: Uri.parse((uri!.queryParameters['url']
                            .toString()
                            .contains('resto-detail/'))
                        ? uri.queryParameters['url'].toString()
                        : uri.queryParameters['url']
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/'))));
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString("table", uri.queryParameters['url'].toString().split('qr=')[1]);
          } else {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: Uri.parse((uri!.queryParameters['url']
                            .toString()
                            .contains('resto-detail/'))
                        ? uri.queryParameters['url'].toString()
                        : uri.queryParameters['url']
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/'))));
          }
        }
        print('Received URI: $uri');
        // setState(() {
        //   _currentURI = uri;
        //   _err = null;
        // });
        // 3
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        _webViewController!.loadUrl(
            urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        debugPrint('Error occurred: $err');
        setState(() {
          _currentURI = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }



  Future handleTableLink(String urlLink) async {
    var parameters = DynamicLinkParameters(
      uriPrefix: 'https://irgresto.page.link',
      link: Uri.parse(urlLink),
      androidParameters: AndroidParameters(
        packageName: "com.devus.indonesiarestoguide",
        fallbackUrl: Uri.parse("https://jiitu.co.id"),
      ),
      iosParameters: IOSParameters(
        bundleId: "com.devus.indonesiarestoguide",
        appStoreId: "6447268805",
      ),
    );
    var shortLink = await dynamicLinks.buildShortLink(parameters);
    var shortUrl = shortLink.shortUrl;

    print('table 2');
    print(urlLink);
    print(shortUrl);
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getDynamicLink(shortUrl);
    print(data);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("table", shortUrl.toString());
  }

  // Future<bool> _handleBackButton() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.setString("url_dylink", "");
  //   if (notifOrder) {
  //     return false;
  //   } else if (_webViewController != null &&
  //       await _webViewController!.canGoBack()) {
  //     _webViewController?.getUrl().then((value) {
  //       if (value.toString().contains("resto-detail")) {
  //         _webViewController!.loadUrl(
  //             urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
  //       } else if (value.toString() != '$mainUrl/resto' &&
  //           value.toString() != '$mainUrl/login' &&
  //           value.toString() != '$mainUrl/owner/resto-create') {
  //         _webViewController!.goBack();
  //       }
  //     });
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  DateTime? currentBackPressTime;

  Future<bool> _handleBackButton() async {
    _webViewController?.getUrl().then((value) {
      print(value.toString());
      if (value.toString() == '$mainUrl/resto' ||
          value.toString() == '$mainUrl/login') {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
          return Future.value(false);
        }
        // SystemNavigator.pop();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      } else if (value.toString() == '$mainUrl/owner/resto-create') {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
          return Future.value(false);
        }
        // SystemNavigator.pop();
        _webViewController!.loadUrl(
            urlRequest: URLRequest(url: Uri.parse('$mainUrl/profile/user')));
        return Future.value(true);
      } else if (value.toString().contains('resto-feature')) {
        _webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        return Future.value(true);
      } else if (value.toString().contains('resto-detail')) {
        _webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        return Future.value(true);
      } else if ((value.toString().contains('history') == true &&
          value.toString().contains('resto') == true)) {
        _webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        return Future.value(true);
      } else if (value.toString().contains('/owner/home')) {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk kembali');
          return Future.value(false);
        }
        _webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        return Future.value(true);
      } else if (value.toString().contains('/owner/transaction')) {
        if (value.toString().contains('/owner/transaction/') != true) {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(url: Uri.parse('$mainUrl/owner/home')));
          return Future.value(true);
        } else {
          _webViewController!.goBack();
          return Future.value(true);
        }
      } else {
        _webViewController!.goBack();
        return Future.value(true);
        // Fluttertoast.showToast(msg: 'Tekan sekali lagi untuk keluar');
      }
    });
    return false;
  }

  String qrcode = "";

  Future QRScanner() async {
    await BarcodeScanner.scan().then((value) {
      print(value.rawContent);
    });
  }

  Future idPlayer() async {
    await OneSignal.shared.getDeviceState().then((status) {
      print(playerId);
      setState(() {
        playerId = status?.userId;
      });
    });
  }

  String? playerId;

  Future<void> saveBase64Image(String name, String base64String) async {
    try {
      // Decode the Base64 string to bytes
      Uint8List bytes = base64.decode(base64String);

      // Create an Image object from the decoded bytes
      img.Image? image = img.decodeImage(bytes);

      // Get the application documents directory
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();

      print('name');
      print(name);

      // Define the file path where you want to save the image
      final filePath = '${appDocumentsDirectory.path}/$name';

      String newName = name.split('.')[0].replaceAll(' ', '_');

      // Encode the image to PNG format and save it to the file
      dartIo.File(filePath).writeAsBytesSync(img.encodePng(image!));

      // Display a message or perform any other action as needed
      print('Image saved to: $filePath');
      print(newName);

      // Save the image to the gallery
      final result = await ImageGallerySaver.saveFile(filePath,
          isReturnPathOfIOS: true, name: newName);

      if (result['isSuccess'] == true) {
        print('Image saved to gallery: ${result['filePath']}');
        Fluttertoast.showToast(
            msg:
                'Gambar ${name.split('.')[0].replaceAll('_', ' ')} tersimpan di galeri anda');
      } else {
        print('Failed to save image to gallery.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String doneCodeNotif = 'null';
  bool done = false;

  Future checkToken() async {
    String? token = await _webViewController
        ?.evaluateJavascript(source: '''localStorage.getItem('token');''');
    if (token != "" && token != "null") {
      var apiResult = await http.get(
          Uri.parse('https://jiitu.co.id/api/irg/v2/transaction/user-check'),
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      print(apiResult.body);
      if (apiResult.body.toString().contains('Unauthenticated') == false) {
        if (json.decode(apiResult.body)['transaction'] != false) {
          var data = json.decode(apiResult.body)['transaction']['id'];
          print(data);

          setState(() {
            widget.codeNotif = "IRG-" +
                data.toString().padLeft(5, '0') +
                " sudah siap diambil";
            notifOrder = true;
          });
        }
      }
    }
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // String token = pref.getString("token") ?? "";
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    idPlayer();
    initDynamicLinks();
    _incomingLinkHandler();
    // _initURIHandler();
    checkToken();
    // if (widget.codeNotif != "") {
    //   setState(() {
    //     notifOrder = true;
    //   });
    // }
    setState(() {
      if (widget.url == "") {
        url = '$mainUrl';
      } else {
        url = widget.url ?? '$mainUrl';
      }
    });
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('"OneSignal: notification opened: ' +
          result.notification.collapseId.toString());
      var res = result.notification.collapseId.toString();
      // print(result.notification.payload.collapseId);
      print('res onesignal');
      print(res);
      if (res.contains('home_user')) {
        if (res.split('home_')[1].split('_')[0] == 'user') {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url: Uri.parse(
                      '$mainUrl/resto-detail/' + res.split('home_user_')[1])));
        }
      } else if (res.contains('home_admin')) {
        if (res.split('home_')[1].split('_')[0] == 'admin') {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url: Uri.parse(
                      '$mainUrl/profile/user/?page=/redirectToTrasaction/' +
                          res.split('home_admin_')[1])));
        }
      }
    });

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(backgroundColor: CustomColor.primary),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          _webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          _webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('resumed');
      // initDynamicLinks();
      checkToken();
    }
    if (state == AppLifecycleState.inactive) {
      print('inactive');
    }
    if (state == AppLifecycleState.paused) {
      print('paused');
    }
    if (state == AppLifecycleState.detached) {
      print('detached');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onLongPress: () {},
            child: Stack(
              children: [
                InAppWebView(
                  pullToRefreshController: pullToRefreshController,
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        verticalScrollBarEnabled: false,
                        horizontalScrollBarEnabled: false,
                        supportZoom: false,
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        javaScriptEnabled: true,
                        useOnLoadResource: true,
                        cacheEnabled: true,
                        transparentBackground: true),
                    android: AndroidInAppWebViewOptions(
                      builtInZoomControls: false,
                      initialScale: 100,
                      useHybridComposition: true,
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                  },
                  androidOnGeolocationPermissionsShowPrompt:
                      (InAppWebViewController controller, String origin) async {
                    return GeolocationPermissionShowPromptResponse(
                        origin: origin, allow: true, retain: true);
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, progress) async {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }

                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool("is_first") != true) {
                      print('first_install');
                      String? token2 = await controller.evaluateJavascript(
                          source: '''localStorage.getItem('token');''');
                      print(token2);
                      controller.clearCache();
                      controller.evaluateJavascript(
                          source: "window.localStorage.clear();");
                      controller.webStorage.localStorage.clear();
                      pref.setBool("is_first", true);
                    }

                    String? token = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('token');''');
                    if (token == null || token == "") {
                      pref.remove("token");
                    }

                    controller.getUrl().then((value) async {
                      pref.setString("url", value.toString());
                      if (value.toString() == '$mainUrl/login') {
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('token');");
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('table');");
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('cart');");
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('cart-details');");
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('notes');");
                        // var is_ios = await controller.evaluateJavascript(
                        //     source: '''localStorage.getItem("is_ios");''');
                        // var device_id = await controller.evaluateJavascript(
                        //     source: '''localStorage.getItem("device_id");''');
                        // var latitude = await controller.evaluateJavascript(
                        //     source: '''localStorage.getItem("lat");''');
                        // var longitude = await controller.evaluateJavascript(
                        //     source: '''localStorage.getItem("long");''');
                        // var getIfHasLocation = await controller.evaluateJavascript(
                        //     source:
                        //         '''localStorage.getItem("activedPermissionLocation");''');
                        // controller.clearCache();
                        // controller.evaluateJavascript(
                        //     source: "window.localStorage.clear();");
                        // controller.webStorage.localStorage.clear();
                        // controller.evaluateJavascript(
                        //     source:
                        //         "window.localStorage.setItem('is_ios', '$is_ios');");
                        // print(is_ios);
                        // controller.evaluateJavascript(
                        //     source:
                        //         "window.localStorage.setItem('device_id', '$device_id');");
                        // print('login device_id ' + device_id.toString());
                        // controller.evaluateJavascript(
                        //     source:
                        //         "window.localStorage.setItem('lat', '$latitude');");
                        // print(latitude);
                        // controller.evaluateJavascript(
                        //     source:
                        //         "window.localStorage.setItem('long', '$longitude');");
                        // print(longitude);
                        // controller.evaluateJavascript(
                        //     source:
                        //         "window.localStorage.setItem('activedPermissionLocation', '$getIfHasLocation');");
                        // print(getIfHasLocation);
                      }
                    });

                    var new_device_id = await controller.evaluateJavascript(
                        source: '''localStorage.getItem("device_id");''');
                    print('always device_id ' + new_device_id.toString());

                    String tokenValue = await pref.getString("token") ?? "";
                    // print('uhuy');
                    // print(value);
                    // String? value = await controller.evaluateJavascript(
                    //     source: '''localStorage.getItem('token');''');

                    if (tokenValue == null || tokenValue == "") {
                      pref.remove("token");
                      Future.delayed(Duration(seconds: 3), () async {
                        String? secondValue = await controller
                            .evaluateJavascript(
                                source: '''localStorage.getItem('token');''');
                        if (secondValue != null && secondValue != "") {
                          setState(() {
                            if (done != true) {
                              setState(() {
                                done = true;
                              });
                              checkToken();
                            }
                          });
                        } else {
                          pref.remove("token");
                        }
                      });
                    }
                  },
                  onLoadStart: (InAppWebViewController controller, url) async {
                    // controller.clearCache();

                    // if (widget.codeNotif != "") {
                    //   setState(() {
                    //     notifOrder = true;
                    //   });
                    // }

                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setString("url", url.toString());

                    var tableShared = pref.getString("table") ?? "";

                    if (tableShared != "") {
                      await controller
                          .evaluateJavascript(
                              source:
                                  "window.localStorage.setItem('table', '$tableShared')")
                          .whenComplete(() {
                        pref.remove("table");
                      });
                    }

                    await controller.evaluateJavascript(
                        source:
                            "window.localStorage.setItem('device_id', '$playerId')");

                    String? value = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('token');''');

                    String? restoDetailID = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('resto-detail-id');''');

                    String urlDyLink = pref.getString("url_dylink") ?? "";

                    if (url == Uri.parse('$mainUrl/login-google')) {
                      GoogleSignIn _googleSignIn = GoogleSignIn(
                        clientId:
                            "839490096186-4ulavkeso7qrl384n3tmd55qmh4iot2o.apps.googleusercontent.com",
                        scopes: [
                          'email',
                          'https://www.googleapis.com/auth/userinfo.profile',
                        ],
                      );
                      _googleSignIn.signOut();
                      await _googleSignIn.signIn().then((value) async {
                        if (value == null) {
                          _webViewController!.loadUrl(
                              urlRequest:
                                  URLRequest(url: Uri.parse('$mainUrl/login')));
                        } else {
                          String email = value!.email;
                          String displayName = value.displayName.toString();
                          String photoUrl = value.photoUrl.toString();

                          await controller.evaluateJavascript(
                              source:
                                  "window.localStorage.setItem('email_google', '$email')");
                          await controller.evaluateJavascript(
                              source:
                                  "window.localStorage.setItem('name_google', '$displayName')");
                          await controller.evaluateJavascript(
                              source:
                                  "window.localStorage.setItem('photo_google', '$photoUrl')");

                          controller.goBack();
                        }
                      });
                    }

                    if (url == Uri.parse('$mainUrl')) {
                      if (value != null && value != "") {
                        if (urlDyLink.isNotEmpty) {
                          controller.loadUrl(
                              urlRequest:
                                  URLRequest(url: Uri.parse(urlDyLink)));
                        } else {
                          controller.loadUrl(
                              urlRequest:
                                  URLRequest(url: Uri.parse('$mainUrl/resto')));
                        }
                      }
                    }

                    if (url == Uri.parse('$mainUrl/about')) {
                      await controller.goBack().whenComplete(() async {
                        if (await canLaunch('https://indonesiarestoguide.id')) {
                          await launch('https://indonesiarestoguide.id');
                        } else {
                          throw 'Could not launch url';
                        }
                      });
                    }

                    if (url == Uri.parse('$mainUrl/feedback')) {
                      String? userLS = await controller.evaluateJavascript(
                          source: '''localStorage.getItem('user');''');
                      var user = json.decode(userLS!);
                      var email = user['email'];

                      await controller.goBack().whenComplete(() {
                        launch('mailto:info@indonesiarestoguide.id'+'?subject='+'Masukan dari akun IRG: '+email+'&body='+'Terimakasih telah menggunakan Indonesia Resto Guide, ada yang bisa kami bantu?%0D%0A%0D%0A');
                      });
                    }

                    if (url == Uri.parse('$mainUrl/share-resto')) {
                      await controller.goBack().whenComplete(() {
                        createDynamicLink(
                                '$mainUrl/resto-detail/' + restoDetailID!)
                            .whenComplete(() {
                          Share.share('Kunjungi Restaurant kami di ' + link);
                        });
                      });
                    }

                    if (url == Uri.parse('$mainUrl/barcode')) {
                      await Permission.camera.request();
                      await Permission.audio.request();
                      // QRScanner();
                      // if (await Permission.camera.request().isGranted) {
                      //   print('sudah bg');
                      //   showDialog(
                      //       context: context,
                      //       builder: (context) {
                      //         return AlertDialog(
                      //           contentPadding: EdgeInsets.only(
                      //               left: 25, right: 25, top: 15, bottom: 5),
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(10))),
                      //           title: Center(
                      //               child: Text('dah bg',
                      //                   style: TextStyle(color: Colors.blue))),
                      //         );
                      //       });
                      // }
                    }

                    if (url == Uri.parse('$mainUrl/scan')) {
                      await Permission.camera.request();
                      await Permission.audio.request();
                    }

                    if (url.toString().contains("open-jiitu")) {
                      await controller.goBack().whenComplete(() async {
                        if (await canLaunch('https://jiitu.co.id/')) {
                          await launch('https://jiitu.co.id/');
                        } else {
                          throw 'Could not launch url';
                        }
                      });
                    }

                    if (url.toString().contains("call-resto")) {
                      await controller.goBack().whenComplete(() {
                        String phone = url.toString().split('call-resto/')[1];
                        launch("tel:$phone");
                      });
                    }

                    if (url.toString() != '$mainUrl' &&
                        url.toString() != '$mainUrl/') {
                      if (url.toString().contains(mainUrl)) {
                        await Permission.location.status.isGranted
                            .then((value) async {
                          if (!value) {
                            CustomNavigator.navigatorPushReplacement(
                                context, new permissionLocation());
                          }
                        });
                        // new permissionLocation();
                      }
                    }

                    if (url.toString().contains(":tableName;")) {
                      await controller.goBack().whenComplete(() async {
                        Fluttertoast.showToast(msg: 'Tunggu sebentar');
                        String? dataQr = await controller.evaluateJavascript(
                            source: '''localStorage.getItem('dataQr');''');
                        print(dataQr!
                            .toString()
                            .split(':~;/')[0]
                            .replaceAll(' ', '_'));
                        saveBase64Image(
                            dataQr!
                                .toString()
                                .split(':~;/')[0]
                                .replaceAll(' ', '_'),
                            dataQr.toString().split(':~;/')[1]);
                      });
                    }

                    if (url.toString().contains("resto-detail")) {
                      pref.setString("url_dylink", "");
                    }
                  },
                  onLoadStop: (InAppWebViewController controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (url.toString().contains("resto-detail")) {
                      pref.setString("url_dylink", "");
                    }
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController?.endRefreshing();
                    if (message.isNotEmpty) {
                      CustomNavigator.navigatorPushReplacement(
                          context, new Maintenance());
                    }
                  },
                  onLoadHttpError: (controller, url, code, message) {
                    if (message.isNotEmpty) {
                      CustomNavigator.navigatorPushReplacement(
                          context, new Maintenance());
                    }
                  },
                  androidOnPermissionRequest:
                      (InAppWebViewController controller, String origin,
                          List<String> resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                ),
                (notifOrder)
                    ? Container(
                        height: CustomSize.sizeHeight(context),
                        width: CustomSize.sizeWidth(context),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(.5)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            Container(
                              height: 200,
                              width: CustomSize.sizeWidth(context),
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "assets/irgLogo.png"))),
                                            ),
                                            CustomText.text(
                                                textAlign: TextAlign.left,
                                                text: "  IRG",
                                                minSize: 14,
                                                weight: FontWeight.bold,
                                                color: CustomColor.primary),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: CustomColor.primary,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 20),
                                            child: CustomText.text(
                                                textAlign: TextAlign.center,
                                                text: "Detail",
                                                minSize: 14,
                                                weight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText.text(
                                                textAlign: TextAlign.left,
                                                text:
                                                    "Pesanan Anda Sudah Siap!",
                                                size: 12,
                                                weight: FontWeight.bold,
                                                color: Colors.black),
                                            CustomText.text(
                                                textAlign: TextAlign.left,
                                                text: "Silahkan mengambil",
                                                size: 12,
                                                weight: FontWeight.bold,
                                                color: Colors.black),
                                            CustomText.text(
                                                textAlign: TextAlign.left,
                                                text:
                                                    "pesanan Anda, Terima Kasih 🙏",
                                                size: 12,
                                                weight: FontWeight.bold,
                                                color: Colors.black),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: GestureDetector(
                                            onTap: () async {
                                              setState(() {
                                                notifOrder = false;
                                                doneCodeNotif =
                                                    widget.codeNotif.toString();
                                              });

                                              String idHistory = widget
                                                  .codeNotif
                                                  .toString()
                                                  .split(" sudah")[0]
                                                  .split("IRG-")[1];
                                              await _webViewController!
                                                  .evaluateJavascript(
                                                      source:
                                                          "window.localStorage.setItem('id_history', '$idHistory')");
                                              _webViewController!.loadUrl(
                                                  urlRequest: URLRequest(
                                                      url: Uri.parse(
                                                          '$mainUrl/history')));
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.check,
                                                  color: CustomColor.primary,
                                                  size: 28,
                                                ),
                                                CustomText.text(
                                                    textAlign: TextAlign.center,
                                                    text: "Terima",
                                                    minSize: 18,
                                                    weight: FontWeight.bold,
                                                    color: CustomColor.primary),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    CustomText.text(
                                        textAlign: TextAlign.left,
                                        text: widget.codeNotif
                                            .toString()
                                            .split(" sudah")[0],
                                        minSize: 24,
                                        weight: FontWeight.bold,
                                        color: CustomColor.primary),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
