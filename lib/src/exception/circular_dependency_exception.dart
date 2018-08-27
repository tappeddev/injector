import 'package:meta/meta.dart';

class CircularDependencyException implements Exception {
  String type;

  CircularDependencyException({@required this.type});

  @override
  String toString() =>
      "Circular dependency detected when requesting instance of \"$type\".";
}
