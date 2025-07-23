import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('Ref', () {
    group('invalidateSelf', () {
      test('can disposes of the element if not used anymore', () async {
        late Ref<Object?> ref;
        final provider = Provider.autoDispose((r) {
          ref = r;
          r.keepAlive();
          return 0;
        });
        final container = createContainer();

        container.read(provider);
        ref.invalidateSelf();

        await container.pump();

        expect(container.getAllProviderElements(), isEmpty);
      });
    });

    group('invalidate', () {
      test('can disposes of the element if not used anymore', () async {
        late Ref<Object?> ref;
        final dep = Provider((r) {
          ref = r;
          return 0;
        });
        final provider = Provider.autoDispose((r) {
          r.keepAlive();
          return 0;
        });
        final container = createContainer();

        container.read(dep);
        container.read(provider);
        ref.invalidate(provider);

        await container.pump();

        expect(
          container.getAllProviderElements().map((e) => e.origin),
          [dep],
        );
      });
    });

    group('refresh', () {
      test('refreshes a provider and return the new state', () {
        var value = 0;
        final state = Provider((ref) => value);
        late Ref ref;
        final provider = Provider((r) {
          ref = r;
        });
        final container = createContainer();

        container.read(provider);

        expect(container.read(state), 0);

        value = 42;
        expect(ref.refresh(state), 42);
        expect(container.read(state), 42);
      });
    });

    group('.onDispose', () {
      test(
          'calls all the listeners in order when the ProviderContainer is disposed',
          () {
        final onDispose = OnDisposeMock();
        final onDispose2 = OnDisposeMock();
        final provider = Provider((ref) {
          ref.onDispose(onDispose.call);
          ref.onDispose(onDispose2.call);
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(provider); // register the onDispose hooks

        verifyZeroInteractions(onDispose);
        verifyZeroInteractions(onDispose2);

        container.dispose();

        verifyInOrder([
          onDispose(),
          onDispose2(),
        ]);
        verifyNoMoreInteractions(onDispose);
        verifyNoMoreInteractions(onDispose2);
      });

      test(
        'once a provider was disposed, cannot add more listeners until it is rebuilt',
        () {},
        skip: 'TODO',
      );
    });
  });
}
