package com.aishop.outfit;

import java.util.List;

public record RecommendOutfitsResponse(List<OutfitResponse> outfits, boolean degraded, String message) {
}
