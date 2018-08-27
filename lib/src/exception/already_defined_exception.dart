import 'package:meta/meta.dart';

class AlreadyDefinedException implements Exception {
  String type;

  AlreadyDefinedException({@required this.type});

  @override
  String toString() => "Type \"$type\" already defined !";
}
