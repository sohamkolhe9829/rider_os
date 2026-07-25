enum MaintenanceType {
  engineOil,
  chainClean,
  chainLube,
  brakePads,
  coolant,
  airFilter,
  sparkPlug,
  battery,
  insurance,
  puc;

  String get displayName {
    switch (this) {
      case MaintenanceType.engineOil:
        return 'Engine Oil';
      case MaintenanceType.chainClean:
        return 'Chain Clean';
      case MaintenanceType.chainLube:
        return 'Chain Lube';
      case MaintenanceType.brakePads:
        return 'Brake Pads';
      case MaintenanceType.coolant:
        return 'Coolant';
      case MaintenanceType.airFilter:
        return 'Air Filter';
      case MaintenanceType.sparkPlug:
        return 'Spark Plug';
      case MaintenanceType.battery:
        return 'Battery';
      case MaintenanceType.insurance:
        return 'Insurance';
      case MaintenanceType.puc:
        return 'PUC';
    }
  }

  /// Default service intervals in KM. Null means time-based only (e.g. Insurance).
  double? get defaultIntervalKm {
    switch (this) {
      case MaintenanceType.chainLube:
        return 500;
      case MaintenanceType.chainClean:
        return 1000;
      case MaintenanceType.engineOil:
        return 5000;
      case MaintenanceType.brakePads:
        return 10000;
      case MaintenanceType.coolant:
        return 20000;
      case MaintenanceType.airFilter:
        return 15000;
      case MaintenanceType.sparkPlug:
        return 12000;
      case MaintenanceType.battery:
        return null;
      case MaintenanceType.insurance:
        return null;
      case MaintenanceType.puc:
        return null;
    }
  }

  /// Default service intervals in Days.
  int? get defaultIntervalDays {
    switch (this) {
      case MaintenanceType.chainLube:
        return 14;
      case MaintenanceType.chainClean:
        return 30;
      case MaintenanceType.engineOil:
        return 180;
      case MaintenanceType.brakePads:
        return 365;
      case MaintenanceType.coolant:
        return 730;
      case MaintenanceType.airFilter:
        return 365;
      case MaintenanceType.sparkPlug:
        return 365;
      case MaintenanceType.battery:
        return 1095; // 3 years
      case MaintenanceType.insurance:
        return 365;
      case MaintenanceType.puc:
        return 180;
    }
  }
}

class MaintenanceItem {
  MaintenanceItem({
    required this.id,
    required this.type,
    this.lastServiceDate,
    this.lastServiceDistance = 0.0,
    this.nextDueDate,
    this.nextDueDistance,
    this.notes = '',
  });

  final String id;
  final MaintenanceType type;
  final DateTime? lastServiceDate;
  final double lastServiceDistance;
  final DateTime? nextDueDate;
  final double? nextDueDistance;
  final String notes;

  MaintenanceItem copyWith({
    String? id,
    MaintenanceType? type,
    DateTime? lastServiceDate,
    double? lastServiceDistance,
    DateTime? nextDueDate,
    double? nextDueDistance,
    String? notes,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      type: type ?? this.type,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceDistance: lastServiceDistance ?? this.lastServiceDistance,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueDistance: nextDueDistance ?? this.nextDueDistance,
      notes: notes ?? this.notes,
    );
  }
}
