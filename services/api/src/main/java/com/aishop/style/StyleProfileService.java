package com.aishop.style;

import com.aishop.wardrobe.Category;
import com.aishop.wardrobe.ItemStatus;
import com.aishop.wardrobe.WardrobeItem;
import com.aishop.wardrobe.WardrobeItemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class StyleProfileService {
    private final WardrobeItemRepository itemRepository;

    public StyleProfileService(WardrobeItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    @Transactional(readOnly = true)
    public StyleProfileResponse current(UUID userId) {
        List<WardrobeItem> items = itemRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<WardrobeItem> available = items.stream().filter(item -> item.getStatus() == ItemStatus.AVAILABLE).toList();
        List<StyleProfileResponse.Distribution> styles = distribution(items, this::styleTags);
        List<StyleProfileResponse.Distribution> colors = distribution(items, item -> List.of(item.getPrimaryColor() == null ? "UNKNOWN" : item.getPrimaryColor()));
        Map<String, Integer> categories = new LinkedHashMap<>();
        for (Category category : Category.values()) {
            if (category != Category.UNKNOWN) {
                categories.put(category.name(), (int) items.stream().filter(item -> item.getCategory() == category).count());
            }
        }
        long coveredCategories = categories.values().stream().filter(count -> count > 0).count();
        int healthScore = items.isEmpty() ? 0 : (int) Math.min(100, Math.round(40 + coveredCategories * 8 + 20.0 * available.size() / items.size()));
        int tops = (int) available.stream().filter(item -> item.getCategory() == Category.TOP).count();
        int bottoms = (int) available.stream().filter(item -> item.getCategory() == Category.BOTTOM).count();
        int dresses = (int) available.stream().filter(item -> item.getCategory() == Category.DRESS).count();
        int possibleOutfits = tops * bottoms + dresses;
        int totalWears = items.stream().mapToInt(WardrobeItem::getWearCount).sum();
        List<String> insights = insights(items, categories, colors, possibleOutfits);
        String tier = items.size() >= 20 ? "COMPLETE" : items.size() >= 5 ? "PREVIEW" : "DISCOVERING";
        return new StyleProfileResponse(tier, "rules-v1", items.size(), available.size(), healthScore,
                possibleOutfits, totalWears, styles, colors, categories, insights, Instant.now());
    }

    private List<String> styleTags(WardrobeItem item) {
        if (item.getStyleTags() == null || item.getStyleTags().isBlank()) {
            return List.of("DISCOVERING");
        }
        return java.util.Arrays.stream(item.getStyleTags().split(","))
                .map(String::trim).filter(tag -> !tag.isEmpty()).toList();
    }

    private List<StyleProfileResponse.Distribution> distribution(List<WardrobeItem> items,
                                                                  Function<WardrobeItem, List<String>> extractor) {
        if (items.isEmpty()) {
            return List.of();
        }
        Map<String, Long> counts = items.stream().flatMap(item -> extractor.apply(item).stream())
                .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
        long total = counts.values().stream().mapToLong(Long::longValue).sum();
        return counts.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue(Comparator.reverseOrder()).thenComparing(Map.Entry::getKey))
                .limit(6)
                .map(entry -> new StyleProfileResponse.Distribution(entry.getKey(), entry.getValue().intValue(),
                        (int) Math.round(entry.getValue() * 100.0 / total)))
                .toList();
    }

    private List<String> insights(List<WardrobeItem> items, Map<String, Integer> categories,
                                  List<StyleProfileResponse.Distribution> colors, int possibleOutfits) {
        List<String> insights = new ArrayList<>();
        if (items.isEmpty()) {
            return List.of("录入 5 件衣物即可解锁风格预览，20 件后生成完整画像。");
        }
        insights.add("当前衣橱可组成 " + possibleOutfits + " 种基础上装/下装或连衣裙组合。");
        categories.forEach((category, count) -> {
            if (count == 0 && !category.equals("ACCESSORY")) {
                insights.add("补充" + category + "品类可以解锁更多搭配路径。");
            }
        });
        if (!colors.isEmpty() && colors.getFirst().percentage() >= 50) {
            insights.add(colors.getFirst().key() + "是衣橱主色，适合通过配饰或不同材质增加层次。");
        }
        long unworn = items.stream().filter(item -> item.getWearCount() == 0).count();
        if (unworn > 0) {
            insights.add(unworn + " 件衣物还没有实穿记录，可优先用今日推荐激活它们。");
        }
        return insights.stream().limit(4).toList();
    }
}
