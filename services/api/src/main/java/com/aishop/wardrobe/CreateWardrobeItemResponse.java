package com.aishop.wardrobe;

import java.util.UUID;

public record CreateWardrobeItemResponse(WardrobeItemResponse item, UUID taskId) {
}
