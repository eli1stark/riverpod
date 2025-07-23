import 'dart:math';

import 'package:example/home/notifier/home_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotipod);
    final notifier = ref.watch(homeNotipod.notifier);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Name: ${state.name}',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Text(
            'Age: ${state.age}',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          TextButton(
            child: Text(
              'Update name',
            ),
            onPressed: () {
              notifier.updateName('Jack-${Random().nextInt(100)}');
            },
          ),
          TextButton(
            child: Text(
              'Update age',
            ),
            onPressed: () {
              notifier.updateAge(Random().nextInt(100));
            },
          ),
        ],
      ),
    );
  }
}
