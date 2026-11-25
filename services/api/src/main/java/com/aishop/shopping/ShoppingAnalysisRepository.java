package com.aishop.shopping;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ShoppingAnalysisRepository extends JpaRepository<ShoppingAnalysis, UUID> {
    List<ShoppingAnalysis> findTop20ByUserIdOrderByCreatedAtDesc(UUID userId);
}
