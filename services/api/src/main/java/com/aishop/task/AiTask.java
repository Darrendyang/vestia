package com.aishop.task;

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
@Table(name = "ai_tasks", indexes = @Index(name = "idx_task_user", columnList = "userId"))
public class AiTask {
    public enum Type { WARDROBE_RECOGNITION }
    public enum Status { QUEUED, RUNNING, SUCCEEDED, FAILED }

    @Id
    private UUID id;
    @Column(nullable = false)
    private UUID userId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Type type;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status;
    @Column(nullable = false)
    private UUID resourceId;
    private String errorCode;
    @Column(nullable = false)
    private Instant createdAt;
    @Column(nullable = false)
    private Instant updatedAt;

    protected AiTask() {
    }

    public AiTask(UUID userId, Type type, UUID resourceId) {
        this.id = UUID.randomUUID();
        this.userId = userId;
        this.type = type;
        this.resourceId = resourceId;
        this.status = Status.QUEUED;
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

    public void start() { status = Status.RUNNING; }
    public void succeed() { status = Status.SUCCEEDED; }
    public void fail(String code) { status = Status.FAILED; errorCode = code; }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public Type getType() { return type; }
    public Status getStatus() { return status; }
    public UUID getResourceId() { return resourceId; }
    public String getErrorCode() { return errorCode; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
