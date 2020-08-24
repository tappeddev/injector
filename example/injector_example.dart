import 'package:injector/injector.dart';
import 'package:meta/meta.dart';

class Engine {
  String capacity = "";
}

abstract class Car {
  bool drive();

  bool stop();
}

class CarImpl extends Car {
  final Engine engine;

  CarImpl({@required this.engine});

  @override
  bool drive() {
    return true;
  }

  @override
  bool stop() {
    return true;
  }
}

abstract class Database {
  void add(String text);

  void remove(int id);
}

class TikkrDatabase extends Database {
  TikkrDatabase() {
    _initialize(_createTableString());
  }

  void _initialize(String createTableString) {
    //Create the Database
  }

  String _createTableString() {
    return "CREATE TABLE USER";
  }

  @override
  void add(String text) {
    //Do something
  }

  @override
  void remove(int id) {
    //Do something
  }
}

class CustomFactory<T> extends Factory<T> {
  CustomFactory(Builder<T> builder) : super(builder);

  @override
  T get instance {
    //Use this.builder to create your instance with custom logic.
    return builder();
  }
}

void main() {
  // Use this static instance
  final injector = Injector.appInstance;

  // Register a dependency
  injector.registerDependency<Engine>(() => Engine());

  injector.registerDependency<Car>(() {
    final engine = injector.get<Engine>();
    return CarImpl(engine: engine);
  });

  //Use custom Factories by extending [Factory]
  injector.register(CustomFactory(() => Engine()));

  // Maybe you want to register a class and you need it as a singleton
  injector.registerSingleton<Database>(() => TikkrDatabase());
}

// Now you can easily get your dependencies / singletons with one line
class WebView {
  Database database;
  Car customerCar;

  WebView() {
    final injector = Injector.appInstance;
    database = injector.get<Database>();
    customerCar = injector.get<Car>();
  }
}
