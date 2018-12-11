import 'package:meta/meta.dart';

/**
 * This [Exception] is for the case
 * if you try to register two instance with the same key type.
 *
 * For Example:
 *
 *
 * Injector().registerDependency<IInterface>((_) => FirstImplementation());
 *
 * Injector().registerDependency<IInterface>((_) => SecondImplementation());
 *
 * In the second line about we throw the [AlreadyDefinedException] exception
 *
 */
class AlreadyDefinedException implements Exception {

  // The Type of the already defined instance
  String type;

  AlreadyDefinedException({@required this.type});

  @override
  String toString() => "Type \"$type\" already defined !";
}
