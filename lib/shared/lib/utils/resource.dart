sealed class Resource<T> {
  const Resource();
}

final class Success<T> extends Resource<T> {
  const Success(this.data);
  final T data;

  @override
  String toString() => 'Success(data: $data)';
}

final class Failure<T> extends Resource<T> {

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });
  final String message;
  final int? statusCode;
  final dynamic error;

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

extension ResourceExtension<T> on Resource<T> {
  void onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
  }

  void onFailure(void Function(String message) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).message);
    }
  }

  Resource<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(message: final msg, statusCode: final code, error: final err) =>
          Failure(message: msg, statusCode: code, error: err),
    };
  }

  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;
}