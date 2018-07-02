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

  Widget _mainBoardBody() =>
      new StoreConnector<GameModel, MainBoardViewModel>(
          converter: (store) => new MainBoardViewModel._(
              heistIsActive(store.state),
              requestInProcess(store.state, Request.ResolvingAuction),
              goingOnHeist(store.state),
              !currentRound(store.state).teamSubmitted,
              isMyGo(store.state),
              biddingComplete(store.state),
              heistComplete(store.state)),
          distinct: true,
          builder: (context, viewModel) {

            // team picking (not needed for auctions)
            if (!isAuction(_store.state) && viewModel.waitingForTeam) {
              return viewModel.isMyGo ? teamPicker(_store) : waitForTeam(_store);
            }

            // bidding
            if (!viewModel.biddingComplete) {
              return bidding(_store);
            }

            if (!viewModel.heistComplete) {
              if (amOwner(_store.state)) {
                // TODO: add up pot
              }
              return centeredMessage('Resolving bids...');
            }

            // active heist
            if (viewModel.heistIsActive) {
              if (isAuction(_store.state) && viewModel.waitingForTeam) {
                return _resolveAuctionWinners(viewModel.resolvingAuction);
              }
              return viewModel.goingOnHeist ? makeDecision(context, _store) : observeHeist(_store);
            }

            // TODO: go to new round
            return new Container();
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
        converter: (store) => new LoadingScreenViewModel._(
            roomIsAvailable(store.state),
            waitingForPlayers(store.state),
            isNewGame(store.state),
            getPlayers(store.state).length),
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

  LoadingScreenViewModel._(this.roomIsAvailable, this.waitingForPlayers, this.isNewGame,
      this.playersSoFar);

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
  final bool heistIsActive;
  final bool resolvingAuction;
  final bool goingOnHeist;
  final bool waitingForTeam;
  final bool isMyGo;
  final bool biddingComplete;
  final bool heistComplete;

  MainBoardViewModel._(this.heistIsActive, this.resolvingAuction, this.goingOnHeist,
      this.waitingForTeam, this.isMyGo, this.biddingComplete, this.heistComplete);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MainBoardViewModel &&
              heistIsActive == other.heistIsActive &&
              resolvingAuction == other.resolvingAuction &&
              goingOnHeist == other.goingOnHeist &&
              waitingForTeam == other.waitingForTeam &&
              isMyGo == other.isMyGo &&
              biddingComplete == other.biddingComplete &&
              heistComplete == other.heistComplete;

  @override
  int get hashCode =>
      heistIsActive.hashCode ^
      resolvingAuction.hashCode ^
      goingOnHeist.hashCode ^
      waitingForTeam.hashCode ^
      isMyGo.hashCode ^
      biddingComplete.hashCode ^
      heistComplete.hashCode;

  @override
  String toString() {
    return 'MainBoardViewModel{heistIsActive: $heistIsActive, resolvingAuction: $resolvingAuction, goingOnHeist: $goingOnHeist, waitingForTeam: $waitingForTeam, isMyGo: $isMyGo, biddingComplete: $biddingComplete, heistComplete: $heistComplete}';
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
