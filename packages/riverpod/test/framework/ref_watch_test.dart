import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import '../utils.dart';

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
}
