import 'package:injector/src/factory/factory.dart';
import 'package:injector/src/injector_base.dart';

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [instance]
class SingletonFactory<T> implements Factory<T> {
  @override
  Builder<T> builder;

  @override
  Injector injector;

  T _value;

  SingletonFactory(this.builder, this.injector);

  @override
  T get instance {
    if (_value == null) {
      _value = builder(injector);
    }

    return _value;
  }
}
