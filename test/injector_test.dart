import 'package:injector/injector.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:test/test.dart';

import 'test_classes.dart';
import 'test_classes_2.dart' as test2;

void main() {
  Injector injector;

  setUp(() {
    injector = Injector.appInstance;
    injector.clearAll();
  });

  test('Register dependency / Get dependency - Test', () {
    injector.registerDependency<Fuel>(() => Fuel());

    injector.registerDependency<Driver>(() => Driver());

    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<Car>(() {
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
    injector.registerSingleton<Fuel>(() => Fuel());

    injector.registerSingleton<Driver>(() => Driver());

    injector.registerSingleton<Engine>(() => Engine());

    injector.registerSingleton<Car>(() {
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
    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<test2.Engine>(() => test2.Engine());

    var engine1 = injector.getDependency<Engine>();

    var engine2 = injector.getDependency<test2.Engine>();

    expect(engine1, isNot(engine2));
  });

  test('Detects Cylce dependencies', () {
    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<Fuel>(() {
      injector.getDependency<Engine>();

      // this will trigger the cycle
      // since Fuel requires Driver and Driver requires Fuel
      injector.getDependency<Driver>();
      return Fuel();
    });

    injector.registerDependency<Driver>(() {
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
    String dependencyName = "RegisterWithName";

    var rawEngine = Engine();

    injector.registerSingleton<Engine>(() => rawEngine, dependencyName: dependencyName);

    var engine = injector.getDependency<Engine>(dependencyName: dependencyName);

    expect(engine == rawEngine, true);
  });

  test("Register two time the same dependencies with different names", () {
    String dependencyName1 = "Dep1";
    String dependencyName2 = "Dep2";

    injector.registerDependency<Engine>(() => Engine(), dependencyName: dependencyName1);

    injector.registerDependency<Engine>(() => Engine(), dependencyName: dependencyName2);

    var engine1 = injector.getDependency<Engine>(dependencyName: dependencyName1);
    var engine2 = injector.getDependency<Engine>(dependencyName: dependencyName2);

    expect(engine1, TypeMatcher<Engine>());
    expect(engine2, TypeMatcher<Engine>());
  });

  test("override a dependencies", () {
    injector.registerDependency<Engine>(() => Engine()..capacity = "1");

    injector.registerDependency<Engine>(
      () => Engine()..capacity = "2",
      override: true,
    );

    var engine = injector.getDependency<Engine>();

    expect(engine.capacity, "2");
  });
}
