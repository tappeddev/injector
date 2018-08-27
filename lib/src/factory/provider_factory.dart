import 'package:injector/injector.dart';
import 'package:injector/src/factory/factory.dart';

/// This Factory does lazy instantiation of [T] and
/// always returns a new instance built by the [builder]
class ProviderFactory<T> implements Factory<T> {
  @override
  Builder<T> builder;

  @override
  Injector injector;

  ProviderFactory(this.builder, this.injector);

  @override
  T get instance => builder(injector);
}
