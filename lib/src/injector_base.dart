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

  T getDependency<T>() {
    var type = T.toString();
    _assertType(T);

    if (!_factoryMap.containsKey(type)) {
      throw Exception("Dependency with type $type not registered");
    }

    return _factoryMap[type].instance as T;
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
