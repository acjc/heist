part of heist;

final heistReducer = combineReducers<List<Heist>>([
  new TypedReducer<List<Heist>, UpdateStateAction<List<Heist>>>(reduce),
]);
