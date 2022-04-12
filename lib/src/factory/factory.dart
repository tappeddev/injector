/// Gets registered at the injector and then gets called by the injector to
/// instantiate the dependency and all of its dependencies.
///
///
/// Example:
/// ```dart
/// final myInjector = Injector();
///
/// myInjector.registerDependency<Car>(() {
///     var engine = myInjector.getDependency<Engine>();
///     return CarImpl(engine: engine);
/// });
/// ```
typedef DependencyBuilder<T> = T Function();

abstract class Factory<T> {
  final DependencyBuilder<T> builder;

  Factory(this.builder);

  T get instance;

  static Factory<T> provider<T>(DependencyBuilder<T> builder) =>
      _ProviderFactory(builder);

  static Factory<T> singleton<T>(DependencyBuilder<T> builder) =>
      _SingletonFactory(builder);
}

/// This Factory does lazy instantiation of [T] and
/// always returns a new instance built by the [builder].
class _ProviderFactory<T> implements Factory<T> {
  @override
  DependencyBuilder<T> builder;

  _ProviderFactory(this.builder);

  @override
  T get instance => builder();
}

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [instance].
class _SingletonFactory<T> implements Factory<T> {
  @override
  DependencyBuilder<T> builder;

  T? _value;

  _SingletonFactory(this.builder);

  @override
  T get instance => _value ??= builder();
}
