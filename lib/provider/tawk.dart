


import 'dart:convert';

import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';

class TawkProvider extends ChatProvider {

  final String basicUrl;
  final String widgetId;
  final User user;

  final String codeDisableBorder = """
  function(){
    var iframe = document.querySelector('iframe');
    var innerDoc = iframe.contentDocument || iframe.contentWindow.document;
    innerDoc.querySelector('.tawk-max-container').style.border = '';
  }();
  '__inialize_finish'
  """;

  TawkProvider(
    this.widgetId,
    {
      this.basicUrl: "https://tawk.to/chat",
      this.user,
    }
  ) : super();

  @override
  String get url => "$basicUrl/$widgetId";

  @override
  String get isInited => """Tawk_API && Tawk_API.getStatus() === 'online'""";

  /// initialize a provider
  @override
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    // set user if exits
    if (user != null) {
      // call set user method
      setUser(user).catchError((e) {
        print("set user failed: $e");
      });
    }

    return Future.value("""function _disable_border(){
      var _sb = setInterval(function(){
        var iframe = document.querySelector('iframe');
        if (iframe) {
          var innerDoc = iframe.contentDocument || iframe.contentWindow.document;
          innerDoc.querySelector('.tawk-max-container').style.borderWidth = '0';
          clearInterval(_sb);
        }
      }, 500);
    }
    _disable_border();
    '__inialize_finish'
    """);
  }

  @override
  String codeSelectCopyright = """function(){
    var iframe = document.querySelector('iframe');
    var innerDoc = iframe.contentDocument || iframe.contentWindow.document;
    return innerDoc.querySelectorAll('.tawk-branding').forEach(i=>i.style="display:none");
  }()
  """;

  @override
  Future<String> setUser(User user) {
    var data = jsonEncode(user).replaceAll("nickname", 'name');
    return Future.value("""Tawk_API.setAttributes($data)""");
  }

  /// set field
  @override
  Future<String> setValue(String key, dynamic value) {
    return Future.value("""Tawk_API.setAttributes({$key: '$value'})""");
  }
}