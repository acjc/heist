part of heist;

final roundReducer = combineReducers<Map<Heist, List<Round>>>([
  new TypedReducer<Map<Heist, List<Round>>, UpdateStateAction<Map<Heist, List<Round>>>>(reduce),
]);
