/// Gets thrown when trying to register dependencies that depends on each other
/// in a circular way.
///
/// The best example is:
/// * A chicken depends on an egg.
/// * An egg depends on a chicken.
class CircularDependencyException implements Exception {
  /// The Type of the dependency that caused the circular dependency.
  String type;

  CircularDependencyException({required this.type});

  @override
  String toString() =>
      "Circular dependency detected when requesting instance of \"$type\".";
}
