import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../utils.dart';

void main() {
  group('Ref.listenSelf', () {
    test('does not break autoDispose', () async {
      final container = createContainer();
      final provider = Provider.autoDispose((ref) {
        ref.listenSelf((previous, next) {});
      });

      container.read(provider);
      expect(container.getAllProviderElements(), [anything]);

      await container.pump();

      expect(container.getAllProviderElements(), isEmpty);
    });

    test('listens to mutations post build', () async {
      final container = createContainer();
      final listener = Listener<int>();
      final listener2 = Listener<int>();

      late ProviderRef<int> ref;
      final provider = Provider<int>((r) {
        ref = r;
        ref.listenSelf(listener.call);
        ref.listenSelf(listener2.call);

        return 0;
      });

      container.read(provider);

      verifyInOrder([
        listener(null, 0),
        listener2(null, 0),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);

      ref.state = 42;

      verifyInOrder([
        listener(0, 42),
        listener2(0, 42),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);
    });

    test('listens to rebuild', () async {
      final container = createContainer();
      final listener = Listener<int>();
      final listener2 = Listener<int>();
      var result = 0;
      final provider = Provider<int>((ref) {
        ref.listenSelf(listener.call);
        ref.listenSelf(listener2.call);

        return result;
      });

      container.read(provider);

      verifyInOrder([
        listener(null, 0),
        listener2(null, 0),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);

      result = 42;
      container.refresh(provider);

      verifyInOrder([
        listener(0, 42),
        listener2(0, 42),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);
    });

    test('notify listeners independently from updateShouldNotify', () async {
      final container = createContainer();
      final listener = Listener<int>();
      final listener2 = Listener<int>();
      final provider = Provider<int>((ref) {
        ref.listenSelf(listener.call);
        ref.listenSelf(listener2.call);

        return 0;
      });

      container.read(provider);

      verifyInOrder([
        listener(null, 0),
        listener2(null, 0),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);

      container.refresh(provider);

      verifyInOrder([
        listener(0, 0),
        listener2(0, 0),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);
    });

    test('clears state listeners on rebuild', () async {
      final container = createContainer();
      final listener = Listener<int>();
      final listener2 = Listener<int>();
      var result = 0;
      final provider = Provider<int>((ref) {
        if (result == 0) {
          ref.listenSelf(listener.call);
        } else {
          ref.listenSelf(listener2.call);
        }

        return result;
      });

      container.read(provider);

      verifyOnly(listener, listener(null, 0));
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);

      result = 42;
      container.refresh(provider);

      verifyOnly(listener2, listener2(0, 42));
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);
    });

    test('listens to errors', () {
      final container = createContainer();
      final listener = Listener<int>();
      final errorListener = ErrorListener();
      final errorListener2 = ErrorListener();
      var error = 42;
      final provider = Provider<int>((ref) {
        ref.listenSelf(listener.call, onError: errorListener.call);
        ref.listenSelf((prev, next) {}, onError: errorListener2.call);

        Error.throwWithStackTrace(error, StackTrace.empty);
      });

      expect(() => container.read(provider), throwsA(42));

      verifyZeroInteractions(listener);
      verifyInOrder([
        errorListener(42, StackTrace.empty),
        errorListener2(42, StackTrace.empty),
      ]);
      verifyNoMoreInteractions(errorListener);
      verifyNoMoreInteractions(errorListener2);

      error = 21;
      expect(() => container.refresh(provider), throwsA(21));

      verifyZeroInteractions(listener);

      verifyInOrder([
        errorListener(21, StackTrace.empty),
        errorListener2(21, StackTrace.empty),
      ]);
      verifyNoMoreInteractions(errorListener);
      verifyNoMoreInteractions(errorListener2);
    });

    test('executes error listener before other listeners', () {
      final container = createContainer();
      final errorListener = ErrorListener();
      final errorListener2 = ErrorListener();
      Exception? error;
      final provider = Provider<int>((ref) {
        ref.listenSelf((prev, next) {}, onError: errorListener.call);

        if (error != null) Error.throwWithStackTrace(error, StackTrace.empty);

        return 0;
      });

      container.listen(provider, (prev, next) {}, onError: errorListener2.call);

      verifyZeroInteractions(errorListener);
      verifyZeroInteractions(errorListener2);

      error = Exception();
      expect(() => container.refresh(provider), throwsA(error));

      verifyInOrder([
        errorListener(error, StackTrace.empty),
        errorListener2(error, StackTrace.empty),
      ]);
      verifyNoMoreInteractions(errorListener);
      verifyNoMoreInteractions(errorListener2);
    });

    test('executes state listener before other listeners', () {
      final container = createContainer();
      final listener = Listener<int>();
      final listener2 = Listener<int>();
      var result = 0;
      final provider = Provider<int>((ref) {
        ref.listenSelf(listener.call);
        return result;
      });

      container.listen(provider, listener2.call, fireImmediately: true);

      verifyInOrder([
        listener(null, 0),
        listener2(null, 0),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);

      result = 42;
      container.refresh(provider);

      verifyInOrder([
        listener(0, 42),
        listener2(0, 42),
      ]);
      verifyNoMoreInteractions(listener);
      verifyNoMoreInteractions(listener2);
    });

    test('listeners are not allowed to modify the state', () {});
  });

  group('Ref.listen', () {
    test(
        'when rebuild throws identical error/stack, listeners are still notified',
        () {
      final container = createContainer();
      const stack = StackTrace.empty;
      final listener = Listener<int>();
      final errorListener = ErrorListener();
      final provider = Provider<int>((ref) {
        Error.throwWithStackTrace(42, stack);
      });

      container.listen(
        provider,
        listener.call,
        onError: errorListener.call,
        fireImmediately: true,
      );

      verifyZeroInteractions(listener);
      verifyOnly(errorListener, errorListener(42, stack));

      expect(() => container.refresh(provider), throwsA(42));

      verifyZeroInteractions(listener);
      verifyOnly(errorListener, errorListener(42, stack));
    });

    test('cannot listen itself', () {
      final container = createContainer();
      final listener = Listener<int>();
      late ProviderRef<int> ref;
      late Provider<int> provider;
      provider = Provider<int>((r) {
        ref = r;
        ref.listen(provider, (previous, next) {});
        return 0;
      });

      expect(() => container.read(provider), throwsA(isAssertionError));

      ref.state = 42;

      verifyZeroInteractions(listener);
    });

    group('fireImmediately', () {
      test('when no onError is specified, fallbacks to handleUncaughtError',
          () {
        final container = createContainer();
        final dep = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errors = <Object>[];
        final provider = Provider((ref) {
          runZonedGuarded(
            () {
              ref.listen(
                dep,
                listener.call,
                fireImmediately: true,
              );
            },
            (err, stack) => errors.add(err),
          );
        });

        container.read(provider);

        verifyZeroInteractions(listener);
        expect(errors, [
          isUnimplementedError,
        ]);
      });

      test(
          'when no onError is specified on selectors, fallbacks to handleUncaughtError',
          () {
        final container = createContainer();
        final dep = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errors = <Object>[];
        final provider = Provider((ref) {
          runZonedGuarded(
            () {
              ref.listen(
                dep.select((value) => value),
                listener.call,
                fireImmediately: true,
              );
            },
            (err, stack) => errors.add(err),
          );
        });

        container.read(provider);

        verifyZeroInteractions(listener);
        expect(errors, [
          isUnimplementedError,
        ]);
      });

      test('on provider that threw, fireImmediately calls onError', () {
        final container = createContainer();
        final dep = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errorListener = ErrorListener();
        final provider = Provider((ref) {
          ref.listen(
            dep,
            listener.call,
            onError: errorListener.call,
            fireImmediately: true,
          );
        });

        container.read(provider);

        verifyZeroInteractions(listener);
        verifyOnly(
          errorListener,
          errorListener(isUnimplementedError, argThat(isNotNull)),
        );
      });

      test('when selecting provider that threw, fireImmediately calls onError',
          () {
        final container = createContainer();
        final dep = Provider<String>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errorListener = ErrorListener();
        final provider = Provider((ref) {
          ref.listen<int>(
            dep.select((value) => 0),
            listener.call,
            onError: errorListener.call,
            fireImmediately: true,
          );
        });

        container.read(provider);

        verifyZeroInteractions(listener);
        verifyOnly(
          errorListener,
          errorListener(isUnimplementedError, argThat(isNotNull)),
        );
      });
    });
  });

  group('ProviderContainer.listen', () {
    group('fireImmediately', () {
      test('when no onError is specified, fallbacks to handleUncaughtError',
          () {
        final container = createContainer();
        final dep = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errors = <Object>[];

        runZonedGuarded(
          () {
            container.listen(
              dep,
              listener.call,
              fireImmediately: true,
            );
          },
          (err, stack) => errors.add(err),
        );

        verifyZeroInteractions(listener);
        expect(errors, [
          isUnimplementedError,
        ]);
      });

      test(
          'when no onError is specified on selectors, fallbacks to handleUncaughtError',
          () {
        final container = createContainer();
        final dep = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errors = <Object>[];

        runZonedGuarded(
          () {
            container.listen(
              dep.select((value) => value),
              listener.call,
              fireImmediately: true,
            );
          },
          (err, stack) => errors.add(err),
        );

        verifyZeroInteractions(listener);
        expect(errors, [
          isUnimplementedError,
        ]);
      });

      test('on provider that threw, fireImmediately calls onError', () {
        final container = createContainer();
        final provider = Provider<int>((ref) => throw UnimplementedError());
        final listener = Listener<int>();
        final errorListener = ErrorListener();

        container.listen(
          provider,
          listener.call,
          onError: errorListener.call,
          fireImmediately: true,
        );

        verifyZeroInteractions(listener);
        verifyOnly(
          errorListener,
          errorListener(isUnimplementedError, argThat(isNotNull)),
        );
      });
    });

    test("doesn't trow when creating a provider that failed", () {
      final container = createContainer();
      final provider = Provider((ref) {
        throw Error();
      });

      final sub = container.listen(provider, (_, __) {});

      expect(sub, isA<ProviderSubscription<Object?>>());
    });

    test('calls immediately the listener with the current value', () {
      final provider = Provider((ref) => 0);
      final listener = Listener<int>();

      final container = createContainer();

      container.listen(provider, listener.call, fireImmediately: true);

      verifyOnly(listener, listener(null, 0));
    });
  });
}
