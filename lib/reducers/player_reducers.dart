part of heist;

final playerReducer = combineReducers<Player>([
  new TypedReducer<Player, UpdateStateAction<Player>>(reduce),
]);
