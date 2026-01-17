sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, {this.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {super.cause}) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {super.cause}) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {super.cause}) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {super.cause}) : super(message);
}
