import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Passes key', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          key: const Key('42'),
          builder: (context, ref, _) {
            return Container();
          },
        ),
      ),
    );

    expect(find.byKey(const Key('42')), findsOneWidget);
  });

  testWidgets('Ref is unusable after dispose', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, r, child) {
            ref = r;
            return Container();
          },
        ),
      ),
    );

    await tester.pumpWidget(ProviderScope(child: Container()));

    final throwsDisposeError = throwsA(
      isA<StateError>().having(
        (e) => e.message,
        'message',
        'Cannot use "ref" after the widget was disposed.',
      ),
    );

    expect(() => ref.read(_provider), throwsDisposeError);
    expect(() => ref.watch(_provider), throwsDisposeError);
    expect(() => ref.refresh(_provider), throwsDisposeError);
    expect(() => ref.invalidate(_provider), throwsDisposeError);
    expect(() => ref.listen(_provider, (_, __) {}), throwsDisposeError);
    expect(() => ref.listenManual(_provider, (_, __) {}), throwsDisposeError);
  });

  group('WidgetRef.exists', () {
    testWidgets('simple use-case', (tester) async {
      late WidgetRef ref;
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, r, child) {
              ref = r;
              return Container();
            },
          ),
        ),
      );

      final provider = Provider((ref) => 0);

      expect(ref.exists(provider), false);
      expect(ref.exists(provider), false);

      ref.read(provider);

      expect(ref.exists(provider), true);
    });
  });

  testWidgets('WidgetRef.context exposes the BuildContext', (tester) async {
    late WidgetRef ref;

    await tester.pumpWidget(
      CallbackConsumerWidget(
        key: const Key('initState'),
        initState: (ctx, r) {
          ref = r;
        },
      ),
    );

    final consumerElement = tester.element(find.byType(CallbackConsumerWidget));

    expect(ref.context, same(consumerElement));
  });

  testWidgets('throws if listen is used outside of `build`', (tester) async {
    final provider = Provider((ref) => 0);

    await tester.pumpWidget(
      CallbackConsumerWidget(
        key: const Key('initState'),
        initState: (ctx, ref) {
          ref.listen(provider, (prev, value) {});
        },
      ),
    );

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('works with providers that returns null', (tester) async {
    final nullProvider = Provider((ref) => null);

    Consumer(
      builder: (context, ref, _) {
        // should compile
        ref.watch(nullProvider);
        return Container();
      },
    );
  });

  testWidgets('can use "watch" inside ListView.builder', (tester) async {
    final provider = Provider((ref) => 'hello world');

    await tester.pumpWidget(
      ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(
            builder: (context, ref, _) {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Text(ref.watch(provider));
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('can extend ConsumerWidget', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyWidget()));

    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('hot-reload forces the widget to refresh', (tester) async {
    var buildCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            buildCount++;
            return Container();
          },
        ),
      ),
    );

    expect(find.byType(Container), findsOneWidget);
    expect(buildCount, 1);

    // ignore: unawaited_futures
    tester.binding.reassembleApplication();
    await tester.pump();

    expect(find.byType(Container), findsOneWidget);
    expect(buildCount, 2);
  });

  testWidgets('changing provider', (tester) async {
    final provider = Provider((_) => 0);

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final value = ref.watch(provider);
            return Text(
              '$value',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);

    final provider2 = Provider((_) => 42);

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final value = ref.watch(provider2);
            return Text(
              '$value',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('0'), findsNothing);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('can read scoped providers', (tester) async {
    final provider = Provider((_) => 0);

    final child = Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(provider);
        return Text(
          '$value',
          textDirection: TextDirection.ltr,
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provider.overrideWithValue(42),
        ],
        child: child,
      ),
    );

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provider.overrideWithValue(21),
        ],
        child: child,
      ),
    );

    expect(find.text('21'), findsOneWidget);
  });
}

class TestNotifier extends StateNotifier<int> {
  TestNotifier([super.initialValue = 0]);

  void increment() => state++;

  // ignore: avoid_setters_without_getters
  set value(int value) => state = value;
}

final _provider = Provider((ref) => 'hello world');

class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(ref.watch(_provider), textDirection: TextDirection.rtl);
  }
}

class CallbackConsumerWidget extends ConsumerStatefulWidget {
  const CallbackConsumerWidget({
    super.key,
    this.initState,
    this.didChangeDependencies,
    this.dispose,
    this.didUpdateWidget,
    this.reassemble,
  });

  final void Function(BuildContext context, WidgetRef ref)? initState;
  final void Function(BuildContext context, WidgetRef ref)?
      didChangeDependencies;
  final void Function(BuildContext context, WidgetRef ref)? dispose;
  final void Function(
    BuildContext context,
    WidgetRef ref,
    CallbackConsumerWidget oldWidget,
  )? didUpdateWidget;
  final void Function(BuildContext context, WidgetRef ref)? reassemble;

  @override
  // ignore: library_private_types_in_public_api
  _CallbackConsumerWidgetState createState() => _CallbackConsumerWidgetState();
}

class _CallbackConsumerWidgetState
    extends ConsumerState<CallbackConsumerWidget> {
  @override
  void initState() {
    super.initState();
    widget.initState?.call(context, ref);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context, ref);
  }

  @override
  void dispose() {
    super.dispose();
    widget.dispose?.call(context, ref);
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.reassemble?.call(context, ref);
  }

  @override
  void didUpdateWidget(covariant CallbackConsumerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, ref, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
