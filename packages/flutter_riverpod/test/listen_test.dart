import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ErrorListener;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'utils.dart';

void main() {
  group('WidgetRef.listenManual', () {
    testWidgets('returns a subscription that can be used within State.dispose',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: DisposeListenManual()),
      );

      // Unmounting DisposeListenManual will throw if this is not allowed
      await tester.pumpWidget(ProviderScope(child: Container()));
    });
  });

  group('WidgetRef.listen', () {
    testWidgets('expose previous and new value on change', (tester) async {
      final container = createContainer();
      final dep = StateNotifierProvider<StateController<int>, int>(
        (ref) => StateController(0),
      );
      final listener = Listener<int>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<int>(dep, listener.call);
              return Container();
            },
          ),
        ),
      );

      container.read(dep.notifier).state++;

      verifyOnly(listener, listener(0, 1));
    });

    testWidgets(
        'when using selectors, `previous` is the latest notification instead of latest event',
        (tester) async {
      final container = createContainer();
      final dep = StateNotifierProvider<StateController<int>, int>(
        (ref) => StateController(0),
      );
      final listener = Listener<bool>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              ref.listen<bool>(
                dep.select((value) => value.isEven),
                listener.call,
              );
              return Container();
            },
          ),
        ),
      );

      container.read(dep.notifier).state += 2;

      verifyNoMoreInteractions(listener);

      container.read(dep.notifier).state++;

      verifyOnly(listener, listener(true, false));
    });
  });
}

final _provider = Provider<String>((ref) => '');

class DisposeListenManual extends ConsumerStatefulWidget {
  const DisposeListenManual({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DisposeListenOnceState();
}

class _DisposeListenOnceState extends ConsumerState<DisposeListenManual> {
  late final ProviderSubscription<String> sub;

  @override
  void initState() {
    super.initState();
    sub = ref.listenManual(_provider, (prev, next) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    sub.read();
    super.dispose();
  }
}
