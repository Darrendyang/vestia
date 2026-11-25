package com.aishop.wardrobe;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WardrobeItemRepository extends JpaRepository<WardrobeItem, UUID> {
    List<WardrobeItem> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<WardrobeItem> findByUserIdAndStatusAndCategoryIn(UUID userId, ItemStatus status, List<Category> categories);
    Optional<WardrobeItem> findByIdAndUserId(UUID id, UUID userId);
    void deleteByUserId(UUID userId);
}
