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

class WebViewExample extends StatefulWidget {
  final String url;

  const WebViewExample({super.key, required this.url});
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

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
      userAgent = 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5790.166 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      // iOS-specific code
      userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/115.0.5790.160 Mobile/15E148 Safari/604.1';
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
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
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
    }
    // #enddocregion platform_features

    _controller = controller;
  }


  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    if (widget.url != "") {
      _controller.loadRequest(Uri.parse('${widget.url}'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Example Webview'), toolbarHeight: 50),
      body: WebViewWidget(controller: _controller),
    );
  }
// #enddocregion webview_widget
}