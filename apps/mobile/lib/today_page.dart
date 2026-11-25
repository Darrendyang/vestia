import 'package:material_ui/material_ui.dart';

import 'ai_effects.dart';
import 'api_client.dart';
import 'app_theme.dart';
import 'main.dart';
import 'models.dart';
import 'weather_service.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key, required this.api, required this.onOpenWardrobe});
  final ApiClient api;
  final VoidCallback onOpenWardrobe;

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  final weatherController = TextEditingController();
  String occasion = 'COMMUTE';
  RecommendationResult? result;
  WeatherSnapshot? weather;
  bool loading = false;
  bool weatherLoading = false;
  String? error;
  String? weatherError;

  @override
  void initState() {
    super.initState();
    loadRecentOutfits();
    loadWeather();
  }

  Future<void> loadWeather() async {
    setState(() {
      weatherLoading = true;
      weatherError = null;
    });
    try {
      final snapshot = await WeatherService(widget.api).current();
      setState(() {
        weather = snapshot;
        weatherController.text = snapshot.displayValue;
      });
    } on ApiException catch (exception) {
      setState(() => weatherError = exception.message);
    } catch (_) {
      setState(() => weatherError = '无法获取实时天气，请检查网络后重试');
    } finally {
      if (mounted) setState(() => weatherLoading = false);
    }
  }

  Future<void> loadRecentOutfits() async {
    try {
      final history = await widget.api.listOutfitHistory();
      if (history.isNotEmpty && mounted) {
        setState(() {
          result = RecommendationResult(
            outfits: history.take(3).toList(),
            degraded: false,
            message: '已恢复最近的穿搭决策，可重新生成获取新组合',
          );
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    weatherController.dispose();
    super.dispose();
  }

  Future<void> generate() async {
    if (weatherController.text.trim().isEmpty) {
      setState(() => error = '正在获取实时天气，请稍后重试');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final value = await widget.api.recommend(
        occasion,
        weatherController.text.trim(),
      );
      setState(() => result = value);
    } on ApiException catch (exception) {
      setState(() => error = exception.message);
    } catch (_) {
      setState(() => error = '无法连接服务，请确认 API 已启动');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> sendFeedback(Outfit outfit, String feedback) async {
    try {
      final updated = await widget.api.feedback(outfit.id, feedback);
      setState(() {
        final index = result!.outfits.indexWhere(
          (item) => item.id == outfit.id,
        );
        result!.outfits[index] = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(feedback == 'ADOPTED' ? '已记录实穿，下一次推荐会更懂你' : '已记录跳过'),
          ),
        );
      }
    } on ApiException catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: generate,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                const MorningHero(),
                const SizedBox(height: 28),
                Text('先告诉我今天', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  '场景和天气是硬约束，风格偏好只负责排序。',
                  style: TextStyle(color: VestiaColors.muted),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final scene = DropdownButtonFormField<String>(
                      initialValue: occasion,
                      decoration: const InputDecoration(labelText: '今日场景'),
                      items: const [
                        DropdownMenuItem(
                          value: 'COMMUTE',
                          child: Text('通勤 / 会议'),
                        ),
                        DropdownMenuItem(value: 'DATE', child: Text('约会')),
                        DropdownMenuItem(value: 'CASUAL', child: Text('休闲出行')),
                      ],
                      onChanged: (value) => setState(() => occasion = value!),
                    );
                    final weather = TextField(
                      controller: weatherController,
                      readOnly: true,
                      showCursor: false,
                      decoration: const InputDecoration(
                        labelText: '实时天气（自动获取）',
                        prefixIcon: Icon(Icons.cloud_outlined),
                      ),
                    );
                    if (constraints.maxWidth > 560) {
                      return Row(
                        children: [
                          Expanded(child: scene),
                          const SizedBox(width: 12),
                          Expanded(child: weather),
                        ],
                      );
                    }
                    return Column(
                      children: [scene, const SizedBox(height: 12), weather],
                    );
                  },
                ),
                const SizedBox(height: 12),
                AutoWeatherPanel(
                  weather: this.weather,
                  loading: weatherLoading,
                  error: weatherError,
                  onRefresh: loadWeather,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: loading || weatherLoading ? null : generate,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_outlined),
                  label: Text(loading ? '正在组合真实衣橱…' : '给我 3 套穿搭'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 20),
                  DecisionError(
                    message: error!,
                    onOpenWardrobe: widget.onOpenWardrobe,
                  ),
                ],
                if (result?.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    result!.message!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: result == null
                      ? const SizedBox.shrink()
                      : Column(
                          key: ValueKey(
                            result!.outfits.map((item) => item.id).join(','),
                          ),
                          children: [
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '为你的今天精选',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                const Text(
                                  'DECISION IN 30',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    color: VestiaColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...result!.outfits.asMap().entries.map(
                              (entry) => OutfitCard(
                                key: ValueKey(entry.value.id),
                                lookNumber: entry.key + 1,
                                outfit: entry.value,
                                api: widget.api,
                                onFeedback: sendFeedback,
                              ),
                            ),
                          ],
                        ),
                ),
                if (result == null && !loading && error == null)
                  const DecisionPrinciples(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutoWeatherPanel extends StatelessWidget {
  const AutoWeatherPanel({
    super.key,
    required this.weather,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });
  final WeatherSnapshot? weather;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEE9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, size: 18, color: VestiaColors.forest),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loading
                  ? '正在获取定位与实时天气…'
                  : error ??
                        '${weather?.locationLabel ?? '自动定位'} · ${weather?.source ?? 'Open-Meteo'}',
              style: const TextStyle(fontSize: 12, color: VestiaColors.muted),
            ),
          ),
          IconButton(
            onPressed: loading ? null : onRefresh,
            icon: const Icon(Icons.refresh, size: 19),
            tooltip: '刷新实时天气',
          ),
        ],
      ),
    );
  }
}

class MorningHero extends StatelessWidget {
  const MorningHero({super.key});

  @override
  Widget build(BuildContext context) {
    const demoDate = String.fromEnvironment('VESTIA_DEMO_DATE');
    final now = demoDate.isEmpty ? DateTime.now() : DateTime.parse(demoDate);
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111B35), Color(0xFF254C59)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22203D32),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Color(0xFFF4C5A9)),
                const SizedBox(width: 8),
                Text(
                  '${now.month}月${now.day}日 · ${weekdays[now.weekday - 1]}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const AiOrb(size: 54),
              ],
            ),
            const SizedBox(height: 18),
            const AiStatusBadge(label: 'AI STYLIST · ONLINE'),
            const SizedBox(height: 18),
            const Text(
              '今天穿什么，\n30 秒做决定。',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '不制造更多选择，只给你真正可穿的答案。',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 16,
              children: [
                HeroStep(icon: Icons.checkroom_outlined, label: 'AI 衣橱'),
                HeroStep(icon: Icons.cloud_outlined, label: '实时天气'),
                HeroStep(icon: Icons.favorite_border, label: '风格 DNA'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeroStep extends StatelessWidget {
  const HeroStep({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Colors.white70),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class DecisionPrinciples extends StatelessWidget {
  const DecisionPrinciples({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 36),
      child: Row(
        children: [
          Expanded(
            child: Principle(
              icon: Icons.verified_outlined,
              title: '真实',
              text: '只推你拥有的衣物',
            ),
          ),
          Expanded(
            child: Principle(icon: Icons.tune, title: '可控', text: '天气场景硬约束'),
          ),
          Expanded(
            child: Principle(
              icon: Icons.insights_outlined,
              title: '进化',
              text: '实穿反馈持续学习',
            ),
          ),
        ],
      ),
    );
  }
}

class Principle extends StatelessWidget {
  const Principle({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: VestiaColors.forestLight),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: VestiaColors.muted),
        ),
      ],
    );
  }
}

class DecisionError extends StatelessWidget {
  const DecisionError({
    super.key,
    required this.message,
    required this.onOpenWardrobe,
  });
  final String message;
  final VoidCallback onOpenWardrobe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E6DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onOpenWardrobe, child: const Text('去整理衣橱')),
        ],
      ),
    );
  }
}

class OutfitCard extends StatelessWidget {
  const OutfitCard({
    super.key,
    required this.lookNumber,
    required this.outfit,
    required this.api,
    required this.onFeedback,
  });
  final int lookNumber;
  final Outfit outfit;
  final ApiClient api;
  final Future<void> Function(Outfit outfit, String feedback) onFeedback;

  @override
  Widget build(BuildContext context) {
    final adopted = outfit.feedback == 'ADOPTED';
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adopted ? const Color(0xFFE7EFE9) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: adopted ? VestiaColors.forestLight : const Color(0xFFE9E4DC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'LOOK ${lookNumber.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: VestiaColors.coral,
                ),
              ),
              const Spacer(),
              if (adopted)
                const Icon(Icons.check_circle, color: VestiaColors.forest),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: outfit.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = outfit.items[index].wardrobeItem;
                return SizedBox(
                  width: 116,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 58,
                          height: 72,
                          child: item.imageUrl == null
                              ? const ColoredBox(
                                  color: Color(0xFFEDE8E0),
                                  child: Icon(Icons.checkroom_outlined),
                                )
                              : Image.network(
                                  '${api.baseUrl}${item.imageUrl}',
                                  headers: const {
                                    'X-User-Id': ApiClient.demoUserId,
                                  },
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.brand ?? categoryLabel(item.category),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: VestiaColors.coral,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  outfit.reason,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: VestiaColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: adopted
                      ? null
                      : () => onFeedback(outfit, 'ADOPTED'),
                  icon: const Icon(Icons.check_outlined),
                  label: Text(adopted ? '今天已穿这套' : '今天穿这套'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                onPressed: () => onFeedback(outfit, 'SKIPPED'),
                icon: const Icon(Icons.close),
                tooltip: '跳过',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
