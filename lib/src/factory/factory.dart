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
typedef T Builder<T>();

abstract class Factory<T> {
  final Builder<T> builder;

  Factory(this.builder);

  T get instance;
}
