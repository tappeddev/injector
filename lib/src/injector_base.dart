import 'package:injector/src/exception/already_defined_exception.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/exception/not_defined_exception.dart';
import 'package:injector/src/factory/factory.dart';
import 'package:injector/src/factory/provider_factory.dart';
import 'package:injector/src/factory/singelton_factory.dart';

class Injector {
  static final Injector _singleton = Injector._internal();

  factory Injector() => _singleton;

  Injector._internal();

  Map<int, Factory<dynamic>> _factoryMap = Map<int, Factory>();

  void registerDependency<T>(Builder<T> builder) {
    int identity = _getIdentity<T>();

    _checkValidation<T>();

    _checkForDuplicates<T>(identity);

    _factoryMap[identity] = ProviderFactory<T>(builder, this);
  }

  void registerSingleton<T>(Builder<T> builder) {
    int identity = _getIdentity<T>();

    _checkValidation<T>();

    _checkForDuplicates<T>(identity);

    _factoryMap[identity] = SingletonFactory<T>(builder, this);
  }

  /// Whenever a factory is called to get a dependency
  /// the identifier of that factory is saved to this list and
  /// is removed when the instance is successfully created.
  ///
  /// A circular dependency is detected when the factory id was not removed
  /// meaning that the instance was not created
  /// but the same factory was called more than once
  var _factoryCallIds = List<int>();

  T getDependency<T>() {
    int identity = _getIdentity<T>();

    _checkValidation<T>();

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

  void _checkValidation<T>() {
    var type = T.toString();

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$type\"");
    }
  }

  void _checkForDuplicates<T>(int identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: T.toString());
    }
  }

  int _getIdentity<T>() => T.hashCode;

  void clearDependencies() {
    _factoryCallIds.clear();
    _factoryMap.clear();
  }
}
