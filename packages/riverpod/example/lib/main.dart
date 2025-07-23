///  A pure Dart script that fetches the list of comics from https://developer.marvel.com/
///
///  The process is split into two objects:
///
///  - [Configuration], which stores the API keys of a marvel account.
///    This object is loaded asynchronously by reading a JSON file.
///  - [Repository], a utility that depends on [Configuration] to
///    connect to https://developer.marvel.com/ and request the comics.
///
///  Both [Repository] and [Configuration] are created using `riverpod`.
///
///  This showcases how to use `riverpod` without Flutter.
///  It also shows how a provider can depend on another provider asynchronously loaded.
library main;

import 'models.dart';

Future<void> main() async {}
