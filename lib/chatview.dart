import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';
import 'package:flutter_customer_chat/webview.dart';

class ChatView extends StatefulWidget {

  final ChatProvider provider;
  final bool hiddenCopyright;

  final void Function(Controller controller) onCreated;
  final void Function(Controller controller) onInited;

  ///WebviewType choose a special type
  final WebviewType webviewType;

  ChatView(this.provider, {
    this.hiddenCopyright = false,
    this.onCreated, this.onInited,
    this.webviewType: WebviewType.InappWebview,
  });

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  Controller _controller;

  @override
  void initState() {
    super.initState();

    _controller = Controller(widget);

    widget.onCreated?.call(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Webview(
      webviewType: widget.webviewType,
      initialUrl: widget.provider.url,
      initialData: widget.provider.html,
      onWebViewCreated: (c) => _controller._webview = c,
      onLoadStart: (_, url) => {},
      onLoadStop: (_, url) => _controller.onLoadFinish(),
    );
  }
}


class Controller {

  ChatView _widget;
  ChatProvider _provider;

  WebviewController _webview;

  bool _inited = false;
  
  Controller(this._widget) {
    _provider = _widget.provider;
  }

  // controller for user to controller everything.

  WebviewController get webview => _webview;

  ChatProvider get provider => _provider;

  Future<void> setUser(User user) {
    _provider.setUser(user).then((code) => _webview.evaluateJavascript(code)).then((value) => print("setUser: $value"));
    return Future.value();
  }

  Future<void> setValue(String key, dynamic value) {
    _provider.setValue(key, value).then((code) => _webview.evaluateJavascript(code));
    return Future.value();
  }

  Future<void> sendMessage(Message msg, { User user }) {
    _provider.sendMessage(msg, user: user).then((code) => _webview.evaluateJavascript(code));
    return Future.value();
  }

  Future<void> showCopyright(bool v) async {
    await _webview.evaluateJavascript(v?
      _provider.codeShowCopyright : 
      _provider.codeHiddenCopyright);
    return Future.value();
  }

  onLoadFinish() {
    if (_inited) return;
    /// start the inited check timer
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      _webview.evaluateJavascript(provider.isInited).then((value) {
        if (!value) return;
        print("chat page has been inited ...");
        _inited = true;

        // hidden copyright
        if (_widget.hiddenCopyright) _webview.evaluateJavascript(_provider.codeHiddenCopyright);
        
        _provider.initialize().then((code) => _webview.evaluateJavascript(code)); // from provider
        _widget.onInited?.call(this); // from user
        timer.cancel();
      });
    });
  }
}