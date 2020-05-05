import 'package:flutter/material.dart';
import 'package:flutter_customer_chat/controller.dart';
import 'package:flutter_customer_chat/provider.dart';
import 'package:flutter_customer_chat/webview.dart';

class ChatView extends StatefulWidget {

  final Provider provider;

  final void Function(Controller controller) onCreated;

  ChatView(this.provider, { this.onCreated });

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

  Controller _controller;

  @override
  void initState() {
    super.initState();

    _controller = Controller(widget.provider);

    widget.onCreated?.call(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Webview();
  }
}