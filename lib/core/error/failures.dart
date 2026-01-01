import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String message;
  const Failures(this.message);

  @override
  List<Object?> get props => [message];
}

//local Database Failure

class LocalDatabaseFailure extends Failures {
  const LocalDatabaseFailure({
    String message = 'Local database operation failed',
  }) : super(message);
}

//API Failure with status code
class ApiFailure extends Failures {
  final int? statusCode;

  const ApiFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}
