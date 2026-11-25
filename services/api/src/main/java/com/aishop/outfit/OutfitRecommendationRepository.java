package com.aishop.outfit;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OutfitRecommendationRepository extends JpaRepository<OutfitRecommendation, UUID> {
    List<OutfitRecommendation> findTop20ByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<OutfitRecommendation> findByIdAndUserId(UUID id, UUID userId);
    void deleteByUserId(UUID userId);
}
