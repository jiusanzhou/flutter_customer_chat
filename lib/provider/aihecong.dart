import 'dart:convert';

import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';

class AiHeCongProvider extends ChatProvider {
  final String basicUrl;
  final String entId;
  final bool simple;

  String _url;

  User user;
  Map<String, dynamic> _data;

  @override
  String get copyrightSelector =>
      "#aihecong > div > div.chat-message-body div.copyright";

  final String codeMvCloseBtn =
      """var _sb=setInterval(function(){var btn=document.querySelector('.chat-iframe-close');if (btn) {btn.remove();clearInterval(_sb)}},200);""";

  AiHeCongProvider(
    this.entId, {
    this.basicUrl: "https://aihecong.gitee.io/",
    this.simple: true,
    this.user,
  }) {
    if (basicUrl == "https://aihecong.gitee.io/" && simple) {
      _url = basicUrl + "chat.html";
    } else {
      _url = basicUrl;
    }

    if (user != null) {
      _url = "$_url?customer=${json.encode(user)}";
    }
  }

  @override
  String get url => "$_url?entId=$entId"; // to check

  @override
  String get isInited =>
      simple ? "1 === 1" : "typeof _AIHECONG !== 'undefined'";

  /// initialize a provider
  @override
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value(codeMvCloseBtn);
  }

  @override
  Future<String> setUser(User user) {
    // if simple just reload the page with js

    this.user = user;

    var pre = """
    _AIHECONG = function (key, value) {
      window.location.search='entId=$entId&'+key+'='+JSON.stringify(value);
    }
    """;
    return Future.value("""
    ${simple ? pre : ""}
    _AIHECONG('customer', {
      '名称': '${user.nickname ?? ''}',
      '邮箱' : '${user.email ?? ''}',
      '手机' : '${user.phone ?? ''}',
    });
    """);
  }

  /// send message with a special user
  @override
  Future<String> sendMessage(Message msg, {User user}) {
    // TODO:
    return Future.value();
  }

  /// set field
  @override
  Future<String> setValue(String key, dynamic value) {
    var data = jsonEncode(value);
    return Future.value(
        """_AIHECONG('update', { entId: '$entId', $key: $data });""");
  }

  String _updateCustomerCode() {
    var s = "{";
    s += "'名称': '${user.nickname ?? ''}',";
    s += "'邮箱' : '${user.email ?? ''}',";
    s += "'手机' : '${user.phone ?? ''}',";

    _data.forEach((key, value) {
      s += "'$key': ${jsonEncode(value)},";
    });

    s += "}";

    return "window.location.search='entId=$entId&customer='+JSON.stringify($s)";
  }
}
