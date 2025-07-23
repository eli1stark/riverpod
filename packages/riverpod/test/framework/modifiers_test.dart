// ignore_for_file: prefer_const_constructors
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/builders.dart';
import 'package:test/test.dart';

void main() {
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
