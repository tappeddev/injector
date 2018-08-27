import 'package:injector/injector.dart';

typedef T Builder<T>(Injector injector);

abstract class Factory<T> {
  Builder<T> builder;
  Injector injector;

  T get instance;
}
