import 'package:flutter/material.dart';

class User {
  String email;
  String nickname;
  String phone;
  String avatar;

  User({
    this.email,
    this.avatar,
    this.nickname,
    @required this.phone,
  }) : assert(phone != null);
}