part of heist;

final roundReducer = combineReducers<Map<String, List<Round>>>([
  new TypedReducer<Map<String, List<Round>>, UpdateStateAction<Map<String, List<Round>>>>(reduce),
]);
