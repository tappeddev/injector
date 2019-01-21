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
  static final Injector appInstance = Injector();

  /**
   * The constructor to create a new instance
   */
  Injector();

  /**
   * The Map that contains:
   *
   *  [SingletonFactory] - The single instances
   *
   * [ProviderFactory] - The provider factory that contains the type information.
   *                     If creates a new instance every time
   */
  Map<String, Factory<Object>> _factoryMap = Map<String, Factory<Object>>();

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
   * Injector.appInstance.registerDependency<UserService>((_) => new UserService);
   *
   * If you now trying to get your dependency with:
   *
   *     var userService = Injector.appInstance.getDependency<UserService>();
   *
   * You get a new instance of your dependency every time that you call this function!
   *
   */
  void registerDependency<T>(Builder<T> builder, {String dependencyName = ""}) {
    _checkValidation<T>();

    String identity = _getIdentity<T>(dependencyName);

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
   * Injector.appInstance.registerSingleton<UserService>((_) => new UserService);
   *
   * If you now trying to get your dependency with:
   *
   *    Injector.appInstance.getDependency<UserService>();
   *
   * You get the same instance of your dependency every time!
   *
   */
  void registerSingleton<T>(Builder<T> builder, {String dependencyName = ""}) {
    _checkValidation<T>();

    String identity = _getIdentity<T>(dependencyName);

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

  void _checkValidation<T>() {
    var type = T.toString();

    if (T == dynamic) {
      /**
       * You can register a instance without a "key" type:
       * e.g
       *    - Injector.appInstance.registerDependency((_) => new UserService()); <= This doesn't work
       *
       *     - Injector.appInstance.registerDependency<IUserService>((_) => new UserService()); <= This works
       */
      throw Exception(
          "No type specified !\nCan not register dependencies for type \"$type\"");
    }
  }

  void _checkForDuplicates<T>(String identity) {
    if (_factoryMap.containsKey(identity)) {
      throw AlreadyDefinedException(type: T.toString());
    }
  }

  String _getIdentity<T>(String dependencyName) =>
      "$dependencyName${T.hashCode.toString()}";

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
