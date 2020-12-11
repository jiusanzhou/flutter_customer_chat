



import 'dart:convert';

import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';

class AiHeCongProvider extends ChatProvider {

  final String basicUrl;
  final String entId;

  final String codeMvCloseBtn = """var _sb=setInterval(function(){var btn=document.querySelector('.chat-iframe-close');if (btn) {btn.remove();clearInterval(_sb)}},200);""";

  AiHeCongProvider(this.entId, {
    this.basicUrl: "https://aihecong.gitee.io/",
  }) : super();

  @override
  String get url => "$basicUrl?entId=$entId";

  @override
  String get isInited => "typeof _AIHECONG !== 'undefined'";
  
  /// initialize a provider
  @override
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value(codeMvCloseBtn);
  }

  @override
  Future<String> setUser(User user) {
    return Future.value("""
    _AIHECONG('customer', {
      '名称': '${user.nickname??''}',
      '邮箱' : '${user.email??''}',
      '手机' : '${user.phone??''}',
    });
    """);
  }

  /// send message with a special user
  @override
  Future<String> sendMessage(Message msg, { User user }) {
    // TODO:
    return Future.value();
  }

  /// set field
  @override
  Future<String> setValue(String key, dynamic value) {
    var data = jsonEncode(value);
    return Future.value("""_AIHECONG('update', { entId: '$entId', $key: $data });""");
  }
}