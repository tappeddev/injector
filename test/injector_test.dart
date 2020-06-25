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
      final fuel = injector.instance<Fuel>();
      final driver = injector.instance<Driver>();
      final engine = injector.instance<Engine>();

      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    final car = injector.instance<Car>();

    expect(car, isNotNull);
    expect(car.drive(), true);
    expect(car.stop(), true);
  });

  test("Ecxeption - A not registered Dependency", () {
    try {
      injector.instance<Fuel>();
    } on Exception catch (e) {
      expect(e, const TypeMatcher<Exception>());
    }
  });

  test('Register singleton / Get singleton - Test', () {
    injector.registerSingleton<Fuel>(() => Fuel());

    injector.registerSingleton<Driver>(() => Driver());

    injector.registerSingleton<Engine>(() => Engine());

    injector.registerSingleton<Car>(() {
      final fuel = injector.instance<Fuel>();
      final driver = injector.instance<Driver>();
      final engine = injector.instance<Engine>();
      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    final singleTonCar1 = injector.instance<Car>();

    final singleTonCar2 = injector.instance<Car>();

    expect(singleTonCar1, equals(singleTonCar2));
  });

  test('Register two classes with the same name from different packages - Test',
      () {
    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<test2.Engine>(() => test2.Engine());

    final engine1 = injector.instance<Engine>();
    final engine2 = injector.instance<test2.Engine>();

    expect(engine1, isNot(engine2));
  });

  test('Detects Cylce dependencies', () {
    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<Fuel>(() {
      injector.instance<Engine>();

      // this will trigger the cycle
      // since Fuel requires Driver and Driver requires Fuel
      injector.instance<Driver>();
      return Fuel();
    });

    injector.registerDependency<Driver>(() {
      injector.instance<Engine>();
      injector.instance<Fuel>();
      return Driver();
    });

    try {
      injector.instance<Fuel>();
    } on Exception catch (e) {
      expect(e, const TypeMatcher<CircularDependencyException>());
    }
  });

  test("RegisterDependency with name", () {
    const dependencyName = "RegisterWithName";
    final rawEngine = Engine();

    injector.registerSingleton<Engine>(() => rawEngine,
        dependencyName: dependencyName);

    final engine = injector.instance<Engine>(dependencyName: dependencyName);

    expect(engine == rawEngine, true);
  });

  test("Register two time the same dependencies with different names", () {
    const dependencyName1 = "Dep1";
    const dependencyName2 = "Dep2";

    injector.registerDependency<Engine>(() => Engine(),
        dependencyName: dependencyName1);
    injector.registerDependency<Engine>(() => Engine(),
        dependencyName: dependencyName2);

    final engine1 = injector.instance<Engine>(dependencyName: dependencyName1);
    final engine2 = injector.instance<Engine>(dependencyName: dependencyName2);

    expect(engine1, const TypeMatcher<Engine>());
    expect(engine2, const TypeMatcher<Engine>());
  });

  test("override a dependencies", () {
    injector.registerDependency<Engine>(() => Engine()..capacity = "1");

    injector.registerDependency<Engine>(
      () => Engine()..capacity = "2",
      override: true,
    );

    final engine = injector.instance<Engine>();

    expect(engine.capacity, "2");
  });
}
