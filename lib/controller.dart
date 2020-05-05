

import 'package:flutter_customer_chat/provider.dart';

class Controller {

  final Provider _provider;
  
  Controller(this._provider);

  // controller for user to controller everything.

  Provider get provider => _provider;
}