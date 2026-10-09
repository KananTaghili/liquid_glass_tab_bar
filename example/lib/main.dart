import 'package:flutter/material.dart';
import 'package:liquid_glass_tab_bar/liquid_glass_tab_bar.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E7C66);
    return MaterialApp(
      title: 'Liquid Glass Tab Bar',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomePage(
        dark: _mode == ThemeMode.dark,
        onToggleTheme: () => setState(
          () => _mode = _mode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.dark, required this.onToggleTheme});

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = ['Home', 'Favorites', 'Search', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lets the page scroll behind the glass.
      extendBody: true,
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _ColorfulList(seed: _index),
      bottomNavigationBar: LiquidGlassTabBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        // "Search" opens a sheet instead of becoming the selected tab.
        onTapIntercept: (i) {
          if (i != 2) return false;
          showModalBottomSheet<void>(
            context: context,
            builder: (_) => const SizedBox(
              height: 200,
              child: Center(child: Text('Search sheet')),
            ),
          );
          return true;
        },
        items: const [
          LiquidGlassTabItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          LiquidGlassTabItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          LiquidGlassTabItem(icon: Icon(Icons.search), label: 'Search'),
          LiquidGlassTabItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Colorful cards so the glass has something to refract.
class _ColorfulList extends StatelessWidget {
  const _ColorfulList({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final colors = Colors.primaries;
    return ListView.builder(
      // Keeps the last card above the bar.
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        LiquidGlassTabBar.heightOf(context) + 16,
      ),
      itemCount: 24,
      itemBuilder: (context, i) {
        final color = colors[(i + seed * 3) % colors.length];
        return Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.shade300, color.shade700],
            ),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Card ${i + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
