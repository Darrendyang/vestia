package com.aishop.wardrobe;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "wardrobe_items", indexes = @Index(name = "idx_wardrobe_user", columnList = "userId"))
public class WardrobeItem {
    @Id
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;
    private String primaryColor;
    private String brand;
    private String material;
    private String styleTags;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ItemStatus status;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RecognitionStatus recognitionStatus;
    @Column(nullable = false)
    private String source;
    private String imagePath;
    private Double colorConfidence;
    private int wearCount;
    private Instant lastWornAt;
    @Column(nullable = false)
    private Instant createdAt;
    @Column(nullable = false)
    private Instant updatedAt;

    protected WardrobeItem() {
    }

    public WardrobeItem(UUID userId, Category category, String primaryColor, String brand, String material,
                        String styleTags, String source, String imagePath) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.category = category == null ? Category.UNKNOWN : category;
        this.primaryColor = primaryColor;
        this.brand = brand;
        this.material = material;
        this.styleTags = styleTags;
        this.source = source;
        this.imagePath = imagePath;
        this.status = ItemStatus.AVAILABLE;
        this.recognitionStatus = RecognitionStatus.PENDING;
    }

    @PrePersist
    void onCreate() {
        createdAt = Instant.now();
        updatedAt = createdAt;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }

    public void completeRecognition(String detectedColor, Double confidence) {
        if ((primaryColor == null || primaryColor.isBlank()) && detectedColor != null) {
            primaryColor = detectedColor;
            colorConfidence = confidence;
        }
        recognitionStatus = RecognitionStatus.COMPLETED;
    }

    public void failRecognition() {
        recognitionStatus = RecognitionStatus.FAILED;
    }

    public void update(Category category, String primaryColor, String brand, String material,
                       String styleTags, ItemStatus status) {
        this.category = category == null ? Category.UNKNOWN : category;
        this.primaryColor = primaryColor;
        this.brand = brand;
        this.material = material;
        this.styleTags = styleTags;
        this.status = status;
    }

    public void replaceImage(String imagePath) {
        this.imagePath = imagePath;
        recognitionStatus = RecognitionStatus.PENDING;
    }

    public void markWorn(Instant wornAt) {
        wearCount++;
        lastWornAt = wornAt;
    }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public Category getCategory() { return category; }
    public String getPrimaryColor() { return primaryColor; }
    public String getBrand() { return brand; }
    public String getMaterial() { return material; }
    public String getStyleTags() { return styleTags; }
    public ItemStatus getStatus() { return status; }
    public RecognitionStatus getRecognitionStatus() { return recognitionStatus; }
    public String getSource() { return source; }
    public String getImagePath() { return imagePath; }
    public Double getColorConfidence() { return colorConfidence; }
    public int getWearCount() { return wearCount; }
    public Instant getLastWornAt() { return lastWornAt; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
