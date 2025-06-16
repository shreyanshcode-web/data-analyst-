import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.color,
    this.size = 24.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconData? icon = _getIconData(iconName);

    if (icon == null) {
      debugPrint('Icon not found: $iconName');
      return SizedBox(width: size, height: size);
    }

    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color ?? Theme.of(context).iconTheme.color,
        size: size,
      ),
    );
  }

  IconData? _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard_outlined;
      case 'analytics':
        return Icons.analytics_outlined;
      case 'settings':
        return Icons.settings_outlined;
      case 'profile':
        return Icons.person_outline;
      case 'notifications':
        return Icons.notifications_outlined;
      case 'search':
        return Icons.search;
      case 'menu':
        return Icons.menu;
      case 'close':
        return Icons.close;
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'edit':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'refresh':
        return Icons.refresh;
      case 'error_outline':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'info':
        return Icons.info_outline;
      case 'upload':
        return Icons.upload_file_outlined;
      case 'download':
        return Icons.download_outlined;
      case 'chart':
        return Icons.insert_chart_outlined;
      case 'filter':
        return Icons.filter_list;
      case 'sort':
        return Icons.sort;
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'time':
        return Icons.access_time;
      case 'location':
        return Icons.location_on_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'link':
        return Icons.link;
      case 'share':
        return Icons.share_outlined;
      case 'favorite':
        return Icons.favorite_border;
      case 'bookmark':
        return Icons.bookmark_border;
      default:
        return null;
    }
  }
}
