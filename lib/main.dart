import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/visitor_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VisitorProvider()..fetchVisitors(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
      ],
      child: const VisitDeskApp(),
    ),
  );
}
