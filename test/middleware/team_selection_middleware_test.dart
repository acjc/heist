import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/middleware/team_selection_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, PickPlayerMiddlewareAction(myId));
    Player onlyExclusion = currentExclusions(store.state).single;
    expect(onlyExclusion.id, myId);
    expect(onlyExclusion.name, '_name');

    await handle(store, RemovePlayerMiddlewareAction(myId));
    expect(currentExclusions(store.state), isEmpty);
  });

  test('test resolve auction winners', () async {
    Store<GameModel> store = await initGame();
    Player me = getSelf(store.state);

    List<Player> otherPlayers = getOtherPlayers(store.state);
    for (Player player in otherPlayers) {
      await handle(store, SubmitBidAction(player.id, 9));
    }
    await handle(store, SubmitBidAction(me.id, 10));

    await handle(store, ResolveAuctionWinnersAction());
    expect(currentTeam(store.state), containsAll([me, otherPlayers[0]]));
  });
}
