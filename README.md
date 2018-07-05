# injector

The Dependency Injection is more a simple service locator but provides basic functionality.

Use `registerDependency<Type>()` to register the dependency. 
    This takes a function that gives you an instance of the injector. That way you are able to get other dependency required by your registered dependency.
    
    Get your dependency using `getDependency<Type>()`. 
    
    __Never ever try to register or get dependencies without the generic type! Dart allows it, but we don't ;)__
    

## Usage

A simple usage example:

    ///Register a dependency (Every time a new instance)
    injector.registerDependency<Car>((injector) {
          var engine = injector.getDependency<Engine>();
          var fuel = injector.getDependency<Fuel>();
          var driver = injector.getDependency<Driver>();
          
          return CarImpl(engine,fuel,driver);
        });
        
    ///Register a singleton
     injector.registerSingleton<Car>((injector) {
              var engine = injector.getDependency<Engine>();
              var fuel = injector.getDependency<Fuel>();
              var driver = injector.getDependency<Driver>();
              
              return CarImpl(engine,fuel,driver);
            });
        
    //Register your dependencies / singletons in the  __main.dart__ file
    



## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/tikkrapp/injector/issues
