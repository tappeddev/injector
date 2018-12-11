import 'package:injector/src/exception/already_defined_exception.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/exception/not_defined_exception.dart';
import 'package:injector/src/factory/factory.dart';
import 'package:injector/src/factory/provider_factory.dart';
import 'package:injector/src/factory/singelton_factory.dart';

class Injector {

  /**
   * The static / single instance of the injector
   */
  static final Injector _singleton = Injector._internal();

  /**
   * The factory to get the singleton / static instance
   */
  factory Injector() => _singleton;

  /**
   * The private constructor of the injector
   * We don't allow the user to create a second instance of the injector!
   */
  Injector._internal();

  /**
   * The Map that contains:
   *
   *  [SingletonFactory] - The single instances
   *
   * [ProviderFactory] - The provider factory that contains the type information.
   *                     If creates a new instance every time
   */
  Map<int, Factory<dynamic>> _factoryMap = Map<int, Factory>();


  /**
   * abstract class UserService {
   *  void Login(String username, String password);
   * }
   *
   * class UserServiceImpl implements UserService {
   *  void Login(String username, String password){
   *    .....
   *    .....
   *  }
   * }
   *
   * Injector().registerDependency<UserService>((_) => new UserService);
   *
   * If you now trying to get your dependency with:
   *
   *     var userService = Injector().getDependency<UserService>();
   *
   * You get a new instance every time that you call this function!
   *
   */
  void registerDependency<T>(Builder<T> builder) {
    int identity = _getIdentity<T>();

    _checkValidation<T>();

    _checkForDuplicates<T>(identity);

    _factoryMap[identity] = ProviderFactory<T>(builder, this);
  }

  /**
   * abstract class UserService {
   *  void Login(String username, String password);
   * }
   *
   * class UserServiceImpl implements UserService {
   *  void Login(String username, String password){
   *    .....
   *    .....
   *  }
   * }
   *
   *
   * Injector().registerSingleton<UserService>((_) => new UserService);
   *
   * If you now trying to get your dependency with:
   *
   *    Injector().getDependency<UserService>();
   *
   * You get the same instance every time!
   *
   */
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

  /**
   * Get your registered dependencies / singletons !
   *
   * Be careful! It throws the following Exceptions:
   *
   *    [NotDefinedException] - If you try to get a instance that is not registered
   *
   *    [CircularDependencyException] - If you have an circulatory issue
   *
   */
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

      /**
       * You can register a instance without a "key" type:
       * e.g
       *    - Injector().registerDependency((_) => new UserService()); <= This doesn't work
       *
       *     - Injector().registerDependency<IUserService>((_) => new UserService()); <= This works
       */
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


  /**
   * This method removes clears the injector.
   *
   * Maybe you need this in some test cases.
   *
   */
  void clearDependencies() {
    _factoryCallIds.clear();
    _factoryMap.clear();
  }
}
