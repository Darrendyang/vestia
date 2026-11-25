package com.aishop.outfit;

import com.aishop.common.ApiException;
import com.aishop.wardrobe.Category;
import com.aishop.wardrobe.ItemStatus;
import com.aishop.wardrobe.WardrobeItem;
import com.aishop.wardrobe.WardrobeItemRepository;
import com.aishop.wardrobe.WardrobeItemResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class RecommendationService {
    private static final Set<String> NEUTRALS = Set.of("BLACK", "WHITE", "GRAY", "BROWN");
    private final WardrobeItemRepository itemRepository;
    private final OutfitRecommendationRepository recommendationRepository;

    public RecommendationService(WardrobeItemRepository itemRepository,
                                 OutfitRecommendationRepository recommendationRepository) {
        this.itemRepository = itemRepository;
        this.recommendationRepository = recommendationRepository;
    }

    @Transactional
    public RecommendOutfitsResponse recommend(UUID userId, RecommendOutfitsRequest request) {
        Instant repeatThreshold = Instant.now().minus(Duration.ofDays(3));
        List<WardrobeItem> available = itemRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .filter(item -> item.getStatus() == ItemStatus.AVAILABLE)
                .filter(item -> item.getCategory() != Category.UNKNOWN)
                .filter(item -> item.getLastWornAt() == null || item.getLastWornAt().isBefore(repeatThreshold))
                .filter(item -> !isRainUnsafe(item, request.weather()))
                .toList();
        List<Candidate> candidates = buildCandidates(available, request);
        if (candidates.isEmpty()) {
            throw new ApiException(HttpStatus.UNPROCESSABLE_ENTITY, "INSUFFICIENT_WARDROBE",
                    "缺少可搭配的上装与下装/连衣裙，或相关衣物处于在洗、近期实穿状态", false);
        }
        List<Candidate> selected = selectDiverse(candidates);
        List<OutfitResponse> responses = new ArrayList<>();
        for (Candidate candidate : selected) {
            OutfitRecommendation recommendation = new OutfitRecommendation(userId, request.occasion(), request.weather());
            for (SlotItem slotItem : candidate.items()) {
                recommendation.addItem(slotItem.item().getId(), slotItem.slot(), slotItem.position());
            }
            recommendationRepository.save(recommendation);
            responses.add(toResponse(recommendation));
        }
        boolean degraded = responses.size() < 3;
        String message = degraded ? "当前可用衣物不足，已返回所有满足硬约束的搭配" : null;
        return new RecommendOutfitsResponse(responses, degraded, message);
    }

    @Transactional(readOnly = true)
    public List<OutfitResponse> list(UUID userId) {
        return recommendationRepository.findTop20ByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse).toList();
    }

    @Transactional
    public OutfitResponse feedback(UUID userId, UUID recommendationId, OutfitFeedbackRequest request) {
        OutfitRecommendation recommendation = recommendationRepository.findByIdAndUserId(recommendationId, userId)
                .orElseThrow(() -> ApiException.notFound("穿搭推荐"));
        OutfitRecommendation.Feedback previous = recommendation.getFeedback();
        recommendation.feedback(request.feedback());
        if (request.feedback() == OutfitRecommendation.Feedback.ADOPTED && previous != OutfitRecommendation.Feedback.ADOPTED) {
            Instant now = Instant.now();
            recommendation.getItems().forEach(outfitItem -> itemRepository.findByIdAndUserId(outfitItem.getItemId(), userId)
                    .ifPresent(item -> item.markWorn(now)));
        }
        return toResponse(recommendation);
    }

    private List<Candidate> buildCandidates(List<WardrobeItem> items, RecommendOutfitsRequest request) {
        List<WardrobeItem> tops = candidates(items, Category.TOP);
        List<WardrobeItem> bottoms = candidates(items, Category.BOTTOM);
        List<WardrobeItem> dresses = candidates(items, Category.DRESS);
        List<WardrobeItem> outers = withEmpty(candidates(items, Category.OUTERWEAR));
        List<WardrobeItem> shoes = withEmpty(candidates(items, Category.SHOES));
        List<Candidate> result = new ArrayList<>();
        for (WardrobeItem top : tops) {
            for (WardrobeItem bottom : bottoms) {
                addCombinations(result, List.of(new SlotItem("TOP", 0, top), new SlotItem("BOTTOM", 1, bottom)), outers, shoes, request);
            }
        }
        for (WardrobeItem dress : dresses) {
            addCombinations(result, List.of(new SlotItem("DRESS", 0, dress)), outers, shoes, request);
        }
        return result;
    }

    private void addCombinations(List<Candidate> result, List<SlotItem> base, List<WardrobeItem> outers,
                                 List<WardrobeItem> shoes, RecommendOutfitsRequest request) {
        for (WardrobeItem outer : outers) {
            for (WardrobeItem shoe : shoes) {
                List<SlotItem> combination = new ArrayList<>(base);
                if (outer != null) combination.add(new SlotItem("OUTERWEAR", combination.size(), outer));
                if (shoe != null) combination.add(new SlotItem("SHOES", combination.size(), shoe));
                result.add(new Candidate(combination, score(combination, request)));
            }
        }
    }

    private int score(List<SlotItem> items, RecommendOutfitsRequest request) {
        int score = 0;
        long neutralCount = items.stream().filter(item -> NEUTRALS.contains(item.item().getPrimaryColor())).count();
        score += (int) neutralCount * 2;
        for (SlotItem slotItem : items) {
            String tags = slotItem.item().getStyleTags();
            if (tags != null && tags.toUpperCase().contains(request.occasion().toUpperCase())) {
                score += 5;
            }
            score -= slotItem.item().getWearCount();
        }
        if (isCold(request.weather())) {
            score += items.stream().anyMatch(item -> item.item().getCategory() == Category.OUTERWEAR) ? 8 : -8;
        }
        return score;
    }

    private List<Candidate> selectDiverse(List<Candidate> candidates) {
        candidates.sort(Comparator.comparingInt(Candidate::score).reversed());
        Set<String> signatures = new HashSet<>();
        List<Candidate> selected = new ArrayList<>();
        for (Candidate candidate : candidates) {
            String signature = candidate.items().stream()
                    .filter(item -> item.item().getCategory() != Category.SHOES)
                    .map(item -> item.item().getId().toString()).sorted().reduce("", (a, b) -> a + b);
            if (signatures.add(signature)) {
                selected.add(candidate);
            }
            if (selected.size() == 3) break;
        }
        return selected;
    }

    private List<WardrobeItem> candidates(List<WardrobeItem> items, Category category) {
        return items.stream().filter(item -> item.getCategory() == category)
                .sorted(Comparator.comparingInt(WardrobeItem::getWearCount)
                        .thenComparing(WardrobeItem::getCreatedAt, Comparator.reverseOrder()))
                .limit(6).toList();
    }

    private List<WardrobeItem> withEmpty(List<WardrobeItem> items) {
        List<WardrobeItem> result = new ArrayList<>();
        result.add(null);
        result.addAll(items);
        return result;
    }

    private boolean isCold(String weather) {
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("-?\\d+").matcher(weather);
        return weather.contains("寒") || (matcher.find() && Integer.parseInt(matcher.group()) <= 10);
    }

    private boolean isRainUnsafe(WardrobeItem item, String weather) {
        if (!weather.contains("雨") || item.getCategory() != Category.SHOES) return false;
        String material = item.getMaterial() == null ? "" : item.getMaterial();
        String tags = item.getStyleTags() == null ? "" : item.getStyleTags();
        return material.contains("帆布") || tags.toUpperCase().contains("CANVAS");
    }

    private OutfitResponse toResponse(OutfitRecommendation recommendation) {
        List<UUID> ids = recommendation.getItems().stream().map(OutfitItem::getItemId).toList();
        Map<UUID, WardrobeItem> items = new HashMap<>();
        itemRepository.findAllById(ids).forEach(item -> items.put(item.getId(), item));
        List<OutfitResponse.Item> responseItems = recommendation.getItems().stream()
                .filter(item -> items.containsKey(item.getItemId()))
                .map(item -> new OutfitResponse.Item(item.getSlot(), item.getPosition(),
                        WardrobeItemResponse.from(items.get(item.getItemId()))))
                .toList();
        String reason = "基于真实衣橱生成，适配" + recommendation.getOccasion() + "场景与" + recommendation.getWeather()
                + "；已排除在洗、归档和近三天实穿衣物。";
        return new OutfitResponse(recommendation.getId(), recommendation.getOccasion(), recommendation.getWeather(),
                recommendation.getFeedback().name(), reason, responseItems, recommendation.getCreatedAt());
    }

    private record SlotItem(String slot, int position, WardrobeItem item) {
    }

    private record Candidate(List<SlotItem> items, int score) {
    }
}
