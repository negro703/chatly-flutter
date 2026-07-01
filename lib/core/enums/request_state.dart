/// Represents the state of an asynchronous request.
enum RequestState {
  /// Initial idle state before any request.
  initial,

  /// Request is currently loading.
  loading,

  /// Request completed successfully.
  loaded,

  /// Request failed with an error.
  error,
}