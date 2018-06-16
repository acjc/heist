import 'dart:async';
import 'package:redux/redux.dart';
import 'package:uuid/uuid.dart';
import 'package:heist/main.dart';

Future<void> handle(Store<GameModel> store, MiddlewareAction action) {
  return action.handle(store, action, null);
}

String uuid() {
  return new Uuid().v4();
}

