package com.aishop.outfit;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RecommendOutfitsRequest(
        @NotBlank @Size(max = 40) String occasion,
        @NotBlank @Size(max = 80) String weather
) {
}
