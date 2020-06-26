/// Gets registered at the injector an then gets called by the injector to
/// instantiate the dependency and all of its dependencies.
///
/// Use the inner [injector] to get the dependencies that are required to
/// instantiate the new dependency.
///
/// Example:
/// ```dart
/// var myInjector = Injector();
///
/// myInjector.registerDependency<Car>((Injector innerInjector) {
///     var engine = innerInjector.getDependency<Engine>();
///     return CarImpl(engine: engine);
/// });
/// ```
typedef Builder<T> = T Function();

abstract class Factory<T> {
  final Builder<T> builder;

  Factory(this.builder);

  T get instance;

  static Factory<T> provider<T>(Builder<T> builder) => _ProviderFactory(builder);
  static Factory<T> singleton<T>(Builder<T> builder) => _SingletonFactory(builder);
}

/// This Factory does lazy instantiation of [T] and
/// always returns a new instance built by the [builder].
class _ProviderFactory<T> implements Factory<T> {
  @override
  Builder<T> builder;

  _ProviderFactory(this.builder);

  @override
  T get instance => builder();
}

/// This Factory does lazy instantiation of [T] and
/// returns the same instance when accessing [instance].
class _SingletonFactory<T> implements Factory<T> {
  @override
  Builder<T> builder;

  T _value;

  _SingletonFactory(this.builder);

  @override
  T get instance => _value ??= builder();
}
