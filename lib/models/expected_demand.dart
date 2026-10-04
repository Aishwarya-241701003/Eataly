/// Represents forecasted demand for a specific popular dish during a campus rush slot
class DemandDishForecast {
  final String dishName;
  final String canteenName;
  final String category;
  final int forecastedQuantity;
  final int preOrdersPlaced;
  int preppedQuantity;

  DemandDishForecast({
    required this.dishName,
    required this.canteenName,
    required this.category,
    required this.forecastedQuantity,
    required this.preOrdersPlaced,
    this.preppedQuantity = 0,
  });

  double get prepProgress =>
      forecastedQuantity == 0 ? 0.0 : (preppedQuantity / forecastedQuantity).clamp(0.0, 1.0);

  bool get isPrepComplete => preppedQuantity >= forecastedQuantity;
}

/// Represents an expected ordering period (e.g. morning break, lunch rush)
class DemandSlot {
  final String id;
  final String title;
  final String timeRange;
  final int expectedOrderCount;
  final int currentPreOrders;
  final String rushLevel; // 'Normal', 'Moderate Rush', 'CRITICAL HIGH DEMAND'
  final double rushMultiplier; // e.g. 1.2x, 2.7x
  final String kitchenAdvisory;
  final List<DemandDishForecast> dishes;
  bool isRushAlertTriggered;

  DemandSlot({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.expectedOrderCount,
    required this.currentPreOrders,
    required this.rushLevel,
    required this.rushMultiplier,
    required this.kitchenAdvisory,
    required this.dishes,
    this.isRushAlertTriggered = false,
  });

  int get totalForecastedDishes =>
      dishes.fold(0, (sum, d) => sum + d.forecastedQuantity);

  int get totalPreppedDishes =>
      dishes.fold(0, (sum, d) => sum + d.preppedQuantity);

  double get overallPrepPercentage => totalForecastedDishes == 0
      ? 0.0
      : (totalPreppedDishes / totalForecastedDishes).clamp(0.0, 1.0);
}
