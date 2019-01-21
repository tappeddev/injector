import 'package:injector/injector.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:test/test.dart';

import 'test_classes.dart';
import 'test_classes_2.dart' as test2;

void main() {
  Injector injector;

  setUp(() {
    injector = Injector.appInstance;
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

  test("Ecxeption - A not registered Dependency", () {
    try {
      injector.getDependency<Fuel>();
    } on Exception catch (e) {
      expect(e, TypeMatcher<Exception>());
    }
  });

  test('Register singleton / Get singleton - Test', () {
    injector.registerSingleton<Fuel>((_) => Fuel());

    injector.registerSingleton<Driver>((_) => Driver());

    injector.registerSingleton<Engine>((_) => Engine());

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

  test('Register two classes with the same name from different packages - Test',
      () {
    injector.registerDependency<Engine>((_) => Engine());

    injector.registerDependency<test2.Engine>((_) => test2.Engine());

    var engine1 = injector.getDependency<Engine>();

    var engine2 = injector.getDependency<test2.Engine>();

    expect(engine1, isNot(engine2));
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

  test("RegisterDependency with name", () {
    String dependencyName = "RegistedWithName";

    injector.registerDependency<Engine>((injector) => Engine(),
        dependencyName: dependencyName);

    var engine = injector.getDependency<Engine>(dependencyName: dependencyName);

    expect(engine, TypeMatcher<Engine>());
  });

  test("Register two time the same dependencies with different names", () {
    String dependencyName1 = "Dep1";
    String dependencyName2 = "Dep2";

    injector.registerDependency<Engine>((injector) => Engine(),
        dependencyName: dependencyName1);

    injector.registerDependency<Engine>((injector) => Engine(),
        dependencyName: dependencyName2);

    var engine1 =
        injector.getDependency<Engine>(dependencyName: dependencyName1);
    var engine2 =
        injector.getDependency<Engine>(dependencyName: dependencyName2);

    expect(engine1, TypeMatcher<Engine>());
    expect(engine2, TypeMatcher<Engine>());
  });
}
