import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:visitdesk/app.dart';
import 'package:visitdesk/providers/theme_provider.dart';
import 'package:visitdesk/providers/visitor_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full walkthrough', (t) async {
    await t.pumpWidget(
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
    Future<void> settle() => t.pumpAndSettle(const Duration(milliseconds: 300));
    Future<void> scrollDown() async {
      FocusManager.instance.primaryFocus?.unfocus();
      await settle();
      final sv = find.byType(SingleChildScrollView);
      if (sv.evaluate().isNotEmpty) {
        await t.drag(sv.first, const Offset(0, -400), warnIfMissed: false);
      }
      await settle();
    }

    Future<void> waitSnack() async {
      await t.pump(const Duration(seconds: 5));
      await settle();
    }

    Future<void> tapText(String s) async {
      await scrollDown();
      await t.tap(find.text(s).first);
      await settle();
    }

    await t.pump(const Duration(milliseconds: 2500));
    await settle();

    // Dashboard
    expect(find.text('Total Visitors Today'), findsOneWidget);
    expect(find.text('Currently Checked In'), findsOneWidget);
    await t.tap(find.byTooltip('Toggle dark mode'));
    await settle();
    await t.tap(find.byTooltip('Toggle dark mode'));
    await settle();

    // Visitors list
    await tapText('Visitors');
    expect(find.text('Rahul Sharma'), findsOneWidget);
    await t.enterText(find.byType(SearchBar), 'priya');
    await settle();
    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsNothing);
    await t.enterText(find.byType(SearchBar), 'zzz');
    await settle();
    expect(find.text('No matching visitors'), findsOneWidget);
    await t.enterText(find.byType(SearchBar), '');
    await settle();
    await tapText('Checked In');
    expect(find.text('Rahul Sharma'), findsNothing);
    await tapText('Checked In');
    await t.drag(
      find.widgetWithText(FilterChip, 'Checked Out'),
      const Offset(-500, 0),
    );
    await settle();
    await t.tap(find.widgetWithText(FilterChip, 'Project C'));
    await settle();
    expect(find.text('Arjun Reddy'), findsOneWidget);
    await t.tap(find.widgetWithText(FilterChip, 'Project C'));
    await settle();

    // Details + check in / out
    await tapText('Rahul Sharma');
    expect(find.text('Visitor Details'), findsOneWidget);
    await tapText('Check In');
    expect(find.text('Check Out'), findsWidgets);
    await tapText('Check Out');
    expect(find.text('Visit completed'), findsOneWidget);
    await waitSnack();

    // Edit: clear email
    await t.tap(find.byTooltip('Edit'));
    await settle();
    final fields = find.byType(TextFormField);
    await t.enterText(fields.at(0), 'Rahul S');
    await t.enterText(fields.at(2), '');
    await settle();
    await tapText('Save Changes');
    expect(find.text('Rahul S'), findsWidgets);
    expect(find.text('—'), findsWidgets);
    await waitSnack();

    // Delete from details
    await t.tap(find.byTooltip('Delete'));
    await settle();
    await tapText('Delete');
    expect(find.text('Rahul S'), findsNothing);

    // Register: validation then success
    await waitSnack();
    await tapText('Register');
    Future<void> submit() async {
      final b = find.widgetWithText(ElevatedButton, 'Register Visitor');
      await scrollDown();
      await t.tap(b);
      await settle();
    }

    await submit();
    expect(find.text('Name is required'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(0), 'Test User');
    await t.enterText(find.byType(TextFormField).at(1), '9000000001');
    await t.tap(find.text('Visitor Type'));
    await settle();
    await tapText('Vendor');
    await t.tap(find.text('Project').first);
    await settle();
    await tapText('Project B');
    await t.enterText(find.byType(TextFormField).at(3), 'Delivery');
    await submit();
    expect(find.text('Test User'), findsWidgets);
    expect(find.text('Registered'), findsWidgets);
    await waitSnack();

    // Scan tab (simulator has no camera)
    await t.pageBack();
    await settle();
    await tapText('Scan');
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Scan QR'), findsWidgets);
  });
}
