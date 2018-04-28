library heist;

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:meta/meta.dart';

part 'database_model.dart';
part 'home_page.dart';

void main() => runApp(new MyApp());

const int _minPlayers = 5;
const int _maxPlayers = 10;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Heist',
        theme: new ThemeData(
          primaryColor: Colors.deepOrange,
        ),
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text("Heist"),
          ),
          body: new HomePage(),
        ));
  }
}


