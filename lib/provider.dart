import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';

abstract class Provider {

  // get the code back

  String url; // url to load
  String html; // html 

  String isInited; // code to check 
  
  Provider();

  /// initialize a provider
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value();
  }

  /// set a special user for current instance
  Future<String> setUser(User user) {
    return Future.value();
  }

  /// send message with a special user
  Future<String> sendMessage(Message msg, { User user }) {
    return Future.value();
  }

  /// set field
  Future<String> setValue(String key, dynamic value) {
    return Future.value();
  }

  /// TODO: initialized
}