import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/factory/factory.dart';
import 'package:injector/src/factory/provider_factory.dart';
import 'package:injector/src/factory/singelton_factory.dart';

class Injector {
  static final Injector _singleton = Injector._internal();

  factory Injector() => _singleton;

  Injector._internal();

  Map<String, Factory<dynamic>> _factoryMap = Map<String, Factory>();

  void registerDependency<T>(Builder<T> builder) {
    var type = T.toString();
    _assertType(T);

    if (_factoryMap.containsKey(type)) {
      throw Exception("type \"$type\" already defined !");
    }

    _factoryMap[type] = ProviderFactory<T>(builder, this);
  }

  void registerSingleton<T>(Builder<T> builder) {
    var type = T.toString();
    _assertType(T);

    if (_factoryMap.containsKey(type)) {
      throw Exception("type \"$type\" already defined !");
    }

    _factoryMap[type] = SingletonFactory(builder, this);
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
    var type = T.toString();
    _assertType(T);

    if (!_factoryMap.containsKey(type)) {
      throw Exception("Dependency with type $type not registered");
    }

    var factory = _factoryMap[type];
    var factoryId = factory.hashCode;

    if (_factoryCallIds.contains(factoryId))
      throw CircularDependencyException();

    _factoryCallIds.add(factoryId);

    var instance = factory.instance as T;
    _factoryCallIds.remove(factoryId);

    return instance;
  }

  void _assertType<T>(T type) {
    var type = T.toString();

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$type\"");
    }
  }

  void clearDependencies() => _factoryMap.clear();
}
