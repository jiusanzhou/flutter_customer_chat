import 'package:flutter/material.dart';
import 'package:flutter_zoewebview/flutter_zoewebview.dart';
import 'package:flutter_customer_chat/flutter_customer_chat.dart';
import 'package:flutter_customer_chat/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.title, this.provider, {Key key}) : super(key: key);

  final String title;
  final ChatProvider provider;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: ChatView(
          widget.provider,
          webviewType: WebviewType.InappWebview,
          hiddenCopyright: true,
        ),
      ),
    );
  }
}
