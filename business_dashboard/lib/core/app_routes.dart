import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard_overview/dashboard_overview_screen.dart';
import '../presentation/filter_configuration/filter_configuration.dart';
import '../presentation/detailed_metric_view/detailed_metric_view.dart';
import '../presentation/data_upload/data_upload_screen.dart';
import '../widgets/custom_error_widget.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String dataUpload = '/data-upload';
  static const String dashboardOverview = '/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardOverviewScreen());
      case dataUpload:
        return MaterialPageRoute(builder: (_) => DataUploadScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => CustomErrorWidget(
            message: 'Page not found',
          ),
        );
    }
  }
} 