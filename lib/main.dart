import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'database_model.dart';

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

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  int _numPlayers = _minPlayers;

  @override
  Widget build(BuildContext context) {
    Column buildArrowColumn(IconData icon, Function onPressed) {
      Color color = Theme.of(context).primaryColor;
      return new Column(
        children: [
          new IconButton(
            iconSize: 64.0,
            onPressed: onPressed,
            icon: new Icon(icon, color: color),
          )
        ],
      );
    }

    Widget numPlayersText = new Container(
      padding: const EdgeInsets.all(32.0),
      child: new Text(
        _numPlayers.toString(),
        style: const TextStyle(
          fontSize: 32.0,
        ),
      ),
    );

    Widget numPlayersTitle = new Container(
      padding: const EdgeInsets.all(32.0),
      child: const Text(
        "Choose number of players:",
        style: const TextStyle(fontSize: 16.0),
      ),
    );

    Widget numPlayers = new Column(
      children: [
        numPlayersTitle,
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildArrowColumn(
                Icons.arrow_back,
                () => setState(() {
                      if (_numPlayers > _minPlayers) _numPlayers--;
                    })),
            numPlayersText,
            buildArrowColumn(
                Icons.arrow_forward,
                () => setState(() {
                      if (_numPlayers < _maxPlayers) _numPlayers++;
                    }))
          ],
        )
      ],
    );

    int _getCapitalLetterOrdinal(Random random) {
      return random.nextInt(26) + 65; // 65 is 'A' in ASCII
    }

    String _generateCode() {
      Random random = new Random();
      List<int> numbers = [
        _getCapitalLetterOrdinal(random),
        _getCapitalLetterOrdinal(random),
        _getCapitalLetterOrdinal(random),
        _getCapitalLetterOrdinal(random)
      ];
      return new String.fromCharCodes(numbers);
    }

    void createRoom() {
      print('CREATE ROOM');

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        // TODO: get the right roles
        final Set<String> roles = new Set<String>();
        roles.addAll(['ACCOUNTANT', 'KINGPIN', 'LEAD_AGENT']);

        // create the room in the database
        Firestore.instance.collection('rooms').document().setData(new Room(
                appVersion: packageInfo.version,
                code: _generateCode(),
                createdAt: new DateTime.now(),
                numPlayers: _numPlayers,
                roles: roles)
            .toJson());
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Your room has been created"),
            ));
      });
    }

    Widget createRoomButton = new Container(
      padding: const EdgeInsets.all(32.0),
      child: new RaisedButton(
        child: const Text('CREATE ROOM',
            style: const TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: createRoom,
        color: Theme.of(context).primaryColor,
      ),
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [numPlayers, createRoomButton, _buildRoomList()],
    );
  }

  Widget _buildRoomList() {
    return new Expanded(
        child: new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('rooms').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return new Text('Loading...');
        }

        final tiles = snapshot.data.documents.map((DocumentSnapshot document) {
          Room room = new Room.fromJson(document.data);
          return new ListTile(
            title: new Text(room.code),
            subtitle: new Text(room.createdAt.toString()),
          );
        }).toList();

        final dividedTiles = ListTile
            .divideTiles(
              context: context,
              tiles: tiles,
            )
            .toList();

        return new ListView(
          children: dividedTiles,
        );
      },
    ));
  }
}
