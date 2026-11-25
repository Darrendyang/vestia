package com.aishop.shopping;

import com.aishop.wardrobe.Category;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "shopping_analyses", indexes = @Index(name = "idx_shopping_user", columnList = "userId"))
public class ShoppingAnalysis {
    @Id
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category candidateCategory;
    @Column(nullable = false)
    private String candidateColor;
    private String candidateBrand;
    private String candidateStyleTags;
    private BigDecimal targetPrice;
    @Column(nullable = false)
    private int unlockedOutfits;
    @Column(nullable = false)
    private String decision;
    @Column(nullable = false, length = 2000)
    private String compatibleItemIds;
    @Column(nullable = false)
    private Instant createdAt;

    protected ShoppingAnalysis() {
    }

    public ShoppingAnalysis(UUID userId, ShoppingAnalysisRequest request, int unlockedOutfits,
                            String decision, String compatibleItemIds) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.candidateCategory = request.category();
        this.candidateColor = request.primaryColor();
        this.candidateBrand = request.brand();
        this.candidateStyleTags = request.styleTags();
        this.targetPrice = request.targetPrice();
        this.unlockedOutfits = unlockedOutfits;
        this.decision = decision;
        this.compatibleItemIds = compatibleItemIds;
    }

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
    }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public Category getCandidateCategory() { return candidateCategory; }
    public String getCandidateColor() { return candidateColor; }
    public String getCandidateBrand() { return candidateBrand; }
    public String getCandidateStyleTags() { return candidateStyleTags; }
    public BigDecimal getTargetPrice() { return targetPrice; }
    public int getUnlockedOutfits() { return unlockedOutfits; }
    public String getDecision() { return decision; }
    public String getCompatibleItemIds() { return compatibleItemIds; }
    public Instant getCreatedAt() { return createdAt; }
}
