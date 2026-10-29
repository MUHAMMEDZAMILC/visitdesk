import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitdesk/core/theme/app_colors.dart';
import 'package:visitdesk/core/theme/app_theme.dart';
import 'package:visitdesk/widgets/app_filter_chip.dart';

Color? labelColor(WidgetTester t, String label) =>
    t.renderObject<RenderParagraph>(find.text(label)).text.style?.color;

Future<void> pumpChips(WidgetTester t, ThemeData theme) => t.pumpWidget(
  MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Row(
        children: [
          AppFilterChip(label: 'Off', selected: false, onSelected: (_) {}),
          AppFilterChip(label: 'On', selected: true, onSelected: (_) {}),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('light: unselected navy, selected white', (t) async {
    await pumpChips(t, AppTheme.light);
    expect(labelColor(t, 'Off'), AppColors.secondary);
    expect(labelColor(t, 'On'), AppColors.white);
  });

  testWidgets('dark: both labels white', (t) async {
    await pumpChips(t, AppTheme.dark);
    expect(labelColor(t, 'Off'), AppColors.white);
    expect(labelColor(t, 'On'), AppColors.white);
  });
}
