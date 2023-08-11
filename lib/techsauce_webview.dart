import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'example_webview.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}
class TechSauceWebView extends StatefulWidget {
  final String url;
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser();

   TechSauceWebView({super.key, required this.url});
  @override
  State<TechSauceWebView> createState() => _TechSauceWebViewState();
}

class _TechSauceWebViewState extends State<TechSauceWebView> {
  late final WebViewController _controller;
  late final cookieManager = WebViewCookieManager();

  @override
  void initState() {
    super.initState();

widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 1,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
        }));
    // #docregion platform_features
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
    // #enddocregion platform_features

    late final String userAgent;
    if (Platform.isAndroid) {
      // Android-specific code
      userAgent = 'Mozilla/5.0 (Linux; Android 10; Android SDK built for x86 Build/LMY48X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/4.0 Chrome/81.0.4044.117 Mobile Safari/608.2.11';
    } else if (Platform.isIOS) {
      // iOS-specific code
      userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.160 Mobile/15E148 Safari/604.1';
      // userAgent  = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36";
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            // if (url.startsWith('https://twitter.com/')) {
            //   _controller.setUserAgent(userAgent);
            // }
            
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
                      ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            debugPrint(widget.hashCode.toString());
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            // if (request.url.startsWith('https://twitter.com/')) {
            //   debugPrint("TWITTER");

            //   var returnUrl = await Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => WebViewExample(url: request.url)));
            //   debugPrint("RETURN URL: $returnUrl");
            //   _controller.loadRequest(Uri.parse(returnUrl));
            //   return NavigationDecision.prevent;
            // }

            if (request.url.startsWith('https://twitter.com/')) {
              await widget.browser.open(
                  url: Uri.parse(request.url),
                  options: ChromeSafariBrowserClassOptions(
                      android: AndroidChromeCustomTabsOptions(
                          shareState: CustomTabsShareState.SHARE_STATE_OFF),
                      ios: IOSSafariOptions(barCollapsingEnabled: true)));
              return NavigationDecision.prevent;
            }

            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );
      // ..loadRequest(Uri.parse('https://flutter.dev'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
      (controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest(
            (PlatformWebViewPermissionRequest request) {
              debugPrint(
                'requesting permissions for ${request.types.map((WebViewPermissionResourceType type) => type.name)}',
              );
              request.grant();
            },
          );
    }
    cookieManager.clearCookies();
    // #enddocregion platform_features

    _controller = controller;
  }


  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    if (widget.url != "") {
      _controller.loadRequest(Uri.parse('${widget.url}'));
    }
    return WillPopScope(
      onWillPop: () async {
        // Will be called before pop happens.
        // You can get the current route here.
        Navigator.of(context).pop(); // This will pop the route.
        return false; // Return true if you want to allow the pop, false otherwise.
      },
      child: Scaffold(
      appBar: AppBar(title: const Text('TechSauce Webview'), toolbarHeight: 50),
      body: WebViewWidget(controller: _controller),
    )
    );
  }
// #enddocregion webview_widget
}