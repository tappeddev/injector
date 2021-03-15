# 2.0.0
- Stable release for null safety


## 1.0.9
- Add `get` as shortcut for `getDependency`
- Add deprecated annotation to `getDependency`
- Some preparations for nullability
- [bug] Fixed the bug, that the library detects a wrong circular dependency ([#25][i25])

[i25]: https://github.com/tappeddev/injector/issues/25

## 1.0.8
- Add travis ci badge to readme
- Reformat using dartfmt

## 1.0.7
- Refactor docs

## 1.0.6

- Add remove dependency method
- Add override dependencies property 

## 1.0.5

- **Breaking Changes!** Injector is not a singleton. 
You can use it like a singleton with the static instance ```Injector.appInstance``` 
- You can register your dependencies with a name. But be careful, 
you need always the generic type! It looks like ```Injector.allInstance.registerDependency<UserService>((injector) => UserServiceImpl), dependencyName: "MyCustomName"); ```

## 1.0.4

- Add some documentation for each class


## 1.0.3

- Change license from BSD-3 to Apache 2

## 1.0.2

- Upgrade analysis_options.yaml
- Add missing Cast ("as T")
- Add Test - Cycle dependencies

## 1.0.1

- Upgrade pubspec.yaml (Change dart sdk constraint)
- Update README.md
- Update Description


## 1.0.0

- Create package, 
- Add Injector class
- Add unit tests for "Injector"
- Add example - How to deal with the injector / dependency injector 
