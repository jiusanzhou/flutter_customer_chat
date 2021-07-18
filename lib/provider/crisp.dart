import 'dart:convert';

import 'package:flutter_customer_chat/models/message.dart';
import 'package:flutter_customer_chat/models/user.dart';
import 'package:flutter_customer_chat/provider.dart';

/// CrispProvider scrisp
class CrispProvider extends ChatProvider {
  /// onweb or native ???
  ///
  /// for now only suppoted web
  ///

  ///
  final String basicUrl;
  final String websiteID;

  CrispProvider(
    this.websiteID, {
    this.basicUrl: 'https://go.crisp.chat',
  }) : super();

  @override
  String get url => "$basicUrl/chat/embed/?website_id=$websiteID";

  @override
  String get isInited => "typeof \$crisp !== 'undefined'";

  @override
  String get copyrightSelector =>
      "#crisp-chatbox > div > div > div\:nth-child(2) > div > div\:nth-child(7)";

  /// initialize a provider
  @override
  Future<String> initialize({Map<String, dynamic> config: const {}}) {
    return Future.value("");
  }

  /// set a special user for current instance
  @override
  Future<String> setUser(User user) {
    return Future.value((user.email != null
            ? "\$crisp.push([\"set\", \"user:email\", [\"${user.email}\"]]);"
            : "") +
        (user.nickname != null
            ? "\$crisp.push([\"set\", \"user:nickname\", [\"${user.nickname}\"]]);"
            : "") +
        (user.phone != null
            ? "\$crisp.push([\"set\", \"user:phone\", [\"${user.phone}\"]]);"
            : "") +
        (user.avatar != null
            ? "\$crisp.push([\"set\", \"user:avatar\", [\"${user.avatar}\"]]);"
            : ""));
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
    return Future.value("\$crisp.push([\"set\", \"$key\", [$data]])");
  }
}
