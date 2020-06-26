import 'package:injector/injector.dart';
import 'package:injector/src/factory/factory.dart';

extension RegisterExtension on Injector {
  void registerSingleton<T>(
    Builder<T> builder, {
    bool override = false,
    String dependencyName = "",
  }) =>
      this.register(Factory.singleton(builder), override: override, dependencyName: dependencyName);

  void registerDependency<T>(
    Builder<T> builder, {
    bool override = false,
    String dependencyName = "",
  }) =>
      this.register(Factory.singleton(builder), override: override, dependencyName: dependencyName);
}
