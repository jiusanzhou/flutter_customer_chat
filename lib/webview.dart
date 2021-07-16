import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inappWebview;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart' as officalWebview;

enum WebviewType {
  WebviewPreview,
  WebviewPlugin,
  InappWebview,
}

class Webview extends StatefulWidget {
  ///Event fired when the [Webview] is created.
  final void Function(WebviewController controller) onWebViewCreated;

  ///Event fired when the [Webview] starts to load an [url].
  final void Function(WebviewController controller, String url) onLoadStart;

  ///Event fired when the [Webview] finishes loading an [url].
  final void Function(WebviewController controller, String url) onLoadStop;

  ///Initial url that will be loaded.
  final String initialUrl;

  ///Initial [WebviwInitialData] that will be loaded.
  final String initialData;

  ///WebviewType choose a special type
  final WebviewType webviewType;

  Webview({
    this.webviewType: WebviewType.InappWebview,
    this.initialUrl: "about:blank",
    this.initialData,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
  });

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {

  WebviewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebviewController(widget);
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    // });

    widget.onWebViewCreated?.call(_controller);
  }

    @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 只有 pluginwebview 的输入框在键盘弹出时正常工作
    switch (widget.webviewType) {
      case WebviewType.InappWebview:
        return _inappwebview();
      case WebviewType.WebviewPlugin:
        return _pluginwebview();
      case WebviewType.WebviewPreview:
        return _flutterwebview();
      default:
        return _inappwebview();
    }
  }

  Widget _pluginwebview() {
    return WebviewScaffold(
      url: widget.initialUrl,
      mediaPlaybackRequiresUserGesture: false,
      // appBar: widget.appBar,
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      withJavascript: true,
      resizeToAvoidBottomInset: true,
      appCacheEnabled: true,
      geolocationEnabled: true,
      initialChild: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inappwebview() {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 弹起键盘时可以 resize
      body: inappWebview.InAppWebView(
        initialUrlRequest: inappWebview.URLRequest(url: Uri.parse(widget.initialUrl)),
        // initialData: widget.initialData ?? InAppWebViewInitialData(
        //   data: widget.initialData,
        // ),
        onWebViewCreated: (c) => _controller._inAppWebViewController = c,
        initialOptions: inappWebview.InAppWebViewGroupOptions(
          crossPlatform: inappWebview.InAppWebViewOptions(
            javaScriptEnabled: true,
            // contentBlockers: widget.blockers,
          ),
          android: inappWebview.AndroidInAppWebViewOptions(
            useWideViewPort: false,
          ),
        ),
        onLoadStop: (c, url) => widget.onLoadStop?.call(_controller, url.toString()),
        onLoadStart: (c, url) => widget.onLoadStart?.call(_controller, url.toString()),
      ),
    );
  }

  Widget _flutterwebview() {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: officalWebview.WebView(
        initialUrl: widget.initialUrl,
        debuggingEnabled: false,
        javascriptMode: officalWebview.JavascriptMode.unrestricted,
        onWebViewCreated: (c) => _controller._webViewController = c,
        onPageFinished: (url) => widget.onLoadStop?.call(_controller, url),
        onPageStarted: (url) => widget.onLoadStart?.call(_controller, url),
      ),
    );
  }
}

class WebviewController {
  Webview _widget;

  officalWebview.WebViewController _webViewController;
  inappWebview.InAppWebViewController _inAppWebViewController;
  FlutterWebviewPlugin _flutterWebViewPlugin;

  WebviewController(this._widget) {
    _flutterWebViewPlugin = FlutterWebviewPlugin();

    _flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      switch (state.type) {
      case WebViewState.finishLoad:
        _widget.onLoadStop(this, state.url);
        break;
      case WebViewState.startLoad:
        _widget.onLoadStart(this, state.url);
        break;
      default:
        break;
      }
    });
  }

    ///Evaluates JavaScript code into the WebView and returns the result of the evaluation.
  Future<dynamic> evaluateJavascript(String source) async {

    switch (_widget.webviewType) {
      case WebviewType.InappWebview:
        print("code: $source");
        return _inAppWebViewController.evaluateJavascript(source: source);
        break;
      case WebviewType.WebviewPlugin:
        return _flutterWebViewPlugin.evalJavascript(source).then((value) => jsonDecode(value));
        break;
      case WebviewType.WebviewPreview:
        return _webViewController.evaluateJavascript(source).then((value) => jsonDecode(value));
        break;
      default:
    }

    return Future.value();
  }


 dispose() {
   _flutterWebViewPlugin?.dispose();
 }
}