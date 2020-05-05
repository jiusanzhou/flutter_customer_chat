import 'package:flutter/cupertino.dart';
import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';

abstract class Provider {

  String url; // url to load

  /// initialize a provider
  @protected
  Future<void> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value();
  }

  /// set a special user for current instance
  @protected
  Future<User> setUser(User user) {
    return Future.value();
  }

  //// send message with a special user
  @protected
  Future<void> sendMessage(Message msg, { User user }) {
    return Future.value();
  }
}