import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import 'ai_effects.dart';
import 'api_client.dart';
import 'app_theme.dart';
import 'main.dart';
import 'models.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({
    super.key,
    required this.api,
    required this.onWardrobeChanged,
  });
  final ApiClient api;
  final VoidCallback onWardrobeChanged;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late Future<List<WardrobeItem>> itemsFuture;
  bool seeding = false;
  String query = '';
  String selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    itemsFuture = loadWardrobeWithImages();
  }

  Future<List<WardrobeItem>> loadWardrobeWithImages() async {
    var items = await widget.api.listWardrobe();
    final needsImages = items.any(
      (item) => item.source == 'DEMO' && item.imageUrl == null,
    );
    if (needsImages) {
      await widget.api.backfillDemoImages(items);
      items = await widget.api.listWardrobe();
    }
    return items;
  }

  Future<void> refresh() async {
    setState(() => itemsFuture = loadWardrobeWithImages());
    await itemsFuture;
  }

  Future<void> addItem() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AddItemSheet(api: widget.api),
    );
    if (added == true) {
      await refresh();
      widget.onWardrobeChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('已加入衣橱，主色识别在后台完成'),
          ),
        );
      }
    }
  }

  Future<void> seed() async {
    setState(() => seeding = true);
    try {
      await widget.api.seedDemoWardrobe();
      await refresh();
    } finally {
      if (mounted) setState(() => seeding = false);
    }
  }

  Future<void> update(
    WardrobeItem item, {
    String? category,
    String? status,
  }) async {
    try {
      await widget.api.updateItem(item, category: category, status: status);
      await refresh();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('更新失败，请重试')));
    }
  }

  Future<void> delete(WardrobeItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这件衣物？'),
        content: const Text('衣物及其图片将被删除，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.api.deleteItem(item.id);
      await refresh();
    }
  }

  List<WardrobeItem> filter(List<WardrobeItem> items) {
    return items.where((item) {
      final matchesCategory =
          selectedCategory == 'ALL' || item.category == selectedCategory;
      final text =
          '${item.brand ?? ''} ${item.primaryColor ?? ''} ${item.styleTags ?? ''}'
              .toLowerCase();
      return matchesCategory && text.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的衣橱'),
        actions: [
          IconButton(
            onPressed: addItem,
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: '录入衣物',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addItem,
        backgroundColor: VestiaColors.forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('录入衣物'),
      ),
      body: FutureBuilder<List<WardrobeItem>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '衣橱加载失败：${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: refresh, child: const Text('重试')),
                  ],
                ),
              ),
            );
          }
          final allItems = snapshot.data ?? [];
          if (allItems.isEmpty)
            return EmptyWardrobe(
              onAdd: addItem,
              onSeed: seed,
              seeding: seeding,
            );
          final items = filter(allItems);
          return RefreshIndicator(
            onRefresh: refresh,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: WardrobeSummary(items: allItems)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: TextField(
                          onChanged: (value) => setState(() => query = value),
                          decoration: const InputDecoration(
                            hintText: '搜索名称、颜色或风格',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children:
                              [
                                'ALL',
                                'TOP',
                                'BOTTOM',
                                'DRESS',
                                'OUTERWEAR',
                                'SHOES',
                                'ACCESSORY',
                              ].map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      category == 'ALL'
                                          ? '全部'
                                          : categoryLabel(category),
                                    ),
                                    selected: selectedCategory == category,
                                    onSelected: (_) => setState(
                                      () => selectedCategory = category,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    if (items.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text('没有符合筛选条件的衣物')),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.crossAxisExtent > 850
                                ? 4
                                : constraints.crossAxisExtent > 560
                                ? 3
                                : 2;
                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.76,
                                  ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => WardrobeCard(
                                  item: items[index],
                                  api: widget.api,
                                  onUpdate: update,
                                  onDelete: delete,
                                ),
                                childCount: items.length,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WardrobeSummary extends StatelessWidget {
  const WardrobeSummary({super.key, required this.items});
  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    final available = items
        .where((item) => item.status == 'AVAILABLE')
        .toList();
    final tops = available.where((item) => item.category == 'TOP').length;
    final bottoms = available.where((item) => item.category == 'BOTTOM').length;
    final dresses = available.where((item) => item.category == 'DRESS').length;
    final combinations = tops * bottoms + dresses;
    final wears = items.fold<int>(0, (sum, item) => sum + item.wearCount);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [VestiaColors.forest, VestiaColors.forestLight],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiStatusBadge(label: 'AI WARDROBE · CONNECTED'),
          const SizedBox(height: 14),
          const Text(
            '让每一件衣服，都有更多可能。',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              SummaryMetric(value: '${items.length}', label: '数字单品'),
              SummaryMetric(value: '$combinations', label: '基础组合'),
              SummaryMetric(value: '$wears', label: '实穿记录'),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryMetric extends StatelessWidget {
  const SummaryMetric({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class EmptyWardrobe extends StatelessWidget {
  const EmptyWardrobe({
    super.key,
    required this.onAdd,
    required this.onSeed,
    required this.seeding,
  });
  final VoidCallback onAdd;
  final VoidCallback onSeed;
  final bool seeding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFE4EBE6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checkroom_outlined,
                size: 48,
                color: VestiaColors.forest,
              ),
            ),
            const SizedBox(height: 24),
            Text('从第一件衣服开始', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              '拍照入库，让衣橱开始为你工作。',
              style: TextStyle(color: VestiaColors.muted),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('拍照 / 上传'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: seeding ? null : onSeed,
              child: Text(seeding ? '正在准备演示衣橱' : '先体验演示衣橱'),
            ),
          ],
        ),
      ),
    );
  }
}

class WardrobeCard extends StatelessWidget {
  const WardrobeCard({
    super.key,
    required this.item,
    required this.api,
    required this.onUpdate,
    required this.onDelete,
  });
  final WardrobeItem item;
  final ApiClient api;
  final Future<void> Function(
    WardrobeItem item, {
    String? category,
    String? status,
  })
  onUpdate;
  final Future<void> Function(WardrobeItem item) onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = item.status != 'AVAILABLE';
    return Opacity(
      opacity: muted ? 0.62 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E3DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: item.imageUrl == null
                          ? const ColoredBox(
                              color: Color(0xFFEDE8E0),
                              child: Icon(
                                Icons.checkroom_outlined,
                                size: 42,
                                color: VestiaColors.muted,
                              ),
                            )
                          : Image.network(
                              '${api.baseUrl}${item.imageUrl}',
                              headers: const {
                                'X-User-Id': ApiClient.demoUserId,
                              },
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 2,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'DELETE') onDelete(item);
                        if (value.startsWith('STATUS:'))
                          onUpdate(item, status: value.substring(7));
                        if (value.startsWith('CATEGORY:'))
                          onUpdate(item, category: value.substring(9));
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'STATUS:AVAILABLE',
                          child: Text('标记为可穿'),
                        ),
                        PopupMenuItem(
                          value: 'STATUS:LAUNDRY',
                          child: Text('标记为在洗'),
                        ),
                        PopupMenuItem(
                          value: 'STATUS:ARCHIVED',
                          child: Text('归档'),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'CATEGORY:TOP',
                          child: Text('改为上装'),
                        ),
                        PopupMenuItem(
                          value: 'CATEGORY:BOTTOM',
                          child: Text('改为下装'),
                        ),
                        PopupMenuItem(
                          value: 'CATEGORY:DRESS',
                          child: Text('改为连衣裙'),
                        ),
                        PopupMenuItem(
                          value: 'CATEGORY:OUTERWEAR',
                          child: Text('改为外套'),
                        ),
                        PopupMenuItem(
                          value: 'CATEGORY:SHOES',
                          child: Text('改为鞋履'),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'DELETE', child: Text('删除')),
                      ],
                    ),
                  ),
                  if (item.recognitionStatus == 'PENDING')
                    const Positioned(
                      left: 10,
                      top: 10,
                      child: Chip(
                        label: Text('识别中', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand ?? categoryLabel(item.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${categoryLabel(item.category)} · ${item.primaryColor ?? '待识别'}',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      color: VestiaColors.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${statusLabel(item.status)} · 实穿 ${item.wearCount} 次',
                    style: const TextStyle(
                      fontSize: 11,
                      color: VestiaColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String statusLabel(String status) => switch (status) {
    'LAUNDRY' => '在洗',
    'ARCHIVED' => '已归档',
    _ => '可穿',
  };
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key, required this.api});
  final ApiClient api;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final picker = ImagePicker();
  final brandController = TextEditingController();
  final colorController = TextEditingController();
  final materialController = TextEditingController();
  final tagsController = TextEditingController();
  XFile? image;
  Uint8List? preview;
  String category = 'TOP';
  bool saving = false;
  String? error;

  @override
  void dispose() {
    brandController.dispose();
    colorController.dispose();
    materialController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> pick(ImageSource source) async {
    final selected = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (selected != null) {
      setState(() => image = selected);
      preview = await selected.readAsBytes();
      if (mounted) setState(() {});
    }
  }

  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.api.createItem(
        image: image,
        category: category,
        primaryColor: colorController.text.trim(),
        brand: brandController.text.trim(),
        material: materialController.text.trim(),
        styleTags: tagsController.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (exception) {
      setState(() => error = exception.message);
    } catch (_) {
      setState(() => error = '上传失败，请检查图片和服务连接');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('录入一件新单品', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text(
                '不确定的信息可以留空，之后再修正。',
                style: TextStyle(color: VestiaColors.muted),
              ),
              const SizedBox(height: 18),
              if (preview != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      preview!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('相册'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('拍照'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: '品类'),
                items:
                    [
                          'TOP',
                          'BOTTOM',
                          'DRESS',
                          'OUTERWEAR',
                          'SHOES',
                          'ACCESSORY',
                          'UNKNOWN',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(categoryLabel(value)),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: '名称 / 品牌（可选）'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: '颜色（可选，留空则提取主色）'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: materialController,
                decoration: const InputDecoration(
                  labelText: '材质（可选，如 帆布 / 皮革）',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: '风格标签，如 COMMUTE,MINIMAL',
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(saving ? '正在上传' : '入库并识别'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
