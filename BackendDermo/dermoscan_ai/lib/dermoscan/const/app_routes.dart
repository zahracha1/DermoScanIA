// lib/dermoscan/const/app_routes.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/use_page.dart';
import '../pages/check_page.dart';
import '../pages/result_page.dart';
import '../pages/history_page.dart';
import '../pages/contact_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AppRoutes {
  static const String home     = '/home';
  static const String use      = '/use';
  static const String check    = '/check';
  static const String result   = '/result';
  static const String history  = '/history';
  static const String contact  = '/contact';
  static const String login    = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> get routes => {
    home:     (_) => const HomePage(), //_ signifie (BuildContext context)
    use:      (_) => const UsePage(),
    check:    (_) => const CheckPage(),
    result:   (_) => const ResultPage(),
    history:  (_) => const HistoryPage(),
    contact:  (_) => const ContactPage(),
    login:    (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
  };
}