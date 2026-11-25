import 'package:material_ui/material_ui.dart';

import 'api_client.dart';
import 'app_theme.dart';
import 'models.dart';
import 'style_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.api});
  final ApiClient api;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<ProviderInfo>> providersFuture;

  @override
  void initState() {
    super.initState();
    providersFuture = widget.api.listProviders();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
            children: [
              const Text(
                '我的 Vestia',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [VestiaColors.forest, VestiaColors.forestLight],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0x33FFFFFF),
                      backgroundImage: AssetImage(
                        'assets/avatar/avatar-portrait.jpg',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '本地体验用户',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Wear more. Buy better.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE4EBE6),
                    child: Icon(Icons.fingerprint, color: VestiaColors.forest),
                  ),
                  title: const Text('我的 Style DNA'),
                  subtitle: const Text('风格构成、衣橱色彩与健康度'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StylePage(api: widget.api),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '能力与 Provider',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                '真实展示每项能力的运行状态，不隐藏未配置项。',
                style: TextStyle(color: VestiaColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<ProviderInfo>>(
                future: providersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Text('Provider 状态加载失败：${snapshot.error}');
                  return Column(
                    children: (snapshot.data ?? [])
                        .map(
                          (provider) => Card(
                            child: ListTile(
                              leading: Icon(
                                provider.available
                                    ? Icons.check_circle_outline
                                    : Icons.cloud_off_outlined,
                                color: provider.available
                                    ? VestiaColors.forest
                                    : VestiaColors.muted,
                              ),
                              title: Text(provider.name),
                              subtitle: Text(provider.message),
                              trailing: Text(
                                provider.mode,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: VestiaColors.muted,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('API 服务'),
                  subtitle: Text(widget.api.baseUrl),
                ),
              ),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('开发环境边界'),
                  subtitle: Text(
                    '当前为本地演示账号。正式登录、订阅、完整隐私删除和电商结算需在对应 Provider 验收后启用。',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
