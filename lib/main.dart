import 'package:battery_charge_notifier/screen/home.dart';
import 'package:battery_charge_notifier/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/theme_notifier.dart';


void main() => runApp(
  ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(darkTheme),
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeNotifier.getTheme(),
      home: Home(),
    );
  }
}