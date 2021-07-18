import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';

abstract class ChatProvider {
  // get the code back

  String url; // url to load
  String html; // html

  String isInited; // code to check

  String copyrightSelector; // copyright element selector

  ChatProvider();

  String get codeHiddenCopyright => copyrightSelector != null
      ? """
    var _sb = setInterval(function(){
      var b = document.querySelector("$copyrightSelector");
      if (b) {
        b.style = "display: none!important";
        clearInterval(_sb);
      }
    }, 500);
    """
      : "";

  String get codeShowCopyright => copyrightSelector != null
      ? """
    var b = document.querySelector("$copyrightSelector");
    if (b) b.style = "display: block!important";
    """
      : "";

  /// initialize a provider
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value();
  }

  /// set a special user for current instance
  Future<String> setUser(User user) {
    return Future.value();
  }

  /// send message with a special user
  Future<String> sendMessage(Message msg, {User user}) {
    return Future.value();
  }

  /// set field
  Future<String> setValue(String key, dynamic value) {
    return Future.value();
  }
}
