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
      expect(find.text(item.label), findsNWidgets(2));
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

  testWidgets('builds in dark mode', (tester) async {
    await tester.pumpWidget(
      _app(index: 1, onTap: (_) {}, brightness: Brightness.dark),
    );
    expect(tester.takeException(), isNull);
  });

  test('bar height follows the style', () {
    const style = LiquidGlassTabBarStyle(capsuleHeight: 50, capsuleInset: 5);
    expect(style.barHeight, 60);
  });
}
