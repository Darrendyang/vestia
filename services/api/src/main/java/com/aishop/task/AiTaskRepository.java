package com.aishop.task;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface AiTaskRepository extends JpaRepository<AiTask, UUID> {
    Optional<AiTask> findByIdAndUserId(UUID id, UUID userId);
    void deleteByUserId(UUID userId);
}
