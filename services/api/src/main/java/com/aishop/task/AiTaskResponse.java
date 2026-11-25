package com.aishop.task;

import java.time.Instant;
import java.util.UUID;

public record AiTaskResponse(UUID taskId, String type, String status, UUID resourceId,
                             String errorCode, Instant createdAt, Instant updatedAt) {
    public static AiTaskResponse from(AiTask task) {
        return new AiTaskResponse(task.getId(), task.getType().name(), task.getStatus().name(),
                task.getResourceId(), task.getErrorCode(), task.getCreatedAt(), task.getUpdatedAt());
    }
}
