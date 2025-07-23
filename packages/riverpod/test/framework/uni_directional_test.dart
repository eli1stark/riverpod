import 'package:riverpod/src/internals.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late ProviderContainer container;
  setUp(() {
    container = ProviderContainer();
  });
  tearDown(() {
    container.dispose();
  });

  test(
      'Catches circular dependency when dependencies are setup during provider initialization',
      () {
    // regression for #1766
    final container = createContainer();

    final authInterceptorProvider = Provider((ref) => ref);

    final dioProvider = Provider<int>((ref) {
      ref.watch(authInterceptorProvider);
      return 0;
    });

    final accessTokenProvider = Provider<int>((ref) {
      return ref.watch(dioProvider);
    });

    container.read(dioProvider);
    final interceptor = container.read(authInterceptorProvider);

    expect(
      () => interceptor.read(accessTokenProvider),
      throwsA(isA<CircularDependencyError>()),
    );
  });

  group('ref.watch cannot end-up in a circular dependency', () {
    test('direct dependency', () {
      final provider = Provider((ref) => ref);
      final provider2 = Provider((ref) => ref);
      final container = ProviderContainer();

      final ref = container.read(provider);
      final ref2 = container.read(provider2);

      ref.watch(provider2);
      expect(
        () => ref2.watch(provider),
        throwsA(isA<CircularDependencyError>()),
      );
    });
    test('indirect dependency', () {
      final provider = Provider((ref) => ref);
      final provider2 = Provider((ref) => ref);
      final provider3 = Provider((ref) => ref);
      final provider4 = Provider((ref) => ref);
      final container = ProviderContainer();

      final ref = container.read(provider);
      final ref2 = container.read(provider2);
      final ref3 = container.read(provider3);
      final ref4 = container.read(provider4);

      ref.watch(provider2);
      ref2.watch(provider3);
      ref3.watch(provider4);

      expect(
        () => ref4.watch(provider),
        throwsA(isA<CircularDependencyError>()),
      );
    });
  });

  group('ref.read cannot end-up in a circular dependency', () {
    test('direct dependency', () {
      final provider = Provider((ref) => ref);
      final provider2 = Provider((ref) => ref);
      final container = ProviderContainer();

      final ref = container.read(provider);
      final ref2 = container.read(provider2);

      ref.watch(provider2);
      expect(
        () => ref2.read(provider),
        throwsA(isA<CircularDependencyError>()),
      );
    });
    test('indirect dependency', () {
      final provider = Provider((ref) => ref);
      final provider2 = Provider((ref) => ref);
      final provider3 = Provider((ref) => ref);
      final provider4 = Provider((ref) => ref);
      final container = ProviderContainer();

      final ref = container.read(provider);
      final ref2 = container.read(provider2);
      final ref3 = container.read(provider3);
      final ref4 = container.read(provider4);

      ref.watch(provider2);
      ref2.watch(provider3);
      ref3.watch(provider4);

      expect(
        () => ref4.read(provider),
        throwsA(isA<CircularDependencyError>()),
      );
    });
  });
}
