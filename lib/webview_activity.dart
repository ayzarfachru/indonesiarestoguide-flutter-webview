import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kam5ia/utils/utils.dart';
import 'package:kam5ia/ui/maintenance.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future initDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    print('dylink1');
    if (data != null) {
      print(data.link);
    }
    FirebaseDynamicLinks.instance.onLink
        .listen((PendingDynamicLinkData dynamicLink) async {
      print('dylink2');
      print(dynamicLink.link.queryParameters["url"]);
      _webViewController!.loadUrl(
          urlRequest: URLRequest(
              url: Uri.parse(
                  dynamicLink.link.queryParameters["url"].toString())));
    });
  }

  Future<bool> _handleBackButton() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("url_dylink", "");
    if (notifOrder) {
      return false;
    } else if (_webViewController != null &&
        await _webViewController!.canGoBack()) {
      _webViewController?.getUrl().then((value) {
        if (value.toString().contains("resto-detail")) {
          _webViewController!.loadUrl(
              urlRequest: URLRequest(url: Uri.parse('$mainUrl/resto')));
        } else if (value.toString() != '$mainUrl/resto' &&
            value.toString() != '$mainUrl/login' &&
            value.toString() != '$mainUrl/owner/resto-create') {
          _webViewController!.goBack();
        }
      });
      return false;
    } else {
      return true;
    }
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

  @override
  void initState() {
    idPlayer();
    initDynamicLinks();
    if (widget.codeNotif != "") {
      setState(() {
        notifOrder = true;
      });
    }
    setState(() {
      if (widget.url == "") {
        url = '$mainUrl';
      } else {
        url = widget.url ?? '$mainUrl';
      }
    });

    // pullToRefreshController = kIsWeb
    //     ? null
    //     : PullToRefreshController(
    //         options: PullToRefreshOptions(backgroundColor: CustomColor.primary),
    //         onRefresh: () async {
    //           if (defaultTargetPlatform == TargetPlatform.android) {
    //             _webViewController?.reload();
    //           } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //             _webViewController?.loadUrl(
    //                 urlRequest:
    //                     URLRequest(url: await _webViewController?.getUrl()));
    //           }
    //         },
    //       );
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('resumed');
      initDynamicLinks();
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
                    ),
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
                  onLoadStart: (InAppWebViewController controller, url) async {
                    // controller.clearCache();

                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setString("url", url.toString());

                    await controller.evaluateJavascript(
                        source:
                            "window.localStorage.setItem('device_id', '$playerId')");

                    String? value = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('token');''');

                    String? restoDetailID = await controller.evaluateJavascript(
                        source: '''localStorage.getItem('resto-detail-id');''');

                    String urlDyLink = pref.getString("url_dylink") ?? "";

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
                      controller.goBack();
                      if (await canLaunch('$mainUrl')) {
                        await launch('$mainUrl');
                      } else {
                        throw 'Could not launch url';
                      }
                    }

                    if (url == Uri.parse('$mainUrl/feedback')) {
                      controller.goBack();
                      launch('mailto:info@indonesiarestoguide.id');
                    }

                    if (url == Uri.parse('$mainUrl/share-resto')) {
                      controller.goBack();
                      createDynamicLink(
                              '$mainUrl/resto-detail/' + restoDetailID!)
                          .whenComplete(() {
                        Share.share('Kunjungi Restaurant kami di ' + link);
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

                    if (url.toString().contains("call-resto")) {
                      controller.goBack();
                      String phone = url.toString().split('call-resto/')[1];
                      launch("tel:$phone");
                    }

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
                      });
                    }

                    if (url.toString().contains("resto-detail")) {
                      pref.setString("url_dylink", "");
                    }
                  },
                  onLoadStop: (InAppWebViewController controller, url) async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    if (url.toString().contains("resto-detail")) {
                      pref.setString("url_dylink", "");
                    }
                  },
                  onLoadError: (controller, url, code, message) {
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
                                          child: Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  notifOrder = false;
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      text: "Terima",
                                                      minSize: 18,
                                                      weight: FontWeight.bold,
                                                      color:
                                                          CustomColor.primary),
                                                ],
                                              ),
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
