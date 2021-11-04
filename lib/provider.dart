import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';

abstract class ChatProvider {
  // get the code back

  String url; // url to load
  String html; // html

  String isInited; // code to check

  String copyrightSelector; // copyright element selector
  String codeSelectCopyright; // code to get copyright element

  ChatProvider();

  static ChatProvider from(String type) {
    // TODO:
  }

  String get codeHiddenCopyright => copyrightSelector != null || codeSelectCopyright != null
      ? """
    var _sb = setInterval(function(){
    var b = ${codeSelectCopyright!=null?codeSelectCopyright:'document.querySelector("$copyrightSelector")'};
      if (b) {
        b.style.display = "none!important";
        clearInterval(_sb);
      }
    }, 500);
    '__hidden_copyright'
    """
      : "";

  String get codeShowCopyright => copyrightSelector != null || codeSelectCopyright != null
      ? """
    var b = ${codeSelectCopyright!=null?codeSelectCopyright:'document.querySelector("$copyrightSelector")'};
    if (b) b.style.display = "block!important";
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

// custom provider