import 'package:meta/meta.dart';

class NotDefinedException implements Exception {
  String type;

  NotDefinedException({@required this.type});

  @override
  String toString() => "The type \"$type\" is not defined!";
}
