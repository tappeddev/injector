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

void main() {
  // Use this static instance
  Injector injector = Injector.appInstance;

  //Register a dependency
  injector.registerDependency<Engine>((_) => Engine());

  injector.registerDependency<Car>((Injector injector) {
    var engine = injector.getDependency<Engine>();
    return CarImpl(engine: engine);
  });

  //Maybe you want to register a class and you need it as a singleton
  injector.registerSingleton<Database>((_) => TikkrDatabase());
}

//Now you can easily get your dependencies / singletons with one line
class WebView {
  Database database;
  Car customerCar;

  WebView() {
    Injector injector = Injector.appInstance;
    database = injector.getDependency<Database>();
    customerCar = injector.getDependency<Car>();
  }
}
