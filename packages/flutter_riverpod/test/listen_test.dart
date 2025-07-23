import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetRef.listenManual', () {
    testWidgets('returns a subscription that can be used within State.dispose',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: DisposeListenManual()),
      );

      await tester.pumpWidget(ProviderScope(child: Container()));
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
