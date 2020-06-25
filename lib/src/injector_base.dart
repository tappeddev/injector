import 'package:injector/src/exception/already_defined_exception.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/exception/not_defined_exception.dart';
import 'package:injector/src/factory/factory.dart';
import 'package:injector/src/factory/provider_factory.dart';
import 'package:injector/src/factory/singelton_factory.dart';

class Injector {
  /// The static/single instance of the [Injector].
  static final Injector appInstance = Injector();

  /// Stores [SingletonFactory] and [ProviderFactory] instances that have been
  /// registered by [registerSingleton] and [registerDependency] respectively.
  Map<String, Factory<Object>> _factoryMap = Map<String, Factory<Object>>();

  /// Registers a dependency.
  ///
  /// Overrides dependencies with the same signature when [override] is true.
  /// Uses [dependencyName] to differentiate between dependencies that have the
  /// same type.
  ///
  /// The signature of a dependency consists of [T]
  /// and the optional [dependencyName].
  ///
  /// The injector will always create new instances of dependencies that got
  /// registered this way when calling [getDependency].
  ///
  /// Example:
  /// ```dart
  /// abstract class UserService {
  ///     void Login(String username, String password);
  /// }
  ///
  /// class UserServiceImpl implements UserService {
  ///     void Login(String username, String password) {
  ///         // does something..
  ///     }
  /// }
  ///
  /// Injector.appInstance.registerDependency<UserService>((_) => new UserServiceImpl());
  /// ```
  ///
  /// Then getting the registered dependency:
  ///
  /// ```dart
  /// var userService = Injector.appInstance.getDependency<UserService>();
  /// ```
  void registerDependency<T>(
    Builder<T> builder, {
    bool override = false,
    String dependencyName = "",
  }) {
    _checkValidation<T>();

    String identity = _getIdentity<T>(dependencyName);

    if (!override) {
      _checkForDuplicates<T>(identity);
    }

    _factoryMap[identity] = ProviderFactory<T>(builder);
  }

  /// Registers a singleton dependency.
  ///
  /// Overrides dependencies with the same signature when [override] is true.
  /// Uses [dependencyName] to differentiate between dependencies that have the
  /// same type.
  ///
  /// The signature of a dependency consists of [T]
  /// and the optional [dependencyName].
  ///
  /// The injector will always return the same singleton instance dependencies
  /// that got registered this way when calling [getDependency].
  ///
  /// ```dart
  /// abstract class UserService {
  ///  void login(String username, String password);
  /// }
  ///
  /// class UserServiceImpl implements UserService {
  ///  void login(String username, String password){
  ///    .....
  ///    .....
  ///  }
  /// }
  ///
  /// Injector.appInstance.registerSingleton<UserService>((_) => new UserServiceImpl());
  /// ```
  /// Then getting the registered dependency:
  /// ```dart
  /// Injector.appInstance.getDependency<UserService>();
  /// ```
  void registerSingleton<T>(Builder<T> builder, {bool override = false, String dependencyName = ""}) {
    _checkValidation<T>();

    String identity = _getIdentity<T>(dependencyName);

    if (!override) {
      _checkForDuplicates<T>(identity);
    }

    _factoryMap[identity] = SingletonFactory<T>(builder);
  }

  /// Whenever a factory is called to get a dependency
  /// the identifier of that factory is saved to this list and
  /// is removed when the instance is successfully created.
  ///
  /// A circular dependency is detected when the factory id was not removed
  /// meaning that the instance was not created
  /// but the same factory was called more than once
  var _factoryCallIds = List<int>();

  /// Returns the registered dependencies with the signature of [T] and
  /// [dependencyName].
  ///
  /// Throws [NotDefinedException] when the requested dependency has not been
  /// registered yet.
  ///
  /// Throws [CircularDependencyException] when the injector detected a circular
  /// dependency setup.
  T getDependency<T>({String dependencyName = ""}) {
    _checkValidation<T>();

    String identity = _getIdentity<T>(dependencyName);

    if (!_factoryMap.containsKey(identity)) {
      throw NotDefinedException(type: T.toString());
    }

    var factory = _factoryMap[identity];
    var factoryId = factory.hashCode;

    if (_factoryCallIds.contains(factoryId)) {
      throw CircularDependencyException(type: T.toString());
    }

    _factoryCallIds.add(factoryId);

    var instance = factory.instance as T;
    _factoryCallIds.remove(factoryId);

    return instance;
  }

  /// Checks if the dependency with the signature of [T] and [dependency] exists.
  bool exists<T>({String dependencyName = ""}) {
    String dependencyKey = _getIdentity<T>(dependencyName);

    return _factoryMap.containsKey(dependencyKey);
  }

  /// Removes the dependency with the signature of [T] and [dependencyName].
  void removeByKey<T>({String dependencyName = ""}) {
    String dependencyKey = _getIdentity<T>(dependencyName);

    _factoryMap.remove(dependencyKey);
  }

  /// Removes all registered dependencies.
  void clearAll() {
    _factoryCallIds.clear();
    _factoryMap.clear();
  }

  // ------
  // Helper
  // ------

  /// Checks if [T] is actually set.
  void _checkValidation<T>() {
    var type = T.toString();

    if (T == dynamic) {
      throw Exception("No type specified !\nCan not register dependencies for type \"$type\"");
    }
  }

  void _checkForDuplicates<T>(String identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: T.toString());
    }
  }

  String _getIdentity<T>(String dependencyName) => "$dependencyName${T.hashCode.toString()}";
}
