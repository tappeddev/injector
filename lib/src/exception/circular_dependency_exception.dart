import 'package:meta/meta.dart';

/**
 * We throw this exception if you try to register some classes that depends on each other.
 *
 * The best / simples example is:
 *
 *      - A Chicken depends on an Egg.
 *      - An Egg depends on a Chicken.
 *
 */
class CircularDependencyException implements Exception {

  String type;

  CircularDependencyException({@required this.type});

  @override
  String toString() =>
      "Circular dependency detected when requesting instance of \"$type\".";
}
