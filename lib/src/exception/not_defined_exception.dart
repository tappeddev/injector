import 'package:meta/meta.dart';

/// Gets thrown when trying to get a dependency that has not been registered yet.
///
/// Some checkpoints that could cause this issue:
/// * The dependency got registered with the wrong key type:
///   ```dart
///   Injector().registerDependency<Interface1>((_) => Implementation1());
///
///   Injector().getDependency<Interface2>(); // This throws the Exception!
///   ```
/// * The dependency has not been registered at all
class NotDefinedException implements Exception {
  // The Type of the missing instance
  String type;

  NotDefinedException({@required this.type});

  @override
  String toString() => "The type \"$type\" is not defined!";
}
