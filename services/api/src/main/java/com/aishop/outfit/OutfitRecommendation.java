package com.aishop.outfit;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "outfit_recommendations", indexes = @Index(name = "idx_outfit_user", columnList = "userId"))
public class OutfitRecommendation {
    public enum Feedback { NONE, ADOPTED, SKIPPED }

    @Id
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Column(nullable = false)
    private String occasion;
    @Column(nullable = false)
    private String weather;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Feedback feedback;
    @Column(nullable = false)
    private Instant createdAt;
    @OneToMany(mappedBy = "recommendation", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("position ASC")
    private List<OutfitItem> items = new ArrayList<>();

    protected OutfitRecommendation() {
    }

    public OutfitRecommendation(UUID userId, String occasion, String weather) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.occasion = occasion;
        this.weather = weather;
        this.feedback = Feedback.NONE;
    }

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
    }

    public void addItem(UUID itemId, String slot, int position) {
        items.add(new OutfitItem(this, itemId, slot, position));
    }

    public void feedback(Feedback value) {
        feedback = value;
    }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public String getOccasion() { return occasion; }
    public String getWeather() { return weather; }
    public Feedback getFeedback() { return feedback; }
    public Instant getCreatedAt() { return createdAt; }
    public List<OutfitItem> getItems() { return items; }
}
