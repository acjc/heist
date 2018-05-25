part of heist;

final playerReducer = combineReducers<Set<Player>>([
  new TypedReducer<Set<Player>, UpdateStateAction<Set<Player>>>(reduce),
]);
