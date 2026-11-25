package com.aishop.wardrobe;

import java.time.Instant;
import java.util.UUID;

public record WardrobeItemResponse(
        UUID id, String category, String primaryColor, String brand, String material,
        String styleTags, String status, String recognitionStatus, String source,
        String imageUrl, Double colorConfidence, int wearCount, Instant lastWornAt,
        Instant createdAt, Instant updatedAt
) {
    public static WardrobeItemResponse from(WardrobeItem item) {
        String imageUrl = item.getImagePath() == null ? null : "/api/v1/wardrobe/items/" + item.getId() + "/image";
        return new WardrobeItemResponse(item.getId(), item.getCategory().name(), item.getPrimaryColor(),
                item.getBrand(), item.getMaterial(), item.getStyleTags(), item.getStatus().name(),
                item.getRecognitionStatus().name(), item.getSource(), imageUrl, item.getColorConfidence(),
                item.getWearCount(), item.getLastWornAt(), item.getCreatedAt(), item.getUpdatedAt());
    }
}
