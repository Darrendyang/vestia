package com.aishop.shopping;

import com.aishop.wardrobe.Category;
import com.aishop.wardrobe.ItemStatus;
import com.aishop.wardrobe.WardrobeItem;
import com.aishop.wardrobe.WardrobeItemRepository;
import com.aishop.wardrobe.WardrobeItemResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ShoppingAnalysisService {
    private static final Set<String> NEUTRALS = Set.of("BLACK", "WHITE", "GRAY", "BROWN");
    private final WardrobeItemRepository itemRepository;
    private final ShoppingAnalysisRepository analysisRepository;

    public ShoppingAnalysisService(WardrobeItemRepository itemRepository,
                                   ShoppingAnalysisRepository analysisRepository) {
        this.itemRepository = itemRepository;
        this.analysisRepository = analysisRepository;
    }

    @Transactional
    public ShoppingAnalysisResponse analyze(UUID userId, ShoppingAnalysisRequest request) {
        List<WardrobeItem> available = itemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .filter(item -> item.getStatus() == ItemStatus.AVAILABLE)
                .filter(item -> item.getCategory() != Category.UNKNOWN)
                .toList();
        int unlocked = unlockedOutfits(available, request.category());
        List<WardrobeItem> compatible = compatibleItems(available, request);
        String decision = unlocked >= 3 ? "STRONG_MATCH" : unlocked >= 1 ? "POTENTIAL_MATCH" : "LOW_PRIORITY";
        String ids = compatible.stream().map(item -> item.getId().toString()).collect(Collectors.joining(","));
        ShoppingAnalysis analysis = analysisRepository.save(new ShoppingAnalysis(userId, request, unlocked, decision, ids));
        return toResponse(analysis, compatible);
    }

    @Transactional(readOnly = true)
    public List<ShoppingAnalysisResponse> history(UUID userId) {
        List<WardrobeItem> wardrobe = itemRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return analysisRepository.findTop20ByUserIdOrderByCreatedAtDesc(userId).stream().map(analysis -> {
            Set<String> ids = Arrays.stream(analysis.getCompatibleItemIds().split(",")).collect(Collectors.toSet());
            List<WardrobeItem> compatible = wardrobe.stream().filter(item -> ids.contains(item.getId().toString())).toList();
            return toResponse(analysis, compatible);
        }).toList();
    }

    private int unlockedOutfits(List<WardrobeItem> items, Category category) {
        long tops = count(items, Category.TOP);
        long bottoms = count(items, Category.BOTTOM);
        long dresses = count(items, Category.DRESS);
        return (int) switch (category) {
            case TOP -> bottoms;
            case BOTTOM -> tops;
            case DRESS -> 1;
            case OUTERWEAR -> tops + dresses;
            case SHOES -> tops * bottoms + dresses;
            case ACCESSORY, UNKNOWN -> 0;
        };
    }

    private List<WardrobeItem> compatibleItems(List<WardrobeItem> items, ShoppingAnalysisRequest request) {
        List<WardrobeItem> candidates = items.stream().filter(item -> switch (request.category()) {
            case TOP -> item.getCategory() == Category.BOTTOM;
            case BOTTOM -> item.getCategory() == Category.TOP;
            case DRESS -> item.getCategory() == Category.OUTERWEAR || item.getCategory() == Category.SHOES;
            case OUTERWEAR -> item.getCategory() == Category.TOP || item.getCategory() == Category.DRESS;
            case SHOES -> item.getCategory() == Category.TOP || item.getCategory() == Category.BOTTOM || item.getCategory() == Category.DRESS;
            case ACCESSORY -> true;
            case UNKNOWN -> false;
        }).toList();
        Set<String> candidateTags = tags(request.styleTags());
        return candidates.stream()
                .sorted(Comparator.comparingInt((WardrobeItem item) -> compatibility(item, candidateTags, request.primaryColor())).reversed()
                        .thenComparing(WardrobeItem::getCreatedAt, Comparator.reverseOrder()))
                .limit(6).toList();
    }

    private int compatibility(WardrobeItem item, Set<String> candidateTags, String color) {
        int score = NEUTRALS.contains(color) || NEUTRALS.contains(item.getPrimaryColor()) ? 2 : 0;
        Set<String> itemTags = tags(item.getStyleTags());
        score += (int) candidateTags.stream().filter(itemTags::contains).count() * 4;
        return score;
    }

    private Set<String> tags(String value) {
        if (value == null || value.isBlank()) return Set.of();
        return Arrays.stream(value.split(",")).map(String::trim).filter(tag -> !tag.isEmpty()).collect(Collectors.toSet());
    }

    private long count(List<WardrobeItem> items, Category category) {
        return items.stream().filter(item -> item.getCategory() == category).count();
    }

    private ShoppingAnalysisResponse toResponse(ShoppingAnalysis analysis, List<WardrobeItem> compatible) {
        String decisionText = switch (analysis.getDecision()) {
            case "STRONG_MATCH" -> "值得优先考虑";
            case "POTENTIAL_MATCH" -> "有搭配潜力";
            default -> "购买优先级较低";
        };
        String explanation = analysis.getUnlockedOutfits() > 0
                ? decisionText + "：预计可新增 " + analysis.getUnlockedOutfits() + " 种基础搭配，并展示与你现有衣物的实际组合证据。"
                : decisionText + "：从当前衣橱看新增基础搭配有限，建议先检查是否已有相似款，避免因一时心动重复购买。";
        List<WardrobeItemResponse> items = new ArrayList<>(compatible.stream().map(WardrobeItemResponse::from).toList());
        return new ShoppingAnalysisResponse(analysis.getId(), analysis.getCandidateCategory().name(), analysis.getCandidateColor(),
                analysis.getCandidateBrand(), analysis.getCandidateStyleTags(), analysis.getUnlockedOutfits(), analysis.getDecision(),
                explanation, "wardrobe-gap-rules-v1", items, analysis.getCreatedAt());
    }
}
