package com.aishop.shopping;

import com.aishop.wardrobe.WardrobeItemResponse;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ShoppingAnalysisResponse(
        UUID analysisId,
        String category,
        String primaryColor,
        String brand,
        String styleTags,
        int unlockedOutfits,
        String decision,
        String explanation,
        String algorithmVersion,
        List<WardrobeItemResponse> compatibleItems,
        Instant createdAt
) {
}
