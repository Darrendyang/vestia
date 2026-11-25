class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.category,
    required this.primaryColor,
    required this.brand,
    required this.material,
    required this.styleTags,
    required this.status,
    required this.recognitionStatus,
    required this.source,
    required this.imageUrl,
    required this.wearCount,
  });

  final String id;
  final String category;
  final String? primaryColor;
  final String? brand;
  final String? material;
  final String? styleTags;
  final String status;
  final String recognitionStatus;
  final String source;
  final String? imageUrl;
  final int wearCount;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) => WardrobeItem(
    id: json['id'] as String,
    category: json['category'] as String,
    primaryColor: json['primaryColor'] as String?,
    brand: json['brand'] as String?,
    material: json['material'] as String?,
    styleTags: json['styleTags'] as String?,
    status: json['status'] as String,
    recognitionStatus: json['recognitionStatus'] as String,
    source: json['source'] as String? ?? 'MANUAL',
    imageUrl: json['imageUrl'] as String?,
    wearCount: json['wearCount'] as int? ?? 0,
  );

  Map<String, dynamic> updateJson({String? newCategory, String? newStatus}) => {
    'category': newCategory ?? category,
    'primaryColor': primaryColor,
    'brand': brand,
    'material': material,
    'styleTags': styleTags,
    'status': newStatus ?? status,
  };
}

class OutfitItem {
  const OutfitItem({required this.slot, required this.wardrobeItem});
  final String slot;
  final WardrobeItem wardrobeItem;

  factory OutfitItem.fromJson(Map<String, dynamic> json) => OutfitItem(
    slot: json['slot'] as String,
    wardrobeItem: WardrobeItem.fromJson(
      json['wardrobeItem'] as Map<String, dynamic>,
    ),
  );
}

class Outfit {
  const Outfit({
    required this.id,
    required this.reason,
    required this.feedback,
    required this.items,
  });

  final String id;
  final String reason;
  final String feedback;
  final List<OutfitItem> items;

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
    id: json['recommendationId'] as String,
    reason: json['reason'] as String,
    feedback: json['feedback'] as String,
    items: (json['items'] as List<dynamic>)
        .map((item) => OutfitItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class RecommendationResult {
  const RecommendationResult({
    required this.outfits,
    required this.degraded,
    required this.message,
  });
  final List<Outfit> outfits;
  final bool degraded;
  final String? message;

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      RecommendationResult(
        outfits: (json['outfits'] as List<dynamic>)
            .map((outfit) => Outfit.fromJson(outfit as Map<String, dynamic>))
            .toList(),
        degraded: json['degraded'] as bool,
        message: json['message'] as String?,
      );
}

class StyleDistribution {
  const StyleDistribution({
    required this.key,
    required this.count,
    required this.percentage,
  });
  final String key;
  final int count;
  final int percentage;

  factory StyleDistribution.fromJson(Map<String, dynamic> json) =>
      StyleDistribution(
        key: json['key'] as String,
        count: json['count'] as int,
        percentage: json['percentage'] as int,
      );
}

class StyleProfile {
  const StyleProfile({
    required this.tier,
    required this.itemCount,
    required this.availableCount,
    required this.healthScore,
    required this.possibleOutfits,
    required this.totalWears,
    required this.styles,
    required this.colors,
    required this.categories,
    required this.insights,
  });

  final String tier;
  final int itemCount;
  final int availableCount;
  final int healthScore;
  final int possibleOutfits;
  final int totalWears;
  final List<StyleDistribution> styles;
  final List<StyleDistribution> colors;
  final Map<String, int> categories;
  final List<String> insights;

  factory StyleProfile.fromJson(Map<String, dynamic> json) => StyleProfile(
    tier: json['tier'] as String,
    itemCount: json['itemCount'] as int,
    availableCount: json['availableCount'] as int,
    healthScore: json['healthScore'] as int,
    possibleOutfits: json['possibleOutfits'] as int,
    totalWears: json['totalWears'] as int,
    styles: (json['styles'] as List<dynamic>)
        .map((item) => StyleDistribution.fromJson(item as Map<String, dynamic>))
        .toList(),
    colors: (json['colors'] as List<dynamic>)
        .map((item) => StyleDistribution.fromJson(item as Map<String, dynamic>))
        .toList(),
    categories: (json['categories'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value as int),
    ),
    insights: (json['insights'] as List<dynamic>).cast<String>(),
  );
}

class ProviderInfo {
  const ProviderInfo({
    required this.key,
    required this.name,
    required this.available,
    required this.mode,
    required this.message,
  });
  final String key;
  final String name;
  final bool available;
  final String mode;
  final String message;

  factory ProviderInfo.fromJson(Map<String, dynamic> json) => ProviderInfo(
    key: json['key'] as String,
    name: json['name'] as String,
    available: json['available'] as bool,
    mode: json['mode'] as String,
    message: json['message'] as String,
  );
}

class ShoppingAnalysis {
  const ShoppingAnalysis({
    required this.id,
    required this.unlockedOutfits,
    required this.decision,
    required this.explanation,
    required this.compatibleItems,
  });

  final String id;
  final int unlockedOutfits;
  final String decision;
  final String explanation;
  final List<WardrobeItem> compatibleItems;

  factory ShoppingAnalysis.fromJson(Map<String, dynamic> json) =>
      ShoppingAnalysis(
        id: json['analysisId'] as String,
        unlockedOutfits: json['unlockedOutfits'] as int,
        decision: json['decision'] as String,
        explanation: json['explanation'] as String,
        compatibleItems: (json['compatibleItems'] as List<dynamic>)
            .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.description,
    required this.source,
    required this.observedAt,
    required this.isFallbackLocation,
  });

  final double temperature;
  final String description;
  final String source;
  final String observedAt;
  final bool isFallbackLocation;

  String get displayValue => '${temperature.round()}°C $description';
  String get locationLabel => isFallbackLocation ? '上海（默认位置）' : '当前位置';

  factory WeatherSnapshot.fromJson(
    Map<String, dynamic> json, {
    bool isFallbackLocation = false,
  }) => WeatherSnapshot(
    temperature: (json['temperature'] as num).toDouble(),
    description: json['description'] as String,
    source: json['source'] as String,
    observedAt: json['observedAt'] as String,
    isFallbackLocation: isFallbackLocation,
  );
}
