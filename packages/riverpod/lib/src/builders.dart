// GENERATED CODE - DO NOT MODIFY BY HAND
//
// If you need to modify this file, instead update /tools/generate_providers/bin/generate_providers.dart
//
// You can install this utility by executing:
// dart pub global activate -s path <repository_path>/tools/generate_providers
//
// You can then use it in your terminal by executing:
// generate_providers <riverpod/flutter_riverpod/hooks_riverpod> <path to builder file to update>

import 'package:state_notifier/state_notifier.dart';

import 'internals.dart';

/// Builds a [NotifierProvider].
class NotifierProviderBuilder {
  /// Builds a [NotifierProvider].
  const NotifierProviderBuilder();

  /// {@macro riverpod.autoDispose}
  NotifierProvider<NotifierT, State>
      call<NotifierT extends Notifier<State>, State>(
    NotifierT Function() create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return NotifierProvider<NotifierT, State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeNotifierProviderBuilder get autoDispose {
    return const AutoDisposeNotifierProviderBuilder();
  }

  /// {@macro riverpod.family}
  NotifierProviderFamilyBuilder get family {
    return const NotifierProviderFamilyBuilder();
  }
}

/// Builds a [NotifierProviderFamily].
class NotifierProviderFamilyBuilder {
  /// Builds a [NotifierProviderFamily].
  const NotifierProviderFamilyBuilder();

  /// {@macro riverpod.family}
  NotifierProviderFamily<NotifierT, State, Arg>
      call<NotifierT extends FamilyNotifier<State, Arg>, State, Arg>(
    NotifierT Function() create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return NotifierProviderFamily<NotifierT, State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeNotifierProviderFamilyBuilder get autoDispose {
    return const AutoDisposeNotifierProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeNotifierProvider].
class AutoDisposeNotifierProviderBuilder {
  /// Builds a [AutoDisposeNotifierProvider].
  const AutoDisposeNotifierProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeNotifierProvider<NotifierT, State>
      call<NotifierT extends AutoDisposeNotifier<State>, State>(
    NotifierT Function() create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeNotifierProvider<NotifierT, State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeNotifierProviderFamilyBuilder get family {
    return const AutoDisposeNotifierProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeNotifierProviderFamily].
class AutoDisposeNotifierProviderFamilyBuilder {
  /// Builds a [AutoDisposeNotifierProviderFamily].
  const AutoDisposeNotifierProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeNotifierProviderFamily<NotifierT, State, Arg>
      call<NotifierT extends AutoDisposeFamilyNotifier<State, Arg>, State, Arg>(
    NotifierT Function() create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeNotifierProviderFamily<NotifierT, State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}

/// Builds a [StateNotifierProvider].
class StateNotifierProviderBuilder {
  /// Builds a [StateNotifierProvider].
  const StateNotifierProviderBuilder();

  /// {@macro riverpod.autoDispose}
  StateNotifierProvider<Notifier, State>
      call<Notifier extends StateNotifier<State>, State>(
    // ignore: deprecated_member_use_from_same_package
    Create<Notifier, StateNotifierProviderRef<Notifier, State>> create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return StateNotifierProvider<Notifier, State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeStateNotifierProviderBuilder get autoDispose {
    return const AutoDisposeStateNotifierProviderBuilder();
  }

  /// {@macro riverpod.family}
  StateNotifierProviderFamilyBuilder get family {
    return const StateNotifierProviderFamilyBuilder();
  }
}

/// Builds a [StateNotifierProviderFamily].
class StateNotifierProviderFamilyBuilder {
  /// Builds a [StateNotifierProviderFamily].
  const StateNotifierProviderFamilyBuilder();

  /// {@macro riverpod.family}
  StateNotifierProviderFamily<Notifier, State, Arg>
      call<Notifier extends StateNotifier<State>, State, Arg>(
    // ignore: deprecated_member_use_from_same_package
    FamilyCreate<Notifier, StateNotifierProviderRef<Notifier, State>, Arg>
        create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return StateNotifierProviderFamily<Notifier, State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeStateNotifierProviderFamilyBuilder get autoDispose {
    return const AutoDisposeStateNotifierProviderFamilyBuilder();
  }
}

/// Builds a [Provider].
class ProviderBuilder {
  /// Builds a [Provider].
  const ProviderBuilder();

  /// {@macro riverpod.autoDispose}
  Provider<State> call<State>(
    // ignore: deprecated_member_use_from_same_package
    Create<State, ProviderRef<State>> create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return Provider<State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeProviderBuilder get autoDispose {
    return const AutoDisposeProviderBuilder();
  }

  /// {@macro riverpod.family}
  ProviderFamilyBuilder get family {
    return const ProviderFamilyBuilder();
  }
}

/// Builds a [ProviderFamily].
class ProviderFamilyBuilder {
  /// Builds a [ProviderFamily].
  const ProviderFamilyBuilder();

  /// {@macro riverpod.family}
  ProviderFamily<State, Arg> call<State, Arg>(
    // ignore: deprecated_member_use_from_same_package
    FamilyCreate<State, ProviderRef<State>, Arg> create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return ProviderFamily<State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeProviderFamilyBuilder get autoDispose {
    return const AutoDisposeProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeStateNotifierProvider].
class AutoDisposeStateNotifierProviderBuilder {
  /// Builds a [AutoDisposeStateNotifierProvider].
  const AutoDisposeStateNotifierProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeStateNotifierProvider<Notifier, State>
      call<Notifier extends StateNotifier<State>, State>(
    // ignore: deprecated_member_use_from_same_package
    Create<Notifier, AutoDisposeStateNotifierProviderRef<Notifier, State>>
        create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeStateNotifierProvider<Notifier, State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeStateNotifierProviderFamilyBuilder get family {
    return const AutoDisposeStateNotifierProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeStateNotifierProviderFamily].
class AutoDisposeStateNotifierProviderFamilyBuilder {
  /// Builds a [AutoDisposeStateNotifierProviderFamily].
  const AutoDisposeStateNotifierProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeStateNotifierProviderFamily<Notifier, State, Arg>
      call<Notifier extends StateNotifier<State>, State, Arg>(
    // ignore: deprecated_member_use_from_same_package
    FamilyCreate<Notifier, AutoDisposeStateNotifierProviderRef<Notifier, State>,
            Arg>
        create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeStateNotifierProviderFamily<Notifier, State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}

/// Builds a [AutoDisposeProvider].
class AutoDisposeProviderBuilder {
  /// Builds a [AutoDisposeProvider].
  const AutoDisposeProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeProvider<State> call<State>(
    // ignore: deprecated_member_use_from_same_package
    Create<State, AutoDisposeProviderRef<State>> create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeProvider<State>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeProviderFamilyBuilder get family {
    return const AutoDisposeProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeProviderFamily].
class AutoDisposeProviderFamilyBuilder {
  /// Builds a [AutoDisposeProviderFamily].
  const AutoDisposeProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeProviderFamily<State, Arg> call<State, Arg>(
    // ignore: deprecated_member_use_from_same_package
    FamilyCreate<State, AutoDisposeProviderRef<State>, Arg> create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeProviderFamily<State, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}
