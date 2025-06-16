import 'dart:async';
import 'dart:math' as math;

class RealTimeDataService {
  static final RealTimeDataService _instance = RealTimeDataService._internal();
  factory RealTimeDataService() => _instance;
  RealTimeDataService._internal();

  final _revenueController = StreamController<double>.broadcast();
  final _userActivityController = StreamController<int>.broadcast();
  final _performanceController = StreamController<Map<String, double>>.broadcast();
  final _usersController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Timer? _timer;

  Stream<double> get revenueStream => _revenueController.stream;
  Stream<int> get userActivityStream => _userActivityController.stream;
  Stream<Map<String, double>> get performanceStream => _performanceController.stream;
  Stream<List<Map<String, dynamic>>> get usersStream => _usersController.stream;

  void startRealTimeUpdates() {
    startStreaming();
  }

  void startStreaming() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _generateAndEmitData();
    });
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
  }

  void _generateAndEmitData() {
    // Generate random revenue data
    final revenue = 10000 + math.Random().nextDouble() * 5000;
    _revenueController.add(revenue);

    // Generate random user activity data
    final userActivity = 100 + math.Random().nextInt(50);
    _userActivityController.add(userActivity);

    // Generate random performance metrics
    final performance = {
      'cpu': 20 + math.Random().nextDouble() * 60,
      'memory': 30 + math.Random().nextDouble() * 40,
      'disk': 10 + math.Random().nextDouble() * 30,
      'network': 5 + math.Random().nextDouble() * 95,
    };
    _performanceController.add(performance);

    // Generate random user data
    final users = List.generate(5, (index) => {
      'id': index + 1,
      'name': 'User ${index + 1}',
      'status': math.Random().nextBool() ? 'online' : 'offline',
      'lastActivity': DateTime.now().subtract(Duration(minutes: math.Random().nextInt(60))).toString(),
    });
    _usersController.add(users);
  }

  void dispose() {
    stopStreaming();
    _revenueController.close();
    _userActivityController.close();
    _performanceController.close();
    _usersController.close();
  }
} 