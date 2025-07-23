import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../utils.dart';

class Counter extends StateNotifier<int> {
  Counter([super.initialValue = 0]);

  @override
  int get state => super.state;
  @override
  set state(int value) => super.state = value;

  void increment() => state++;
}

void main() {
  test('when selector throws, rebuild providers', () {}, skip: true);

  test('on provider that threw, exceptions bypass the selector', () {
    final container = createContainer();
    final dep = Provider<int>((ref) {
      throw UnimplementedError();
    });
    final provider = Provider<int>((ref) {
      return ref.watch(dep.select((value) => throw StateError('message')));
    });

    expect(
      () => container.read(provider),
      throwsUnimplementedError,
    );
  });

  test('throw when trying to use ref.read inside selectors during initial call',
      () {
    final dep = Provider((ref) => 0, name: 'dep');
    final provider = Provider(
      name: 'provider',
      (ref) {
        ref.watch(dep.select((value) => ref.read(dep)));
      },
    );
    final container = createContainer();

    expect(
      () => container.read(provider),
      throwsA(isA<AssertionError>()),
    );
  });

  test(
      'throw when trying to use ref.watch inside selectors during initial call',
      () {
    final dep = Provider((ref) => 0);
    final provider = Provider((ref) {
      ref.watch(dep.select((value) => ref.watch(dep)));
    });
    final container = createContainer();

    expect(
      () => container.read(provider),
      throwsA(isA<AssertionError>()),
    );
  });

  test(
      'throw when trying to use ref.listen inside selectors during initial call',
      () {
    final dep = Provider((ref) => 0);
    final provider = Provider((ref) {
      ref.watch(
        dep.select((value) {
          ref.listen(dep, (prev, value) {});
          return 0;
        }),
      );
    });
    final container = createContainer();

    expect(
      () => container.read(provider),
      throwsA(isA<AssertionError>()),
    );
  });

  test(
      'when selecting a provider, element.visitChildren visits the selected provider',
      () {
    final container = createContainer();
    final selected = StateNotifierProvider<StateController<int>, int>((ref) {
      return StateController(0);
    });
    final provider = Provider((ref) {
      ref.watch(selected.select((value) => null));
    });

    final element = container.readProviderElement(provider);
    final selectedElement = container.readProviderElement(selected);

    final ancestors = <ProviderElementBase<Object?>>[];
    element.visitAncestors(ancestors.add);

    expect(ancestors, [selectedElement]);
  });

  test('can watch selectors', () {
    final container = createContainer();
    final provider = StateNotifierProvider<StateController<int>, int>(
      name: 'provider',
      (ref) => StateController(0),
    );
    final isEvenSelector = Selector<int, bool>(false, (c) => c.isEven);
    final isEvenListener = Listener<bool>();
    var buildCount = 0;

    final another = Provider<bool>(
      name: 'another',
      (ref) {
        buildCount++;
        return ref.watch(provider.select(isEvenSelector.call));
      },
    );

    container.listen(another, isEvenListener.call, fireImmediately: true);

    expect(buildCount, 1);
    verifyOnly(isEvenListener, isEvenListener(null, true));
    verifyOnly(isEvenSelector, isEvenSelector(0));

    container.read(provider.notifier).state = 2;

    expect(container.read(another), true);
    expect(buildCount, 1);
    verifyOnly(isEvenSelector, isEvenSelector(2));
    verifyNoMoreInteractions(isEvenListener);

    container.read(provider.notifier).state = 3;

    expect(container.read(another), false);
    expect(buildCount, 2);
    verify(isEvenSelector(3)).called(2);
    verifyOnly(isEvenListener, isEvenListener(true, false));
  });

  test('Provider.family', () async {
    final computed =
        Provider.family<String, AlwaysAliveProviderBase<int>>((ref, provider) {
      return ref.watch(provider).toString();
    });
    final notifier = Counter();
    final provider = StateNotifierProvider<Counter, int>((_) {
      return notifier;
    });
    final container = createContainer();
    final listener = Listener<String>();

    container.listen(computed(provider), listener.call, fireImmediately: true);

    verifyOnly(listener, listener(null, '0'));

    notifier.state = 42;
    await container.pump();

    verifyOnly(listener, listener('0', '42'));
  });

  test(
      'multiple ref.watch, when one of them forces re-evaluate, all dependencies are still flushed',
      () async {
    final container = createContainer();
    final notifier = Notifier(0);
    final provider = StateNotifierProvider<Notifier<int>, int>((_) {
      return notifier;
    });
    var callCount = 0;
    final computed = Provider((ref) {
      callCount++;
      return ref.watch(provider);
    });

    final tested = Provider((ref) {
      final first = ref.watch(provider);
      final second = ref.watch(computed);
      return '$first $second';
    });
    final listener = Listener<String>();

    container.listen(tested, listener.call, fireImmediately: true);

    verifyOnly(listener, listener(null, '0 0'));
    expect(callCount, 1);

    notifier.setState(1);
    await container.pump();

    verifyOnly(listener, listener('0 0', '1 1'));
    expect(callCount, 2);
  });

  test('the value is cached between multiple listeners', () {
    final container = createContainer();
    final notifier = Notifier(0);
    final provider = StateNotifierProvider<Notifier<int>, int>((_) {
      return notifier;
    });
    var callCount = 0;
    final computed = Provider((ref) {
      callCount++;
      return [ref.watch(provider)];
    });

    late List<int> first;
    final firstListener = Listener<List<int>>();
    container.listen<List<int>>(
      computed,
      fireImmediately: true,
      (prev, value) {
        first = value;
        firstListener(prev, value);
      },
    );

    late List<int> second;
    final secondListener = Listener<List<int>>();
    container.listen<List<int>>(
      computed,
      fireImmediately: true,
      (prev, value) {
        second = value;
        secondListener(prev, value);
      },
    );

    expect(first, [0]);
    expect(callCount, 1);
    expect(identical(first, second), isTrue);
    verifyInOrder([
      firstListener(null, [0]),
      secondListener(null, [0]),
    ]);
    verifyNoMoreInteractions(firstListener);
    verifyNoMoreInteractions(secondListener);
  });

  test('Simple Provider flow', () async {
    final container = createContainer();
    final notifier = Notifier(0);
    final provider = StateNotifierProvider<Notifier<int>, int>((_) {
      return notifier;
    });
    final listener = Listener<bool>();
    var callCount = 0;
    final isPositiveComputed = Provider((ref) {
      callCount++;
      return !ref.watch(provider).isNegative;
    });

    container.listen(isPositiveComputed, listener.call, fireImmediately: true);

    expect(notifier.hasListeners, true);
    verifyOnly(listener, listener(null, true));
    expect(callCount, 1);

    notifier.setState(-1);
    await container.pump();

    expect(callCount, 2);
    verifyOnly(listener, listener(true, false));

    notifier.setState(-42);
    await container.pump();

    expect(callCount, 3);
    verifyNoMoreInteractions(listener);
  });
}

class Notifier<T> extends StateNotifier<T> {
  Notifier(super._state);

  // ignore: use_setters_to_change_properties
  void setState(T value) => state = value;
}
