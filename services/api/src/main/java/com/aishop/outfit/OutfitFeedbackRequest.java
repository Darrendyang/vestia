package com.aishop.outfit;

import jakarta.validation.constraints.NotNull;

public record OutfitFeedbackRequest(@NotNull OutfitRecommendation.Feedback feedback) {
}
