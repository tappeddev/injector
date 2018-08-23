import 'package:injector/injector.dart';
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
    injector.clearDependencies();
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
}
