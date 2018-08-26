import 'package:injector/injector.dart';
import 'package:test/test.dart';

import 'test_classes.dart';
import 'test_classes_2.dart' as test2;

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

  test("Get a not registered Dependency", () {
    try {
      injector.getDependency<Fuel>();
    } on Exception catch (e) {
      expect(e, TypeMatcher<Exception>());
    }
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

    expect(singleTonCar1, equals(singleTonCar2));
  });

  test('Register two classes with the same name from different packages - Test', () {
    injector.registerDependency<Engine>((_) => Engine());

    injector.registerDependency<test2.Engine>((_) => test2.Engine());

    var engine1 = injector.getDependency<Engine>();

    var engine2 = injector.getDependency<test2.Engine>();

    expect(engine1, isNot(engine2));
  });
}
