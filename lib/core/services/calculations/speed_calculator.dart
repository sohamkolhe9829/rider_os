class SpeedCalculator {
  double _maxSpeedKmh = 0.0;
  double _speedSum = 0.0;
  int _speedSamples = 0;

  double get maxSpeed => _maxSpeedKmh;

  double get averageSpeed {
    if (_speedSamples == 0) return 0.0;
    return _speedSum / _speedSamples;
  }

  void addSample(double speedKmh) {
    if (speedKmh < 0) return;

    if (speedKmh > _maxSpeedKmh) {
      _maxSpeedKmh = speedKmh;
    }

    _speedSum += speedKmh;
    _speedSamples++;
  }

  void reset() {
    _maxSpeedKmh = 0.0;
    _speedSum = 0.0;
    _speedSamples = 0;
  }
}
