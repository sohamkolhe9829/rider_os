class CompassCalculator {
  static String getDirection(double heading) {
    if (heading < 0 || heading > 360) return '--';

    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) % 360) / 45;
    return directions[index.floor()];
  }
}
