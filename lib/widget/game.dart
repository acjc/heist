part of heist;

class Game extends StatefulWidget {
  final Store<GameModel> _store;

  Game(this._store);

  @override
  State<StatefulWidget> createState() {
    return new GameState(_store);
  }
}

class GameState extends State<Game> {
  final Store<GameModel> _store;

  GameState(this._store);

  @override
  void initState() {
    super.initState();
    _store.dispatch(new LoadGameAction());
  }

  @override
  void dispose() {
    resetGameStore(_store);
    super.dispose();
  }

  Widget _loading() {
    return centeredMessage('Loading...');
  }

  Widget _resolveAuctionWinners(bool resolvingAuction) {
    if (amOwner(_store.state) && !resolvingAuction) {
      _store.dispatch(new ResolveAuctionWinnersAction());
    }
    return centeredMessage('Resolving auction...');
  }

  Widget _mainBoardBody() => new StoreConnector<GameModel, MainBoardViewModel>(
      converter: (store) => new MainBoardViewModel._(
          waitingForTeam: !currentRound(store.state).teamSubmitted,
          biddingComplete: biddingComplete(store.state),
          resolvingAuction: requestInProcess(store.state, Request.ResolvingAuction),
          roundComplete: currentRound(store.state).completed,
          heistIsActive: heistIsActive(store.state),
          heistDecided: heistDecided(store.state),
          completingHeist: requestInProcess(store.state, Request.CompletingHeist),
          heistComplete: currentHeist(store.state).completed),
      distinct: true,
      builder: (context, viewModel) {
        // team picking (not needed for auctions)
        if (!isAuction(_store.state) && viewModel.waitingForTeam) {
          return isMyGo(_store.state) ? teamPicker(_store) : waitForTeam(_store);
        }

        // bidding
        if (!viewModel.biddingComplete) {
          return bidding(_store);
        }

        // resolve round
        if (!viewModel.roundComplete) {
          return roundEnd(_store);
        }

        // resolve auction
        if (isAuction(_store.state) && viewModel.waitingForTeam) {
          return _resolveAuctionWinners(viewModel.resolvingAuction);
        }

        // active heist
        if (viewModel.heistIsActive) {
          return goingOnHeist(_store.state) ? makeDecision(context, _store) : observeHeist(_store);
        }

        // heist has happened
        if (heistDecided(_store.state) && !viewModel.heistComplete) {
          return heistEnd(_store);
        }

        // TODO: go to new round with new leader
        return centeredMessage('Loading next round...');
      });

  Widget _secretBoardBody() => new StoreConnector<GameModel, Player>(
      converter: (store) => getSelf(store.state),
      distinct: true,
      builder: (context, me) => new Card(
          elevation: 2.0,
          child: new ListTile(
            title: new Text(
              "${me.name} (${me.role})",
              style: infoTextStyle,
            ),
          )));

  Widget _loadingScreen() => new StoreConnector<GameModel, LoadingScreenViewModel>(
        converter: (store) => new LoadingScreenViewModel._(roomIsAvailable(store.state),
            waitingForPlayers(store.state), isNewGame(store.state), getPlayers(store.state).length),
        distinct: true,
        builder: (context, viewModel) {
          if (!viewModel.roomIsAvailable) {
            return _loading();
          }

          if (viewModel.waitingForPlayers) {
            return centeredMessage(
                'Waiting for players: ${viewModel.playersSoFar} / ${getRoom(_store.state).numPlayers}');
          }

          if (viewModel.isNewGame) {
            return centeredMessage('Assigning roles...');
          }

          return _loading();
        },
      );

  Widget _mainBoard() => new StoreConnector<GameModel, bool>(
      converter: (store) => gameIsReady(store.state),
      distinct: true,
      builder: (context, gameIsReady) => new Expanded(
            child: gameIsReady ? _mainBoardBody() : _loadingScreen(),
          ));

  Widget _secretBoard() => new StoreConnector<GameModel, bool>(
      converter: (store) => gameIsReady(store.state),
      distinct: true,
      builder: (context, gameIsReady) => new Expanded(
            child: gameIsReady ? _secretBoardBody() : _loadingScreen(),
          ));

  Widget _tabView() => new TabBarView(
        children: [
          new Column(children: [_mainBoard(), _gameHistory(_store)]),
          new Column(children: [_playerInfo(_store), _secretBoard()]),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Room: ${getRoom(_store.state).code}"),
          bottom: new TabBar(
            tabs: [
              new Tab(text: 'GAME'),
              new Tab(text: 'SECRET'),
            ],
          ),
        ),
        endDrawer: isDebugMode() ? new Drawer(child: new ReduxDevTools<GameModel>(_store)) : null,
        body: _tabView(),
      ),
    );
  }
}

class LoadingScreenViewModel {
  final bool roomIsAvailable;
  final bool waitingForPlayers;
  final bool isNewGame;
  final int playersSoFar;

  LoadingScreenViewModel._(
      this.roomIsAvailable, this.waitingForPlayers, this.isNewGame, this.playersSoFar);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingScreenViewModel &&
          roomIsAvailable == other.roomIsAvailable &&
          waitingForPlayers == other.waitingForPlayers &&
          isNewGame == other.isNewGame &&
          playersSoFar == other.playersSoFar;

  @override
  int get hashCode =>
      roomIsAvailable.hashCode ^
      waitingForPlayers.hashCode ^
      isNewGame.hashCode ^
      playersSoFar.hashCode;

  @override
  String toString() {
    return 'LoadingScreenViewModel{roomIsAvailable: $roomIsAvailable, waitingForPlayers: $waitingForPlayers, isNewGame: $isNewGame, playersSoFar: $playersSoFar}';
  }
}

class MainBoardViewModel {
  final bool waitingForTeam;
  final bool biddingComplete;
  final bool resolvingAuction;
  final bool roundComplete;
  final bool heistIsActive;
  final bool heistDecided;
  final bool completingHeist;
  final bool heistComplete;

  MainBoardViewModel._(
      {@required this.waitingForTeam,
      @required this.biddingComplete,
      @required this.resolvingAuction,
      @required this.roundComplete,
      @required this.heistIsActive,
      @required this.heistDecided,
      @required this.completingHeist,
      @required this.heistComplete});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainBoardViewModel &&
          waitingForTeam == other.waitingForTeam &&
          biddingComplete == other.biddingComplete &&
          resolvingAuction == other.resolvingAuction &&
          roundComplete == other.roundComplete &&
          heistIsActive == other.heistIsActive &&
          heistDecided == other.heistDecided &&
          completingHeist == other.completingHeist &&
          heistComplete == other.heistComplete;

  @override
  int get hashCode =>
      waitingForTeam.hashCode ^
      biddingComplete.hashCode ^
      resolvingAuction.hashCode ^
      roundComplete.hashCode ^
      heistIsActive.hashCode ^
      heistDecided.hashCode ^
      completingHeist.hashCode ^
      heistComplete.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{waitingForTeam: $waitingForTeam, biddingComplete: $biddingComplete, resolvingAuction: $resolvingAuction, roundComplete: $roundComplete, heistIsActive: $heistIsActive, heistDecided: $heistDecided, completingHeist: $completingHeist, heistComplete: $heistComplete}';
  }
}

void resetGameStore(Store<GameModel> store) {
  store.dispatch(new ClearAllPendingRequestsAction());
  store.dispatch(new CancelSubscriptionsAction());
  store.dispatch(new UpdateStateAction<Room>(new Room.initial()));
  store.dispatch(new UpdateStateAction<List<Player>>([]));
  store.dispatch(new UpdateStateAction<List<Heist>>([]));
  store.dispatch(new UpdateStateAction<Map<Heist, List<Round>>>({}));
}
