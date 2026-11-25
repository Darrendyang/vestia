import 'package:material_ui/material_ui.dart';

import 'api_client.dart';
import 'app_theme.dart';
import 'main.dart';
import 'models.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final brandController = TextEditingController();
  final tagsController = TextEditingController(text: 'COMMUTE,MINIMAL');
  String category = 'OUTERWEAR';
  String color = 'BLACK';
  ShoppingAnalysis? analysis;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    brandController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> analyze() async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final value = await widget.api.analyzeShopping(
        category: category,
        primaryColor: color,
        brand: brandController.text.trim(),
        styleTags: tagsController.text.trim(),
      );
      setState(() => analysis = value);
    } on ApiException catch (exception) {
      setState(() => error = exception.message);
    } catch (_) {
      setState(() => error = '分析失败，请检查服务连接');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A2F28), Color(0xFF9B5E4B)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUY LESS. BUY BETTER.',
                      style: TextStyle(
                        color: Color(0xFFF4C5A9),
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 22),
                    Text(
                      '心动之前，先看看\n它能搭多少件衣服。',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      '不先推商品，先验证它对你的真实价值。',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('分析一件心动单品', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: '名称 / 品牌（可选）',
                  prefixIcon: Icon(Icons.favorite_border),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: color,
                      decoration: const InputDecoration(labelText: '主色'),
                      items: const [
                        DropdownMenuItem(value: 'BLACK', child: Text('黑色')),
                        DropdownMenuItem(value: 'WHITE', child: Text('白色')),
                        DropdownMenuItem(value: 'GRAY', child: Text('灰色')),
                        DropdownMenuItem(value: 'BLUE', child: Text('蓝色')),
                        DropdownMenuItem(value: 'BROWN', child: Text('棕色')),
                        DropdownMenuItem(value: 'GREEN', child: Text('绿色')),
                        DropdownMenuItem(value: 'RED', child: Text('红色')),
                      ],
                      onChanged: (value) => setState(() => color = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: '风格 / 场景标签'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: loading ? null : analyze,
                icon: const Icon(Icons.diamond_outlined),
                label: Text(loading ? '正在计算搭配价值…' : '看看它值不值得买'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (analysis != null) ...[
                const SizedBox(height: 24),
                AnalysisResult(analysis: analysis!, api: widget.api),
              ],
              const SizedBox(height: 24),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.store_mall_directory_outlined),
                  title: Text('实时比价尚未接入'),
                  subtitle: Text('没有官方平台数据时，不展示虚构价格、库存、历史低价或“全网最低”。'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnalysisResult extends StatelessWidget {
  const AnalysisResult({super.key, required this.analysis, required this.api});
  final ShoppingAnalysis analysis;
  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    final positive = analysis.decision != 'LOW_PRIORITY';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFE4EEE7) : const Color(0xFFF3E8E2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                positive ? Icons.auto_awesome : Icons.pause_circle_outline,
                color: positive ? VestiaColors.forest : VestiaColors.coral,
              ),
              const SizedBox(width: 8),
              Text(
                positive ? '值得进一步考虑' : '先别急着下单',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${analysis.unlockedOutfits}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('种新增基础搭配'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(analysis.explanation, style: const TextStyle(height: 1.5)),
          if (analysis.compatibleItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '可以激活你已有的这些单品',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.compatibleItems
                  .map(
                    (item) => Chip(
                      label: Text(item.brand ?? categoryLabel(item.category)),
                      avatar: const Icon(Icons.checkroom_outlined, size: 17),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            '算法 wardrobe-gap-rules-v1 · 结论仅基于当前衣橱，不代表价格或尺码建议',
            style: TextStyle(fontSize: 11, color: VestiaColors.muted),
          ),
        ],
      ),
    );
  }
}
