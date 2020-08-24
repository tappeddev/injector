# Injector 💉 [![Build Status](https://travis-ci.com/tikkrapp/injector.svg?branch=master)](https://travis-ci.com/tikkrapp/injector)

Injector is a simple dependency injection lib for Dart.

It does not replace a complex dependency injection framework like Dagger, but it provides the basics that most apps need.
Feature requests are welcomed!

Internally the injector is a singleton that stores instances and builders in a Map.

Use `registerDependency<Type>()` to register the dependency.
Never ever try to register or get dependencies without the generic type! Dart allows it, but we don't ;)

All instances are lazy loaded, meaning that at the time you request the dependency the instance is created. 
    
Get your dependency using `get<Type>()`. 

    

## Usage

A simple usage example:

    // Register a dependency (Every time a new instance)
    injector.registerDependency<Car>(() {
          var engine = injector.get<Engine>();
          var fuel = injector.get<Fuel>();
          var driver = injector.get<Driver>();
          
          return CarImpl(engine,fuel,driver);
        });
        
    // Register a singleton
    injector.registerSingleton<Car>(() {
              var engine = injector.get<Engine>();
              var fuel = injector.get<Fuel>();
              var driver = injector.get<Driver>();
              
              return CarImpl(engine,fuel,driver);
            });
            
     // Use custom Factories by extending [Factory].
     injector.register(CustomFactory(() => Engine()));
        
    // Register your dependencies / singletons in the  __main.dart__ file

## Notice

If you have an issue with getting dependencies from the injector, check that imports of your dependencies classes are absolute.

Good:
import 'package:<project_name>/some/package/<file_name>.dart';

Bad:
import '../../some/package/<file_name>.dart';

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/tappeddev/injector/issues
