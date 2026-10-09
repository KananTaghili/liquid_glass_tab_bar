import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_tab_bar/liquid_glass_tab_bar.dart';

const _items = [
  LiquidGlassTabItem(icon: Icon(Icons.home_outlined), label: 'Home'),
  LiquidGlassTabItem(icon: Icon(Icons.search), label: 'Search'),
  LiquidGlassTabItem(icon: Icon(Icons.person_outline), label: 'Profile'),
];

Widget _app({
  required int index,
  required ValueChanged<int> onTap,
  bool Function(int)? intercept,
  Brightness brightness = Brightness.light,
}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        extendBody: true,
        body: const SizedBox.expand(),
        bottomNavigationBar: LiquidGlassTabBar(
          items: _items,
          currentIndex: index,
          onTap: onTap,
          onTapIntercept: intercept,
        ),
      ),
    );

void main() {
  testWidgets('shows every label', (tester) async {
    await tester.pumpWidget(_app(index: 0, onTap: (_) {}));
    for (final item in _items) {
      // Each label is drawn twice (unselected + selected layer).
      expect(find.text(item.label!), findsNWidgets(2));
    }
  });

  testWidgets('tapping an item reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(_app(index: 0, onTap: (i) => tapped = i));
    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(tapped, 2);
  });

  testWidgets('intercepted tap does not select', (tester) async {
    int? tapped;
    int? intercepted;
    await tester.pumpWidget(
      _app(
        index: 0,
        onTap: (i) => tapped = i,
        intercept: (i) {
          if (i != 1) return false;
          intercepted = i;
          return true;
        },
      ),
    );
    await tester.tap(find.text('Search').first);
    await tester.pumpAndSettle();
    expect(intercepted, 1);
    expect(tapped, isNull);
  });

  testWidgets('dragging along the bar selects the item under the finger', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(_app(index: 0, onTap: (i) => tapped = i));
    final from = tester.getCenter(find.text('Home').first);
    final to = tester.getCenter(find.text('Profile').first);
    await tester.dragFrom(from, to - from);
    await tester.pumpAndSettle();
    expect(tapped, 2);
  });

  testWidgets('pressing another item selects only on release', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(_app(index: 0, onTap: (i) => tapped = i));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Profile').first),
    );
    await tester.pump(const Duration(milliseconds: 500));
    // The droplet moves while the finger is down, the page does not change.
    expect(tapped, isNull);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tapped, 2);
  });

  testWidgets('pressing and sliding away does not select', (tester) async {
    int? tapped;
    await tester.pumpWidget(_app(index: 0, onTap: (i) => tapped = i));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Profile').first),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // Sliding up and away cancels the tap; no sideways movement → no select.
    await gesture.moveBy(const Offset(0, -200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tapped, isNull);
  });

  testWidgets('builds in dark mode', (tester) async {
    await tester.pumpWidget(
      _app(index: 1, onTap: (_) {}, brightness: Brightness.dark),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('icon-only items work', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidGlassTabBar(
            currentIndex: 0,
            onTap: (i) => tapped = i,
            items: const [
              LiquidGlassTabItem(icon: Icon(Icons.home), semanticLabel: 'Home'),
              LiquidGlassTabItem(icon: Icon(Icons.star), semanticLabel: 'Star'),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(Text), findsNothing);
    await tester.tap(find.byIcon(Icons.star).first);
    await tester.pumpAndSettle();
    expect(tapped, 1);
  });

  test('bar height follows the style', () {
    const style = LiquidGlassTabBarStyle(capsuleHeight: 50, capsuleInset: 5);
    expect(style.barHeight, 60);
  });
}
