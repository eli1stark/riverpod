import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('WidgetRef.listen', () {
    testWidgets('works with providers that returns null', (tester) async {
      final nullProvider = Provider((ref) => null);

      // should compile
      Consumer(
        builder: (context, ref, _) {
          ref.listen<Object?>(nullProvider, (_, __) {});
          return Container();
        },
      );
    });

    testWidgets('supports Changing the ProviderContainer', (tester) async {
      final provider = Provider((ref) => 0);
      final onChange = Listener<int>();
      final container = createContainer(
        overrides: [provider.overrideWithValue(0)],
      );
      final container2 = createContainer(
        overrides: [provider.overrideWithValue(0)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<int>(provider, onChange.call);
              return Container();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container2,
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<int>(provider, onChange.call);
              return Container();
            },
          ),
        ),
      );

      container.updateOverrides([
        provider.overrideWithValue(21),
      ]);
      container2.updateOverrides([
        provider.overrideWithValue(42),
      ]);

      await container.pump();

      verifyOnly(onChange, onChange(0, 42));
    });

    testWidgets('supports overriding Providers', (tester) async {
      final provider = Provider((ref) => 0);
      final onChange = Listener<int>();
      final container = createContainer(
        overrides: [provider.overrideWithValue(42)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<int>(provider, onChange.call);
              return Container();
            },
          ),
        ),
      );

      container.updateOverrides([
        provider.overrideWithValue(21),
      ]);

      await container.pump();

      verifyOnly(onChange, onChange(42, 21));
    });
  });
}
