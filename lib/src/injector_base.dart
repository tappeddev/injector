typedef T Factory<T>(Injector injector);

class Injector {
  static final Injector _singleton = Injector._internal();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  Map<int, Factory> _dependencyFactoryMap = Map<int, Factory>();

  Map<int, Factory> _singletonFactoryMap = Map<int, Factory>();

  Map<int, Object> _singletonMap = Map<int, Object>();

  void registerDependency<T>(Factory<T> factory) {
    int hashcode = T.hashCode;

    bool isValid = _isRegistrationValid<T>(hashcode);

    if (isValid) {
      _dependencyFactoryMap[hashcode] = factory;
    }
  }

  void registerSingleton<T>(Factory<T> factory) {
    int hashCode = T.hashCode;

    bool isValid = _isRegistrationValid<T>(hashCode);

    if (isValid) {
      _singletonFactoryMap[hashCode] = factory;
    }
  }

  bool _isRegistrationValid<T>(int hashcode) {
    if (T == dynamic) {
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$T\"");
    }

    if (_singletonMap.containsKey(hashcode) ||
        _dependencyFactoryMap.containsKey(hashcode)) {
      throw Exception("type \"$hashcode\" already defined !");
    }

    return true;
  }

  T getDependency<T>() {
    var key = T.hashCode;

    if (T == dynamic) {
      throw Exception("Can not get dependencies for type \"$T\"");
    }

    if (!_dependencyFactoryMap.containsKey(key) &&
        !_singletonMap.containsKey(key) &&
        !_singletonFactoryMap.containsKey(key)) {
      throw Exception("Dependency with type \"$T\" not registered !");
    }

    if (_dependencyFactoryMap.containsKey(key)) {
      var builder = _dependencyFactoryMap[key];
      return builder(this) as T;
    } else if (_singletonFactoryMap.containsKey(key)) {
      var builder = _singletonFactoryMap[key];
      return _singletonMap[key] = builder(this) as T;
    } else if (_singletonMap.containsKey(key)) {
      return _singletonMap[key] as T;
    }
  }

  void clearDependencies() {
    _dependencyFactoryMap.clear();
    _singletonMap.clear();
    _singletonFactoryMap.clear();
  }
}
