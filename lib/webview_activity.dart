import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:indonesiarestoguide/permissionLocation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartIo;
import 'package:http/http.dart' as http;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indonesiarestoguide/utils/utils.dart';
import 'package:indonesiarestoguide/ui/maintenance.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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

  bool notifOrder = false;
  String url = "";
  String link = "";

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  String dataLink = '';

  Future initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null) {
      if (widget.url.toString().contains('resto-detail')) {
        _webViewController!.loadUrl(
            urlRequest:
                URLRequest(url: WebUri.uri(Uri.parse(widget.url.toString()))));
      }
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
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
                      url: WebUri.uri(Uri.parse((dynamicLink
                              .link.queryParameters["url"]
                              .toString()
                              .contains('resto-detail/'))
                          ? dynamicLink.link.queryParameters["url"].toString()
                          : dynamicLink.link.queryParameters["url"]
                              .toString()
                              .replaceAll('resto-detail', 'resto-detail/')))));
            });
          } else {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse((dynamicLink
                            .link.queryParameters["url"]
                            .toString()
                            .contains('resto-detail/'))
                        ? dynamicLink.link.queryParameters["url"].toString()
                        : dynamicLink.link.queryParameters["url"]
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/')))));
          }
        } else {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri.uri(Uri.parse(
                      '${const String.fromEnvironment('url')}/resto'))));
        }
      } else {
        _webViewController!.loadUrl(
            urlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(
                    '${const String.fromEnvironment('url')}/resto'))));
      }
    });
  }

  Object? err;
  StreamSubscription? streamSubscription;
  String urlDeepLinks = '';

  void _incomingLinkHandler() {
    if (!kIsWeb) {
      streamSubscription = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) {
          return;
        }

        if (uri.toString().contains('url')) {
          if (uri.toString().contains('qr')) {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse((uri!.queryParameters['url']
                            .toString()
                            .contains('resto-detail/'))
                        ? uri.queryParameters['url'].toString()
                        : uri.queryParameters['url']
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/')))));
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString(
                "table", uri.queryParameters['url'].toString().split('qr=')[1]);
          } else {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse((uri!.queryParameters['url']
                            .toString()
                            .contains('resto-detail/'))
                        ? uri.queryParameters['url'].toString()
                        : uri.queryParameters['url']
                            .toString()
                            .replaceAll('resto-detail', 'resto-detail/')))));
          }
        } else {
          if (uri.toString().contains('qr')) {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse(
                        uri.toString().replaceAll('mirg://', 'https://')))));
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setString("table", uri.toString().split('qr=')[1]);
          } else {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse(
                        uri.toString().replaceAll('mirg://', 'https://')))));
          }
        }
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        _webViewController!.loadUrl(
            urlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(
                    '${const String.fromEnvironment('url')}/resto'))));
        setState(() {
          if (err is FormatException) {
            err = err;
          } else {
            err = {};
          }
        });
      });
    }
  }

  Future handleTableLink(String urlLink) async {
    var parameters = DynamicLinkParameters(
      uriPrefix: '${const String.fromEnvironment('pagelink')}',
      link: WebUri.uri(Uri.parse(urlLink)),
      androidParameters: AndroidParameters(
        packageName: "com.devus.indonesiarestoguide",
        fallbackUrl: WebUri.uri(Uri.parse("${const String.fromEnvironment('jiitu')}")),
      ),
      iosParameters: IOSParameters(
        bundleId: "com.devus.indonesiarestoguide",
        appStoreId: "6447268805",
      ),
    );
    var shortLink = await dynamicLinks.buildShortLink(parameters);
    var shortUrl = shortLink.shortUrl;

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getDynamicLink(shortUrl);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("table", shortUrl.toString());
  }

  DateTime? currentBackPressTime;

  Future<bool> _handleBackButton() async {
    _webViewController?.getUrl().then((value) {
      if (isPrint) {
        setState(() {
          isPrint = false;
        });
        return Future.value(false);
      } else {
        if (value.toString() ==
                '${const String.fromEnvironment('url')}/resto' ||
            value.toString() ==
                '${const String.fromEnvironment('url')}/login') {
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
        } else if (value.toString() ==
            '${const String.fromEnvironment('url')}/owner/resto-create') {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk keluar');
            return Future.value(false);
          }
          // SystemNavigator.pop();
          _webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri.uri(Uri.parse(
                      '${const String.fromEnvironment('url')}/resto'))));
          return Future.value(true);
        } else if (value.toString().contains('/owner/home')) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: 'Tekan kembali lagi untuk kembali');
            return Future.value(false);
          }
          _webViewController!.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri.uri(Uri.parse(
                      '${const String.fromEnvironment('url')}/resto'))));
          return Future.value(true);
        } else if (value.toString().contains('/owner/transaction')) {
          if (value.toString().contains('/owner/transaction/') != true) {
            _webViewController!.loadUrl(
                urlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse(
                        '${const String.fromEnvironment('url')}/owner/home'))));
            return Future.value(true);
          } else {
            _webViewController!.goBack();
            return Future.value(true);
          }
        } else {
          _webViewController!
              .evaluateJavascript(source: 'window.checkFunctionExists();')
              .then((result) async {
            if (result == null) {
              result = false;
            }
            bool functionExists = result == true;
            if (functionExists) {
              // The function exists in Vue.js
              await _webViewController!
                  .evaluateJavascript(source: 'window.goBackFlutter();');
            } else {
              // The function does not exist in Vue.js
              _webViewController!.goBack();
            }
          });
          return Future.value(true);
        }
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
    if (OneSignal.Notifications.permission == false) {
      OneSignal.Notifications.requestPermission(true);
    }
    _webViewController?.clearCache();
    OneSignal.User.pushSubscription.optIn();
    setState(() {
      playerId = OneSignal.User.pushSubscription.id;
    });
  }

  String? playerId;

  Future<void> saveBase64Image(String name, String base64String) async {
    try {
      Uint8List bytes = base64.decode(base64String);

      img.Image? image = img.decodeImage(bytes);

      final appDocumentsDirectory = await getApplicationDocumentsDirectory();

      final filePath = '${appDocumentsDirectory.path}/$name';

      String newName = name.split('.')[0].replaceAll(' ', '_');

      dartIo.File(filePath).writeAsBytesSync(img.encodePng(image!));

      final result = await ImageGallerySaver.saveFile(filePath,
          isReturnPathOfIOS: true, name: newName);

      if (result['isSuccess'] == true) {
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
          Uri.parse("${const String.fromEnvironment('jiitucheck')}"),
          headers: {
            "Accept": "Application/json",
            "Authorization": "Bearer $token"
          });
      if (apiResult.body.toString().contains('Unauthenticated') == false) {
        if (json.decode(apiResult.body)['transaction'] != false) {
          var data = json.decode(apiResult.body)['transaction']['id'];
          setState(() {
            widget.codeNotif = "IRG-" +
                data.toString().padLeft(5, '0') +
                " sudah siap diambil";
            notifOrder = true;
          });
        }
      }
    }
  }

  bool isLoadingDeviceId = false;

  Future updateDeviceId(String app_id, String user_id, String device_id) async {
    String? token = await _webViewController
        ?.evaluateJavascript(source: '''localStorage.getItem('token');''');
    if (token != "" && token != "null") {
      var apiResult = await http
          .post(Uri.parse("${const String.fromEnvironment('jiituupdate')}"), body: {
        "app_id": app_id,
        "user_id": user_id,
        "device_id": device_id
      }, headers: {
        "Accept": "Application/json",
        "Authorization": "Bearer $token"
      });
    }
  }

  bool isLocationEnabled = false;

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnection().hasInternetAccess;
          if (!isDeviceConnected && isAlertSet == false) {
            final snackBar = SnackBar(
              duration: Duration(days: 365),
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Koneksi tidak stabil',
                message: 'Tolong periksa kembali jaringan anda!',
                contentType: ContentType.warning,
                color: CustomColor.primaryLight,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            setState(() => isAlertSet = true);
          } else {
            ScaffoldMessenger.of(context)..hideCurrentSnackBar();

            if (isAlertSet == true) {
              final snackBarSecond = SnackBar(
                duration: Duration(seconds: 3),
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Berhasil menyambungkan',
                  message: 'Selamat anda sudah bisa mengakses aplikasi lagi!',
                  contentType: ContentType.success,
                  color: CustomColor.accent,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBarSecond);

              setState(() => isAlertSet = false);
              _webViewController?.reload();
            }
          }
        },
      );

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnection().hasInternetAccess;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future checkNotif() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String tokenValue = await pref.getString("token") ?? "";

    setState(() {
      if (tokenValue == null || tokenValue == "") {
        pref.remove("token");
        Future.delayed(Duration(seconds: 3), () async {
          String? secondValue = await _webViewController!
              .evaluateJavascript(source: '''localStorage.getItem('token');''');
          if (secondValue != null && secondValue != "") {
            setState(() {
              if (done != true) {
                setState(() {
                  done = true;
                });
                if (widget.codeNotif
                    .toString()
                    .toLowerCase()
                    .contains('pembayaran transaksi')) {
                  setState(() {
                    var aStr = widget.codeNotif
                        .toString()
                        .replaceAll(new RegExp(r'[^0-9]'), '');
                    var aInt = int.parse(aStr);
                    final RegExp regexp = new RegExp(r'^0+(?=.)');

                    _webViewController?.getUrl().then((value) async {
                      if ((value.toString() ==
                          '${const String.fromEnvironment('url')}/history/' +
                              aInt.toString().replaceAll(regexp, '') +
                              '/resto')) {
                        _webViewController?.reload();
                      } else {
                        _webViewController!.loadUrl(
                            urlRequest: URLRequest(
                                url: WebUri.uri(Uri.parse(
                                    '${const String.fromEnvironment('url')}/history/' +
                                        aInt.toString().replaceAll(regexp, '') +
                                        '/resto'))));
                      }
                    });
                  });
                } else if (widget.codeNotif
                    .toString()
                    .toLowerCase()
                    .contains('sudah siap diambil')) {
                  setState(() {
                    _webViewController?.reload();
                    notifOrder = true;
                  });
                } else {
                  checkToken();
                }
              }
            });
          } else {
            pref.remove("token");
          }
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    idPlayer();
    initDynamicLinks();
    _incomingLinkHandler();
    checkNotif();
    getConnectivity();
    if (widget.codeNotif.toString().contains('sudah siap diambil')) {
      setState(() {
        notifOrder = true;
      });
    }
    setState(() {
      if (widget.url == "") {
        url = '${const String.fromEnvironment('url')}';
      } else {
        url = widget.url ?? '${const String.fromEnvironment('url')}';
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
    subscription.cancel();
    _webViewController?.dispose();
    super.dispose();
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
                  initialUrlRequest:
                      URLRequest(url: WebUri.uri(Uri.parse(url))),
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

                    OneSignal.User.pushSubscription.addObserver((state) async {
                      if (OneSignal.User.pushSubscription.id != '') {
                        await controller.evaluateJavascript(
                            source:
                            "window.localStorage.setItem('device_id', '${OneSignal.User.pushSubscription.id}')");
                      }
                    });

                    var checkId = await controller.evaluateJavascript(
                        source: '''localStorage.getItem("device_id");''');

                    OneSignal.Notifications.requestPermission(true);

                    if (OneSignal.Notifications.permission == false) {
                      OneSignal.Notifications.requestPermission(true);
                    }

                    if (checkId.toString() == 'null') {
                      OneSignal.User.pushSubscription.optIn();
                      await controller.evaluateJavascript(
                          source:
                              "window.localStorage.setItem('device_id', '${OneSignal.User.pushSubscription.id}')");
                    } else if (checkId.toString() !=
                            OneSignal.User.pushSubscription.id.toString() &&
                        OneSignal.Notifications.permission == true) {
                      OneSignal.User.pushSubscription.optOut().whenComplete(() {
                        OneSignal.User.pushSubscription.optIn();
                      });
                      String? userLS = await controller.evaluateJavascript(
                          source: '''localStorage.getItem('user');''');
                      var user = json.decode(userLS!);
                      var userId = user['id'].toString();
                      if (!isLoadingDeviceId) {
                        setState(() {
                          isLoadingDeviceId = true;
                        });
                        updateDeviceId('KAM', userId,
                            OneSignal.User.pushSubscription.id.toString());
                      }
                      await controller.evaluateJavascript(
                          source:
                              "window.localStorage.setItem('device_id', '${OneSignal.User.pushSubscription.id}')");
                    }

                    SharedPreferences pref =
                        await SharedPreferences.getInstance();

                    if (pref.getBool("is_first") != true) {
                      String? token2 = await controller.evaluateJavascript(
                          source: '''localStorage.getItem('token');''');
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
                      if (value.toString() ==
                          '${const String.fromEnvironment('url')}/login') {
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('cart');");
                        controller.evaluateJavascript(
                            source:
                                "window.localStorage.removeItem('cart-details');");
                        controller.evaluateJavascript(
                            source: "window.localStorage.removeItem('notes');");
                      }
                    });
                  },
                  onLoadStart: (InAppWebViewController controller, url) async {
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

                    if (playerId != "") {
                      await controller.evaluateJavascript(
                          source:
                              "window.localStorage.setItem('device_id', '$playerId')");
                    }

                    String? value = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('token');''');

                    String urlDyLink = pref.getString("url_dylink") ?? "";

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}/login-google'))) {
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
                              urlRequest: URLRequest(
                                  url: WebUri.uri(Uri.parse(
                                      '${const String.fromEnvironment('url')}/login'))));
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

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}'))) {
                      _webViewController?.clearCache();
                      _webViewController?.reload();
                      if (value != null && value != "") {
                        if (urlDyLink.isNotEmpty) {
                          controller.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri.uri(Uri.parse(urlDyLink))));
                        } else {
                          controller.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri.uri(Uri.parse(
                                      '${const String.fromEnvironment('url')}/resto'))));
                        }
                      }
                    }

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}/contact_person'))) {}

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}/thermal_print'))) {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      String? macAddress = pref.getString("macAddress") ?? '';
                      setState(() {});
                      await controller.goBack().whenComplete(() async {
                        await Permission.bluetooth.status.isGranted
                            .then((value) async {
                          if (value) {
                            await Permission.bluetoothAdvertise.status.isGranted
                                .then((value) async {
                              if (value) {
                                await Permission
                                    .bluetoothConnect.status.isGranted
                                    .then((value) async {
                                  if (value) {
                                    await Permission
                                        .bluetoothScan.status.isGranted
                                        .then((value) async {
                                      if (value) {
                                        bool bluetoothEnabled =
                                            await PrintBluetoothThermal
                                                .bluetoothEnabled;
                                        if (bluetoothEnabled == false) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Mohon aktifkan terlebih dahulu bluetooth anda dan\nsambungkan ke printer anda!',
                                              toastLength: Toast.LENGTH_LONG,
                                              timeInSecForIosWeb: 5);
                                          AppSettings.openAppSettings(
                                              type: AppSettingsType.bluetooth);
                                        } else {
                                          setState(() {
                                            Fluttertoast.showToast(
                                                msg: 'Tunggu sebentar!');
                                            if (macAddress == '') {
                                              getBluetoots();
                                            } else {
                                              connect(macAddress);
                                            }
                                          });
                                        }
                                      } else {
                                        await Permission.bluetoothScan
                                            .request();
                                      }
                                    });
                                  } else {
                                    await Permission.bluetoothConnect.request();
                                  }
                                });
                              } else {
                                await Permission.bluetoothAdvertise.request();
                              }
                            });
                          } else {
                            await Permission.bluetooth.request();
                          }
                        });
                      });
                    }

                    controller.evaluateJavascript(source: '''
                    window.addEventListener('message', function(event) {
                      var data = event.data;
                      
                      if (data.type === 'share-resto') {
                        handleButtonShare(data.data);
                      }
                      
                      if (data.type === 'call-resto') {
                        handleButtonCall(data.data);
                      }
                      
                      if (data.type === 'contact-person') {
                        contactPerson(data.data);
                      }
                      
                      if (data.type === 'open-map') {
                        handleButtonMap(data.data);
                      }
                      
                      if (data.type === 'feedback') {
                        handleButtonFeedback(data.data);
                      }
                      
                      if (data.type === 'about') {
                        handleButtonFeedback(data.data);
                      }
                    });
                      
                    function handleButtonShare(data) {
                      window.flutter_inappwebview.callHandler('handleButtonShare', data);
                    }
                    
                    function handleButtonCall(data) {
                      window.flutter_inappwebview.callHandler('handleButtonCall', data);
                    }
                    
                    function contactPerson(data) {
                      window.flutter_inappwebview.callHandler('contactPerson', data);
                    }
                    
                    function handleButtonMap(data) {
                      window.flutter_inappwebview.callHandler('handleButtonMap', data);
                    }
                    
                    function handleButtonFeedback(data) {
                      window.flutter_inappwebview.callHandler('handleButtonFeedback', data);
                    }
                    
                    function handleButtonAbout(data) {
                      window.flutter_inappwebview.callHandler('handleButtonAbout', data);
                    }
                    ''');

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'handleButtonShare',
                        callback: (data) {
                          Share.share(data[0].toString());
                        });

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'handleButtonCall',
                        callback: (data) {
                          launch("tel:$data");
                        });

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'contactPerson',
                        callback: (data) {
                          launch("https://wa.me/$data");
                        });

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'handleButtonMap',
                        callback: (data) {
                          launch(data[0].toString());
                        });

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'handleButtonFeedback',
                        callback: (data) {
                          launch(data[0].toString());
                        });

                    _webViewController?.addJavaScriptHandler(
                        handlerName: 'handleButtonAbout',
                        callback: (data) async {
                          if (await canLaunch(data[0].toString())) {
                            await launch(data[0].toString());
                          } else {
                            throw 'Could not launch url';
                          }
                        });

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}/barcode'))) {
                      await Permission.camera.request();
                      await Permission.audio.request();
                    }

                    if (url ==
                        WebUri.uri(Uri.parse(
                            '${const String.fromEnvironment('url')}/scan'))) {
                      await Permission.camera.request();
                      await Permission.audio.request();
                    }

                    if (url.toString().contains("open-jiitu")) {
                      await controller.goBack().whenComplete(() async {
                        if (await canLaunch("${const String.fromEnvironment('jiitu')}/")) {
                          await launch("${const String.fromEnvironment('jiitu')}/");
                        } else {
                          throw 'Could not launch url';
                        }
                      });
                    }

                    if (url.toString() !=
                            '${const String.fromEnvironment('url')}' &&
                        url.toString() !=
                            '${const String.fromEnvironment('url')}/') {
                      if (url
                          .toString()
                          .contains(const String.fromEnvironment('url'))) {
                        await Permission.location.status.isGranted
                            .then((value) async {
                          if (!value) {
                            CustomNavigator.navigatorPushReplacement(
                                context, new permissionLocation());
                          } else {
                            final isLocationServiceEnabled =
                                await Geolocator.isLocationServiceEnabled();

                            setState(() {
                              isLocationEnabled = isLocationServiceEnabled;
                            });

                            if (!isLocationEnabled) {
                              CustomNavigator.navigatorPushReplacement(
                                  context, new permissionLocation());
                            }
                          }
                        });
                      }
                    }

                    if (url.toString().contains(":tableName;")) {
                      await controller.goBack().whenComplete(() async {
                        Fluttertoast.showToast(msg: 'Tunggu sebentar');
                        String? dataQr = await controller.evaluateJavascript(
                            source: '''localStorage.getItem('dataQr');''');
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
                                                      url: WebUri.uri(Uri.parse(
                                                          '${const String.fromEnvironment('url')}/history'))));
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
                (isPrint)
                    ? Container(
                        height: CustomSize.sizeHeight(context),
                        width: CustomSize.sizeWidth(context),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(.5)),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  // height: Heig,
                                  width: CustomSize.sizeWidth(context),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    minSize: 18,
                                                    weight: FontWeight.bold,
                                                    color: Colors.black),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                getBluetoots();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: CustomColor.accent,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6,
                                                      horizontal: 20),
                                                  child: CustomText.text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      text: "Cari Perangkat",
                                                      minSize: 14,
                                                      weight: FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.white,
                                                ),
                                                child: Scrollbar(
                                                  thumbVisibility: true,
                                                  thickness: 5.0,
                                                  child: ListView.builder(
                                                    itemCount: items.length > 0
                                                        ? items.length
                                                        : 0,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          child: ListTile(
                                                            onTap: () {
                                                              if (!isLoadingConnect) {
                                                                String mac =
                                                                    items[index]
                                                                        .macAdress;
                                                                this.connect(
                                                                    mac);
                                                              }
                                                            },
                                                            // title: Text('Name: ${items[index].name}'),
                                                            title: CustomText.textThermal(
                                                                text:
                                                                    '${items[index].name}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                weight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.75),
                                                                minSize: 14),
                                                            subtitle:
                                                                // Text("macAddress: ${items[index].macAdress}"),
                                                                CustomText.textThermal(
                                                                    text:
                                                                        "${items[index].macAdress}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    minSize:
                                                                        12),
                                                            trailing: FaIcon(
                                                              FontAwesomeIcons
                                                                  .print,
                                                              color: CustomColor
                                                                  .primary,
                                                              size: 28,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: CustomText.textThermal(
                                              text:
                                                  "Sambungkan terlebih dahulu di pengaturan\njika perangkat anda tidak tersedia disini",
                                              textAlign: TextAlign.center,
                                              color: CustomColor.primary,
                                              weight: FontWeight.w500,
                                              minSize: 12,
                                              maxLines: 2),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isPrint = !isPrint;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: CustomText.text(
                                                  textAlign: TextAlign.center,
                                                  text: "Tutup",
                                                  minSize: 14,
                                                  weight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
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

  bool isLoadingConnect = false;
  bool isPrint = false;
  List<BluetoothInfo> items = [];
  bool connected = false;
  bool progress = false;
  String msjprogress = "";
  var thermalDataCashier = '';
  var thermalData = '';
  var thermalDataTrans = '';

  // var thermalDataDecode = '';

  Future<void> getBluetoots() async {
    await disconnect();
    setState(() {
      progress = true;
      items = [];
    });
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      progress = false;
    });

    if (listResult.length == 0) {
      Fluttertoast.showToast(
          msg:
              'Tidak ada bluetooh yang ditautkan,\n buka pengaturan dan tautkan printer!',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 5);
      AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } else {
      isPrint = true;
      Fluttertoast.showToast(msg: 'Pilih bluetooth dalam daftar untuk dicetak');
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
  }

  Future<void> connect(String mac) async {
    await disconnect();
    setState(() {
      isLoadingConnect = true;
      progress = true;
      Fluttertoast.showToast(msg: 'Menghubungkan...');
      connected = false;
    });
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (result == true) {
      connected = true;
      setState(() {
        Fluttertoast.showToast(msg: 'Berhasil dicetak');
        pref.setString("macAddress", mac.toString());
        progress = false;
        isLoadingConnect = false;
        this.printTest();
      });
    } else {
      connected = false;
      isLoadingConnect = false;
      String? macAddress = pref.getString("macAddress") ?? '';
      if (macAddress == '') {
        if (!isPrint) {
          isPrint = true;
          getBluetoots();
        }
      } else {
        if (!isPrint) {
          isPrint = true;
          getBluetoots();
          pref.remove("macAddress");
        } else {
          getBluetoots();
          pref.remove("macAddress");
        }
      }
      setState(() {
        Fluttertoast.showToast(msg: 'Gagal menghubungkan!');
      });
    }
  }

  Future<void> printTest() async {
    isPrint = false;
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      List<int> ticket = await testTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
    } else {
      //no conectado, reconecte
    }
  }

  Future<List<int>> testTicket() async {
    thermalDataCashier = await _webViewController!.evaluateJavascript(
        source: '''localStorage.getItem('thermalDataCashier');''');
    thermalData = await _webViewController!
        .evaluateJavascript(source: '''localStorage.getItem('thermalData');''');
    thermalDataTrans = await _webViewController!.evaluateJavascript(
        source: '''localStorage.getItem('thermalDataTrans');''');
    var thermalDataDecode = json.decode(thermalData);
    var thermalDataTransDecode = json.decode(thermalDataTrans);
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();

    final ByteData data = await rootBundle.load('assets/logo-jiitu.png');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);

    if (Platform.isIOS) {
      // Resizes the image to half its original size and reduces the quality to 80%
      final resizedImage = img.copyResize(image!,
          width: image.width ~/ 1.3,
          height: image.height ~/ 1.3,
          interpolation: img.Interpolation.nearest);
      final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
    }

    List<String> menuName = [];
    for (var itemName in thermalDataDecode['item']) {
      String name = itemName['name'];
      menuName.add(name);
    }

    List<String> menuPrice = [];
    for (var itemPrice in thermalDataDecode['item']) {
      String price =
          NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
              .format(int.parse(itemPrice['price'].toString()))
              .toString();
      menuPrice.add(price);
    }

    List<String> qty = [];
    for (var itemQty in thermalDataDecode['item']) {
      String _qty = itemQty['qty'];
      qty.add(_qty);
    }

    List<String> totalHarga = [];
    for (var itemCountPrice in thermalDataDecode['item']) {
      String countPrice =
          NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
              .format((int.parse(itemCountPrice['price'].toString()) *
                  int.parse(itemCountPrice['qty'].toString())))
              .toString();
      totalHarga.add(countPrice);
    }

    String subTotal =
        NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
            .format(int.parse(thermalDataDecode['subtotal'].toString()))
            .toString();
    String platformFee =
        NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
            .format((thermalDataDecode['service_charge'].toString() != '0')
                ? (int.parse(thermalDataDecode['platformFee'].toString()) -
                    int.parse(thermalDataDecode['service_charge'].toString()))
                : int.parse(thermalDataDecode['platformFee'].toString()))
            .toString();
    String serviceCharge =
        NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
            .format(int.parse(thermalDataDecode['service_charge'].toString()))
            .toString();
    String total =
        NumberFormat.currency(decimalDigits: 0, symbol: '', locale: 'ID')
            .format(int.parse(thermalDataDecode['total'].toString()))
            .toString();

    var maxWordLength = 26;
    String nameResto =
        thermalDataDecode['outlet']['name'].toString().toUpperCase();
    var _nameResto = nameResto.split(' ');
    var currentLine = '';

    for (var word in _nameResto) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else {
        var potentialLine = '$currentLine $word';
        if (potentialLine.length > maxWordLength) {
          // Print the current line and start a new line
          bytes += generator.text(currentLine,
              styles: PosStyles(
                bold: true,
                fontType: PosFontType.fontA,
                align: PosAlign.center,
              ));
          currentLine = word;
        } else {
          currentLine = potentialLine;
        }
      }
    }
    // Print the remaining text, if any
    if (currentLine.isNotEmpty) {
      bytes += generator.text(currentLine,
          styles: PosStyles(
            bold: true,
            fontType: PosFontType.fontA,
            align: PosAlign.center,
          ));
    }

    var maxWordLengthSecond = 32;
    String addressResto = thermalDataDecode['outlet']['address'].toString();
    var _addressResto = addressResto.split(' ');
    currentLine = '';

    for (var word in _addressResto) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else {
        var potentialLine = '$currentLine $word';
        if (potentialLine.length > maxWordLengthSecond) {
          // Print the current line and start a new line
          bytes += generator.text(currentLine,
              styles: PosStyles(
                align: PosAlign.center,
              ));
          currentLine = word;
        } else {
          currentLine = potentialLine;
        }
      }
    }
    // Print the remaining text, if any
    if (currentLine.isNotEmpty) {
      bytes += generator.text(currentLine,
          styles: PosStyles(
            align: PosAlign.center,
          ));
    }
    bytes += generator.text('--------------------------------',
        styles: PosStyles(bold: true, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: 'Kasir',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: thermalDataCashier.toString(),
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Tanggal',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: thermalDataTransDecode['created_at']
            .toString()
            .replaceAll(' - ', '-')
            .split('-')[0],
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Jam',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: thermalDataTransDecode['created_at']
            .toString()
            .replaceAll(' - ', '-')
            .split('-')[1],
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'No. Struk',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: 'IRG-' + thermalDataDecode['code'].toString(),
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Jenis',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: thermalDataDecode['type'].toString(),
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    if (thermalDataDecode['type'].toString() == 'Makan Ditempat' &&
        thermalDataDecode['table'].toString() != 'null') {
      bytes += generator.row([
        PosColumn(
          text: 'Meja',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: thermalDataDecode['table'].toString(),
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
    }
    bytes += generator.row([
      PosColumn(
        text: 'Pembayaran',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: thermalDataDecode['payment_method'].toString(),
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);

    bytes += generator.text('--------------------------------',
        styles: PosStyles(bold: true, align: PosAlign.center));

    for (var i = 0; i < menuName.length; i++) {
      var _menuName = menuName[i].split(' ');
      currentLine = '';

      for (var word in _menuName) {
        if (currentLine.isEmpty) {
          currentLine = word;
        } else {
          var potentialLine = '$currentLine $word';
          if (potentialLine.length > maxWordLengthSecond) {
            // Print the current line and start a new line
            bytes += generator.text(currentLine,
                styles: PosStyles(
                  bold: true,
                  fontType: PosFontType.fontA,
                  align: PosAlign.left,
                ));
            currentLine = word;
          } else {
            currentLine = potentialLine;
          }
        }
      }
      // Print the remaining text, if any
      if (currentLine.isNotEmpty) {
        bytes += generator.text(currentLine,
            styles: PosStyles(
              bold: true,
              fontType: PosFontType.fontA,
              align: PosAlign.left,
            ));
      }
      bytes += generator.row([
        PosColumn(
          text: menuPrice[i] + ' X ' + qty[i],
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: totalHarga[i],
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
    }

    bytes += generator.text('--------------------------------',
        styles: PosStyles(bold: true, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: 'SubTotal',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: subTotal,
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Platform Fee',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: platformFee,
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    if (thermalDataDecode['type'].toString() == 'Makan Ditempat' &&
        serviceCharge != '0') {
      bytes += generator.row([
        PosColumn(
          text: 'Service Charge',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: serviceCharge,
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
    }

    bytes += generator.text('--------------------------------',
        styles: PosStyles(bold: true, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: PosStyles(
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: total,
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);

    bytes += generator.text('--------------------------------',
        styles: PosStyles(bold: true, align: PosAlign.center));

    bytes += generator.text('Terima Kasih Banyak',
        styles: PosStyles(
          align: PosAlign.center,
        ));

    bytes += generator.text('Powered by Jiitu',
        styles: PosStyles(
          align: PosAlign.center,
        ));

    bytes += generator.text("${const String.fromEnvironment('jiitu')}",
        styles: PosStyles(
          align: PosAlign.center,
        ));

    bytes += generator.feed(2);
    return bytes;
  }
}
