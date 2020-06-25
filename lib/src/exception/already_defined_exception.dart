import 'package:meta/meta.dart';

/// Gets thrown when trying to register two dependencies with the same signature.
///
/// For example:
/// ```dart
/// Injector().registerDependency<InterfaceClass>((_) => FirstImplementation());
///
/// Injector().registerDependency<InterfaceClass>((_) => SecondImplementation());
/// ```
class AlreadyDefinedException implements Exception {
  // The Type of the already defined instance
  String type;

  AlreadyDefinedException({@required this.type});

  @override
  String toString() => "Type \"$type\" already defined !";
}
