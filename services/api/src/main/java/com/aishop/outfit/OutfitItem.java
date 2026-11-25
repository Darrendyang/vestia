package com.aishop.outfit;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.util.UUID;

@Entity
@Table(name = "outfit_items")
public class OutfitItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "recommendation_id", nullable = false)
    private OutfitRecommendation recommendation;
    @Column(nullable = false)
    private UUID itemId;
    @Column(nullable = false)
    private String slot;
    @Column(name = "item_position", nullable = false)
    private int position;

    protected OutfitItem() {
    }

    OutfitItem(OutfitRecommendation recommendation, UUID itemId, String slot, int position) {
        this.recommendation = recommendation;
        this.itemId = itemId;
        this.slot = slot;
        this.position = position;
    }

    public UUID getItemId() { return itemId; }
    public String getSlot() { return slot; }
    public int getPosition() { return position; }
}
