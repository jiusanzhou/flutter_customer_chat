import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/webview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CrispChatView extends StatefulWidget {

  WebviewType webviewType;

  CrispChatView({
    this.webviewType: WebviewType.WebviewPlugin,
  });

  @override
  _CrispChatViewState createState() => _CrispChatViewState();
}

class _CrispChatViewState extends State<CrispChatView> with AutomaticKeepAliveClientMixin<CrispChatView> {

  WebViewController _webViewController;
  InAppWebViewController _inAppWebViewController;
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  bool browserContextChanged = false;

  handleAppLifecycleState() {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == "AppLifecycleState.resumed" && browserContextChanged) {
        print("AppLifecycleState.resumed && browserContextChanged need reload url");
        flutterWebViewPlugin.reloadUrl(crisp.url);
        browserContextChanged = false;
      }
      return null;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    handleAppLifecycleState();

    /// take 
    flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      switch (state.type) {
      case WebViewState.finishLoad:
        _onPageFinished(state.url);
        break;
      case WebViewState.shouldStart:
        if (_onPageStarted(state.url)) await flutterWebViewPlugin.stopLoading();
        break;
      default:
        break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    print("we have to dispose the instance of crisp webview");

    flutterWebViewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // check if crisp ready?
    if (crisp.websiteID==null) return Container(
      child: Center(
        child: Text("未提供ID"),
      ),
    );


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
      url: crisp.url,
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
              SizedBox(height: 20),
              Text("连接客服系统..."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inappwebview() {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 弹起键盘时可以 resize
      body: InAppWebView(
        initialUrl: crisp.url,
        onWebViewCreated: (v) => _inAppWebViewController = v,
        initialOptions: InAppWebViewWidgetOptions(
          inAppWebViewOptions: InAppWebViewOptions(
            javaScriptEnabled: true,
            debuggingEnabled: false,
            // contentBlockers: widget.blockers,
          ),
          androidInAppWebViewOptions: AndroidInAppWebViewOptions(
            useWideViewPort: false,
          ),
        ),
        onLoadStop: (c, url) {
          _onPageFinished(url);
        },
        onLoadStart: (c, url) {
          if (_onPageStarted(url)) {
            c.stopLoading();
          }
        },
      ),
    );
  }

  Widget _flutterwebview() {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: WebView(
        initialUrl: crisp.url,
        debuggingEnabled: false,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (c) {
          _webViewController = c;
        },
        onPageFinished: (url) {
          _onPageFinished(url);
        },
        onPageStarted: (url) {
          _onPageStarted(url);
        },
      ),
    );
  }

  bool _onPageStarted(String url) {
    if (url.contains(CrispChatController.BASE_URL)) return false;
    /// stop some special url
    return url.startsWith("mailto") || url.startsWith("tel") || url.startsWith("http");
  }

  _onPageFinished(String url) {
    var code = """var _sa = setInterval(function(){if (typeof \$crisp !== 'undefined'){${crisp.initscript};clearInterval(_sa);}},500);''""";
    /// 执行crips初始化
    flutterWebViewPlugin?.evalJavascript(code);
    _inAppWebViewController?.evaluateJavascript(source: code);
    _webViewController?.evaluateJavascript(code);
    
    crisp.scripts.forEach((code) {
      flutterWebViewPlugin?.evalJavascript(code);
      _inAppWebViewController?.evaluateJavascript(source: code);
      _webViewController?.evaluateJavascript(code);
    });
    /// 去掉标识
  }
}

class CrispChatController {

  static const BASE_URL = 'https://go.crisp.chat';

  String websiteID;
  String locale;
  User user;

  bool _inited = false;

  List<String> cmds = [];


  List<String> scripts = [];

  WebViewController _wvController;

  /// get url for chat view
  String get url => "$BASE_URL/chat/embed/?website_id=$websiteID&locale=${locale??""}";

  /// get command string to execute
  String get initscript => cmds.join(';\n');

  void initialize(String websiteID, { String locate }) {
    if (_inited) return; // TODO: panic

    this.websiteID = websiteID;
    this.locale = locale;

    this._inited = true;
  }

  void setUser(User user) {
    this.user = user;

    /// store command to send when provider ready
    _updateUser("phone", user.phone);
    if (user.email != null) _updateUser("email", user.email);
    if (user.nickname != null) _updateUser("nickname", user.nickname);
    if (user.avatar != null) _updateUser("avatar", user.avatar);
  }

  void hiddenBrand() {
    var code = """
      var _sb = setInterval(function(){
        var b = document.querySelector("#crisp-chatbox > div > div > div\:nth-child(2) > div > div\:nth-child(7)");
        if (b) {
          b.style = "display: none!important";
          clearInterval(_sb);
        }
      },500);
    """;
    scripts.add(code);
  }

  /// update user field
  void _updateUser(String key, String value) {
    _set("user:$key", value);
  }

  /// try to call
  void _set(String channel, String data) {
    _exec("set", channel, data);
  }

  void _exec(String cmd, String channel, String data) {
    cmds.add("\$crisp.push([\"$cmd\", \"$channel\", [\"$data\"]])");
  }

  /// execute js
}

final crisp = CrispChatController();