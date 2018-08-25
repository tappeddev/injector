import 'package:injector/injector.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:test/test.dart';

import 'test_classes.dart';

void main() {
  Injector injector;

  setUp(() {
    injector = Injector();
    injector.clearDependencies();
  });

  test('Register dependency / Get dependency - Test', () {
    injector.registerDependency<Fuel>((_) => Fuel());

    injector.registerDependency<Driver>((_) => Driver());

    injector.registerDependency<Engine>((_) => Engine());

    injector.registerDependency<Car>((Injector injector) {
      var fuel = injector.getDependency<Fuel>();
      var driver = injector.getDependency<Driver>();
      var engine = injector.getDependency<Engine>();

      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    Car car = injector.getDependency<Car>();

    expect(car, isNotNull);
    expect(car.drive(), true);
    expect(car.stop(), true);
  });

  test('Register singleton / Get singleton - Test', () {
    injector.registerDependency<Fuel>((_) => Fuel());

    injector.registerDependency<Driver>((_) => Driver());

    injector.registerDependency<Engine>((_) => Engine());

    injector.registerSingleton<Car>((Injector injector) {
      var fuel = injector.getDependency<Fuel>();
      var driver = injector.getDependency<Driver>();
      var engine = injector.getDependency<Engine>();

      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    Car singleTonCar1 = injector.getDependency<Car>();

    Car singleTonCar2 = injector.getDependency<Car>();

    expect(singleTonCar1, singleTonCar2);
  });

  test('Detects Cylce dependencies', () {
    injector.registerDependency<Engine>((_) => Engine());

    injector.registerDependency<Fuel>((injector) {
      injector.getDependency<Engine>();

      // this will trigger the cycle
      // since Fuel requires Driver and Driver requires Fuel
      injector.getDependency<Driver>();
      return Fuel();
    });

    injector.registerDependency<Driver>((injector) {
      injector.getDependency<Engine>();
      injector.getDependency<Fuel>();
      return Driver();
    });

    try {
      injector.getDependency<Fuel>();
    } on Exception catch (e) {
      expect(e, TypeMatcher<CircularDependencyException>());
    }
  });
}
