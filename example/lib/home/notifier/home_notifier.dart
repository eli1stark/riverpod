import 'package:example/home/notifier/home_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _N = HomeNotifier;
typedef _S = HomeState;

final homeNotipod = NotifierProvider<_N, _S>(
  HomeNotifier.new,
  name: 'homeNotipod',
);

class HomeNotifier extends Notifier<_S> {
  @override
  _S build() {
    return HomeState(
      name: 'Jason',
      age: 21,
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
  }
}
