class AltitudeCalculator {
  // Simple moving average filter to smooth GPS spikes
  final List<double> _samples = [];
  final int _windowSize = 10; // Increased window size for better smoothing

  double _highest = -9999.0;
  double _lowest = 9999.0;
  double _currentSmoothed = 0.0;

  double _elevationGain = 0.0;
  double _elevationLoss = 0.0;
  double _previousSmoothed = 0.0;

  double get highestAltitude => _highest == -9999.0 ? 0.0 : _highest;
  double get lowestAltitude => _lowest == 9999.0 ? 0.0 : _lowest;
  double get currentAltitude => _currentSmoothed;
  double get elevationGain => _elevationGain;
  double get elevationLoss => _elevationLoss;

  void addSample(double rawAltitude, {double? accuracy}) {
    // Ignore invalid or wildly inaccurate values
    if (accuracy != null && accuracy > 15.0) return;

    // Ignore extreme jumps (> 50 meters between samples, likely a GPS glitch)
    if (_samples.isNotEmpty) {
      final lastSample = _samples.last;
      if ((rawAltitude - lastSample).abs() > 50.0) return;
    }

    _samples.add(rawAltitude);
    if (_samples.length > _windowSize) {
      _samples.removeAt(0);
    }

    if (_samples.isEmpty) return;

    _previousSmoothed = _currentSmoothed;
    _currentSmoothed = _samples.reduce((a, b) => a + b) / _samples.length;

    // Calculate gain and loss (only if we have a full window to ensure stability)
    if (_samples.length == _windowSize && _previousSmoothed != 0.0) {
      final delta = _currentSmoothed - _previousSmoothed;
      // Use a small threshold (e.g. 0.5m) to avoid micro-fluctuations adding up
      if (delta > 0.5) {
        _elevationGain += delta;
      } else if (delta < -0.5) {
        _elevationLoss += delta.abs();
      }
    }

    if (_samples.length == _windowSize) {
      if (_currentSmoothed > _highest) _highest = _currentSmoothed;
      if (_currentSmoothed < _lowest) _lowest = _currentSmoothed;
    }
  }

  void reset() {
    _samples.clear();
    _highest = -9999.0;
    _lowest = 9999.0;
    _currentSmoothed = 0.0;
    _elevationGain = 0.0;
    _elevationLoss = 0.0;
    _previousSmoothed = 0.0;
  }
}
