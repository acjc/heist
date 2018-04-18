import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

const minPlayers = 5;
const maxPlayers = 10;

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
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _numPlayers = minPlayers;

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
        style: new TextStyle(
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
                      if (_numPlayers > minPlayers) _numPlayers--;
                    })),
            numPlayersText,
            buildArrowColumn(
                Icons.arrow_forward,
                () => setState(() {
                      if (_numPlayers < maxPlayers) _numPlayers++;
                    }))
          ],
        )
      ],
    );

    void createRoom() {
      print('CREATE ROOM');
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [numPlayers, createRoomButton],
    );
  }
}
