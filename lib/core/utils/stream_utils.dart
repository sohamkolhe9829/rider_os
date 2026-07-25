import 'dart:async';

extension ThrottleStreamExtension<T> on Stream<T> {
  /// Emits the most recently received item at most once every [duration].
  Stream<T> throttleTime(Duration duration) {
    StreamController<T>? controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    T? latestData;
    bool hasPendingData = false;

    void emit() {
      if (hasPendingData && controller != null && !controller.isClosed) {
        controller.add(latestData as T);
        hasPendingData = false;
      }
    }

    controller = StreamController<T>.broadcast(
      onListen: () {
        subscription = listen(
          (data) {
            latestData = data;
            hasPendingData = true;
            if (timer == null || !timer!.isActive) {
              // Emit immediately if there's no active timer, then start the timer
              emit();
              timer = Timer(duration, () {
                timer = null; // Timer finished
                emit(); // Emit any data that arrived during the wait
              });
            }
          },
          onError: controller?.addError,
          onDone: () {
            timer?.cancel();
            controller?.close();
          },
        );
      },
      onCancel: () {
        subscription?.cancel();
        timer?.cancel();
        timer = null;
      },
    );

    return controller.stream;
  }
}
