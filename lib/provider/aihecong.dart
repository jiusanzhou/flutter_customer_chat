



import 'dart:convert';

import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';

class AiHeCongProvider extends Provider {

  String entID;

  AiHeCongProvider(this.entID) : super();

  @override
  String get html => """
    <!DOCTYPE html>
    <html>
    <head>
    <meta charset="UTF-8">
    <title>在线咨询</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
    <link href="https://pubres.aihecong.com/web/link/hecong.css" rel="stylesheet"></head>
    // <script>window.entId='$entID';window.hcLinkType=1</script>
    <body>
    <div id="aihecong"></div>
    <script type="text/javascript" src="https://pubres.aihecong.com/web/link/hecong.js"></script>
    <script>
    (function(d, w, c) {
        var s = d.createElement('script');
        w[c] = w[c] || function() {
            (w[c].z = w[c].z || []).push(arguments);
        };
        s.async = true;
        s.src = 'https://pubres.aihecong.com/hecong.js';
        if (d.head) d.head.appendChild(s);
    })(document, window, '_AIHECONG');
    _AIHECONG('ini',{ entId : $entID });
    </script>
    </body>
    </html>
  """;

  @override
  String get isInited => "typeof _AIHECONG !== 'undefined'";
  
  /// initialize a provider
  @override
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value("");
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
    return Future.value("""_AIHECONG('update', { entId: '$entID', $key: $data });""");
  }
}