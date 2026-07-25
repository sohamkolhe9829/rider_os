/// Represents the status of the current ride recording session.
enum RideState {
  /// No ride is currently being recorded.
  inactive,

  /// A ride is actively being recorded. GPS and timer are running.
  recording,

  /// A ride is paused. GPS processing and timer are halted,
  /// but the session state is preserved in memory.
  paused,
}
