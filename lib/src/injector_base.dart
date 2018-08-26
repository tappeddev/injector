typedef T Factory<T>(Injector injector);

class Injector {
  static final Injector _singleton = Injector._internal();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  Map<int, Factory> _factoryMap = Map<int, Factory>();

  Map<int, Factory> _singletonFactoryMap = Map<int, Factory>();

  Map<int, Object> _singletonMap = Map<int, Object>();

  void registerDependency<T>(Factory<T> factory) {
    int key = T.hashCode;

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$T\"");
    }

    if (_singletonMap.containsKey(key)) {
      throw Exception("type \"$T\" already defined !");
    }

    _factoryMap[key] = factory;
  }

  void registerSingleton<T>(Factory<T> factory) {
    int key = T.hashCode;

    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$T\"");
    }

    if (_singletonMap.containsKey(key) || _factoryMap.containsKey(type)) {
      throw Exception("type \"$type\" already defined !");
    }

    _singletonFactoryMap[key] = factory;
  }

  T getDependency<T>() {
    var key = T.hashCode;

    if (T == dynamic) {
      throw Exception("Can not get dependencies for type \"$T\"");
    }

    if (!_factoryMap.containsKey(key) &&
        !_singletonMap.containsKey(key) &&
        !_singletonFactoryMap.containsKey(key)) {
      throw Exception("Dependency with type \"$T\" not registered !");
    }

    if (_factoryMap.containsKey(key)) {
      var builder = _factoryMap[key];
      return builder(this) as T;
    } else {
      if (_singletonMap.containsKey(key)) {
        return _singletonMap[key];
      if (_singletonMap.containsKey(type)) {
        return _singletonMap[type] as T;
      } else {
        var builder = _singletonFactoryMap[key];
        return _singletonMap[key] = builder(this) as T;
      }
    }
  }

  void clearDependencies() {
    _factoryMap.clear();
    _singletonMap.clear();
  }
}
