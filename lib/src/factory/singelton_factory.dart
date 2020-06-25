import 'package:injector/src/factory/factory.dart';

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [instance]
class SingletonFactory<T> implements Factory<T> {
  @override
  Builder<T> builder;

  T _value;

  SingletonFactory(this.builder);

  @override
  T get instance => _value ??= builder();
}
