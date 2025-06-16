import 'dart:async';
import 'dart:math' as math;

class PerformanceMetrics {
  final double cpu;
  final double memory;
  final double disk;
  final double network;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.cpu,
    required this.memory,
    required this.disk,
    required this.network,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'cpu': cpu,
      'memory': memory,
      'disk': disk,
      'network': network,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpu: json['cpu'].toDouble(),
      memory: json['memory'].toDouble(),
      disk: json['disk'].toDouble(),
      network: json['network'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  final _metricsController = StreamController<PerformanceMetrics>.broadcast();
  Timer? _monitoringTimer;
  final List<PerformanceMetrics> _historicalData = [];
  static const int _maxHistoricalDataPoints = 100;

  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  Stream<PerformanceMetrics> get performanceMetrics => _metricsController.stream;
  List<PerformanceMetrics> get historicalData => List.unmodifiable(_historicalData);

  void startMonitoring({Duration interval = const Duration(seconds: 1)}) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(interval, (timer) {
      final metrics = _generateMetrics();
      _metricsController.add(metrics);
      _addToHistory(metrics);
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  PerformanceMetrics _generateMetrics() {
    final random = math.Random();
    return PerformanceMetrics(
      cpu: _generateSmoothedValue(random, 20, 80),
      memory: _generateSmoothedValue(random, 30, 70),
      disk: _generateSmoothedValue(random, 10, 40),
      network: _generateSmoothedValue(random, 5, 95),
    );
  }

  double _generateSmoothedValue(math.Random random, double min, double max) {
    if (_historicalData.isEmpty) {
      return min + random.nextDouble() * (max - min);
    }

    final lastValue = _historicalData.last;
    final targetMetric = (lastValue.cpu + lastValue.memory + lastValue.disk + lastValue.network) / 4;
    final smoothingFactor = 0.3;
    final rawValue = min + random.nextDouble() * (max - min);
    return targetMetric * (1 - smoothingFactor) + rawValue * smoothingFactor;
  }

  void _addToHistory(PerformanceMetrics metrics) {
    _historicalData.add(metrics);
    if (_historicalData.length > _maxHistoricalDataPoints) {
      _historicalData.removeAt(0);
    }
  }

  Map<String, dynamic> getPerformanceReport() {
    if (_historicalData.isEmpty) {
      return {
        'current_status': 'unknown',
        'metrics': {},
        'alerts': [],
      };
    }

    final latestMetrics = _historicalData.last;
    final averageMetrics = getAverageMetrics();
    final alerts = <String>[];

    // Check for potential issues
    if (latestMetrics.cpu > 80) alerts.add('High CPU usage');
    if (latestMetrics.memory > 85) alerts.add('High memory usage');
    if (latestMetrics.disk > 90) alerts.add('Low disk space');
    if (latestMetrics.network > 90) alerts.add('High network utilization');

    String status;
    if (alerts.isEmpty) {
      status = 'healthy';
    } else if (alerts.length <= 2) {
      status = 'warning';
    } else {
      status = 'critical';
    }

    return {
      'current_status': status,
      'metrics': latestMetrics.toJson(),
      'historical_data': averageMetrics,
      'alerts': alerts,
    };
  }

  Map<String, List<double>> getAverageMetrics({Duration period = const Duration(minutes: 5)}) {
    final cutoffTime = DateTime.now().subtract(period);
    final relevantData = _historicalData.where((m) => m.timestamp.isAfter(cutoffTime));

    if (relevantData.isEmpty) {
      return {
        'cpu': [],
        'memory': [],
        'disk': [],
        'network': [],
      };
    }

    return {
      'cpu': _calculateMovingAverage(relevantData.map((m) => m.cpu).toList()),
      'memory': _calculateMovingAverage(relevantData.map((m) => m.memory).toList()),
      'disk': _calculateMovingAverage(relevantData.map((m) => m.disk).toList()),
      'network': _calculateMovingAverage(relevantData.map((m) => m.network).toList()),
    };
  }

  List<double> _calculateMovingAverage(List<double> values, {int windowSize = 5}) {
    if (values.length < windowSize) {
      return values;
    }

    final result = <double>[];
    for (var i = 0; i <= values.length - windowSize; i++) {
      final window = values.sublist(i, i + windowSize);
      final average = window.reduce((a, b) => a + b) / windowSize;
      result.add(average);
    }
    return result;
  }

  void dispose() {
    stopMonitoring();
    _metricsController.close();
  }
} 