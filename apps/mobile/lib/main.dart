import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'ai_effects.dart';
import 'api_client.dart';
import 'app_theme.dart';
import 'buyer_page.dart';
import 'profile_page.dart';
import 'today_page.dart';
import 'tryon_page.dart';
import 'wardrobe_page.dart';

void main() {
  runApp(const AishopApp());
}

class AishopApp extends StatelessWidget {
  const AishopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    return MaterialApp(
      title: 'Vestia — AI 私人买手',
      debugShowCheckedModeBanner: false,
      theme: VestiaTheme.light,
      home: HomeShell(api: api),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api});
  final ApiClient api;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  int wardrobeVersion = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayPage(
        api: widget.api,
        onOpenWardrobe: () => setState(() => index = 1),
      ),
      WardrobePage(
        key: ValueKey(wardrobeVersion),
        api: widget.api,
        onWardrobeChanged: () => wardrobeVersion++,
      ),
      TryOnPage(api: widget.api),
      BuyerPage(api: widget.api),
      ProfilePage(api: widget.api),
    ];
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AuroraBackground(),
          IndexedStack(index: index, children: pages),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                label: 'AI 穿搭',
              ),
              NavigationDestination(
                icon: Icon(Icons.checkroom_outlined),
                label: 'AI 衣橱',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_in_ar_outlined),
                label: '3D 试穿',
              ),
              NavigationDestination(
                icon: Icon(Icons.diamond_outlined),
                label: 'AI 买手',
              ),
              NavigationDestination(icon: Icon(Icons.tune), label: '我的'),
            ],
          ),
        ),
      ),
    );
  }
}

String categoryLabel(String category) => switch (category) {
  'TOP' => '上装',
  'BOTTOM' => '下装',
  'DRESS' => '连衣裙',
  'OUTERWEAR' => '外套',
  'SHOES' => '鞋履',
  'ACCESSORY' => '配饰',
  _ => '待分类',
};
