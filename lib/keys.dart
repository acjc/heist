import 'package:flutter/material.dart';

/// These keys caused various bugs unless I made them static in a different file...
class Keys {
  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  static final GlobalKey<FormState> homePageNameKey = new GlobalKey<FormState>();
  static final GlobalKey<FormState> homePageCodeKey = new GlobalKey<FormState>();
  static final GlobalKey<FormState> createRoomPageNameKey = new GlobalKey<FormState>();
}
