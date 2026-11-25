package com.aishop.shopping;

import com.aishop.wardrobe.Category;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record ShoppingAnalysisRequest(
        @NotNull Category category,
        @NotNull @Size(max = 40) String primaryColor,
        @Size(max = 80) String brand,
        @Size(max = 300) String styleTags,
        @Positive BigDecimal targetPrice
) {
}
