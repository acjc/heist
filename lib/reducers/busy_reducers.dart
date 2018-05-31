part of heist;

final busyReducer = combineReducers<bool>([
  new TypedReducer<bool, MarkAsBusyAction>(reduce),
  new TypedReducer<bool, UnmarkAsBusyAction>(reduce),
]);

class MarkAsBusyAction extends Action<bool> {

  @override
  bool reduce(bool state, action) {
    return true;
  }
}

class UnmarkAsBusyAction extends Action<bool> {

  @override
  bool reduce(bool state, action) {
    return false;
  }
}
