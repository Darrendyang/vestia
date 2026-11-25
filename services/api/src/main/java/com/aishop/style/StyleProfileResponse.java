package com.aishop.style;

import java.time.Instant;
import java.util.List;
import java.util.Map;

public record StyleProfileResponse(
        String tier,
        String profileVersion,
        int itemCount,
        int availableCount,
        int healthScore,
        int possibleOutfits,
        int totalWears,
        List<Distribution> styles,
        List<Distribution> colors,
        Map<String, Integer> categories,
        List<String> insights,
        Instant generatedAt
) {
    public record Distribution(String key, int count, int percentage) {
    }
}
