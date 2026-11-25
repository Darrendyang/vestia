package com.aishop.outfit;

import com.aishop.wardrobe.WardrobeItemResponse;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record OutfitResponse(UUID recommendationId, String occasion, String weather, String feedback,
                             String reason, List<Item> items, Instant createdAt) {
    public record Item(String slot, int position, WardrobeItemResponse wardrobeItem) {
    }
}
