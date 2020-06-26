import '../../injector.dart';

/// Extensions that guarantee compatibility to with code written with
/// previous version of the injector to ensure that the following updates
/// don't break existing code.
extension CompatibilityExtension on Injector {
  @Deprecated("Use get<T>() instead")
  T getDependency<T>({String dependencyName = ""}) => this.get<T>(dependencyName: dependencyName);
}
