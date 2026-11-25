import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class DemoClothing {
  const DemoClothing(
    this.category,
    this.color,
    this.brand,
    this.tags,
    this.material,
    this.asset,
    this.aliases,
  );
  final String category;
  final String color;
  final String brand;
  final String tags;
  final String? material;
  final String asset;
  final List<String> aliases;
}

const demoClothes = [
  DemoClothing(
    'TOP',
    'BLUE',
    '蓝灰印花衬衫',
    'COMMUTE,MINIMAL',
    null,
    'assets/clothes/blue-pattern-shirt.jpg',
    ['通勤衬衫', '蓝灰印花衬衫'],
  ),
  DemoClothing(
    'TOP',
    'WHITE',
    '白色印花T恤',
    'CASUAL,MINIMAL',
    null,
    'assets/clothes/white-graphic-tee.jpg',
    ['蓝色针织衫', '白色印花T恤'],
  ),
  DemoClothing(
    'BOTTOM',
    'PINK',
    '裸粉休闲长裤',
    'COMMUTE,MINIMAL',
    null,
    'assets/clothes/pink-trousers.jpg',
    ['黑色西裤', '裸粉休闲长裤'],
  ),
  DemoClothing(
    'BOTTOM',
    'BLUE',
    '经典直筒牛仔裤',
    'CASUAL',
    null,
    'assets/clothes/blue-jeans.jpg',
    ['直筒牛仔裤', '经典直筒牛仔裤'],
  ),
  DemoClothing(
    'OUTERWEAR',
    'BROWN',
    '卡其风衣',
    'COMMUTE,MINIMAL',
    null,
    'assets/clothes/beige-trench.jpg',
    ['卡其风衣'],
  ),
  DemoClothing(
    'SHOES',
    'BROWN',
    '棕色复古球鞋',
    'COMMUTE,MINIMAL',
    '皮革',
    'assets/clothes/brown-sneakers.jpg',
    ['白色皮鞋', '棕色复古球鞋'],
  ),
  DemoClothing(
    'DRESS',
    'RED',
    '红色礼服裙',
    'DATE,MINIMAL',
    null,
    'assets/clothes/red-dress.jpg',
    ['黑色连衣裙', '红色礼服裙'],
  ),
  DemoClothing(
    'SHOES',
    'RED',
    '酒红帆布鞋',
    'CASUAL',
    '帆布',
    'assets/clothes/red-canvas-shoes.jpg',
    ['蓝色帆布鞋', '酒红帆布鞋'],
  ),
];

class ApiClient {
  ApiClient({String? baseUrl})
    : baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'AISHOP_API_URL',
                    defaultValue: 'http://127.0.0.1:8080',
                  ))
              .replaceFirst(RegExp(r'/$'), '');

  final String baseUrl;
  final http.Client _client = http.Client();
  static const demoUserId = '00000000-0000-0000-0000-000000000001';

  Map<String, String> get _headers => const {'X-User-Id': demoUserId};

  Future<List<WardrobeItem>> listWardrobe() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/wardrobe/items'),
      headers: _headers,
    );
    return _decodeList(response)
        .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createItem({
    XFile? image,
    Uint8List? imageBytes,
    String filename = 'clothing.jpg',
    required String category,
    String? primaryColor,
    String? brand,
    String? material,
    String? styleTags,
    String source = 'MANUAL',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/wardrobe/items'),
    );
    request.headers.addAll(_headers);
    request.fields['category'] = category;
    request.fields['source'] = image == null && imageBytes == null
        ? source
        : source == 'DEMO'
        ? 'DEMO'
        : 'PHOTO';
    if (primaryColor?.isNotEmpty ?? false)
      request.fields['primaryColor'] = primaryColor!;
    if (brand?.isNotEmpty ?? false) request.fields['brand'] = brand!;
    if (material?.isNotEmpty ?? false) request.fields['material'] = material!;
    if (styleTags?.isNotEmpty ?? false)
      request.fields['styleTags'] = styleTags!;
    final bytes = image == null ? imageBytes : await image.readAsBytes();
    if (bytes != null) {
      final name = image?.name ?? filename;
      final extension = name.toLowerCase().split('.').last;
      final subtype = switch (extension) {
        'png' => 'png',
        'webp' => 'webp',
        _ => 'jpeg',
      };
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: name,
          contentType: MediaType('image', subtype),
        ),
      );
    }
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    _decode(response);
  }

  Future<void> updateItem(
    WardrobeItem item, {
    String? category,
    String? status,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/v1/wardrobe/items/${item.id}'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(
        item.updateJson(newCategory: category, newStatus: status),
      ),
    );
    _decode(response);
  }

  Future<void> deleteItem(String id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/v1/wardrobe/items/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) _decode(response);
  }

  Future<WeatherSnapshot> getWeather(
    double latitude,
    double longitude, {
    required bool isFallbackLocation,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/api/v1/weather/current?latitude=$latitude&longitude=$longitude',
      ),
      headers: _headers,
    );
    return WeatherSnapshot.fromJson(
      _decode(response) as Map<String, dynamic>,
      isFallbackLocation: isFallbackLocation,
    );
  }

  Future<RecommendationResult> recommend(
    String occasion,
    String weather,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/outfits/recommendations'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'occasion': occasion, 'weather': weather}),
    );
    return RecommendationResult.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  Future<List<Outfit>> listOutfitHistory() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/outfits/recommendations'),
      headers: _headers,
    );
    return _decodeList(response)
        .map((item) => Outfit.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Outfit> feedback(String recommendationId, String feedback) async {
    final response = await _client.post(
      Uri.parse(
        '$baseUrl/api/v1/outfits/recommendations/$recommendationId/feedback',
      ),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'feedback': feedback}),
    );
    return Outfit.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<StyleProfile> getStyleProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/style-profile/current'),
      headers: _headers,
    );
    return StyleProfile.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<ProviderInfo>> listProviders() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/providers'),
      headers: _headers,
    );
    return _decodeList(response)
        .map((item) => ProviderInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ShoppingAnalysis> analyzeShopping({
    required String category,
    required String primaryColor,
    String? brand,
    String? styleTags,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/shopping/analyses'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'primaryColor': primaryColor,
        'brand': brand,
        'styleTags': styleTags,
      }),
    );
    return ShoppingAnalysis.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> requestTryOn() async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/tryon-jobs?consentConfirmed=true'),
      headers: _headers,
    );
    _decode(response);
  }

  Future<void> seedDemoWardrobe() async {
    for (final item in demoClothes) {
      final bytes = await rootBundle.load(item.asset);
      await createItem(
        imageBytes: bytes.buffer.asUint8List(),
        filename: item.asset.split('/').last,
        category: item.category,
        primaryColor: item.color,
        brand: item.brand,
        material: item.material,
        styleTags: item.tags,
        source: 'DEMO',
      );
    }
  }

  Future<void> backfillDemoImages(List<WardrobeItem> items) async {
    for (final item in items) {
      if (item.source != 'DEMO' || item.imageUrl != null) continue;
      DemoClothing? demo;
      for (final candidate in demoClothes) {
        if (candidate.aliases.contains(item.brand)) {
          demo = candidate;
          break;
        }
      }
      if (demo == null) continue;
      final metadataResponse = await _client.put(
        Uri.parse('$baseUrl/api/v1/wardrobe/items/${item.id}'),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'category': demo.category,
          'primaryColor': demo.color,
          'brand': demo.brand,
          'material': demo.material,
          'styleTags': demo.tags,
          'status': item.status,
        }),
      );
      _decode(metadataResponse);
      final bytes = await rootBundle.load(demo.asset);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/wardrobe/items/${item.id}/image'),
      );
      request.headers.addAll(_headers);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes.buffer.asUint8List(),
          filename: demo.asset.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final response = await http.Response.fromStream(
        await _client.send(request),
      );
      _decode(response);
    }
  }

  dynamic _decode(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty)
      body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    if (body is Map<String, dynamic>)
      throw ApiException(
        body['message'] as String? ?? '请求失败',
        response.statusCode,
      );
    throw ApiException('请求失败（${response.statusCode}）', response.statusCode);
  }

  List<dynamic> _decodeList(http.Response response) =>
      _decode(response) as List<dynamic>;
}
