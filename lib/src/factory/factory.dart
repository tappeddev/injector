import 'package:injector/injector.dart';

/**
 * You get this lazy callback if you register a dependency.
 *
 * You can do stuff like that:
 *
 *
 * var myInjector = Injector();
 *
 *
 *  myInjector.registerDependency<Car>((Injector innerInjector) {
 *
 *      // If you need another dependency that depends on the other
 *      // dependency you need to use the "innerInjector".
 *      //Because that works "lazy"
 *
 *      var engine = innerInjector.getDependency<Engine>();
 *      return CarImpl(engine: engine);
 *   });
 */
typedef T Builder<T>(Injector injector);

abstract class Factory<T> {
  Builder<T> builder;
  Injector injector;

  T get instance;
}
