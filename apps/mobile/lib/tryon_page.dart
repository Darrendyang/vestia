import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'app_theme.dart';
import 'models.dart';
import 'real_3d_viewer.dart';

class TryOnPage extends StatefulWidget {
  const TryOnPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  final picker = ImagePicker();
  late Future<List<ProviderInfo>> providersFuture;
  XFile? person;
  XFile? garment;
  Uint8List? personPreview;
  Uint8List? garmentPreview;
  bool consent = false;
  bool submitting = false;
  String? message;

  @override
  void initState() {
    super.initState();
    providersFuture = widget.api.listProviders();
  }

  Future<void> pick(bool isPerson) async {
    final selected = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (selected == null) return;
    final bytes = await selected.readAsBytes();
    setState(() {
      if (isPerson) {
        person = selected;
        personPreview = bytes;
      } else {
        garment = selected;
        garmentPreview = bytes;
      }
    });
  }

  Future<void> submit() async {
    setState(() {
      submitting = true;
      message = null;
    });
    try {
      await widget.api.requestTryOn();
    } on ApiException catch (exception) {
      setState(() => message = exception.message);
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<ProviderInfo>>(
        future: providersFuture,
        builder: (context, snapshot) {
          final providers = snapshot.data ?? [];
          final available = providers.any(
            (provider) => provider.key == 'TRYON' && provider.available,
          );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: const SizedBox(height: 610, child: Real3DViewer()),
                  ),
                  const SizedBox(height: 24),
                  ProviderNotice(
                    available: available,
                    loading:
                        snapshot.connectionState == ConnectionState.waiting,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI 照片试穿（需 Provider）',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 560;
                      final personCard = PhotoPicker(
                        title: '1. 你的全身照',
                        bytes: personPreview,
                        onTap: () => pick(true),
                      );
                      final garmentCard = PhotoPicker(
                        title: '2. 想试的衣服',
                        bytes: garmentPreview,
                        onTap: () => pick(false),
                      );
                      if (wide)
                        return Row(
                          children: [
                            Expanded(child: personCard),
                            const SizedBox(width: 12),
                            Expanded(child: garmentCard),
                          ],
                        );
                      return Column(
                        children: [
                          personCard,
                          const SizedBox(height: 12),
                          garmentCard,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CheckboxListTile(
                      value: consent,
                      onChanged: (value) =>
                          setState(() => consent = value ?? false),
                      title: const Text('我同意为本次试穿处理这两张照片'),
                      subtitle: const Text('独立授权，不用于通用模型训练；未创建任务前不会上传。'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed:
                        available &&
                            consent &&
                            person != null &&
                            garment != null &&
                            !submitting
                        ? submit
                        : null,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: Text(
                      submitting
                          ? '正在检查 Provider…'
                          : available
                          ? '生成试穿'
                          : 'Provider 未配置',
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: VestiaColors.muted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '2D 换装、多视角生成和真实 3D 布料仿真是不同能力。Vestia 只展示当前 Provider 实际支持的模式，不把单张效果图包装成可 360° 旋转的 3D 试穿。',
                          style: TextStyle(
                            fontSize: 12,
                            color: VestiaColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProviderNotice extends StatelessWidget {
  const ProviderNotice({
    super.key,
    required this.available,
    required this.loading,
  });
  final bool available;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available ? const Color(0xFFE4EEE7) : const Color(0xFFF4E9DF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle_outline : Icons.science_outlined,
            color: available ? VestiaColors.forest : VestiaColors.coral,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loading
                  ? '正在检查 Provider…'
                  : available
                  ? 'Provider 已配置，提交前仍会校验授权和适配契约。'
                  : '上方 3D 示范分身可直接旋转换装；下方 AI 照片试穿未配置，不会上传或伪造结果。',
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.title,
    required this.bytes,
    required this.onTap,
  });
  final String title;
  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4DFD8)),
        ),
        child: bytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 42,
                    color: VestiaColors.forestLight,
                  ),
                  const SizedBox(height: 12),
                  Text(title),
                  const SizedBox(height: 6),
                  const Text(
                    '从相册选择',
                    style: TextStyle(fontSize: 12, color: VestiaColors.muted),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(bytes!, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Chip(label: Text(title)),
                  ),
                ],
              ),
      ),
    );
  }
}
