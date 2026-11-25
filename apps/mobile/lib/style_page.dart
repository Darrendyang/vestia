import 'package:material_ui/material_ui.dart';

import 'api_client.dart';
import 'models.dart';

class StylePage extends StatefulWidget {
  const StylePage({super.key, required this.api});
  final ApiClient api;

  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  late Future<StyleProfile> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = widget.api.getStyleProfile();
  }

  Future<void> refresh() async {
    setState(() => profileFuture = widget.api.getStyleProfile());
    await profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style DNA')),
      body: FutureBuilder<StyleProfile>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton(
                onPressed: refresh,
                child: Text(
                  '加载失败，点击重试\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final profile = snapshot.data!;
          return RefreshIndicator(
            onRefresh: refresh,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    DnaHero(profile: profile),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Metric(
                            value: '${profile.possibleOutfits}',
                            label: '搭配可能',
                          ),
                        ),
                        Expanded(
                          child: Metric(
                            value: '${profile.totalWears}',
                            label: '实穿次数',
                          ),
                        ),
                        Expanded(
                          child: Metric(
                            value: '${profile.itemCount}',
                            label: '数字单品',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('风格构成', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (profile.styles.isEmpty)
                      const Text('录入衣物后开始形成你的风格偏好')
                    else
                      ...profile.styles
                          .take(4)
                          .map(
                            (style) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(styleLabel(style.key)),
                                      ),
                                      Text('${style.percentage}%'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: style.percentage / 100,
                                    minHeight: 7,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Text('衣橱色彩', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: profile.colors
                          .map(
                            (color) => Column(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colorValue(color.key),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${color.percentage}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'AI 买手洞察',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...profile.insights.map(
                      (insight) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.auto_awesome_outlined),
                          title: Text(insight),
                        ),
                      ),
                    ),
                    const Text(
                      '当前由 rules-v1 根据真实衣橱计算，不推断人格，也不把样本偏好包装成科学测评。',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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

  String styleLabel(String key) => switch (key) {
    'MINIMAL' => '简约',
    'COMMUTE' => '通勤',
    'CASUAL' => '休闲',
    'DATE' => '约会',
    'DISCOVERING' => '探索中',
    _ => key,
  };

  Color colorValue(String key) => switch (key) {
    'WHITE' => Colors.white,
    'BLACK' => Colors.black87,
    'GRAY' => Colors.grey,
    'BLUE' => Colors.blue,
    'GREEN' => Colors.green,
    'RED' => Colors.red,
    'YELLOW' => Colors.amber,
    'BROWN' => Colors.brown,
    'PINK' => Colors.pink,
    'PURPLE' => Colors.purple,
    'ORANGE' => Colors.orange,
    _ => Colors.blueGrey,
  };
}

class DnaHero extends StatelessWidget {
  const DnaHero({super.key, required this.profile});
  final StyleProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF20312B), Color(0xFF49665A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.tier == 'COMPLETE' ? 'COMPLETE DNA' : 'DNA PREVIEW',
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '你的衣橱，正在长成你的风格。',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${profile.availableCount} 件可穿 · 规则可解释',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: profile.healthScore / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFFF2B8A0),
                ),
                Text(
                  '${profile.healthScore}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Metric extends StatelessWidget {
  const Metric({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
