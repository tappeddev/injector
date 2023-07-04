import 'package:injector/injector.dart';
import 'package:injector/src/exception/circular_dependency_exception.dart';
import 'package:injector/src/exception/not_defined_exception.dart';
import 'package:test/test.dart';

import 'test_classes.dart';
import 'test_classes_2.dart' as test2;

void main() {
  final Injector injector = Injector.appInstance;

  setUp(() {
    injector.clearAll();
  });

  test('Register dependency / Get dependency - Test', () {
    injector.registerDependency<Fuel>(() => Fuel());
    injector.registerDependency<Driver>(() => Driver());
    injector.registerDependency<Engine>(() => Engine());
    injector.registerDependency<Car>(() {
      final fuel = injector.get<Fuel>();
      final driver = injector.get<Driver>();
      final engine = injector.get<Engine>();

      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    final car = injector.get<Car>();

    expect(car, isNotNull);
    expect(car.drive(), true);
    expect(car.stop(), true);
  });

  test("Exception - A not registered Dependency", () {
    try {
      injector.get<Fuel>();
    } on Exception catch (e) {
      expect(e, const TypeMatcher<NotDefinedException>());
    }
  });

  test('Register singleton / Get singleton - Test', () {
    injector.registerSingleton<Fuel>(() => Fuel());
    injector.registerSingleton<Driver>(() => Driver());
    injector.registerSingleton<Engine>(() => Engine());
    injector.registerSingleton<Car>(() {
      final fuel = injector.get<Fuel>();
      final driver = injector.get<Driver>();
      final engine = injector.get<Engine>();
      return CarImpl(driver: driver, engine: engine, fuel: fuel);
    });

    final singleTonCar1 = injector.get<Car>();
    final singleTonCar2 = injector.get<Car>();

    expect(singleTonCar1, same(singleTonCar2));
  });

  test('Register dependency calls factory function multiple times', () {
    var counter = 0;
    injector
      ..registerDependency<Fuel>(() {
        counter++;
        return Fuel();
      })
      ..get<Fuel>()
      ..get<Fuel>()
      ..get<Fuel>();

    expect(counter, 3);
  });

  test('Register two classes with the same name from different packages - Test',
      () {
    injector.registerDependency<Engine>(() => Engine());
    injector.registerDependency<test2.Engine>(() => test2.Engine());

    final engine1 = injector.get<Engine>();
    final engine2 = injector.get<test2.Engine>();

    expect(engine1, isNot(engine2));
  });

  test('Detects circular dependencies', () {
    injector.registerDependency<Engine>(() => Engine());

    injector.registerDependency<Fuel>(() {
      injector.get<Engine>();

      // this will trigger the cycle
      // since Fuel requires Driver and Driver requires Fuel
      injector.get<Driver>();
      return Fuel();
    });

    injector.registerDependency<Driver>(() {
      injector.get<Engine>();
      injector.get<Fuel>();
      return Driver();
    });

    try {
      injector.get<Fuel>();
    } on Exception catch (e) {
      expect(e, const TypeMatcher<CircularDependencyException>());
    }
  });

  test("RegisterDependency with name", () {
    const dependencyName = "RegisterWithName";
    final rawEngine = Engine();

    injector.registerSingleton<Engine>(() => rawEngine,
        dependencyName: dependencyName);

    final engine = injector.get<Engine>(dependencyName: dependencyName);

    expect(engine == rawEngine, true);
  });

  test("Register two time the same dependencies with different names", () {
    const dependencyName1 = "Dep1";
    const dependencyName2 = "Dep2";

    injector.registerDependency<Engine>(() => Engine()..capacity = "1",
        dependencyName: dependencyName1);
    injector.registerDependency<Engine>(() => Engine()..capacity = "2",
        dependencyName: dependencyName2);

    final engine1 = injector.get<Engine>(dependencyName: dependencyName1);
    final engine2 = injector.get<Engine>(dependencyName: dependencyName2);

    expect(engine1.capacity, "1");
    expect(engine2.capacity, "2");
  });

  test("override a dependency", () {
    injector.registerDependency<Engine>(() => Engine()..capacity = "1");

    injector.registerDependency<Engine>(
      () => Engine()..capacity = "2",
      override: true,
    );

    final engine = injector.get<Engine>();

    expect(engine.capacity, "2");
  });

  test("resets circular detection when get call fails", () {
    var didThrow = false;

    injector.registerDependency<Engine>(() {
      if (!didThrow) {
        didThrow = true;
        throw Exception("ups");
      }
      return Engine();
    });

    // This first call will throw an exception and therefore
    // in that case we have to reset the called factories to ensure that
    // our circular dependency injection will not be triggered in the second call.
    expect(
      () => injector.get<Engine>(),
      throwsA(isA<Exception>()),
    );

    // If this call works, we are save ✅
    final engine = injector.get<Engine>();

    expect(engine, isNotNull);
  });
}
