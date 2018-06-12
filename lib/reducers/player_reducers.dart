part of heist;

final playerReducer = combineReducers<List<Player>>([
  new TypedReducer<List<Player>, UpdateStateAction<List<Player>>>(reduce),
]);
