import 'package:meta/meta.dart';

/**
 * We throw this exception if you try to call a dependency that doesn't exist.
 *
 * For example:
 *
 * var myInstance = Injector().getDependency<IInterface>();
 *
 * You can fix this issue with the following checkpoints:
 *  - Did you register the register the instance with the right key type?
 *
 *    e.g:
 *       - Injector().registerDependency<FirstImplementation>((_) => FirstImplementation());
 *
 *       // This throws the [NotDefinedException]
 *       - Injector().getDependency<IInterface>();
 *
 *    You try to get the instance with the wrong key type!
 *
 *    e.g:
 *       - Injector().registerDependency<IInterface>((_) => FirstImplementation());
 *
 *  - Did you call your register method?
 *
 *    Maybe you missed to call the register function!
 *
 *    Be sure that you call:
 *    - Injector().registerDependency<IInterface>((_) => Implementation());
 *
 */
class NotDefinedException implements Exception {

  // The Type of the missing instance
  String type;

  NotDefinedException({@required this.type});

  @override
  String toString() => "The type \"$type\" is not defined!";
}
