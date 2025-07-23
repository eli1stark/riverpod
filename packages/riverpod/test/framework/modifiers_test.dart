// ignore_for_file: prefer_const_constructors
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/builders.dart';
import 'package:test/test.dart';

void main() {
  test('builders', () {
    expect(Provider.autoDispose.family, Provider.family.autoDispose);
    expect(
      StateNotifierProvider.autoDispose.family,
      StateNotifierProvider.family.autoDispose,
    );
  });

  test('StateNotifierProvider', () {
    final stateNotifierProviderBuilder = StateNotifierProviderBuilder();
    StateNotifierProviderFamilyBuilder();
    AutoDisposeStateNotifierProviderBuilder();
    AutoDisposeStateNotifierProviderFamilyBuilder();

    expect(
      StateNotifierProvider.family,
      const StateNotifierProviderFamilyBuilder(),
    );
    expect(
      StateNotifierProvider.autoDispose,
      const AutoDisposeStateNotifierProviderBuilder(),
    );
    expect(
      StateNotifierProvider.autoDispose.family,
      StateNotifierProvider.family.autoDispose,
    );
    expect(
      stateNotifierProviderBuilder.autoDispose,
      StateNotifierProvider.autoDispose,
    );
    expect(
      stateNotifierProviderBuilder.family,
      StateNotifierProvider.family,
    );
    expect(
      stateNotifierProviderBuilder<StateController<int>, int>(
        (ref) => StateController(42),
        name: 'foo',
      ),
      isA<StateNotifierProvider<StateController<int>, int>>()
          .having((s) => s.name, 'name', 'foo'),
    );
  });

  test('Provider', () {
    final providerBuilder = ProviderBuilder();
    ProviderFamilyBuilder();
    AutoDisposeProviderBuilder();
    AutoDisposeProviderFamilyBuilder();

    expect(
      Provider.family,
      const ProviderFamilyBuilder(),
    );
    expect(
      Provider.autoDispose,
      const AutoDisposeProviderBuilder(),
    );
    expect(
      Provider.autoDispose.family,
      Provider.family.autoDispose,
    );
    expect(
      providerBuilder.autoDispose,
      Provider.autoDispose,
    );
    expect(
      providerBuilder.family,
      Provider.family,
    );
    expect(
      providerBuilder((ref) => StateController(42), name: 'foo'),
      isA<Provider<StateController<int>>>()
          .having((s) => s.name, 'name', 'foo'),
    );
  });
}
