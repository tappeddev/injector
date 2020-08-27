class Engine {
  String capacity = "";
}

class Fuel {
  int octane = 95;
}

class Driver {
  String name = "Max";
}

abstract class Car {
  bool drive();

  bool stop();
}

class CarImpl extends Car {
  final Engine engine;
  final Fuel fuel;
  final Driver driver;

  CarImpl({required this.engine, required this.fuel, required this.driver});

  @override
  bool drive() {
    return true;
  }

  @override
  bool stop() {
    return true;
  }
}
