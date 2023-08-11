import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class InappWebView extends StatefulWidget{
  final String appBarTitle;
  final String openUrl;

  const InappWebView({super.key, required this.openUrl, required this.appBarTitle});
  @override
  State<StatefulWidget> createState() => _InappWebViewState();
}

class _InappWebViewState extends State<InappWebView>{

  bool isLoading = true;
  late WebViewController controller;
  late PackageInfo packageInfo;
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late AndroidDeviceInfo androidDeviceInfo;
  late IosDeviceInfo iosDeviceInfo;
  @override
  void initState() {

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if(progress>50 && isLoading){
              setState((){
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      packageInfo = await PackageInfo.fromPlatform();
      if(Platform.isAndroid) {
        androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      }else if(Platform.isIOS){
        iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      }
      if(widget.openUrl.startsWith('https://tswv.sixprotocol.com/')){
        if(Platform.isIOS){
          controller.setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.160 Mobile/15E148 Safari/604.1');
        }else if(Platform.isAndroid){
          controller.setUserAgent('Mozilla/5.0 (Linux; Android 10; Android SDK built for x86 Build/LMY48X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/4.0 Chrome/81.0.4044.117 Mobile Safari/608.2.11');
        }
      }
    //   else if(widget.openUrl.startsWith(appAPIEndpoint)||widget.openUrl.startsWith(appGetTicketEndpoint)){
    //     if(Platform.isIOS){
    //       controller.setUserAgent('${packageInfo.appName}/${packageInfo.version} ${kDebugMode?'(UAT)':'(PRD)'} (${iosDeviceInfo.name};${iosDeviceInfo.systemName} ${iosDeviceInfo.systemVersion};)');
    //     }else if(Platform.isAndroid){
    //       controller.setUserAgent('${packageInfo.appName}/${packageInfo.version} ${kDebugMode?'(UAT)':'(PRD)'} (${androidDeviceInfo.brand};${androidDeviceInfo.model};${androidDeviceInfo.version.sdkInt})');
    //     }
    //   }
      setState(() {});
      controller.loadRequest(Uri.parse(widget.openUrl));
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //   appBar: AppBarWithImageBackground(title: widget.appBarTitle, bgImage: bgImage, hasLeading: true),
        appBar: AppBar(title: const Text('Example Webview'), toolbarHeight: 50),
        body: WebViewWidget(controller: controller),
    //   body: WillPopScope(
    //       onWillPop: _willPopCallback,
    //       child: Stack(children: [
    //         WebViewWidget(controller: controller),
    //         isLoading
    //             ? const Center(child: LoadingIndicator())
    //             : const SizedBox()
    //       ])),
    );
  }

  Future<bool> _willPopCallback() async{
    if(await controller.canGoBack()){
      controller.goBack();
      return false;
    }
    return true;
  }
}