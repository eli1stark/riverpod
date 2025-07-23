import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  test('throw if overrideWithProvider returns a provider with dependencies',
      () {
    final family = Provider.family<int, int>((ref, _) => 0);
    final a = Provider((ref) => 0);

    final container = createContainer(
      overrides: [
        family.overrideWithProvider(
          (argument) => Provider((ref) => 0, dependencies: [a]),
        ),
      ],
    );

    expect(
      () => container.read(family(42)),
      throwsA(isA<AssertionError>()),
    );
  });

  test(
      'does not re-initialize a family if read by a child container after the provider was initialized',
      () {
    final root = createContainer();
    // the child must be created before the provider is initialized
    final child = createContainer(parent: root);

    var buildCount = 0;
    final provider = Provider.family<int, int>((ref, param) {
      buildCount++;
      return 0;
    });

    expect(root.read(provider(0)), 0);

    expect(buildCount, 1);

    expect(child.read(provider(0)), 0);

    expect(buildCount, 1);
  });

  test(
      'does not re-initialize a scoped family if read by a child container after the provider was initialized',
      () {
    var buildCount = 0;
    final provider = Provider.family<int, int>((ref, param) {
      buildCount++;
      return 42;
    });

    final root = createContainer();
    final scope = createContainer(parent: root, overrides: [provider]);
    // the child must be created before the provider is initialized
    final child = createContainer(parent: scope);

    expect(scope.read(provider(0)), 42);

    expect(root.getAllProviderElements(), isEmpty);
    expect(buildCount, 1);

    expect(child.read(provider(0)), 42);

    expect(root.getAllProviderElements(), isEmpty);
    expect(buildCount, 1);
  });

  test('caches the provider per value', () {
    final family = Provider.family<String, int>((ref, a) => '$a');
    final container = createContainer();

    expect(family(42), family(42));
    expect(container.read(family(42)), '42');

    expect(family(21), family(21));
    expect(container.read(family(21)), '21');
  });

  test('family override', () {
    final family = Provider.family<String, int>((ref, a) => 'Hello $a');
    final container = createContainer(
      overrides: [
        // Provider overrides always takes over family overrides
        family(84).overrideWithValue('Bonjour 84'),
        family,
        family(21).overrideWithValue('Hi 21'),
      ],
    );

    expect(container.read(family(21)), 'Hi 21');
    expect(container.read(family(84)), 'Bonjour 84');
    expect(container.read(family(42)), 'Hello 42');
  });
}
