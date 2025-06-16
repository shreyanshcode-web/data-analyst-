import 'dart:async';
import 'dart:math' as math;

class PredictiveAnalytics {
  final double predictedValue;
  final double confidenceLevel;
  final List<double> trendData;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalMetrics;

  PredictiveAnalytics({
    required this.predictedValue,
    required this.confidenceLevel,
    required this.trendData,
    DateTime? timestamp,
    this.additionalMetrics,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'predictedValue': predictedValue,
      'confidenceLevel': confidenceLevel,
      'trendData': trendData,
      'timestamp': timestamp.toIso8601String(),
      'additionalMetrics': additionalMetrics,
    };
  }

  factory PredictiveAnalytics.fromJson(Map<String, dynamic> json) {
    return PredictiveAnalytics(
      predictedValue: json['predictedValue'].toDouble(),
      confidenceLevel: json['confidenceLevel'].toDouble(),
      trendData: (json['trendData'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      timestamp: DateTime.parse(json['timestamp']),
      additionalMetrics: json['additionalMetrics'],
    );
  }
}

class PredictiveAnalyticsService {
  static final PredictiveAnalyticsService _instance =
      PredictiveAnalyticsService._internal();
  factory PredictiveAnalyticsService() => _instance;
  PredictiveAnalyticsService._internal();

  final _predictionsController = StreamController<PredictiveAnalytics>.broadcast();
  Timer? _predictionTimer;
  final List<double> _historicalData = [];
  static const int _maxHistoricalDataPoints = 100;

  Stream<PredictiveAnalytics> get predictionsStream => _predictionsController.stream;

  Future<Map<String, dynamic>> predictMetrics() async {
    final prediction = _generatePrediction();
    return {
      'prediction': prediction.toJson(),
      'confidence': prediction.confidenceLevel,
      'trend': prediction.trendData,
      'metrics': prediction.additionalMetrics,
    };
  }

  Future<Map<String, dynamic>> getAnomalyDetection() async {
    if (_historicalData.length < 20) {
      return {
        'anomalies': [],
        'risk_level': 'low',
        'details': {
          'message': 'Insufficient data for anomaly detection',
          'data_points': _historicalData.length,
          'required_points': 20
        },
      };
    }

    final anomalies = <Map<String, dynamic>>[];
    final mean = _historicalData.reduce((a, b) => a + b) / _historicalData.length;
    final stdDev = _calculateStandardDeviation(_historicalData);
    final threshold = 2.0; // Number of standard deviations for anomaly detection

    for (var i = 0; i < _historicalData.length; i++) {
      final value = _historicalData[i];
      final zScore = (value - mean).abs() / stdDev;

      if (zScore > threshold) {
        anomalies.add({
          'index': i,
          'value': value,
          'z_score': zScore,
          'timestamp': DateTime.now().subtract(Duration(minutes: _historicalData.length - i)),
        });
      }
    }

    final riskLevel = anomalies.length > 5 ? 'high' : 
                     anomalies.length > 2 ? 'medium' : 'low';

    return {
      'anomalies': anomalies,
      'risk_level': riskLevel,
      'details': {
        'mean': mean,
        'standard_deviation': stdDev,
        'threshold': threshold,
        'total_anomalies': anomalies.length,
      },
    };
  }

  double _calculateStandardDeviation(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b);
    return math.sqrt(squaredDiffs / (values.length - 1));
  }

  void startPredictions({Duration interval = const Duration(seconds: 5)}) {
    _predictionTimer?.cancel();
    _predictionTimer = Timer.periodic(interval, (timer) {
      final prediction = _generatePrediction();
      _predictionsController.add(prediction);
    });
  }

  void stopPredictions() {
    _predictionTimer?.cancel();
    _predictionTimer = null;
  }

  PredictiveAnalytics _generatePrediction() {
    final random = math.Random();
    
    // Generate historical data point
    final currentValue = 1000 + math.sin(_historicalData.length * 0.1) * 200 +
        random.nextDouble() * 100;
    _historicalData.add(currentValue);
    
    if (_historicalData.length > _maxHistoricalDataPoints) {
      _historicalData.removeAt(0);
    }

    // Calculate trend using simple linear regression
    final trend = _calculateTrend();
    
    // Generate prediction
    final predictedValue = trend.last + (trend.last - trend.first) * 0.1;
    
    // Calculate confidence level based on historical volatility
    final confidenceLevel = _calculateConfidenceLevel();

    return PredictiveAnalytics(
      predictedValue: predictedValue,
      confidenceLevel: confidenceLevel,
      trendData: trend,
      additionalMetrics: {
        'volatility': _calculateVolatility(),
        'momentum': _calculateMomentum(),
        'seasonality': _detectSeasonality(),
      },
    );
  }

  List<double> _calculateTrend() {
    if (_historicalData.length < 2) {
      return _historicalData;
    }

    final n = _historicalData.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = _historicalData;

    // Calculate means
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;

    // Calculate slope and intercept
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }

    final slope = numerator / denominator;
    final intercept = yMean - slope * xMean;

    // Generate trend line
    return List.generate(
      n,
      (i) => slope * i + intercept,
    );
  }

  double _calculateConfidenceLevel() {
    if (_historicalData.length < 2) {
      return 0.5;
    }

    // Calculate standard deviation
    final mean = _historicalData.reduce((a, b) => a + b) / _historicalData.length;
    final squaredDiffs = _historicalData
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b);
    final standardDeviation =
        math.sqrt(squaredDiffs / (_historicalData.length - 1));

    // Normalize confidence level between 0.5 and 1.0
    // Lower standard deviation = higher confidence
    final maxStdDev = mean * 0.5; // 50% of mean as maximum expected std dev
    return 1.0 - (standardDeviation / maxStdDev).clamp(0.0, 0.5);
  }

  double _calculateVolatility() {
    if (_historicalData.length < 2) {
      return 0.0;
    }

    final returns = List.generate(_historicalData.length - 1, (i) {
      return (_historicalData[i + 1] - _historicalData[i]) / _historicalData[i];
    });

    final meanReturn = returns.reduce((a, b) => a + b) / returns.length;
    final squaredDiffs = returns
        .map((r) => math.pow(r - meanReturn, 2))
        .reduce((a, b) => a + b);
    
    return math.sqrt(squaredDiffs / (returns.length - 1));
  }

  double _calculateMomentum() {
    if (_historicalData.length < 10) {
      return 0.0;
    }

    final recentData = _historicalData.sublist(_historicalData.length - 10);
    final oldValue = recentData.first;
    final newValue = recentData.last;
    
    return (newValue - oldValue) / oldValue;
  }

  Map<String, double> _detectSeasonality() {
    if (_historicalData.length < 20) {
      return {'strength': 0.0, 'period': 0.0};
    }

    // Simple seasonality detection using autocorrelation
    final data = _historicalData;
    final n = data.length;
    final maxLag = n ~/ 2;
    
    var maxCorrelation = 0.0;
    var bestPeriod = 0.0;
    
    for (var lag = 1; lag < maxLag; lag++) {
      var correlation = 0.0;
      var count = 0;
      
      for (var i = 0; i < n - lag; i++) {
        correlation += data[i] * data[i + lag];
        count++;
      }
      
      correlation /= count;
      
      if (correlation > maxCorrelation) {
        maxCorrelation = correlation;
        bestPeriod = lag.toDouble();
      }
    }
    
    return {
      'strength': maxCorrelation,
      'period': bestPeriod,
    };
  }

  void dispose() {
    stopPredictions();
    _predictionsController.close();
  }
} 