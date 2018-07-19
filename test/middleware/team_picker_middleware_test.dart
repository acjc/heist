import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, new PickPlayerMiddlewareAction(myId));
    expect(teamIds(store.state).single, myId);
    expect(teamNames(store.state).single, '_name');

    await handle(store, new RemovePlayerMiddlewareAction(myId));
    expect(teamIds(store.state), isEmpty);
    expect(teamNames(store.state), isEmpty);
  });

  test('test resolve auction winners', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    List<String> otherPlayers =
        getPlayers(store.state).where((p) => p.id != myId).map((p) => p.id).toList();
    for (String playerId in otherPlayers) {
      await handle(store, new SubmitBidAction(playerId, 9));
    }
    await handle(store, new SubmitBidAction(myId, 10));

    await handle(store, new ResolveAuctionWinnersAction());
    expect(teamIds(store.state), containsAll([myId, otherPlayers[0]]));
  });
}
