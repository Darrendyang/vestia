package com.aishop.wardrobe;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateWardrobeItemRequest(
        @NotNull Category category,
        @Size(max = 40) String primaryColor,
        @Size(max = 80) String brand,
        @Size(max = 80) String material,
        @Size(max = 300) String styleTags,
        @NotNull ItemStatus status
) {
}
