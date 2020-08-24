import 'package:injector/src/exception/already_defined_exception.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/exception/not_defined_exception.dart';
import 'package:injector/src/factory/factory.dart';

class Injector {
  /// The static/single instance of the [Injector].
  static final Injector appInstance = Injector();

  /// Stores [SingletonFactory] and [ProviderFactory] instances that have been
  /// registered by [registerSingleton] and [registerDependency] respectively.
  final _factoryMap = <String, Factory<Object>>{};

  /// Registers a dependency that will be created with the provided [Factory].
  /// See [Factory.provider] or [Factory.singleton].
  /// You can also create your custom factory by implementing [Factory].
  ///
  /// Overrides dependencies with the same signature when [override] is true.
  /// Uses [dependencyName] to differentiate between dependencies that have the
  /// same type.
  ///
  /// The signature of a dependency consists of [T]
  /// and the optional [dependencyName].
  ///
  /// ```dart
  /// abstract class UserService {
  ///  void login(String username, String password);
  /// }
  ///
  /// class UserServiceImpl implements UserService {
  ///  void login(String username, String password) {
  ///    .....
  ///    .....
  ///  }
  /// }
  ///
  /// injector.register(Factory.singleton(() => UserServiceImpl()));
  /// ```
  /// Then getting the registered dependency:
  /// ```dart
  /// injector.get<UserService>();
  /// ```
  void register<T>(Factory<T> factory, {bool override = false, String dependencyName = ""}) {
    _checkValidation<T>();

    final identity = _getIdentity<T>(dependencyName);

    if (!override) {
      _checkForDuplicates<T>(identity);
    }

    _factoryMap[identity] = factory;
  }

  /// Whenever a factory is called to get a dependency
  /// the identifier of that factory is saved to this list and
  /// is removed when the instance is successfully created.
  ///
  /// A circular dependency is detected when the factory id was not removed
  /// meaning that the instance was not created
  /// but the same factory was called more than once
  final _factoryCallIds = <int>[];

  /// Returns the registered dependencies with the signature of [T] and
  /// the optional [dependencyName].
  ///
  /// Throws [NotDefinedException] when the requested dependency has not been
  /// registered yet.
  ///
  /// Throws [CircularDependencyException] when the injector detected a circular
  /// dependency setup.
  T get<T>({String dependencyName = ""}) {
    _checkValidation<T>();

    final identity = _getIdentity<T>(dependencyName);

    if (!_factoryMap.containsKey(identity)) {
      throw NotDefinedException(type: T.toString());
    }

    final factory = _factoryMap[identity];
    final factoryId = factory.hashCode;

    if (_factoryCallIds.contains(factoryId)) {
      throw CircularDependencyException(type: T.toString());
    }

    _factoryCallIds.add(factoryId);

    try {
      final instance = factory.instance as T;
      _factoryCallIds.remove(factoryId);
      return instance;
    } catch (e) {
      // In case something went wrong, we have to clear the called factory list
      // because this will trigger a [CircularDependencyException] the next time
      // this factory is called again.
      _factoryCallIds.clear();
      rethrow;
    }
  }

  /// Shorter syntax for [get].
  T call<T>({String dependencyName = ""}) => this.get<T>(dependencyName: dependencyName);

  /// Checks if the dependency with the signature of [T] and [dependency] exists.
  bool exists<T>({String dependencyName = ""}) {
    _checkValidation<T>();

    final dependencyKey = _getIdentity<T>(dependencyName);
    return _factoryMap.containsKey(dependencyKey);
  }

  /// Removes the dependency with the signature of [T] and [dependencyName].
  void removeByKey<T>({String dependencyName = ""}) {
    _checkValidation<T>();

    final dependencyKey = _getIdentity<T>(dependencyName);
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
    final type = T.toString();

    if (T == dynamic) {
      throw Exception(
        "No type specified !\nCan not register dependencies for type \"$type\"",
      );
    }
  }

  void _checkForDuplicates<T>(String identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: T.toString());
    }
  }

  String _getIdentity<T>(String dependencyName) => "$dependencyName${T.hashCode.toString()}";
}
