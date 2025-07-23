import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('ProviderObserver', () {
    test('life-cycles do nothing by default', () {
      const observer = ConstObserver();

      final provider = Provider((ref) => 0);
      final container = createContainer();

      observer.didAddProvider(provider, 0, container);
      observer.didDisposeProvider(provider, container);
      observer.didUpdateProvider(provider, 0, 0, container);
      observer.providerDidFail(provider, 0, StackTrace.empty, container);
    });

    test('ProviderObservers can have const constructors', () {
      final root = createContainer(
        observers: [
          const ConstObserver(),
        ],
      );

      root.dispose();
    });

    group('providerDidFail', () {
      test('is called on uncaught error during first initialization', () {
        final observer = ObserverMock();
        final observer2 = ObserverMock();
        final container = createContainer(observers: [observer, observer2]);
        final provider = Provider((ref) => throw UnimplementedError());

        expect(
          () => container.read(provider),
          throwsUnimplementedError,
        );

        verifyInOrder([
          observer.didAddProvider(provider, null, container),
          observer2.didAddProvider(provider, null, container),
          observer.providerDidFail(
            provider,
            argThat(isUnimplementedError),
            argThat(isNotNull),
            container,
          ),
          observer2.providerDidFail(
            provider,
            argThat(isUnimplementedError),
            argThat(isNotNull),
            container,
          ),
        ]);
        verifyNoMoreInteractions(observer);
      });
    });

    group('didAddProvider', () {
      test('when throwing during creation, receives `null` as value', () {
        final observer = ObserverMock();
        final container = createContainer(observers: [observer]);
        final provider = Provider((ref) => throw UnimplementedError());

        expect(
          () => container.read(provider),
          throwsUnimplementedError,
        );

        verify(observer.didAddProvider(provider, null, container));
      });

      test(
          'on scoped ProviderContainer, applies both child and ancestors observers',
          () {
        final provider = Provider((ref) => 0);
        final observer = ObserverMock();
        final observer2 = ObserverMock();
        final observer3 = ObserverMock();
        final root = createContainer(observers: [observer]);
        final mid = createContainer(
          parent: root,
          observers: [observer2],
        );
        final child = createContainer(
          parent: mid,
          overrides: [provider.overrideWithValue(42)],
          observers: [observer3],
        );

        expect(child.read(provider), 42);

        verifyInOrder([
          observer3.didAddProvider(provider, 42, child),
          observer2.didAddProvider(provider, 42, child),
          observer.didAddProvider(provider, 42, child),
        ]);

        expect(mid.read(provider), 0);

        verify(observer.didAddProvider(provider, 0, root)).called(1);

        verifyNoMoreInteractions(observer3);
        verifyNoMoreInteractions(observer2);
        verifyNoMoreInteractions(observer);
      });

      test('works', () {
        final observer = ObserverMock();
        final observer2 = ObserverMock();
        final provider = Provider((_) => 42);
        final container = createContainer(observers: [observer, observer2]);

        expect(container.read(provider), 42);
        verifyInOrder([
          observer.didAddProvider(
            provider,
            42,
            container,
          ),
          observer2.didAddProvider(
            provider,
            42,
            container,
          ),
        ]);
        verifyNoMoreInteractions(observer);
        verifyNoMoreInteractions(observer2);
      });

      test('guards against exceptions', () {
        final observer = ObserverMock();
        when(observer.didAddProvider(any, any, any)).thenThrow('error1');
        final observer2 = ObserverMock();
        when(observer2.didAddProvider(any, any, any)).thenThrow('error2');
        final observer3 = ObserverMock();
        final provider = Provider((_) => 42);
        final container = createContainer(
          observers: [observer, observer2, observer3],
        );

        final errors = <Object>[];
        final result = runZonedGuarded(
          () => container.read(provider),
          (err, stack) {
            errors.add(err);
          },
        );

        expect(result, 42);
        expect(errors, ['error1', 'error2']);
        verifyInOrder([
          observer.didAddProvider(provider, 42, container),
          observer2.didAddProvider(provider, 42, container),
          observer3.didAddProvider(provider, 42, container),
        ]);
        verifyNoMoreInteractions(observer);
      });
    });
  });

  group('didDisposeProvider', () {
    test('supports invalidate', () {
      final observer = ObserverMock();
      final container = createContainer(observers: [observer]);
      final provider = Provider<int>((ref) => 0);

      container.read(provider);
      clearInteractions(observer);

      container.invalidate(provider);
      verifyOnly(observer, observer.didDisposeProvider(provider, container));

      container.invalidate(provider);
      verifyNoMoreInteractions(observer);
    });

    test('is guarded', () {
      final observer = ObserverMock();
      when(observer.didDisposeProvider(any, any)).thenThrow('error1');
      final observer2 = ObserverMock();
      when(observer2.didDisposeProvider(any, any)).thenThrow('error2');
      final observer3 = ObserverMock();
      final onDispose = OnDisposeMock();
      final provider = Provider((ref) {
        ref.onDispose(onDispose.call);
        return 0;
      });
      final provider2 = Provider((ref) => ref.watch(provider));
      final container = createContainer(
        observers: [observer, observer2, observer3],
      );

      expect(container.read(provider), 0);
      expect(container.read(provider2), 0);
      clearInteractions(observer);
      clearInteractions(observer2);
      clearInteractions(observer3);
      verifyNoMoreInteractions(onDispose);

      final errors = <Object>[];
      runZonedGuarded(container.dispose, (err, stack) => errors.add(err));

      expect(errors, ['error1', 'error2', 'error1', 'error2']);
      verifyInOrder([
        observer.didDisposeProvider(provider2, container),
        observer2.didDisposeProvider(provider2, container),
        observer3.didDisposeProvider(provider2, container),
        onDispose(),
        observer.didDisposeProvider(provider, container),
        observer2.didDisposeProvider(provider, container),
        observer3.didDisposeProvider(provider, container),
      ]);
      verifyNoMoreInteractions(onDispose);
      verifyNoMoreInteractions(observer);
      verifyNoMoreInteractions(observer2);
      verifyNoMoreInteractions(observer3);
    });
  });
}

class OnDisposeMock extends Mock {
  void call();
}

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() => state++;

  // ignore: use_setters_to_change_properties
  void setState(int value) => state = value;
}

class ConstObserver extends ProviderObserver {
  const ConstObserver();
}
