typedef T Factory<T>(Injector injector);

class Injector {
  static final Injector _singleton = Injector._internal();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  Map<String, Factory> _factoryMap = Map<String, Factory>();

  Map<String, Factory> _singletonFactoryMap = Map<String, Factory>();
  Map<String, Object> _singletonMap = Map<String, Object>();

  void registerDependency<T>(Factory<T> factory) {
    String type = T.toString();

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$type\"");
    }

    if (_singletonMap.containsKey(type)) {
      throw Exception("type \"$type\" already defined !");
    }

    _factoryMap[type] = factory;
  }

  void registerSingleton<T>(Factory<T> factory) {
    String type = T.toString();

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$type\"");
    }

    if (_singletonMap.containsKey(type)) {
      throw Exception("type \"$type\" already defined !");
    }

    _singletonFactoryMap[type] = factory;
  }

  T getDependency<T>() {
    var type = T.toString();

    if (T == dynamic) {
      throw Exception("Can not get dependencies for type \"$type\"");
    }

    if (!_factoryMap.containsKey(type) &&
        !_singletonMap.containsKey(type) &&
        !_singletonFactoryMap.containsKey(type)) {
      throw Exception("Dependency with type \"$type\" not registered !");
    }

    if (_factoryMap.containsKey(type)) {
      var builder = _factoryMap[type];
      return builder(this) as T;
    } else {
      if (_singletonMap.containsKey(type)) {
        return _singletonMap[type];
      } else {
        var builder = _singletonFactoryMap[type];
        return _singletonMap[type] = builder(this) as T;
      }
    }
  }

  void clearDependencies() {
    _factoryMap.clear();
    _singletonMap.clear();
  }
}
