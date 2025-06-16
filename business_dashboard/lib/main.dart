import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/utils/navigator_service.dart';
import 'core/utils/pref_utils.dart';
import 'widgets/custom_error_widget.dart';
import 'presentation/dashboard_overview/flutterflow_dashboard_overview.dart';
import 'presentation/data_upload/flutterflow_data_upload.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/insights/ai_insights_screen.dart';
import 'presentation/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Try to load .env file if it exists
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found or error loading it. Using defaults.');
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      message: details.toString(),
    );
  };

  await PrefUtils().init();
  await SharedPreferences.getInstance();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardColor: Color(0xFF1E1E1E),
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: const DashboardScaffold(),
    );
  }
}

class DashboardScaffold extends StatefulWidget {
  const DashboardScaffold({Key? key}) : super(key: key);

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Widget _getScreen() {
    if (!_isLoggedIn) {
      return LoginScreen(onLogin: () {
        setState(() {
          _isLoggedIn = true;
        });
      });
    }

    switch (_selectedIndex) {
      case 0:
        return const FlutterFlowDashboardOverview();
      case 1:
        return const FlutterFlowDataUpload();
      case 2:
        return const AIInsightsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const FlutterFlowDashboardOverview();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isLoggedIn ? NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  'Business Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.upload_file),
            label: Text('Data Upload'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.psychology),
            label: Text('AI Insights'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
      ) : null,
      body: _getScreen(),
    );
  }
}