import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class InappWebView extends StatefulWidget{
  final String appBarTitle;
  final String openUrl;

  const InappWebView({super.key, required this.openUrl, required this.appBarTitle});
  @override
  State<StatefulWidget> createState() => _InappWebViewState();
}

class _InappWebViewState extends State<InappWebView>{

  bool isLoading = true;
//   late WebViewController controller;  <<<<<<< Techsauce
  late final WebViewController _controller; // <<<<<<< SIX ADD this line then can open the camera
  late PackageInfo packageInfo;
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late AndroidDeviceInfo androidDeviceInfo;
  late IosDeviceInfo iosDeviceInfo;
  final String appAPIEndpoint = "";
  final String appGetTicketEndpoint = "";
  final bool kDebugMode = true;

  @override
  void initState() {

    // Start SIX ADD this line then can open the camera
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // End SIX ADD this line then can open the camera

    controller
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

    // Start SIX ADD this line then can open the camera
    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
      (controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest(
            (PlatformWebViewPermissionRequest request) {
              request.grant();
            },
          );
    }
    // End SIX ADD this line then can open the camera

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
      // **** Start SIX comment for run in local project please uncomment back when run on Techsauce *****
      else if(widget.openUrl.startsWith(appAPIEndpoint)||widget.openUrl.startsWith(appGetTicketEndpoint)){
        if(Platform.isIOS){
          controller.setUserAgent('${packageInfo.appName}/${packageInfo.version} ${kDebugMode?'(UAT)':'(PRD)'} (${iosDeviceInfo.name};${iosDeviceInfo.systemName} ${iosDeviceInfo.systemVersion};)');
        }else if(Platform.isAndroid){
          controller.setUserAgent('${packageInfo.appName}/${packageInfo.version} ${kDebugMode?'(UAT)':'(PRD)'} (${androidDeviceInfo.brand};${androidDeviceInfo.model};${androidDeviceInfo.version.sdkInt})');
        }
      }
       // **** End SIX comment for run in local project please uncomment back when run on Techsauce *****

      setState(() {});

      // **** Please try to remove or comment this line and change the way to set openUrl after set controller to _controller *****
    //   controller.loadRequest(Uri.parse(widget.openUrl));
    });

    _controller = controller; // <<<<<<< SIX Add this line then can open the camera
    _controller.loadRequest(Uri.parse('${widget.openUrl}')); // <<<<<<< SIX Add this line then can open the camera

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Start SIX ADD for runnung on local project please remove this code when running on Techsauce
        appBar: AppBar(title: const Text('SIX WebView'), toolbarHeight: 50),
        body: WebViewWidget(controller: _controller),
        // End SIX ADD for runnung on local project please remove this code when running on Techsauce

        // ***** when running on Techsauce, please change controller parameter to _controller *****
    //   appBar: AppBarWithImageBackground(title: widget.appBarTitle, bgImage: bgImage, hasLeading: true),
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
    // ***** SIX Change controller to _controller *****
    if(await _controller.canGoBack()){
      _controller.goBack();
      return false;
    }
    return true;
  }
}